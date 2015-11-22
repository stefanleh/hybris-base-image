FROM isuper/java-oracle
MAINTAINER Stefan Lehmann <stefan.lehmann@unic.com>

# hybris needs unzip and lsof for the solr server setup
RUN apt-get update && apt-get install -y unzip lsof ca-certificates curl && apt-get clean

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# set the PLATFORM_HOME environment variable used by hybris
ENV PLATFORM_HOME=/home/hybris/bin/platform/
ENV PATH=$PLATFORM_HOME:$PATH
	
# add hybris user
RUN useradd -d /home/hybris -u 1000 -m -s /bin/bash hybris

# define hybris home dir as volume
VOLUME /home/hybris

# expose hybris ports
EXPOSE 9001
EXPOSE 9002

# copy the entrypoint script over
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/hybris

# set entrypoint of container
ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]