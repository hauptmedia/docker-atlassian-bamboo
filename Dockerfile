FROM		hauptmedia/java:oracle-java7
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		BAMBOO_VERSION 5.7.2 
ENV		MYSQL_CONNECTOR_J_VERSION 5.1.34

ENV		BAMBOO_USER     	bamboo
ENV		BAMBOO_HOME     	/var/atlassian/application-data/bamboo
ENV		BAMBOO_INSTALL_DIR	/opt/atlassian/bamboo

ENV		SENCHA_CMD_VERSION	5.1.1.39
ENV		SENCHA_CMD_FILENAME	SenchaCmd-${SENCHA_CMD_VERSION}-linux-x64
ENV		SENCHA_CMD_DOWNLOAD_URL http://cdn.sencha.com/cmd/${SENCHA_CMD_VERSION}/${SENCHA_CMD_FILENAME}.run.zip

ENV             DEBIAN_FRONTEND noninteractive
ENV		PATH /opt/Sencha/Cmd/${SENCHA_CMD_VERSION}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


# install needed debian packages & clean up
RUN             apt-get update && \
                apt-get install -y --no-install-recommends curl tar xmlstarlet ca-certificates git openssh-client && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# install PHP development dependencies
RUN             apt-get update && \
                apt-get install -y --no-install-recommends php5-cli php5-curl php5-mysql php5-xdebug php5-sqlite phpunit && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# install SenchaCmd dependencies
RUN             apt-get update && \
                apt-get install -y --no-install-recommends ruby unzip libfreetype6 libfontconfig1 && \
                apt-get clean autoclean && \
                apt-get autoremove --yes && \
                rm -rf /var/lib/{apt,dpkg,cache,log}/

# install Java/Scala dependencies
RUN             curl -L --silent https://dl.bintray.com/sbt/native-packages/sbt/0.13.7/sbt-0.13.7.tgz | tar -xz -C /opt

# create bamboo user
RUN		mkdir -p ${BAMBOO_HOME} && \
		useradd --home ${BAMBOO_HOME} --shell /bin/bash --comment "Bamboo User" ${BAMBOO_USER} && \
		chown -R ${BAMBOO_USER}:${BAMBOO_USER} ${BAMBOO_HOME}

# change ownership of opt directory to BAMBOO_USER
RUN		chown -R ${BAMBOO_USER}:${BAMBOO_USER} /opt

# run the following commands with this user and group
USER		${BAMBOO_USER}:${BAMBOO_USER}	

# download and extract bamboo & configure git
RUN             mkdir -p ${BAMBOO_INSTALL_DIR} && \
                curl -L --silent http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz | tar -xz --strip=1 -C ${BAMBOO_INSTALL_DIR} && \
                echo -e "\nbamboo.home=$BAMBOO_HOME" >> "${BAMBOO_INSTALL_DIR}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties" && \
		git config --global http.sslVerify false

# integrate mysql connector j library
RUN             curl -L --silent http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}.tar.gz | tar -xz --strip=1 -C /tmp && \
                cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_J_VERSION}-bin.jar ${BAMBOO_INSTALL_DIR}/lib && \
                rm -rf /tmp/*


# integrate SenchaCmd
RUN		curl -L --silent -o /tmp/${SENCHA_CMD_FILENAME}.run.zip ${SENCHA_CMD_DOWNLOAD_URL} && \
		unzip /tmp/${SENCHA_CMD_FILENAME}.run.zip -d /tmp && \
		chmod +x /tmp/${SENCHA_CMD_FILENAME}.run && \
		/tmp/${SENCHA_CMD_FILENAME}.run --prefix /opt --mode unattended && \
		rm -rf /tmp/*
	
# add docker-entrypoint.sh script
COPY            docker-entrypoint.sh ${BAMBOO_INSTALL_DIR}/bin/

# HTTP Port
EXPOSE		8085

# Remote Agent port
EXPOSE		54663

VOLUME		["${BAMBOO_INSTALL_DIR}"]

WORKDIR		${BAMBOO_INSTALL_DIR}

USER		root:root

ENTRYPOINT	["bin/docker-entrypoint.sh"]
CMD		["bin/start-bamboo.sh", "-fg"]
