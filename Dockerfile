FROM ubuntu:latest
MAINTAINER Stefan Lehmann <stefan.lehmann@oxaion.de>

ENV VERSION 8
ENV UPDATE 161
ENV BUILD 12

ENV GOSU_VERSION 1.9

ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

ARG HYBRIS_HOME=/home/hybris

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/stefanleh/hybris-base-image"

# accept the oracle java licence (must be done before install)
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# hybris needs unzip and lsof for the solr server setup
RUN    apt-get update \ 
    && add-apt-repository ppa:webupd8team/java \
    && apt-get update \ 
    && apt-get install -y oracle-java8-installer ca-certificates net-tools curl unzip lsof wget \
    && apt-get autoclean && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# grab gosu for easy step-down from root
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# set the PLATFORM_HOME environment variable used by hybris
ENV PLATFORM_HOME=${HYBRIS_HOME}/bin/platform/
ENV PATH=$PLATFORM_HOME:$PATH
ENV HYBRIS_HOME=${HYBRIS_HOME}

# add hybris user
RUN useradd -d ${HYBRIS_HOME} -u 1000 -m -s /bin/bash hybris

# define hybris home dir as volume
VOLUME ${HYBRIS_HOME}

# expose hybris ports
EXPOSE 9001
EXPOSE 9002

# expose default solr port
EXPOSE 8983

# expose the default debug port for connecting via IDE
EXPOSE 8000

# copy the entrypoint script over
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# copy the update system config to image
COPY updateRunningSystem.config ${HYBRIS_HOME}/updateRunningSystem.config

WORKDIR ${HYBRIS_HOME}

# set entrypoint of container
ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]
