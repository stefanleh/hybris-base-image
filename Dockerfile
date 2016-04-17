FROM ubuntu:latest
MAINTAINER Stefan Lehmann <stefan.lehmann@unic.com>

ENV VERSION 8
ENV UPDATE 77
ENV BUILD 03

ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

# hybris needs unzip and lsof for the solr server setup
RUN apt-get update && apt-get install ca-certificates curl unzip lsof -y && \
        curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
        --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/server-jre-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz \
        | tar xz -C /tmp && \
        mkdir -p /usr/lib/jvm && mv /tmp/jdk1.${VERSION}.0_${UPDATE} "${JAVA_HOME}" && \
        apt-get autoclean && apt-get --purge -y autoremove && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set oracle jre as default java
RUN update-alternatives --install "/usr/bin/java" "java" "${JRE_HOME}/bin/java" 1 && \
        update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
        update-alternatives --set java "${JRE_HOME}/bin/java" && \
        update-alternatives --set javac "${JAVA_HOME}/bin/javac"
        
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
