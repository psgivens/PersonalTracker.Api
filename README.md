# PersonalTracker.Api

### Setup

# https://docs.microsoft.com/en-us/aspnet/core/tutorials/web-api-vsc?view=aspnetcore-2.1

    dotnet new webapi -o Pomodoro.Api

    
### Create the migration

    # Required dotnet-sdk-2.1.300

    dotnet ef migrations add InitialMigration

    dotnet ef database update

### Replace the volume
    sudo docker volume rm pomo-pgsql-volume
    sudo docker volume create pomo-pgsql-volume

### Create the network
    sudo docker network create --driver bridge pomodoro-net
  
### Build the pgsql database

    sudo docker build -t pomo-pgsql -f pgsql/Dockerfile ./pgsql

### Build the pomodoro container

    sudo docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api

    sudo docker build -t pomodoro-watch-rapi -f Pomodoro.Api/watch.Dockerfile Pomodoro.Api

### Running the database container

    # run the database container
    # https://hub.docker.com/_/postgres/
    sudo docker run `
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
      pomo-pgsql

    # run bash in the database container
    sudo docker exec -it pomo-pgsql bash

    # While logged into database container
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"

    # Use pgadmin to explore the database
    sudo docker run `
      -p 5002:80 `
      --rm `
      --name pomo-pgadmin `
      --network pomodoro-net `
      -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" `
      -e "PGADMIN_DEFAULT_PASSWORD=Password1" `
      -d `
      dpage/pgadmin4


### Running the application
This can run with or without autoreloading

    clear
    # Cannot attach a debugger, but can have the app auto reload during development.
    # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
    sudo docker run `
      --name watch-pomo-rapi `
      --rm -it `
      -p 4000:4000 `
      -p 4001:4001 `
      --network pomodoro-net `
      -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/:/app/ `
      pomodoro-watch-rapi
    
    # Does not currently work
    sudo docker run `
      --name pomo-rapi `
      --network pomodoro-net `
      --rm `
      -it `
      -p 5000:80 `
      -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/out/:/app/ `
      pomodoro-rapi

    # Explore the rest api container
    sudo docker exec -it watch-pomo-rapi bash

    # Explore the watch rest api container
    sudo docker exec -it pomo-rapi bash


### Take inventory
    clear
    sudo docker network list | grep weighttrack
    sudo docker volume list | grep weighttrack
    sudo docker container list -a | grep -E "NAMES|wapi|pgadmin|weight|dbg"

    sudo docker image list

### Start existing contaienrs

    sudo docker container start weight-pgsql

    sudo docker container start pgadmin_dock

    sudo docker container start wt-wapi

### Removing containers

    sudo docker container stop weight-pgsql
    sudo docker container rm weight-pgsql

    sudo docker container stop wt-wapi
    sudo docker container rm wt-wapi

    sudo docker container stop pgadmin_dock
    sudo docker container rm pgadmin_dock








