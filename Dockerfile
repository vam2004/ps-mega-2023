FROM eclipse-temurin:latest
COPY . /home/developer/
WORKDIR /home/developer
#RUN apk --no-cache add curl;  
RUN mkdir .dynimport && ./install.sh;
# postgres:alpine3.18 | postgres:lastest
ENTRYPOINT /bin/sh
