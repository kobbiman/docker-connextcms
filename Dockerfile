#Creates a ConnextCMS/KeystoneJS installation in Ubuntu container with user/password connextcms/password
#This version of the Dockerfile leverages a pre-built git hub repository that is faster and lighter
#weight than building KeystoneJS from source.

#INSTRUCTIONS
#Build docker image as 'connextcms':
#docker build -t connextcms .

#Run the MongoDB image
#Map port 27017 on the image to 3500 on the host.
#docker run --name mongo -d -p 3500:27017 --rm -v <your path>/db:/data/db mongo

#Execute my keystonejs docker image
#docker container run --name connextcms --link mongo:mongo -v <your path>/theme:/home/connextcms/theme --rm -it connextcms bash


#IMAGE BUILD COMMANDS
FROM ubuntu:16.10
MAINTAINER Chris Troutner <chris.troutner@gmail.com>

#Update the OS and install any OS packages needed.
RUN apt-get update
RUN apt-get install -y sudo

#Create the user 'connextcms' and add them to the sudo group.
RUN useradd -ms /bin/bash connextcms
RUN adduser connextcms sudo

#Set password to 'password' change value below if you want a different password
RUN echo connextcms:password | chpasswd

#Set the working directory to be the connextcms home directory
WORKDIR /home/connextcms

#Install KeystoneJS Dependencies
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y nano
#RUN apt-get install -y make
#RUN apt-get install -y g++
RUN apt-get install -y python

#Install Node and NPM
RUN curl -sL https://deb.nodesource.com/setup_4.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential
#RUN npm install -g npm

#Give node.js permission to run on port 80
RUN apt-get install libcap2-bin
RUN setcap cap_net_bind_service=+ep /usr/bin/nodejs

#Create a volume for persisting MongoDB data.
VOLUME /data/db

#Log into the shell as the newly created user
USER connextcms

#Create a directory for customizing the new site.
VOLUME /home/connextcms/theme
VOLUME /home/connextmcs/plugins

#Clone the keystone files.
RUN git clone https://github.com/skagitpublishing/keystone4-compiled
RUN mv keystone4-compiled keystone4
#WORKDIR /home/connextcms/keystone4/node_modules/keystone
#RUN npm install
#WORKDIR /home/connextcms

#Clone ConnextCMS
RUN git clone https://github.com/skagitpublishing/ConnextCMS
RUN mv ConnextCMS connextCMS

#Clone plugins
#RUN git clone https://github.com/skagitpublishing/plugin-template-connextcms

COPY finalsetup finalsetup
COPY keystone.js keystone.js
RUN echo 'password' | sudo -S pwd
RUN sudo chmod 775 finalsetup
RUN ./finalsetup

#Installation is buggy.
#RUN sudo npm install -g node-inspector

#Clean up files
RUN rm -f finalsetup /theme/
RUN rm -f keystone.js
RUN rm -f nodesource_setup.sh

WORKDIR /home/connextcms/myCMS

EXPOSE 80

CMD ["node", "keystone.js"]
