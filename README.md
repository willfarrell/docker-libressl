# libressl

docker container to be use to load in libressl into other containers


```Dockerfile
FROM willfarrell/libressl AS libressl

FROM node:8
COPY --from=libressl /libressl/ /

...

```
