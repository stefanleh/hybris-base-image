#!/bin/bash

export DOCKER_CONTAINER_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

if [ "$1" = 'run' ]; then

    if [ ! -d "/home/hybris/bin" ]; then

        cd /home/hybris

        # unzip the artifacts created by production ant target
        echo "Unzipping hybris production archives ..."
        for z in hybrisServer*.zip; do unzip $z -d /home ; done

        # add container ip to cluster configuration of hybris instance
        echo "cluster.broadcast.method.jgroups.tcp.bind_addr=$DOCKER_CONTAINER_IP" >> config/local.properties

        # add database properties passed as environment variables
        if [ ! -z "$HYBRIS_DB_URL" ]; then
            echo "db.url=$HYBRIS_DB_URL" >> config/local.properties
        fi
        if [ ! -z "$HYBRIS_DB_DRIVER" ]; then
            echo "db.driver=$HYBRIS_DB_DRIVER" >> config/local.properties
        fi
        if [ ! -z "$HYBRIS_DB_USER" ]; then
            echo "db.username=$HYBRIS_DB_USER" >> config/local.properties
        fi
        if [ ! -z "$HYBRIS_DB_PASSWORD" ]; then
            echo "db.password=$HYBRIS_DB_PASSWORD" >> config/local.properties
        fi

        # add datahub properties passed as environment variables
        if [ ! -z "$HYBRIS_DATAHUB_URL" ]; then
            echo "datahubadapter.datahuboutbound.url=$HYBRIS_DATAHUB_URL" >> config/local.properties
        fi

    fi

    cd ${PLATFORM_HOME}

    # fix ownership of files
    chown -R hybris /home/hybris
    chmod +x hybrisserver.sh

    # if initialize system is wanted we do it before starting the hybris server
    if [ "$HYBRIS_INITIALIZE_SYSTEM" = "yes" ]; then
        # set ant environment
    	source ./setantenv.sh
    	# run hybris update with predefined config and without rebuilding
    	gosu hybris ant initialize -Dde.hybris.platform.ant.production.skip.build=true 
    fi

    # if update system is wanted we do it before starting the hybris server
    if [ "$HYBRIS_UPDATE_SYSTEM" = "yes" ]; then
    	# set ant environment
    	source ./setantenv.sh
    	# run hybris update with predefined config
    	gosu hybris ant updatesystem -DconfigFile=/home/hybris/updateRunningSystem.config
    fi

    # run hybris commerce suite as user hybris
    exec gosu hybris ./hybrisserver.sh $2

fi

exec "$@"
