# docker-atlassian-bamboo

Runs Atlassian Bamboo in a docker container.

If you want to use docker inside your container you should mount the docker.sock
and docker binary in the container

## Example usage
```bash
docker run -d \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker
hauptmedia/atlassian-bamboo
```
