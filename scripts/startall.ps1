#!/usr/bin/pwsh

    clear

    echo "Starting pomo-pgsql..."
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

    echo "Starting pomo-pgadmin..."
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


    #
    # Get the IP of the localmachine
    #
    $regex=[regex] '\d+\.\d+\.\d+\.\d+'
    $interface=ip -family inet -o addr show docker0
    $hostip=$regex.Match($interface).Value.Trim()
    $addhost="{0}:{1}" -f  "localmachine", $hostip
    echo "Starting pmodoro-reverse-proxy with --add-host $addhost..."
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
      myrevprox 
    
    echo "Starting watch-pomo-rapi..."
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

    echo "Starting pomodoro-idserver"
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

