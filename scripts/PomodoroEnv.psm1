#!/usr/bin/pwsh

Function Test-PomMissing {
    if (-not $env:POMODORO_REPOS) {
        Write-Host "Please set the $env:POMODORO_REPOS to the location of this repo."
        return $true
    }   
}

Function Use-PomDirectory {
    if (Test-PomMissing) { RETURN }
    Set-Location "$env:POMODORO_REPOS/PersonalTracker.Api"
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
    pomodoro-reverse-proxy 
}

Function Start-PomMountebank {
    param(
        [Parameter(ParameterSetName="MountebankProxy")]
        [switch]$Proxy,

        [Parameter(ParameterSetName="MountebankReplay")]
        [ValidateSet("webapp")] 
        [string]$Replay
    )

    if (Test-PomMissing) { RETURN }

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

Function Start-PomContainer {
    param(
        [Parameter(
            Mandatory=$true, 
            HelpMessage="Containers not involved in proxy.",
            ParameterSetName="Individual")]
        [ValidateSet(
            "pomodoro-pgsql",
            "pomodoro-idserver",
            "pomodoro-reverse-proxy",
            "watch-pomo-rapi",
            "pomo-ping-rapi",
            "pomodoro-client"
        )] 
        [string]$Container
    )

    if (Test-PomMissing) { RETURN }

    switch ($Container) {
        "pomodoro-pgsql" {
            Write-Host "Starting pomodoro-pgsql..."
            if ($Attach) { Write-Host "'Attach' is not a valid switch with this immage."; exit; }

            # run the database container
            # https://hub.docker.com/_/postgres/
            docker run `
                --name pomodoro-pgsql `
                --mount source=pomodoro-pgsql-volume,target=/var/lib/postgresql/data/pgdata `
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
            Write-Host "Use Start-PomIdServer for more options"
            Start-PomIdServer 
        }
        "watch-pomo-rapi" {
            Write-Host "Starting watch-pomo-rapi..."
            if ($Attach) { Write-Host "'Attach' is not a valid switch with this immage."; exit; }

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
            if ($Attach) { Write-Host "'Attach' is not a valid switch with this immage."; exit; }

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
        "pomodoro-client" {
            Write-Host "Starting pomodoro-client..."
            if ($Attach) { Write-Host "'Attach' is not a valid switch with this immage."; exit; }

            # Cannot attach a debugger, but can have the app auto reload during development.
            # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
            docker run `
                --name pomodoro-client `
                --rm -it `
                --network pomodoro-net `
                -v $env:POMODORO_REPOS/PersonalTracker.Api/ClientTools/src/:/app/src/ `
                pomodoro-client
        }
        "pomodoro-reverse-proxy" {
            Write-Host "Use Start-PomReverse for more options"
            Start-PomReverse -Client localmachine -NoProxy
        }
        default {}
    }
}


Function Start-PomIdServer {
    param(
        [Parameter()]
        [switch]$Attach
    )

    if (Test-PomMissing) { RETURN }

    Write-Host "Starting pomodoro-idserver..."
    $Flags = if ($Attach) { '--debug' } else { '' }
    
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
        pomodoro-idserver $Flags
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
        
        Start-PomContainer -Container "pomodoro-pgsql"
        Start-PomContainer -Container "watch-pomo-rapi"
        Start-PomContainer -Container "pomo-ping-rapi"
        Start-PomContainer -Container "pomodoro-idserver"
        Start-PomReverse -Client $Client -Proxy
        Start-PomMountebank -Proxy

    } elseif ($Replay) {    
        $Replay = $Replay.ToLower()
        Write-Host "Starting replay"
        Write-Host (" - mocks configured as {0}." -f $Replay)
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

        Start-PomReverse -Client $Client -Replay $Replay
        Start-PomMountebank -Replay $Replay
    } else {    
        Write-Host "Starting services"
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

        Start-PomContainer -Container "pomodoro-pgsql"
        Start-PomContainer -Container "watch-pomo-rapi"
        Start-PomContainer -Container "pomo-ping-rapi"
        Start-PomContainer -Container "pomodoro-idserver"
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
    @("pomodoro-pgsql",
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

Function Start-PomPgAdmin {
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

    Write-Host "Starting pomodoro-pgadmin..."
    # Use pgadmin to explore the database
    docker run `
        -p 5002:80 `
        --rm `
        --name pomodoro-pgadmin `
        --network pomodoro-net `
        -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" `
        -e "PGADMIN_DEFAULT_PASSWORD=Password1" `
        -d `
        dpage/pgadmin4
}

Function Stop-PomPgAdmin {
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
    docker container stop pomodoro-pgadmin
}

Function Connect-PomContainer {
<#
.SYNOPSIS
    Executes /bin/sh in of the available containers for the pomodoro project
.DESCRIPTION
    Executes /bin/sh in of the available containers for the pomodoro project
.PARAMETER Container
    One of the valid containers for the pomodoro project    
.EXAMPLE
    Connect-PomContainer pomodoro-pgsql
    Executes /bin/sh in the pomodoro-pgsql container
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
            "pomodoro-pgsql",
            "pomodoro-pgadmin",
            "pomodoro-utils"
            )] 
        [string]$Container,

        [Parameter(Mandatory=$false)]
        [switch]$Bash,

        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker = "docker",

        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "0", 
            "1",
            "2"
            )] 
        [string]$Number
    )

    if (Test-PomMissing) { RETURN }

    $sh = if ($Bash) { "/bin/bash" } else { "/bin/sh" }

    switch ($Docker) {
        "microk8s.docker" {
            $c = if ($Number) { "{0}-{1}" -f $Container, $Number }
                 else { $Container }
            microk8s.kubectl exec `
                --namespace pomodoro-services `
                -it `
                $c `
                -- /bin/bash
        }
        "docker" {
            docker exec -it $Container $sh
        }
        "azure" {
            throw "Connecting to Azure is not currently supported."
        }
    }

}


