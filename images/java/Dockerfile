FROM oraclelinux:7-slim

LABEL maintainer="Dennis Waterham <dennis.waterham@oracle.com>"

# Location of Oracle instant client
ARG JAVA_HOME=/usr/java/jdk

# Set environment variables
ENV JAVA_HOME=$JAVA_HOME \
    PATH=$PATH:$JAVA_HOME/bin

# Change into Java Home
WORKDIR $JAVA_HOME

# Software repository base URL
ARG REPO_URL=http://localhost:8000

# Java Server JRE version
ARG JAVA_VERSION=8u211

# Install tar
RUN yum -y install tar gzip \
 && yum -y clean all \
 && rm -rf /var/cache/yum

# Install Server JRE
RUN curl -f#L "$REPO_URL/server-jre-$JAVA_VERSION-linux-x64.tar.gz" | tar -xazv --strip-components=1 \
 && echo 'networkaddress.cache.ttl=5' >>jre/lib/security/java.security \
 && java -version
