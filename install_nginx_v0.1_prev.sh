# /bin/bash

    #sudo apt-get -y update
    #sudo apt-get -y install nginx
    #sudo service nginx start
    #echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html


    #!/bin/bash

    # user_data scripts automatically execute as root user,
    # so, no need to use sudo


      sudo apt-get update
  		sudo apt-get install -y apache2
  		sudo systemctl start apache2
  		sudo systemctl enable apache2
  		echo "<h1>Deployed Apache2 via Terraform</h1>" | sudo tee /var/www/html/index.html


    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update

    # install docker community edition
    apt-cache policy docker-ce
    apt-get install -y docker-ce

    # pull nginx image
    docker pull nginx:latest

    # run container with port mapping - host:container
    docker run -d -p 80:80 --name nginx nginx

    echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
