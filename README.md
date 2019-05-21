# Siebel on Docker

This repository containers the necessary Docker files, scripts and Docker Compose files to create a Siebel Enterprise from scratch, running on an Oracle database.

## Prerequisites

To build and run this project, it is assumed you have a supported Linux OS (Red Hat, SUSE, Oracle Linux, CentOS , Ubuntu or derivatives) with enough resources (disk storage, CPU, RAM) and have [Docker](https://docs.docker.com/v17.12/install/) installed already.

For convenience, Docker Compose files are provided, allowing for easy building and container orchestration. If needed, Docker Compose can be installed using [these instructions](https://docs.docker.com/compose/install/).

## Install Files

This repository does not contain the install files to install the Oracle database or the Siebel servers. These need to be downloaded from [Oracle eDelivery](https://edelivery.oracle.com) or [Oracle Technology Network](https://otn.oracle.com).

During the image build process, the install script will try to download any necessary install files from the root directory of a local web server on port 8000.

If not available, a local web server can easily be started using `python`. From the directory containing the downloaded install files, run the following command:

```
python -m SimpleHTTPServer
```

The base URL (http://localhost:8000) can be overridden by providing a value for build argument REPO_URL in the Docker Compose files or when running the Docker build commands manually.

### Oracle Database

For the Oracle database, make sure to download both files for Oracle 12c Release 1 for the Linux x86-64 platform. These files are called `linuxamd64_12102_database_1of2.zip` and `linuxamd64_12102_database_2of2.zip`.

## Build Docker Images

After having cloned this repository, make sure to adjust permissions for the `oradata` directory. The Oracle container runs as user Oracle and will not be able to create files inside the `oradata`

This can be done by either changing the ownership of `oradata` directory or setting permissions to 777:

```
chown -R 54321:54321 data/oradata
```

or

```
chmod -R 777 data/oradata
```

To build all required Docker images, run the following command from the directory where you cloned the repository into:

```
docker-compose build
```

## Run the Project

To create the necessary networks and Docker containers, start the entire project using the following command:

```
docker-compose up
```

