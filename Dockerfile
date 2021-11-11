FROM ubuntu:latest as buildcontainer

ARG DEBIAN_FRONTEND=noninteractive
ENV GOSU_VERSION 1.11

# hybris needs unzip and lsof for the solr server setup
RUN    apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget \
    && apt-get install -y --install-recommends gnupg2 dirmngr

# grab gosu for easy step-down from root
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && command -v gpgconf && gpgconf --kill all || : \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu --version \
    && gosu nobody true


FROM ubuntu:latest
MAINTAINER Stefan Lehmann <stefan.lehmann@isb-ag.de>

ARG HYBRIS_HOME=/home/hybris

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/stefanleh/hybris-base-image"

ARG DEBIAN_FRONTEND=noninteractive

# hybris needs the JAVA_HOME environment variable even if java is in path
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# hybris needs unzip and lsof for the solr server setup
RUN    apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common apt-utils ca-certificates net-tools curl unzip lsof wget \
    && add-apt-repository ppa:webupd8team/java \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer  \
    && apt-get autoclean && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /usr/lib/jvm/java-8-oracle/*src.zip

# copy gosu from buildcontainer over
COPY --from=buildcontainer /usr/local/bin/gosu /usr/local/bin/gosu

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
