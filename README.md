### hybris-base-image

A base image for Hybris Commerce Suite, based on **ubuntu:latest**.

Can be used Out-Of-The-Box for projects based on Hybris Commerce Suite >5.5.

**Please read this documentation directly in [GitHub](https://github.com/stefanleh/hybris-base-image "GitHub"). Otherwise the links might not work.**

The image on [DockerHub](https://hub.docker.com/r/stefanlehmann/hybris-base-image/ "DockerHub") is built automatically from the Dockerfile in the GitHub source repository.

[![](https://images.microbadger.com/badges/image/stefanlehmann/hybris-base-image.svg)](https://microbadger.com/#/images/stefanlehmann/hybris-base-image "Get your own image badge on microbadger.com")

#### Installed packages

* [gosu](https://github.com/tianon/gosu)
* lsof
* unzip
* ca-certificates
* curl
* oracle java 8 (server jre 8u121b13)

#### User

| User   | Group  | uid  | gid  |
|--------|--------|------|------|
| hybris | hybris | 1000 | 1000 |

#### Ports

| Port | Purpose            |
|------|--------------------|
| 9001 | default HTTP port  |
| 9002 | default HTTPS port |
| 8983 | default SOLR port  |
| 8000 | default DEBUG port |

The image exposes ``9001`` and ``9002`` for access to the hybris Tomcat server via HTTP and HTTPS.

Also the default Solr server port ``8983`` is exposed.
> Please be aware that in non dev environments the Solr server(s) should run in own container(s).

If you like to debug via your IDE on the running server you can use the exposed ``8000`` port.

#### Volumes
The hybris home directory `/home/hybris` is marked as volume.

#### How to add your code

Using a Dockerfile you can copy the output archives, generated using ``ant production``, into the hybris home directory of the image. The [entrypoint-script](entrypoint.sh) will unzip them when the container starts.

If you want you can copy unzipped content too, but this will bloat the images you push to your own repository.

	FROM stefanlehmann/hybris-base-image:latest
	MAINTAINER You <you.yourname@yourdomain.com>

	# copy the build packages over
	COPY hybrisServer*.zip /home/hybris/

#### Configuration support

For support of different database configurations per container the following environment variables can be set when starting a container.
They will be used to add the properties in second column to ``local.properties`` file.

| Environment variable | local.properties          								|
|----------------------|--------------------------------------------------------|
| HYBRIS_DB_URL        | db.url=$HYBRIS_DB_URL           						|
| HYBRIS_DB_DRIVER     | db.driver=$HYBRIS_DB_DRIVER     						|
| HYBRIS_DB_USER       | db.username=$HYBRIS_DB_USER    						|
| HYBRIS_DB_PASSWORD   | db.password=$HYBRIS_DB_PASSWORD 						|
| HYBRIS_DATAHUB_URL   | datahubadapter.datahuboutbound.url=$HYBRIS_DATAHUB_URL |

Of course you can also build with defaults like ``db.url=jdbc:mysql://database-container/database?useConfigs=maxPerformance&characterEncoding=utf8`` in your ``local.properties`` and use the linking functionality of docker to inject the correct container name which should be mapped to ``database-container``.

##### Clustering

For easy clustering the [entrypoint-script](entrypoint.sh) adds the property ``cluster.broadcast.method.jgroups.tcp.bind_addr`` with currently used container-IP-adress to `local.properties`.
Please be aware that this only happens on first start of the container, so when you restart the container and maybe get another ip this can lead to not working clustering.

#### How to use

As this image is just a base for running SAP Hybris you need to either copy your own production artefacts in and commit the result as your own image or mount a directory containing them.
For the latter no own images are needed.

##### Using hybris artefacts copied into image

	docker run -d --name HYBRIS_CONTAINER_NAME -p HOST_HTTP_PORT:9001 -p HOST_HTTPS_PORT:9002 REGISTRY/IMAGE:VERSION

##### Using hybris artefacts in directory on Docker host

	docker run -d --name HYBRIS_CONTAINER_NAME -p HOST_HTTP_PORT:9001 -p HOST_HTTPS_PORT:9002 -v /PATH/TO/hybris:/home/hybris stefanlehmann/hybris-base-image:latest

##### Running with debug listener enabled

	docker run -d --name HYBRIS_CONTAINER_NAME -p HOST_HTTP_PORT:9001 -p HOST_HTTPS_PORT:9002 REGISTRY/IMAGE:VERSION run debug

The important part is the ``run debug`` at the end if the line.

##### Running update system when starting a container

For automation of running the system update before starting the server you can use the environment variable `HYBRIS_UPDATE_SYSTEM=yes`.
You can find the default configuration for this in [updateRunningSystem.config](updateRunningSystem.config).

If you like to use your own configuration you can export it in HAC

![HAC Screenshot](https://github.com/stefanleh/hybris-base-image/raw/develop/documentation/images/hybris_administration_console_export_config.png)

After you got your config you can include it into your own application image via

	FROM stefanlehmann/hybris-base-image:latest
	MAINTAINER You <you.yourname@yourdomain.com>

	# copy the build packages over
	COPY hybrisServer*.zip /home/hybris/

	# copy the update system config to image
	COPY updateRunningSystem.config /home/hybris/updateRunningSystem.config

#### Hint

As the image is not intended for recompiling the hybris platform inside a container please get sure to build with following parameter in your ``local.properties`` to avoid hardcoded paths in your config artifact:

	## https://wiki.hybris.com/display/release5/ant+production+improvements#antproductionimprovements-withoutAntHowtorunhybrisserveronproductionenvironmentwithoutneedtocallanyanttarget
	## for docker we need to use the PLATFORM_HOME environment variable instead of absolute paths in server*.xml files and wrapper*.conf files
	production.legacy.mode=false
