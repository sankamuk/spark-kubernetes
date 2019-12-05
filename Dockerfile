FROM java:openjdk-8-jdk 

# Install nessesory pakage in base image
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update ; exit 0
RUN apt-get -qq install netcat

# Push Spark Binaries
RUN mkdir /sdh/
COPY BUILD_BINARY/spark2 /sdh/spark2 

# Set Environment to log to System Out
ENV SPARK_NO_DAEMONIZE TRUE


