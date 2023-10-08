FROM openjdk:11
MAINTAINER ravi@gmail.com
COPY ./target/gs-spring-boot-0.1.0.jar app.jar
ENTRYPOINT java -jar app.jar
