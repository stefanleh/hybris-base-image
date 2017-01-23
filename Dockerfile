FROM ubuntu:latest
MAINTAINER Stefan Lehmann <stefan.lehmann@unic.com>

ENV VERSION 8
ENV UPDATE 121
ENV BUILD 13

ENV GOSU_VERSION 1.9

ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

# hybris needs unzip and lsof for the solr server setup
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates net-tools curl unzip lsof wget \
    && curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
       --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
       http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/e9e7ea248e2c4826b92b3f075a80e441/server-jre-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz \
       | tar xz -C /tmp \
    && mkdir -p /usr/lib/jvm && mv /tmp/jdk1.${VERSION}.0_${UPDATE} "${JAVA_HOME}" \
    && apt-get autoclean && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set oracle jre as default java
RUN update-alternatives --install "/usr/bin/java" "java" "${JRE_HOME}/bin/java" 1 \
    && update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 \
    && update-alternatives --set java "${JRE_HOME}/bin/java" \
    && update-alternatives --set javac "${JAVA_HOME}/bin/javac"

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
ENV PLATFORM_HOME=/home/hybris/bin/platform/
ENV PATH=$PLATFORM_HOME:$PATH

# add hybris user
RUN useradd -d /home/hybris -u 1000 -m -s /bin/bash hybris

# define hybris home dir as volume
VOLUME /home/hybris

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
COPY updateRunningSystem.config /home/hybris/updateRunningSystem.config

WORKDIR /home/hybris

# set entrypoint of container
ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]
