#!/bin/sh

if [ -z "$BAMBOO_HOME" ]; then
	echo Missing STASH_HOME env
	exit 1
fi

# if a DOCKER_GID was specified add the bamboo user to the docker group
if [ -n ${DOCKER_GID} ]; then
        groupadd -g ${DOCKER_GID} docker
	gpasswd -a ${BAMBOO_USER} docker 
fi

if [ -n "$CONNECTOR_PROXYNAME" ]; then
        xmlstarlet ed --inplace --delete "/Server/Service/Connector/@proxyName" $BAMBOO_INSTALL_DIR/conf/server.xml
        xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n proxyName -v $CONNECTOR_PROXYNAME $BAMBOO_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_PROXYPORT" ]; then
        xmlstarlet ed --inplace --delete "/Server/Service/Connector/@proxyPort" $BAMBOO_INSTALL_DIR/conf/server.xml
        xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n proxyPort -v $CONNECTOR_PROXYPORT $BAMBOO_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_SECURE" ]; then
        xmlstarlet ed --inplace --delete "/Server/Service/Connector/@secure" $BAMBOO_INSTALL_DIR/conf/server.xml
        xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n secure -v $CONNECTOR_SECURE $BAMBOO_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONNECTOR_SCHEME" ]; then
        xmlstarlet ed --inplace --delete "/Server/Service/Connector/@scheme" $BAMBOO_INSTALL_DIR/conf/server.xml
        xmlstarlet ed --inplace --insert "/Server/Service/Connector" --type attr -n scheme -v $CONNECTOR_SCHEME $BAMBOO_INSTALL_DIR/conf/server.xml
fi

if [ -n "$CONTEXT_PATH" ]; then
        if [ "$CONTEXT_PATH" = "/" ]; then
                CONTEXT_PATH=""
        fi

        xmlstarlet ed --inplace --delete "/Server/Service/Engine/Host/Context/@path" $BAMBOO_INSTALL_DIR/conf/server.xml
        xmlstarlet ed --inplace --insert "/Server/Service/Engine/Host/Context" --type attr -n path -v "$CONTEXT_PATH" $BAMBOO_INSTALL_DIR/conf/server.xml
fi

# configure git
git config --global http.sslVerify false

exec "$@"

