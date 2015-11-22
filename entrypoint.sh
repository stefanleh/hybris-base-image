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
		
	fi

	cd ${PLATFORM_HOME}

	chown -R hybris /home/hybris
	chmod +x hybrisserver.sh
	
	# run hybris commerce suite as user hybris
	exec gosu hybris ./hybrisserver.sh $@

fi

exec "$@"
