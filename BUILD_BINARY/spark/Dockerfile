FROM java:openjdk-8-jdk 

# Push Spark Binaries
RUN mkdir /sdh/
COPY spark2 /sdh/spark2 
COPY script/* /sdh/spark2/sbin/
COPY conf/* /sdh/spark2/conf/
RUN chmod 755 /sdh/spark2/sbin/*
RUN chmod 755 /sdh/spark2/bin/*

# Set Environment to log to System Out
ENV SPARK_NO_DAEMONIZE TRUE


