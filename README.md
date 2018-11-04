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
    docker network create --driver bridge pomodoro-net
  
### Build the pgsql database

    docker build -t pomodoro-pgsql -f pgsql/Dockerfile ./pgsql

### Build the pomodoro container

    sudo docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api

    sudo docker build -t pomodoro-watch-rapi -f Pomodoro.Api/watch.Dockerfile Pomodoro.Api

    sudo docker build -t pomodoro-idserver -f IdServer/Dockerfile IdServer

    sudo docker build -t pomodoro-simplehtml -f simplehtml/Dockerfile simplehtml

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

    $myip = (hostname -I).split(' ') | ?{ $_ -match '^192' }

    clear
    # Cannot attach a debugger, but can have the app auto reload during development.
    # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
    docker run `
      --name watch-pomo-rapi `
      --rm -d `
      -p 2003:80 `
      --add-host="localhost:$myip" `
      --network pomodoro-net `
      -v ~/Repos/psgivens/PersonalTracker.Api/Pomodoro.Api/:/app/ `
      pomodoro-watch-rapi

    docker logs watch-pomo-rapi 

    docker container stop watch-pomo-rapi
    
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
    docker exec -it watch-pomo-rapi bash

    # Explore the watch rest api container
    sudo docker exec -it pomo-rapi bash

    clear
    # Cannot attach a debugger, but can have the app auto reload during development.
    # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
    docker run `
      --name pomodoro-idserver `
      --rm `
      -d `
      -p 2002:80 `
      --network pomodoro-net `
      -v ~/Repos/psgivens/PersonalTracker.Api/IdServer/:/app/ `
      pomodoro-idserver

    docker container stop pomodoro-idserver

    sudo docker exec -it pomodoro-idserver bash

    clear
    # Cannot attach a debugger, but can have the app auto reload during development.
    # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
    sudo docker run `
      --name pomodoro-simplehtml `
      --rm -d `
      -p 2001:80 `
      --network pomodoro-net `
      -v ~/Repos/psgivens/PersonalTracker.Api/simplehtml/:/app/ `
      pomodoro-simplehtml

### Take inventory
    clear
    sudo docker network list | grep -E "NAME|pomodoro"
    sudo docker volume list | grep -E "NAME|pomodoro"
    sudo docker container list -a | grep -E "NAMES|rapi|pgadmin|pomo|dbg"

    sudo docker image list




### Reverse Proxy

    # https://bitbucket.org/mimiz33/apache-proxy

    $myip = (hostname -I).split(' ') | ?{ $_ -match '^192' }

    docker run -it --rm --add-host="localhost:$myip" -p 8080:80 httpd /bin/bash

    docker run -it --rm --add-host="localhost:$myip" -p 8080:80 rgoyard/apache-proxy /bin/bash

    docker container stop my_reverse_proxy 
    docker build -t myrevprox -f local/Dockerfile ./local
    sudo docker run `
      --name my_reverse_proxy `
      --network pomodoro-net `
      -d `
      --rm `
      --add-host="localhost:$myip" `
      -p 80:80 `
      myrevprox 
    
    docker exec -it my_reverse_proxy /bin/bash

    docker container stop my_reverse_proxy 