Function Build-PomImage {
    <#
    .SYNOPSIS
        Builds the docker container related to the pomodor project.
    .DESCRIPTION
        Builds the docker container related to the pomodor project.
    .PARAMETER Image
        One of the valid images for the pomodoro project
    .EXAMPLE
    .NOTES
        Author: Phillip Scott Givens
    #>    
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "pomodoro-watch-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomodoro-pgsql",
            "pomodoro-pgadmin",
            "pomodoro-dotnet-stage",
            "pomodoro-utils",
            "pomodoro-rapi",
            "pomodoro-ping-rapi",
            "pomodoro-client"
            )] 
        [string]$Image,

        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker="docker"
    )

    if (Test-PomMissing) { RETURN }
    if ($Docker) {
        Set-Alias dkr $Docker -Option Private
    }

    $buildpath = "$env:POMODORO_REPOS/PersonalTracker.Api"
    switch($Image) {
        "pomodoro-watch-rapi" {
            dkr build `
                -t pomodoro-watch-rapi `
                -f "$buildpath/Pomodoro.Api/watch.Dockerfile" `
                "$buildpath/Pomodoro.Api"
        }
        "pomodoro-idserver" {
            dkr build `
                -t pomodoro-idserver `
                -f "$buildpath/IdServer/debug.Dockerfile" `
                "$buildpath/IdServer"
        }
        "pomodoro-reverse-proxy" {
            dkr build `
                -t pomodoro-reverse-proxy `
                -f "$buildpath/LocalProxy/Dockerfile" `
                "$buildpath/LocalProxy"
        }
        "pomodoro-mountebank" {
            dkr build `
                -t pomodoro-mountebank `
                -f "$buildpath/Mountebank/Dockerfile" `
                "$buildpath/Mountebank"
        }
        "pomodoro-dotnet-stage" {
            dkr build `
                -t pomodoro-dotnet-stage `
                -f "$buildpath/tools/dotnet.stage.Dockerfile" `
                "$buildpath/tools"
        }
        "pomodoro-utils" {
            dkr build `
                -t pomodoro-utils `
                -f "$buildpath/tools/utils.Dockerfile" `
                "$buildpath/tools"
        }
        "pomodoro-rapi" {
            dkr build `
                -t pomodoro-rapi `
                -f "$buildpath/Pomodoro.Api/Dockerfile" `
                "$buildpath/Pomodoro.Api"
        }
        "pomodoro-pgsql" {
            dkr build `
                -t pomodoro-pgsql `
                -f "$buildpath/pgsql/Dockerfile" `
                "$buildpath/./pgsql"
        }
        "pomodoro-pgadmin" {
            dkr pull `
                dpage/pgadmin4
        }
        "pomodoro-ping-rapi" {
            dkr build `
                -t pomodoro-ping-rapi `
                -f "$buildpath/Ping.Api/watch.Dockerfile" `
                "$buildpath/Ping.Api"
        }
        "pomodoro-client" {
            dkr build `
                -t pomodoro-client `
                -f "$buildpath/ClientTools/watch.Dockerfile" `
                "$buildpath/ClientTools"
        }
    }
}

Function Publish-PomImage {
    <#
    .SYNOPSIS
        Publish the docker image related to the pomodoro project.
    .DESCRIPTION
        Publish the docker image related to the pomodoro project.
    .PARAMETER Image
        One of the valid images for the pomodoro project
    .EXAMPLE
    .NOTES
        Author: Phillip Scott Givens
    #>    
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "pomodoro-watch-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomodoro-pgsql", 
            "pomodoro-pgadmin", 
            "pomodoro-dotnet-stage", 
            "pomodoro-utils",
            "pomodoro-rapi", 
            "pomodoro-ping-rapi"
            )] 
        [string]$Image,

        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker = "docker"
    )

    if (Test-PomMissing) { RETURN }
    
    Set-Alias dkr $Docker -Option Private
    $repo = switch ($Docker) {
        "microk8s.docker" {
            "localhost:32000"
        }
        "docker" {
            throw "publishing to docker hub is not supported"
        }
        "azure" {
            throw "publishing to Azure is not currently supported."
        }

    }

    $remote = "{0}/{1}" -f $repo, $Image

    $imgname = switch ($Image) {
        "pomodoro-pgadmin" { "dpage/pgadmin4" }
        default { $Image }
    }

    dkr tag $imgname $remote
    dkr push $remote
}

Function Publish-PomEnv {
    <#
    .SYNOPSIS
        Publish all the docker images related to the pomodoro project.
    .DESCRIPTION
        Publish all the docker images related to the pomodoro project.
    .PARAMETER Image
        One of the valid images for the pomodoro project
    .EXAMPLE
    .NOTES
        Author: Phillip Scott Givens
    #>    
    param(        
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker = "docker"
    )

    if (Test-PomMissing) { RETURN }    
    
    
    @(
        "pomodoro-watch-rapi", 
        "pomodoro-idserver", 
        "pomodoro-reverse-proxy", 
        "pomodoro-mountebank", 
        "pomodoro-pgsql", 
        "pomodoro-dotnet-stage", 
        "pomodoro-utils",
        "pomodoro-rapi", 
        "pomodoro-ping-rapi"
    ) | %{ Publish-PomImage -Docker $Docker -Image $_ }
}


Function Get-PomImage {
    <#
    .SYNOPSIS
        Get the docker image related to the pomodoro project.
    .DESCRIPTION
        Get the docker image related to the pomodoro project.
    .PARAMETER Image
        One of the valid images for the pomodoro project
    .EXAMPLE
    .NOTES
        Author: Phillip Scott Givens
    #>    
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "pomodoro-watch-rapi", 
            "pomodoro-idserver", 
            "pomodoro-reverse-proxy", 
            "pomodoro-mountebank", 
            "pomodoro-pgsql",
            "pomodoro-pgadmin",
            "pomodoro-dotnet-stage",
            "pomodoro-utils",
            "pomodoro-rapi",
            "pomodoro-ping-rapi"
            )] 
        [string]$Image,

        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker = "docker"
    )

    if (Test-PomMissing) { RETURN }
    
    Set-Alias dkr $Docker -Option Private
    $repo = switch ($Docker.ToLower()) {
        "microk8s.docker" {
            "localhost:32000"
        }
        "docker" {
            throw "Retrieving is not supported for docker hub."
        }
        "azure" {
            throw "Retrieving from Azure is not currently supported."
        }
    }

    $remote = "{0}/{1}" -f $repo, $Image    
    dkr pull $remote
}


Function Build-PomImages {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "docker", 
            "microk8s.docker",
            "azure"
            )] 
        [string]$Docker = "docker"
    )

    if (Test-PomMissing) { RETURN }

    @(
        "pomodoro-watch-rapi", 
        "pomodoro-idserver", 
        "pomodoro-reverse-proxy", 
        "pomodoro-mountebank", 
        "pomodoro-pgsql",
        "pomodoro-pgadmin",
        "pomodoro-dotnet-stage",
        "pomodoro-utils",
        "pomodoro-rapi",
        "pomodoro-ping-rapi"
    ) | %{ Build-PomImage -Docker $Docker -Image $_ }
}


Function Start-PomContainerShell {
<#
.SYNOPSIS
    Starts and executes /bin/sh in of the available containers for the pomodoro project.
.DESCRIPTION
    Starts and executes /bin/sh in of the available containers for the pomodoro project.
    This overrides the images entrypoint with /bin/sh
.PARAMETER Container
    One of the valid containers for the pomodoro project    
.EXAMPLE
    Start-DockerBash pomodoro-pgsql
    Starts and executes /bin/sh in the pomodoro-pgsql container
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
            "pomodoro-pgsql",
            "pomodoro-pgadmin"
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
    Import-Module -Force PomodoroEnv -Global
}

Function Initialize-PomEnv {
    Write-Host "Creating volume 'pomodoro-pgsql-volume'"
    docker volume create pomodoro-pgsql-volume
    Write-Host "Creating network 'pomodoro-net'"
    docker network create --driver bridge pomodoro-net
}

Function Get-K8sName {
    echo "kctl config current-context"
    kctl config current-context
}

Function Set-K8sName {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet(
            "default",
            "playground"
            )] 
        [string]$Namespace
    )
    kctl config set-context (kctl config current-context) --namespace $Namespace
}

Function Invoke-PomK8Docker {
    microk8s.docker @args
}
Set-Alias kdock Invoke-PomK8Docker

Function Invoke-PomKubectl {
    microk8s.kubectl --namespace pomodoro-services @args
}
Set-Alias k8p Invoke-PomKubectl

Export-ModuleMember -Function Initialize-PomAlias
Export-ModuleMember -Function Build-PomImage
Export-ModuleMember -Function Build-PomImages
Export-ModuleMember -Function Connect-PomContainer
Export-ModuleMember -Function Get-K8sName
Export-ModuleMember -Function Get-PomImage
Export-ModuleMember -Function Initialize-PomEnv
Export-ModuleMember -Function Invoke-PomK8Docker -Alias kdock
Export-ModuleMember -Function Invoke-PomKubectl -Alias k8p
Export-ModuleMember -Function Publish-PomImage
Export-ModuleMember -Function Publish-PomEnv
Export-ModuleMember -Function Set-K8sName
Export-ModuleMember -Function Start-DockerBash
Export-ModuleMember -Function Start-PomPgAdmin
Export-ModuleMember -Function Start-PomContainer
Export-ModuleMember -Function Start-PomContainerShell
Export-ModuleMember -Function Start-PomIdServer
Export-ModuleMember -Function Start-PomEnv
Export-ModuleMember -Function Start-PomMountebank
Export-ModuleMember -Function Start-PomReverse
Export-ModuleMember -Function Stop-PomEnv
Export-ModuleMember -Function Stop-PomPgAdmin
Export-ModuleMember -Function Update-PomModule
Export-ModuleMember -Function Use-PomDirectory