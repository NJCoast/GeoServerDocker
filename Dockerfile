FROM tomcat:9-jre8
MAINTAINER GeoNode Development Team

#
# Set GeoServer version and data directory
#
ENV GEOSERVER_VERSION=2.10.x
ENV GEOSERVER_DATA_DIR="/geoserver_data/data"

#
# Download and install GeoServer
#
RUN cd /usr/local/tomcat/webapps \
    && wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/geoserver-${GEOSERVER_VERSION}.war \
    && unzip -q geoserver-${GEOSERVER_VERSION}.war -d geoserver \
    && rm geoserver-${GEOSERVER_VERSION}.war \
    && mkdir -p $GEOSERVER_DATA_DIR 

# Install Patch
RUN apt-get update && \
    apt-get install -y --no-install-recommends git libgeos-dev libproj-dev && \
    ln -s /usr/lib/x86_64-linux-gnu/libproj.so /usr/lib/libproj.so.0 && \
    rm -rf /var/lib/apt/lists/* && \
    printf "\norg.apache.catalina.startup.ContextConfig.jarsToSkip=bcprov*.jar" >> /usr/local/tomcat/conf/catalina.properties

VOLUME $GEOSERVER_DATA_DIR

# copy the script and perform the change to config.xml
RUN mkdir -p /usr/local/tomcat/tmp
WORKDIR /usr/local/tomcat/tmp

COPY entrypoint.sh /usr/local/tomcat/tmp/entrypoint.sh
RUN chmod +x /usr/local/tomcat/tmp/entrypoint.sh
CMD ["/usr/local/tomcat/tmp/entrypoint.sh"]