#!/usr/bin/pwsh

Function Test-PomMissing {
    if (-not $env:POMODORO_REPOS) {
        Write-Host "Please set the $env:POMODORO_REPOS to the location of this repo."
        return $true
    }   
}

Function Start-PomReverse {
    param(
        # Which client would you use
        [Parameter(Mandatory=$false, HelpMessage="To what does the root web directory point?")]
        [ValidateSet("default", "localmachine")] 
        [string]$Client,

        [Parameter(ParameterSetName="MountebankProxy")]
        [switch]$Proxy,

        [Parameter(ParameterSetName="MountebankReplay")]
        [ValidateSet("webapp")] 
        [string]$Replay,

        [Parameter(ParameterSetName="NoMountebank")]
        [switch]$NoProxy
    )

    if (Test-PomMissing) { RETURN }

    $confdir = if ($Proxy -or $Replay) { "Mocks/proxyconf" } else { "LocalProxy/conf" }
    $proxyconfdir = if ($Client) { $Client.ToLower() } else { "default" }
    $confmount = "$env:POMODORO_REPOS/PersonalTracker.Api/{0}/{1}/:/conf/" -f $confdir, $proxyconfdir

    #
    # Get the IP of the localmachine
    #
    $regex=[regex] '\d+\.\d+\.\d+\.\d+'
    $interface=ip -family inet -o addr show docker0
    $hostip=$regex.Match($interface).Value.Trim()
    $addhost="{0}:{1}" -f  "localmachine", $hostip
    Write-Host "Starting pomodoro-reverse-proxy with --add-host $addhost..."
    #
    # Run the docker image
    #
    docker run `
    --name pomodoro-reverse-proxy `
    --network pomodoro-net `
    --add-host $addhost `
    -d `
    --rm `
    -p 80:80 `
    -v $env:POMODORO_REPOS/PersonalTracker.Api/LocalProxy/app/:/app/ `
    -v $confmount `
    myrevprox 
}

Function Start-PomMountebank {
    param(
        # Which client would you use
        [Parameter(Mandatory=$false, HelpMessage="To what does the root web directory point?")]
        [ValidateSet("default", "localmachine")] 
        [string]$Client,

        [Parameter(ParameterSetName="MountebankProxy")]
        [switch]$Proxy,

        [Parameter(ParameterSetName="MountebankReplay")]
        [ValidateSet("webapp")] 
        [string]$Replay
    )

    if (Test-PomMissing) { RETURN }

    $confdir = if ($Proxy -or $Replay) { "Mocks/proxyconf" } else { "LocalProxy/conf" }
    $proxyconfdir = if ($Client) { $Client.ToLower() } else { "default" }
    $confmount = "$env:POMODORO_REPOS/PersonalTracker.Api/{0}/{1}/:/conf/" -f $confdir, $proxyconfdir

    if ($Proxy) {
        
        Write-Host "Starting pomodoro-mountebank..."
        ##################################
        # Mountebank with proxy forwards
        ############################
        docker run `
            --name pomodoro-mountebank `
            --network pomodoro-net `
            -d `
            --rm `
            -p 2525:2525 `
            -p 3001:3001 `
            -p 3002:3002 `
            -p 3003:3003 `
            -p 3004:3004 `
            -v $env:POMODORO_REPOS/PersonalTracker.Api/Mountebank/conf/:/mocks/conf/ `
            -v $env:POMODORO_REPOS/PersonalTracker.Api/Mountebank/gen_conf/:/mocks/gen_conf/ `
            pomodoro-mountebank         
    } elseif ($Replay) {            
        $Replay = $Replay.ToLower()
        
        Write-Host "Starting pomodoro-mountebank..."
        ##################################
        # Mountebank with proxy forwards
        ############################
        docker run `
        --name pomodoro-mountebank `
        --network pomodoro-net `
        -d `
        --rm `
        -p 2525:2525 `
        -p 3001:3001 `
        -p 3002:3002 `
        -p 3003:3003 `
        -p 3004:3004 `
        -v $env:POMODORO_REPOS/PersonalTracker.Api/Mocks/$Replay/mountebankconf/:/mocks/conf/ `
        -v $env:POMODORO_REPOS/PersonalTracker.Api/Mountebank/gen_conf/:/mocks/gen_conf/ `
        pomodoro-mountebank `
        '--configfile' '/mocks/conf/imposters.json'        
    }
}

