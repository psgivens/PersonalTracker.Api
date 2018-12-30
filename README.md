# PersonalTracker.Api

## Introduction

PersonalTracker.Api is a reference implementation of using microservices with a browser based application. It currently has two services, each backed by a database.

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

The proxy has been changed. The above testclient and index won't work. To get them to work remove the last line of LocalProxy/conf/proxy.conf

* http://localhost:3000 - The react app running on the local system
* http://localhost - Proxy of the react app running on the local system

Ports used in this project

* 2002 - id server
* 2003 - pomodoro api 
* 2004 - ping api 
* 2525 - mountebank
* 300x - mountebank imposters matching other 200x. 

### Local Proxy Server

LocalProxy/conf/proxy.conf defines the forwarding rules in the proxy

# Setup

## Environment
Set a local environment variable POMODORO_REPOS to the folder containing your Pomodoro Repos 

    $env:POMODORO_REPOS= "{0}/Repos/psgivens" -f (ls -d ~)

Link the powershell modules to the psmodule path

    $MyPSModulePath = "{0}/.local/share/powershell/Modules" -f (ls -d ~)
    mkdir -p $MyPSModulePath/PomodoroEnv
    cp -f $env:POMODORO_REPOS/PersonalTracker.Api/scripts/PomodoroEnv.psm1  $MyPSModulePath/PomodoroEnv/

Once the PomodoroEnv.psm1 is installed you can use the cmdlets to start and stop the environment. 

    Get-Command -Module PomodoroEnv

    Get-Help Build-PomDocker     
    Get-Help Connect-PomDocker   
    Get-Help Initialize-PomEnv   
    Get-Help Start-PgAdmin       
    Get-Help Start-PomDocker     
    Get-Help Start-PomDockerShell
    Get-Help Start-PomEnv        
    Get-Help Start-PomMountebank 
    Get-Help Start-PomReverse    
    Get-Help Stop-PgAdmin        
    Get-Help Stop-PomEnv         
    Get-Help Update-PomModule    


### Generate Proxies

    Start-PomEnv -Client default -Proxy
    ./scripts/run.ps1

