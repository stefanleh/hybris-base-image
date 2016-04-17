### hybris-base-image

[![](https://badge.imagelayers.io/stefanlehmann/hybris-base-image:latest.svg)](https://imagelayers.io/?images=stefanlehmann/hybris-base-image:latest 'Get your own badge on imagelayers.io')

A base image for Hybris Commerce Suite, based on **ubuntu:latest**.

Can be used Out-Of-The-Box for projects based on Hybris Commerce Suite >5.5.

The image on [DockerHub](https://hub.docker.com/r/stefanlehmann/hybris-base-image/ "DockerHub") is built automatically from the Dockerfile here.

#### Installed packages

* [gosu](https://github.com/tianon/gosu)
* lsof
* unzip
* ca-certificates 
* curl 
* oracle java 8 (server jre 8u77b03)

#### User
hybris:hybris (with uid 1000)

#### Ports
The image exposes ``9001`` and ``9002`` for access to the hybris Tomcat server via HTTP and HTTPS.

#### Volumes
The hybris home directory `/home/hybris` is marked as volume.

#### How to add your code

Using a Dockerfile you can copy the output of ``ant production`` into the hybris home directory of the image.

The entrypoint script will unzip them when the container starts.

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

#### How to use

As this image is just a base for running SAP Hybris you need to either copy your own production artefacts in and commit the result as your own image or mount a directory containing them.
For the latter no own images are needed.

##### Using hybris artefacts copied into image

	docker run -d --name HYBRIS_CONTAINER_NAME -p HOST_HTTP_PORT:9001 -p HOST_HTTPS_PORT:9002 REGISTRY/IMAGE:VERSION

##### Using hybris artefacts in directory on Docker host

	docker run -d --name HYBRIS_CONTAINER_NAME -p HOST_HTTP_PORT:9001 -p HOST_HTTPS_PORT:9002 -v /PATH/TO/hybris:/home/hybris stefanlehmann/hybris-base-image:latest

#### Hint

As the image is not intended for recompiling the hybris platform inside a container please get sure to build with following parameter in your ``local.properties`` to avoid hardcoded paths in your config artifact:

	
	## https://wiki.hybris.com/display/release5/ant+production+improvements#antproductionimprovements-withoutAntHowtorunhybrisserveronproductionenvironmentwithoutneedtocallanyanttarget
	## for docker we need to use the PLATFORM_HOME environment variable instead of absolute paths in server*.xml files and wrapper*.conf files
	production.legacy.mode=false
