# docker-atlassian-bamboo

Runs Atlassian Bamboo in a docker container.

If you want to use docker inside your container you must mount provide the `/var/run/docker.sock`
and `/usr/bin/docker` files in the container and specify the docker group id via the DOCKER_GID env variable.

## Example usage
```bash
docker run -d \
-e DOCKER_GID=999 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker:ro \
hauptmedia/atlassian-bamboo
```

## Included build tools
* gcc, g++, (build-essentials)
* SenchaCmd (/opt/SenchaCmd/sencha)
* PHP
* Ruby
* NodeJS
* Grunt
* Apidoc
