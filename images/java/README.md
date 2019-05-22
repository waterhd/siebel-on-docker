# Java Server JRE
Docker files for installing Java Server JRE.

This image depends on a web server for downloading the necessary files.

One can easily be started using `python`, serving content from the current directory on port 8000:

```
python -m SimpleHTTPServer &
```

When the Docker engine and web server are both running on the local host, it's easiest to build in 'host' network mode:

```
docker build --network=host ...
```    

An alternative web server location can be specified using the REPO_URL build argument, e.g.:

```
docker build ... --build-arg "REPO_URL=http://webserver/path/to/install/files" .
```
