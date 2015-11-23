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
* oracle java 8 (server jre 8u66b17)

#### User
hybris:hybris (with uid 1000)

#### Ports
The image exposes ``9001`` and ``9002`` for access to the hybris Tomcat server via HTTP and HTTPS.

#### How to add your code

Using a Dockerfile you can copy the output of ``ant production`` into the hybris home directory of the image.

The entrypoint script will unzip them when the container starts.

If you want you can copy unzipped content too, but this will bloat the images you push to your own repository.

	FROM stefanlehmann/hybris-base-image:latest
	MAINTAINER You <you.yourname@yourdomain.com>

	# copy the build packages over
	COPY hybrisServer*.zip /home/hybris/

#### Hint

As the image is not intended for recompiling the hybris platform inside a container please get sure to build with following parameter in your ``local.properties`` to avoid hardcoded paths in your config artifact:

	
	## https://wiki.hybris.com/display/release5/ant+production+improvements#antproductionimprovements-withoutAntHowtorunhybrisserveronproductionenvironmentwithoutneedtocallanyanttarget
	## for docker we need to use the PLATFORM_HOME environment variable instead of absolute paths in server*.xml files and wrapper*.conf files
	production.legacy.mode=false