## dotnet core projects
### Seting up dotnet core applications
Instructions for creating dotnet apps can be found at:
[aspnetcore-2.1](https://docs.microsoft.com/en-us/aspnet/core/tutorials/web-api-vsc?view=aspnetcore-2.1)

    dotnet new webapi -o Pomodoro.Api

    dotnet ef migrations add InitialMigration

    dotnet ef database update

### Setup remote debugging

Remote debugging requires the source on the server to be in sync with the source in the editor. We are going to use docker volumes to achieve this. This should work for both docker and minikube. We do not want to map our binaries because they will get locked by the server which will prevent us from building on the client. This can cause the IDE to have problems finding dependencies. Move everything which requires editing to a subfolder called src. 

In addition, we want to plan for the future for configuration files. We create two folders for this purpose. One to house general configuration, and another for secret configuration. This will allow us to inject these values from our orchastrator (Kubernetes) down the line. 

* [Installing vsdbg on the server](https://github.com/OmniSharp/omnisharp-vscode/wiki/Attaching-to-remote-processes#installing-vsdbg-on-the-server)
* [Configuring Docker attach with launch.json](https://github.com/OmniSharp/omnisharp-vscode/wiki/Attaching-to-remote-processes#configuring-docker-attach-with-launchjson)
* Move your source code (Controllers, models, etc) to a subfolder called source
* * Do include folders
* * Do include Program.cs, Startups.cs, etc
* * Do not include \*.csproj
* * Do not include autogenerated files like ef Migrate folder
* In Dockerfile, copy the root folder to appropriate like /app
* In launch commands, map your source folder to the docker container. 
* * Map 'src' folder
* * Map 'wwwroot' folder
* Map the configuration and secrets
* * config
* * secrets

# Running

* Setup infrastructure
* Take inventory
* Build
* Run containers

### Setting up the docker infrastrucutre

This infrastructure section contains common commands for these containers
* Pomodoro Postgresql Database
* pgadmin4
* Local reverse proxy

Commans for setting up the environment can be found in PomodoroEnv.psm1

Working with volumes

    # Create the volume for the database
    docker volume create pomodoro-pgsql-volume

    # Remove the volume for the database
    docker volume rm pomodoro-pgsql-volume

Working with network

    # Create the network
    docker network create --driver bridge pomodoro-net
  
Working with pgsql container

    # Build the pgsql database
    docker build -t pomodoro-pgsql -f pgsql/Dockerfile ./pgsql

    # run bash in the database container
    docker exec -it pomodoro-pgsql bash

    # alternative
    Connect-PomDocker -Container pomodoro-pgsql

    # While logged into database container
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"

    # PGADMIN_DEFAULT_EMAIL=user@domain.com
    # PGADMIN_DEFAULT_PASSWORD=Password1
    Start-PgAdmin

Some extras for the reverse proxy

    # Create and run the reverse proxy
    #
    docker build -t myrevprox -f LocalProxy/Dockerfile ./LocalProxy
    
    docker exec -it pomodoro-reverse-proxy apache2ctl restart

### Redirect traffic through mountebank for recording

* 3002 - id server
* 3003 - pomodoro api 
* 3004 - ping api 

.

    ############
    # Playing with mountebank
    ###############
    # Checkout the hardcoded imposter
    Invoke-WebRequest -Uri "http://localhost:3001"

    # Non-mock ping api service
    Invoke-RestMethod -Uri "http://localhost:2004/api/ping"

    # Mock passthrough ping api service
    Invoke-RestMethod -Uri "http://localhost:3004/api/ping"

    # Mock passthrough ping api service
    $headers = @{ 'x-mountebank'=$true }
    Invoke-RestMethod -Headers $headers -Uri "http://localhost:3003/api/ping"

    Invoke-RestMethod -Uri "http://localhost:3003/api/ping"

    # Imposter definitions
    Invoke-WebRequest -Uri "http://localhost:2525/imposters" | %{ $_.content }

    # Definition of hardcoded imposter
    Invoke-WebRequest -Uri "http://localhost:2525/imposters/3001" | %{ $_.content }

    # Definition of mock passthrough ping api service
    Invoke-WebRequest -Uri "http://localhost:2525/imposters/3004" | %{ $_.content }

Extra commands for reverse-proxy

    docker exec -it pomodoro-reverse-proxy cat /var/log/apache2/error.log

    docker exec -it pomodoro-reverse-proxy cat /var/log/apache2/access.log

### Take inventory
    clear
    docker network list | grep -E "NAME|pomodoro"
    docker volume list | grep -E "NAME|pomodoro"
    docker container list -a | grep -E "NAMES|rapi|pgadmin|pomo|dbg"

    docker image list

### Build the application containers

    # to see available images for building
    Build-PomImage -Image <tab>

    # Or build them yourself
    docker build -t pomodoro-mountebank -f Mountebank/Dockerfile Mountebank

    docker build -t pomodoro-dotnet-stage -f tools/dotnet.stage.Dockerfile tools

    docker build -t pomodoro-rapi -f Pomodoro.Api/Dockerfile Pomodoro.Api

    docker build -t pomodoro-ping-rapi -f Ping.Api/watch.Dockerfile Ping.Api

    docker build -t pomodoro-watch-rapi -f Pomodoro.Api/watch.Dockerfile Pomodoro.Api

    docker build -t pomodoro-idserver -f IdServer/watch.Dockerfile IdServer


### Use powershell to explore pomodoro-net

    docker pull mcr.microsoft.com/powershell:6.1.0-rc.1-alpine-3.8

    docker run `
      --name pomodoro-pwsh `
      --rm `
      -it `
      --network pomodoro-net `
      mcr.microsoft.com/powershell:6.1.0-rc.1-alpine-3.8 pwsh

# Kubernetes

I am not yet running these in Kubernetes.

### Working with Minikube

    minikube start

    minikube stop

### Working with Azure

    # See following for setup with gpg
    # https://github.com/psgivens/MiscellaneousLinux/blob/master/Desktop/.setup/tools.md

    # This will open a browser and ask you to log in. 
    az login
    
    $acrName = 'psgivens'
    
    # demonstrates that docker-credential-helpers/docker-pass-initialized-check is set
    pass init "269FEEBEE82FCE5D5CF361F398E8CFB1B84CAC37"  

    # The password doesn't matter, it just helps initialize the 'pass' system. 
    pass insert docker-credential-helpers/docker-pass-initialized-check 

    pass show docker-credential-helpers/docker-pass-initialized-check 

    pass show docker-credential-helpers

    docker-credential-pass list
    
    az acr login --name $acrName

    $acrCreds = az acr credential show `
      --name $acrName `
      --query "passwords[0].value"
    $acrCreds

Check out scripts/dockerAz.ps1 for more that you can do with Azure



