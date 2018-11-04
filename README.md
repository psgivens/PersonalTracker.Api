# PersonalTracker.Api

PersonalTracker.Api is a reference implementation of using microservices with a 
browser based application. It currently has two services, each backed by a database.

* The Pomodoro.Api service manages a logs of time blocks of the user.
* The IdServer manages authentication and authorization.

In addition to these there are containers which only exist in development.

* LocalProxy, serves static pages, and makes all requests to look like they are served from the same machine. In production, this will be replaced by a Storage Bucket with CDN for static pages, and a Kubernetes Service for the routing.
* pgsql, hosts a local postgresql database. In production, this would be replaced by a hosted database
* pgadmin4, is a web-based sql explorer for postgresql. It is pulled directly from dockerhub.

All containers are connected via one bridged docker network, pomodoro-net

During run, source code directories are mapped via docker volumes

Here are some URLS to use as sanity checks
* http://localhost/index.html - Is the proxy/static server running?
* http://localhost:2002/.well-known/openid-configuration - Is IdServer running?
* http://localhost/.well-known/openid-configuration - Can the proxy access IdServer?
* http://localhost:2003/api/ping - Is the api server running?
* http://localhost/api/ping - Can the proxy acccess the api server?
* http://localhost/testclient.html - Use debug tools to see if this calls id and api.

## Setup

### Seting up dotnet core applications
Instructions for creating dotnet apps can be found at:
[aspnetcore-2.1](https://docs.microsoft.com/en-us/aspnet/core/tutorials/web-api-vsc?view=aspnetcore-2.1)

    dotnet new webapi -o Pomodoro.Api

    dotnet ef migrations add InitialMigration

    dotnet ef database update

### Setting up the docker infrastrucutre

    # Create the volume for the database
    sudo docker volume create pomo-pgsql-volume

    # Remove the volume for the database
    sudo docker volume rm pomo-pgsql-volume

    # Create the network
    docker network create --driver bridge pomodoro-net
  
    # Build the pgsql database
    docker build -t pomodoro-pgsql -f pgsql/Dockerfile ./pgsql

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

    # Create and run the reverse proxy
    docker build -t myrevprox -f LocalProxy/Dockerfile ./LocalProxy
    sudo docker run `
      --name pomodoro-reverse-proxy `
      --network pomodoro-net `
      -d `
      --rm `
      -p 80:80 `
      -v ~/Repos/psgivens/PersonalTracker.Api/LocalProxy/app/:/app/ `
      myrevprox 
    
    docker exec -it pomodoro-reverse-proxy /bin/bash

    docker container stop pomodoro-reverse-proxy 

### Take inventory
    clear
    docker network list | grep -E "NAME|pomodoro"
    docker volume list | grep -E "NAME|pomodoro"
    docker container list -a | grep -E "NAMES|rapi|pgadmin|pomo|dbg"

    sudo docker image list

### Build the application containers

    sudo docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api

    sudo docker build -t pomodoro-watch-rapi -f Pomodoro.Api/watch.Dockerfile Pomodoro.Api

    sudo docker build -t pomodoro-idserver -f IdServer/Dockerfile IdServer

### Run the application containers
This can run with or without autoreloading

    $myip = (hostname -I).split(' ') | ?{ $_ -match '^192' }

    clear
    # Cannot attach a debugger, but can have the app auto reload during development.
    # https://github.com/dotnet/dotnet-docker/blob/master/samples/dotnetapp/dotnet-docker-dev-in-container.md
    docker run `
      --name watch-pomo-rapi `
      --rm -d `
      -p 2003:80 `
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


