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
RUN cd ..
COPY ./mb-solrquerywriter mb-solrquerywriter
RUN cd mb-solrquerywriter && \
    mvn package -DskipTests

ENV SOLR_HOME /opt/solr/server/solr

RUN mkdir -p $SOLR_HOME/mycores
COPY ./mbsssss $SOLR_HOME/mycores/mbsssss

RUN mkdir -p /opt/solr/lib && \
    cp mb-solrquerywriter/target/solrwriter-0.0.1-SNAPSHOT-jar-with-dependencies.jar /opt/solr/lib
# Pointing default Solr config to our shared lib directory
RUN sed -i'' 's|</solr>|<str name="sharedLib">/opt/solr/lib</str></solr>|' \
        /opt/solr/server/solr/solr.xml
RUN mkdir $SOLR_HOME/data
RUN chown -R solr:solr /opt/solr
USER solr