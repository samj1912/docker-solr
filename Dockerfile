FROM solr:6.5-alpine

# Resetting value set in the parent image
USER root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update-cache --no-cache \
            bash \
            git \
            maven \
            openjdk8 \
            openssh

USER $SOLR_USER

RUN git clone https://github.com/metabrainz/mbsssss.git /opt/solr/server/solr/mycores/mbsssss
RUN git clone https://github.com/metabrainz/mmd-schema.git /tmp/mmd-schema && \
    cd /tmp/mmd-schema/brainz-mmd2-jaxb && \
    mvn install && \
    rm -rf /tmp/mmd-schema
RUN git clone https://github.com/metabrainz/mb-solrquerywriter.git /tmp/querywriter && \
    cd /tmp/querywriter && \
    rm -rf /tmp/querywriter/mbsssss && \
    ln -s /opt/solr/server/solr/mycores/mbsssss /tmp/querywriter/mbsssss && \
    mvn package && \
    cp target/solrwriter-0.0.1-SNAPSHOT-jar-with-dependencies.jar /opt/solr/server/solr/mycores/mbsssss/lib && \
    rm -rf /tmp/querywriter

# Pointing default Solr config to our shared lib directory
RUN sed -i'' 's|</solr>|<str name="sharedLib">/opt/solr/server/solr/mycores/mbsssss/lib</str></solr>|' \
        /opt/solr/server/solr/solr.xml

WORKDIR /opt/solr
