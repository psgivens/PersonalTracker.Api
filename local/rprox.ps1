


$myip = (hostname -I).split(' ') | ?{ $_ -match '^192' }


docker run -it --rm --add-host="localhost:$myip" -p 8080:80 httpd /bin/bash

docker run -it --rm --add-host="localhost:$myip" -p 8080:80 rgoyard/apache-proxy /bin/bash

docker container stop my_reverse_proxy 
docker  build -t myrevprox local/Dockerfile ./local
sudo docker run `
  --name my_reverse_proxy `
  -d `
  --rm `
  --add-host="localhost:$myip" `
  -p 80:80 `
  myrevprox 

  /bin/bash


docker container stop my_reverse_proxy 


