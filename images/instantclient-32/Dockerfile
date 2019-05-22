FROM java/serverjre:8

LABEL maintainer="Dennis Waterham <dennis.waterham@oracle.com>"

# Location of Oracle instant client
ARG ORACLE_HOME=/usr/lib/oracle/12.1/client

# Set environment variables
ENV NLS_LANG=AMERICAN_AMERICA.AL32UTF8 \
    PATH=$PATH:$ORACLE_HOME/bin

# Change into ORACLE home
WORKDIR $ORACLE_HOME

# Names of Oracle instant client RPM files
ARG RPM_BASIC=oracle-instantclient12.1-basic-12.1.0.2.0-1.i386.rpm
ARG RPM_SQLPLUS=oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.i386.rpm

# Software repository base URL
ARG REPO_URL=http://localhost:8000

# Install necessary packages and Oracle client
RUN yum -y install libaio glibc.i686 libaio.i686 \
 && yum -y install "$REPO_URL/$RPM_BASIC" "$REPO_URL/$RPM_SQLPLUS" \
 && yum -q clean all \
 && rm -rf /var/cache/yum \
 && cd lib \
 && ln -srv libclntsh.so.12.1 libclntsh.so \
 && ln -srv libocci.so.12.1 libocci.so \
 && pwd >/etc/ld.so.conf.d/oracle-instantclient-32-12.1.conf \
 && ldconfig \
 && sqlplus -V
