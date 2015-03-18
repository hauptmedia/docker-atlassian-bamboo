# docker-atlassian-bamboo

Runs Atlassian Bamboo in a docker container.

If you want to use docker inside your container you must mount provide the `/var/run/docker.sock`
and `/usr/bin/docker` files in the container.

## Example usage
```bash
docker run -d \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker:ro \
hauptmedia/atlassian-bamboo
```
