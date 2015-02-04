FROM		hauptmedia/java:oracle-java7
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		BAMBOO_VERSION 5.7.2 
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.34

ENV		BAMBOO_HOME     	/var/atlassian/application-data/bamboo
ENV		BAMBOO_INSTALL_DIR	/opt/atlassian/bamboo

ENV		RUN_USER            daemon
ENV		RUN_GROUP           daemon

ENV             DEBIAN_FRONTEND noninteractive

# install needed debian packages & clean up
RUN             apt-get update && \
                apt-get install -y --no-install-recommends curl tar xmlstarlet ca-certificates git php5-cli php5-curl php5-mysql phpunit && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# download and extract bamboo 
RUN             mkdir -p ${BAMBOO_INSTALL_DIR} && \
                curl -L --silent http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz | tar -xz --strip=1 -C ${BAMBOO_INSTALL_DIR} && \
                echo -e "\nbamboo.home=$BAMBOO_HOME" >> "${BAMBOO_INSTALL_DIR}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties" && \
                chown -R ${RUN_USER}:${RUN_GROUP} ${BAMBOO_INSTALL_DIR}

# integrate mysql connector j library
RUN             curl -L --silent http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
                cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${BAMBOO_INSTALL_DIR}/lib && \
                rm -rf /tmp/*

# add docker-entrypoint.sh script
COPY            docker-entrypoint.sh ${BAMBOO_INSTALL_DIR}/bin/

USER		${RUN_USER}:${RUN_GROUP}	

# HTTP Port
EXPOSE		8085

# Remote Agent port
EXPOSE		54663

VOLUME		["${BAMBOO_INSTALL_DIR}"]

WORKDIR		${BAMBOO_INSTALL_DIR}

ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-bamboo.sh", "-fg"]
