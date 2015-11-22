### hybris-base-image

A base image for Hybris Commerce Suite, based on [isuper/java-oracle](https://hub.docker.com/r/isuper/java-oracle/).

Can be used Out-Of-The-Box for projects based on Hybris Commerce Suite >5.5.

The image on [DockerHub](https://hub.docker.com/r/stefanlehmann/hybris-base-image/ "DockerHub") is built automatically from the Dockerfile here.

#### Installed packages

* [gosu](https://github.com/tianon/gosu)
* lsof
* unzip
* ca-certificates
* curl
* oracle java 8 (from isuper/java-oracle)

#### User
hybris:hybris (with uid 1000)

#### How to add your code

Using a Dockerfile you can copy the output of ``ant production`` into the hybris home directory of the image.

The entrypoint script will unzip them when the container starts.

If you want you can copy unzipped content too, but this will bloat the images you push to your own repository.
	
	# copy the build packages over
	COPY hybrisServer*.zip /home/hybris/