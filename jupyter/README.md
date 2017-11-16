Ubuntu Docker file for Julia

Version:v0.6.0

to build;

```docker build -t julia:0.6.0 Dockerfile```

to run (change ```/tmp/julia``` to a host dir);

```docker run -d -rm -p 8888:8888 -v /tmp/julia:/home/julia julia:0.6.0```
