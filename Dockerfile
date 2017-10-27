FROM solr:6.6-alpine

# Resetting value set in the parent image
USER root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update-cache --no-cache \
            bash \
            git \
            maven \
            openjdk8 \
            openssh
COPY ./mmd-schema/brainz-mmd2-jaxb brainz-mmd2-jaxb
RUN cd brainz-mmd2-jaxb && \
    mvn install

COPY ./mb-solrquerywriter mb-solrquerywriter
RUN cd mb-solrquerywriter && \
    mvn package -DskipTests

USER $SOLR_USER

ENV SOLR_HOME /opt/solr/server/solr

RUN mkdir -p $SOLR_HOME/mycores
COPY ./mbsssss $SOLR_HOME/mycores

RUN mkdir $SOLR_HOME/data
VOLUME $SOLR_HOME/data

RUN mkdir -p /opt/solr/lib && \
    cp target/solrwriter-0.0.1-SNAPSHOT-jar-with-dependencies.jar /opt/solr/lib
USER $SOLR_USER
# Pointing default Solr config to our shared lib directory
RUN sed -i'' 's|</solr>|<str name="sharedLib">/opt/solr/lib</str></solr>|' \
        /opt/solr/server/solr/solr.xml