Function Start-PomDocker {
    param(
        [Parameter(
            Mandatory=$true, 
            HelpMessage="Containers not involved in proxy.",
            ParameterSetName="Individual")]
        [ValidateSet(
            "pomo-pgsql",
            "pomodoro-idserver",
            "watch-pomo-rapi",
            "pomo-ping-rapi"
        )] 
        [string]$Container
    )

    if (Test-PomMissing) { RETURN }

    switch ($Container) {
        "pomo-pgsql" {
            Write-Host "Starting pomo-pgsql..."
            # run the database container
            # https://hub.docker.com/_/postgres/
            docker run `
                --name pomo-pgsql `
                --mount source=pomo-pgsql-volume,target=/var/lib/postgresql/data/pgdata `
                --network pomodoro-net `
                --rm `
                -p 5432:5432 `
                -e POSTGRES_PASSWORD=Password1 `
                -e POSTGRES_USER=samplesam `
                -e POSTGRES_DB=defaultdb `
                -e PGDATA=/var/lib/postgresql/data/pgdata `
                -d `
                pomodoro-pgsql        
        }
        "pomodoro-idserver" {
            Write-Host "Starting pomodoro-idserver..."
            # Cannot attach a debugger, but can have the app auto reload during development.
            # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
            docker run `
                --name pomodoro-idserver `
                --rm `
                -d `
                -p 2002:80 `
                --network pomodoro-net `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/IdServer/src/:/app/src/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/IdServer/secrets/:/app/secrets/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/IdServer/config/:/app/config/ `
                pomodoro-idserver
        }
        "watch-pomo-rapi" {
            Write-Host "Starting watch-pomo-rapi..."
            # Cannot attach a debugger, but can have the app auto reload during development.
            # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
            docker run `
                --name watch-pomo-rapi `
                --rm -d `
                -p 2003:80 `
                --network pomodoro-net `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Pomodoro.Api/src/:/app/src/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Pomodoro.Api/wwwroot/:/app/wwwroot/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Mountebank/api_conf/:/app/config/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Pomodoro.Api/secrets/:/app/secrets/ `
                pomodoro-watch-rapi
        }
        "pomo-ping-rapi" {
            Write-Host "Starting pomo-ping-rapi..."
            # Cannot attach a debugger, but can have the app auto reload during development.
            # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
            docker run `
                --name pomo-ping-rapi `
                --rm -d `
                -p 2004:80 `
                --network pomodoro-net `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Ping.Api/src/:/app/src/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Ping.Api/wwwroot/:/app/wwwroot/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Ping.Api/config/:/app/config/ `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/Ping.Api/secrets/:/app/secrets/ `
                pomodoro-ping-rapi
        }
        default {}
    }
}

Function Start-PomEnv {
<#
.SYNOPSIS
    Start necessary microservices via docker. 
.DESCRIPTION
    Starts necessary microservices, configures reverse-proxy, and configures mountebank. 
.PARAMETER Client
    This tells the reverse proxy how to treat the root directory (/). The default behavior
    is to provide the html files which are built into the docker image. The other option is
    localmachine, which points to port 3000 on the host machine. This is usefull if you are 
    debugging a single page application. 
.PARAMETER Proxy
    Start all microservices and mountebank. Point the all connections to mountebank, which
    will proxy to the microservices. Mountebank is configured to record the traffic for
    later playback. 
.PARAMETER Replay
    Starts only the reverse-proxy and mountebank. Takes a parameter which specifies which 
    configuration file to use. Currenlty only supports 'webapp'
.EXAMPLE
    Start-PomEnv -Client default 
    Starts all microservices. Localhost will point to the html files in the reverse
    proxy container.
.EXAMPLE
    Start-PomEnv -Proxy 
    Starts all microservices, and the mountebank container. Localhost will point to 
    the html files in the reverse proxy container (Client:default). Mountebank is 
    configured to record everything. 
.EXAMPLE
    Start-PomEnv -Replay webapp -Client localmachine
    Only starts the reverse proxy container and mountebank. Mountebank is configured 
    to use the configuration file contained in Mocks/webapp/mountebankconf/imposters.json. 
    'Client localmachine' configures the reverse proxy to look for a web app running on 
    port 3000 on the host machine. 
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>
    param(
        # Which client would you use
        [Parameter(Mandatory=$false, HelpMessage="To what does the root web directory point?")]
        [ValidateSet("default", "localmachine")] 
        [string]$Client,

        [Parameter(ParameterSetName="MountebankProxy")]
        [switch]$Proxy,

        [Parameter(ParameterSetName="MountebankReplay")]
        [ValidateSet("webapp")] 
        [string]$Replay,

        [Parameter(ParameterSetName="NoMountebank")]
        [switch]$NoProxy
    )

    if (Test-PomMissing) { RETURN }

    $confdir = if ($Proxy -or $Replay) { "Mocks/proxyconf" } else { "LocalProxy/conf" }
    $proxyconfdir = if ($Client) { $Client.ToLower() } else { "default" }
    $confmount = "$env:POMODORO_REPOS/PersonalTracker.Api/{0}/{1}/:/conf/" -f $confdir, $proxyconfdir
       
    if ($Proxy) {
        Write-Host "Starting microservices and Mountebank for recording."
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"
        
        Start-PomDocker -Container "pomo-pgsql"
        Start-PomDocker -Container "watch-pomo-rapi"
        Start-PomDocker -Container "pomo-ping-rapi"
        Start-PomDocker -Container "pomodoro-idserver"
        Start-PomReverse -Client $Client -Proxy
        Start-PomMountebank -Client $Client -Proxy
    } elseif ($Replay) {    
        $Replay = $Replay.ToLower()
        Write-Host "Starting replay"
        Write-Host (" - mocks configured as {0}." -f $Replay)
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

        Start-PomReverse -Client $Client -Replay $Replay
        Start-PomMountebank -Client $Client -Replay $Replay
    } else {    
        Write-Host "Starting services"
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

        Start-PomDocker -Container "pomo-pgsql"
        Start-PomDocker -Container "watch-pomo-rapi"
        Start-PomDocker -Container "pomo-ping-rapi"
        Start-PomDocker -Container "pomodoro-idserver"
        Start-PomReverse -Client $Client -NoProxy
    } 
}

Function Stop-PomEnv {
<#
.SYNOPSIS
    Shuts down the docker containers for the environment. 
.DESCRIPTION
    Shuts down all docker containers used for the Pomodoro project.
.EXAMPLE
    Stop-PomEnv 
    Checks if each of the known containers is running, and shutds it down. 
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>
    @("pomo-pgsql",
    "pomodoro-reverse-proxy",
    "pomodoro-idserver",
    "pomodoro-mountebank",
    "watch-pomo-rapi",
    "pomo-ping-rapi") | ForEach-Object {
        if (docker container list | grep $_) {
            Write-Host ("Stopping {0}" -f $_)
            docker container stop $_
        } else {
            Write-Host ("Not-running: {0}" -f $_)
        }
    }
}

Function Start-PgAdmin {
<#
.SYNOPSIS
    Starts a container running pgadmin on the pomodoro-net network. 
.DESCRIPTION
    Starts a container running pgadmin on the pomodoro-net network. 
    Uses the following environment variables
    * PGADMIN_DEFAULT_EMAIL=user@domain.com
    * PGADMIN_DEFAULT_PASSWORD=Password1
.EXAMPLE
    Start-PgAdmin
    Starts a container running pgadmin on the pomodoro-net network. 
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>

    Write-Host "Starting pomo-pgadmin..."
    # Use pgadmin to explore the database
    docker run `
        -p 5002:80 `
        --rm `
        --name pomo-pgadmin `
        --network pomodoro-net `
        -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" `
        -e "PGADMIN_DEFAULT_PASSWORD=Password1" `
        -d `
        dpage/pgadmin4
}

Function Stop-PgAdmin {
<#
.SYNOPSIS
    Stops a container running pgadmin on the pomodoro-net network. 
.DESCRIPTION
    Stops a container running pgadmin on the pomodoro-net network. 
.EXAMPLE
    Stop-PgAdmin
    Stops a container running pgadmin on the pomodoro-net network. 
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>
    docker container stop pomo-pgadmin
}

Function Connect-PomDocker {
<#
.SYNOPSIS
    Executes /bin/sh in of the available containers for the pomodoro project
.DESCRIPTION
    Executes /bin/sh in of the available containers for the pomodoro project
.PARAMETER Container
    One of the valid containers for the pomodoro project    
.EXAMPLE
    Connect-PomDocker pomo-pgsql
    Executes /bin/sh in the pomo-pgsql container
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>    
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "watch-pomo-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomo-pgsql",
            "pomo-pgadmin"
            )] 
        [string]$Container,

        [Parameter(Mandatory=$false)]
        [switch]$Bash
        
    )
    $sh = if ($Bash) { "/bin/bash" } else { "/bin/sh" }
    docker exec -it $Container $sh
}






