FROM		hauptmedia/java:oracle-java8
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		DOCKER_GID 999
ENV		BAMBOO_VERSION 5.9.0
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.34

ENV		BAMBOO_USER     	bamboo
ENV		BAMBOO_GROUP     	docker	
ENV		BAMBOO_HOME     	/var/atlassian/application-data/bamboo
ENV		BAMBOO_INSTALL_DIR	/opt/atlassian/bamboo

ENV             DEBIAN_FRONTEND noninteractive

# install needed debian packages & clean up
RUN             apt-get update && \
                apt-get install -y --no-install-recommends curl tar xmlstarlet ca-certificates git openssh-client && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# create bamboo user
RUN		mkdir -p ${BAMBOO_HOME} && \	
		useradd --home ${BAMBOO_HOME} --shell /bin/bash --comment "Bamboo User" ${BAMBOO_USER} && \
       		groupadd -g ${DOCKER_GID} docker && \
		gpasswd -a ${BAMBOO_USER} docker && \
		chown -R ${BAMBOO_USER}:${BAMBOO_GROUP} ${BAMBOO_HOME}

# change ownership of opt directory to BAMBOO_USER
RUN		chown -R ${BAMBOO_USER}:${BAMBOO_GROUP} /opt

# run the following commands with this user and group
USER		${BAMBOO_USER}:${BAMBOO_GROUP}

# download and extract bamboo & configure git
RUN             mkdir -p ${BAMBOO_INSTALL_DIR} && \
                curl -L --silent http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz | tar -xz --strip=1 -C ${BAMBOO_INSTALL_DIR} && \
                echo -e "\nbamboo.home=$BAMBOO_HOME" >> "${BAMBOO_INSTALL_DIR}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties" && \
		git config --global http.sslVerify false

# integrate mysql connector j library
RUN             curl -L --silent http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
                cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${BAMBOO_INSTALL_DIR}/lib && \
                rm -rf /tmp/*


# add docker-entrypoint.sh script
COPY            docker-entrypoint.sh ${BAMBOO_INSTALL_DIR}/bin/

# HTTP Port
EXPOSE		8085

# Remote Agent port
EXPOSE		54663

VOLUME		["${BAMBOO_INSTALL_DIR}"]

WORKDIR		${BAMBOO_INSTALL_DIR}

ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-bamboo.sh", "-fg"]
