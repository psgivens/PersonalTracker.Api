#!/usr/bin/pwsh

Function Start-PomEnv {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("default", "localmachine")] 
        [string]$Client,

        [Parameter(ParameterSetName="MountebankProxy")]
        [switch]$Proxy,

        [Parameter(ParameterSetName="MountebankReplay")]
        [ValidateSet("webapp")] 
        [string]$Replay
    )

    $confdir = if ($Proxy -or $Replay) { "Mocks/proxyconf" } else { "LocalProxy/conf" }
    $proxyconfdir = if ($Client) { $Client.ToLower() } else { "default" }
    $confmount = "~/Repos/psgivens/PersonalTracker.Api/{0}/{1}/:/conf/" -f $confdir, $proxyconfdir
       
    if ($Proxy) {

        Write-Host "Starting microservices and Mountebank for recording."
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"
        
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
        
        #
        # Get the IP of the localmachine
        #
        $regex=[regex] '\d+\.\d+\.\d+\.\d+'
        $interface=ip -family inet -o addr show docker0
        $hostip=$regex.Match($interface).Value.Trim()
        $addhost="{0}:{1}" -f  "localmachine", $hostip
        Write-Host "Starting pmodoro-reverse-proxy with --add-host $addhost..."
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
            -v ~/Repos/psgivens/PersonalTracker.Api/LocalProxy/app/:/app/ `
            -v $confmount `
            myrevprox 

        Write-Host "Starting watch-pomo-rapi..."
        # Cannot attach a debugger, but can have the app auto reload during development.
        # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
        docker run `
            --name watch-pomo-rapi `
            --rm -d `
            -p 2003:80 `
            --network pomodoro-net `
            -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/src/:/app/src/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/wwwroot/:/app/wwwroot/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/Mountebank/api_conf/:/app/config/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/secrets/:/app/secrets/ `
            pomodoro-watch-rapi
        
        Write-Host "Starting pomodoro-idserver..."
        # Cannot attach a debugger, but can have the app auto reload during development.
        # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
        docker run `
            --name pomodoro-idserver `
            --rm `
            -d `
            -p 2002:80 `
            --network pomodoro-net `
            -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/src/:/app/src/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/config/:/app/config/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/secrets/:/app/secrets/ `
            pomodoro-idserver
        
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
            -v ~/Repos/psgivens/PersonalTracker.Api/Mountebank/conf/:/mocks/conf/ `
            -v ~/Repos/psgivens/PersonalTracker.Api/Mountebank/gen_conf/:/mocks/gen_conf/ `
            pomodoro-mountebank 
    } elseif ($Replay) {
    
        $Replay = $Replay.ToLower()
        Write-Host "Starting replay"
        Write-Host (" - mocks configured as {0}." -f $Replay)
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

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
        -v ~/Repos/psgivens/PersonalTracker.Api/Mocks/$Replay/mountebankconf/:/mocks/conf/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/Mountebank/gen_conf/:/mocks/gen_conf/ `
        pomodoro-mountebank `
        '--configfile' '/mocks/conf/imposters.json'

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
        -v ~/Repos/psgivens/PersonalTracker.Api/LocalProxy/app/:/app/ `
        -v $confmount `
        myrevprox 

    } else {
    
        Write-Host "Starting services"
        Write-Host (" - client is {0}" -f $proxyconfdir)
        Write-Host "--------------------------------`n"

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
        -v ~/Repos/psgivens/PersonalTracker.Api/LocalProxy/app/:/app/ `
        -v $confmount `
        myrevprox 

        Write-Host "Starting watch-pomo-rapi..."
        # Cannot attach a debugger, but can have the app auto reload during development.
        # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
        docker run `
        --name watch-pomo-rapi `
        --rm -d `
        -p 2003:80 `
        --network pomodoro-net `
        -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/src/:/app/src/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/wwwroot/:/app/wwwroot/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/config/:/app/config/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/secrets/:/app/secrets/ `
        pomodoro-watch-rapi

        Write-Host "Starting pomodoro-idserver..."
        # Cannot attach a debugger, but can have the app auto reload during development.
        # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
        docker run `
        --name pomodoro-idserver `
        --rm `
        -d `
        -p 2002:80 `
        --network pomodoro-net `
        -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/src/:/app/src/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/config/:/app/config/ `
        -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/secrets/:/app/secrets/ `
        pomodoro-idserver

    } 
}

Function Stop-PomEnv {
    @("pomo-pgsql",
    "pomodoro-reverse-proxy",
    "pomodoro-idserver",
    "pomodoro-mountebank",
    "watch-pomo-rapi") | ForEach {
        if (docker container list | grep $_) {
            Write-Host ("Stopping {0}" -f $_)
            docker container stop $_
        } else {
            Write-Host ("Not-running: {0}" -f $_)
        }
    }
}

Function Start-PgAdmin {
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
    docker container stop pomo-pgadmin
}

Function Connect-PomDocker {
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
        [string]$Container
    )
    docker exec -it $Container /bin/sh
}


Export-ModuleMember -Function Start-PomEnv
Export-ModuleMember -Function Stop-PomEnv
Export-ModuleMember -Function Connect-PomDocker
Export-ModuleMember -Function Start-PgAdmin
Export-ModuleMember -Function Stop-PgAdmin