Function Build-PomDocker {
    <#
    .SYNOPSIS
        Executes /bin/sh in of the available containers for the pomodoro project
    .DESCRIPTION
        Executes /bin/sh in of the available containers for the pomodoro project
    .PARAMETER Container
        One of the valid containers for the pomodoro project    
    .EXAMPLE
        Connect-PomDocker pomo-pgsql
        Executes /bin/sh in the pomo-pgsql container
    .NOTES
        Author: Phillip Scott Givens
        Date:   November 25th, 2018
    #>    
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "watch-pomo-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomo-pgsql",
            "pomo-pgadmin"
            )] 
        [string]$Image
    )

    if (Test-PomMissing) { RETURN }

    $buildpath = "$env:POMODORO_REPOS/PersonalTracker.Api"
    switch($Image) {
        "watch-pomo-rapi" {
            docker build `
                -t pomodoro-watch-rapi `
                -f "$buildpath/Pomodoro.Api/watch.Dockerfile" `
                "$buildpath/Pomodoro.Api"
        }
        "pomodoro-idserver" {
            docker build `
                -t pomodoro-idserver `
                -f "$buildpath/IdServer/watch.Dockerfile" `
                "$buildpath/IdServer"
        }
        "pomodoro-reverse-proxy" {
            Write-Host "Not implemented"
        }
        "pomodoro-mountebank" {
            docker build `
                -t pomodoro-mountebank `
                -f "$buildpath/Mountebank/Dockerfile" `
                "$buildpath/Mountebank"
        }
        "pomo-pgsql" {
            Write-Host "Not implemented"
        }
        "pomo-pgadmin" {
            Write-Host "Not implemented"
        }
    }


# docker build -t pomodoro-dotnet-stage -f tools/dotnet.stage.Dockerfile tools
# docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api
# docker build -t pomodoro-ping-rapi -f Ping.Api/watch.Dockerfile Ping.Api

}



Function Start-PomDockerShell {
<#
.SYNOPSIS
    Starts and executes /bin/sh in of the available containers for the pomodoro project.
.DESCRIPTION
    Starts and executes /bin/sh in of the available containers for the pomodoro project.
    This overrides the images entrypoint with /bin/sh
.PARAMETER Container
    One of the valid containers for the pomodoro project    
.EXAMPLE
    Start-DockerBash pomo-pgsql
    Starts and executes /bin/sh in the pomo-pgsql container
.NOTES
    Author: Phillip Scott Givens
    Date:   November 25th, 2018
#>        
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "watch-pomo-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomo-pgsql",
            "pomo-pgadmin"
            )] 
        [string]$Container,

        [Parameter(Mandatory=$false)]
        [switch]$Bash
    )
    docker run -it --entrypoint $sh $Container
}

Function Update-PomModule {
    if (Test-PomMissing) { RETURN }

    $MyPSModulePath = "{0}/.local/share/powershell/Modules" -f (ls -d ~)
    mkdir -p $MyPSModulePath/PomodoroEnv
    Write-Host ("Copying {0}/PersonalTracker.Api/scripts/PomodoroEnv.psm1 to {1}/PomodoroEnv/" -f $env:POMODORO_REPOS,  $MyPSModulePath)
    cp -f $env:POMODORO_REPOS/PersonalTracker.Api/scripts/PomodoroEnv.psm1  $MyPSModulePath/PomodoroEnv/
    Write-Host "Force import-module PomodorEnv"
    Import-Module -Force PomodoroEnv
}

Function Initialize-PomEnv {
    Write-Host "Creating volume 'pomo-pgsql-volume'"
    docker volume create pomo-pgsql-volume
    Write-Host "Creating network 'pomodoro-net'"
    docker network create --driver bridge pomodoro-net
}

<<<<<<< HEAD
Export-ModuleMember -Function Build-PomDocker
=======
Function Build-PomContainers {
    pushd $env:POMODORO_REPOS
    docker build -t pomodoro-mountebank -f Mountebank/Dockerfile Mountebank

    docker build -t pomodoro-dotnet-stage -f tools/dotnet.stage.Dockerfile tools

    docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api

    docker build -t pomodoro-ping-rapi -f Ping.Api/watch.Dockerfile Ping.Api

    docker build -t pomodoro-watch-rapi -f Pomodoro.Api/watch.Dockerfile Pomodoro.Api

    docker build -t pomodoro-idserver -f IdServer/watch.Dockerfile IdServer

    docker build -t pomodoro-pgsql -f pgsql/Dockerfile ./pgsql

    docker build -t myrevprox -f LocalProxy/Dockerfile ./LocalProxy
    popd
}

Export-ModuleMember -Function Start-PomEnv
Export-ModuleMember -Function Stop-PomEnv
>>>>>>> 4ba1b83ec592bd00c24b9eb01646b108bd8d5337
Export-ModuleMember -Function Connect-PomDocker
Export-ModuleMember -Function Initialize-PomEnv
Export-ModuleMember -Function Start-PgAdmin
Export-ModuleMember -Function Start-PomDocker
Export-ModuleMember -Function Start-PomDockerShell
Export-ModuleMember -Function Start-PomEnv
Export-ModuleMember -Function Start-PomMountebank
Export-ModuleMember -Function Start-PomReverse
Export-ModuleMember -Function Stop-PgAdmin
<<<<<<< HEAD
Export-ModuleMember -Function Stop-PomEnv
Export-ModuleMember -Function Update-PomModule
=======
Export-ModuleMember -Function Start-DockerBash
Export-ModuleMember -Function Update-PomModule
Export-ModuleMember -Function Initialize-PomEnv
Export-ModuleMember -Function Build-PomContainers

>>>>>>> 4ba1b83ec592bd00c24b9eb01646b108bd8d5337
