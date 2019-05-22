# Siebel on Docker

This repository containers the necessary Docker files, scripts and Docker Compose files to create a Siebel Enterprise from scratch, running on an Oracle database.

The minimum supported Siebel version is IP17. The install scripts will install the Siebel base version along with any 18.X or 19.X update.

## Prerequisites

To build and run this project, it is assumed you have a supported Linux OS (Oracle Linux, Red Hat, SUSE, CentOS or Ubuntu) with enough resources (disk storage, CPU, RAM) and have [Docker](https://docs.docker.com/v17.12/install/) installed already.

For convenience, Docker Compose files are provided, allowing for easy building and container orchestration. If needed, Docker Compose can be installed using [these instructions](https://docs.docker.com/compose/install/).

### Oracle Database

An existing Oracle database containing a Siebel schema is not required. If it is already available, you don't need to build the Oracle database image. In this case, simply delete or comment out the database section from the Docker compose file [`docker-compose.yaml`](docker-compose.yaml) and make sure to provide the correct database details, such as host and service name, as well as database credentials in the environment file [`siebel.env`](config/siebel.env).

When the Oracle database image is used and the Oracle database container is started, it tries to detect an existing Oracle database in [`data/oradata`](data/oradata). If no database is found, one is created automatically, after which post-install scripts are run. These scripts are stored in the [`scripts/database`](scripts/database) directory and are mapped to the correct location in the Docker Compose file. 

These scripts contain hardcoded usernames and passwords, so make any modifications, if needed, to match the values supplied in the environment files.

When configured for automatic database schema installation (`DB_INSTALL` environment variable set to `true`), a vanilla Siebel database is installed, but only when the database configuration utilities are installed (`WITH_DBSRVR` set to `true`) and a blank schema is encountered after logging in using the table owner (or schema) account (`DB_TABLEOWNER`).

### Install Files

This repository does not contain the install files to install the Oracle database or the Siebel servers. These need to be downloaded from [Oracle eDelivery](https://edelivery.oracle.com) or for the database, from [Oracle Technology Network](https://otn.oracle.com).

The latest Siebel update can be downloaded from [Oracle Support](https://support.oracle.com).

During the image build process, the install script will try to download any necessary install files from the root directory of a local web server on port 8000.

If not available, a local web server can easily be started using `python`. From the directory containing the downloaded install files, run the following command:

```
python -m SimpleHTTPServer
```

The base URL (http://localhost:8000) can be overridden by providing a value for build argument `REPO_URL` in the Docker Compose files or when running the Docker build commands manually.

To check if the web server is accessible, click the link above and it will should show you an index of the install files.

#### Java Server JRE

The version of the Java JRE that comes with the Siebel installation does not provide proper support for Docker container CPU and memory limits. Therefore, some of the images in this project depend on an updated Java JRE image.

To build the Java image, download the Java 1.8 Server JRE from [Oracle Technology Network](https://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html) for the Linux x64 platform.

At the moment, the latest update is 8u211 and the file is called:

* `server-jre-8u211-linux-x64.tar.gz`


#### Oracle Database Server

For the Oracle database, make sure to download both files for Oracle 12c Release 1 for the Linux x86-64 platform. These files are called:

* `linuxamd64_12102_database_1of2.zip`
* `linuxamd64_12102_database_2of2.zip`.

#### Oracle Database Client





#### Siebel

For Siebel, make sure you have the required files for installing Siebel IP17 base and the desired update. For both you will need the base installer file as well as any language pack you want installed. By default, the only language pack installed is English.

For a Siebel 19.4 installation in English, this means you would need to have at least the following files:

* `SBA_17.0.0.0_Base_Linux_Siebel_Enterprise_Server.jar`
* `SBA_17.0.0.0_enu_Linux_Siebel_Enterprise_Server.jar`
* `SBA_19.4.0.0.update_Base_Linux_Siebel_Enterprise_Server.jar`
* `SBA_19.4.0.0.update_enu_Linux_Siebel_Enterprise_Server.jar`


Please note that you don't need to run the Image Creator, or `snic`. The images will be created automatically during the Docker build process by extracting the JAR files into a temporary directory.

### Keystore and Truststore

The Siebel Application Interface (AI), as well as application containers run on Apache Tomcat. The application containers communicate with each other using HTTPS and therefore require Java keystores and truststores to be set up. 

This repository comes with a default keystore and truststore in the `config` directory. These stores contain a wildcard SSL certificate for the domain "`docker.local`".

These stores can be replaced by your own, make sure to adjust the domain name you used in the Docker Compose environment file [`.env`](.env) and Siebel environment file [`siebel.env`](config/siebel.env).

Location of keystore and truststore files can be adjusted by setting environment variables (`KEYSTORE` and `TRUSTSTORE`). When these variables are set, symbolic links are created in the original locations so that no other changes are required.

By default the password for both stores is set to "`changeit`". It is recommended that you keep this password, because changeing the password requires re-encryption and modifying Java property files. Automatic encryption may be added in future versions or you may alter the property files yourself. Instructions are provided on [Oracle Support](https://support.oracle.com).

For debugging any SSL issues due to possible misconfiguration of keystore or truststore, set environment variable `JAVAX_NET_DEBUG` to `all`.


## Build Docker Images

After having cloned this repository, make sure to adjust permissions for the `oradata` directory. The Oracle container runs as user Oracle and will not be able to create files inside the `oradata`

This can be done by either changing the ownership of `oradata` directory:

```
chown -R 54321:54321 data/oradata
```

or setting permissions to 777:

```
chmod -R 777 data/oradata
```

Build instructions are provided in a separate Docker Compose file. This is done because it allows to build dependent images for the final Oracle and Siebel images, such as Java Server JRE and Oracle Instant Client.

To build all required Docker images, run the following command from the directory where you cloned the repository into:

```
docker-compose -f build.yaml build
```

## Run the Project

To create the necessary networks and Docker containers, start the entire project using the following command:

```
docker-compose up
```



