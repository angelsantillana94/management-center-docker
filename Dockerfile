FROM openjdk:11.0.7-jre-slim

ARG MC_VERSION=4.2020.08
ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_JAR="hazelcast-management-center-${MC_VERSION}.jar"

# Runtime constants / variables
ENV MC_HOME="/opt/hazelcast/management-center" \
    MC_JAR="${MC_JAR}" \
    MC_DATA="/data" \
    MC_HTTP_PORT="8080" \
    MC_HTTPS_PORT="8443" \
    MC_HEALTH_CHECK_PORT="8081" \
    LOGGING_LEVEL="" \
    MC_CONTEXT_PATH="/" \
    NO_CONTAINER_SUPPORT="false" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    JAVA_OPTS="" \
    MC_INIT_SCRIPT="" \
    MC_INIT_CMD="" \
    MC_CLASSPATH="" \
    MC_ADMIN_USER="" \
    MC_ADMIN_PASSWORD=""

RUN echo "Installing wget and unzip" \
    && apt-get update \
    && apt-get install --no-install-recommends --yes wget unzip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${MC_HOME} ${MC_DATA} \
    && echo "Granting full access to ${MC_HOME} and ${MC_DATA} to allow running" \
        "container as non-root with \"docker run --user\" option" \
    && chmod a+rwx ${MC_HOME} ${MC_DATA} \
    && echo "Downloading Hazelcast Management Center" \
    && cd ${MC_HOME} \
    && wget http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP} \
    && unzip ${MC_INSTALL_ZIP} \
             -x ${MC_INSTALL_NAME}/docs/* \
             -x ${MC_INSTALL_NAME}/*.bat \
    && rm -rf ${MC_INSTALL_ZIP} \
    && mv ${MC_INSTALL_NAME}/* . \
    && rm -rf ${MC_INSTALL_NAME}

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

COPY files/mc-start.sh /mc-start.sh

# uncomment to build with local JAR
# WARNING: mc-conf.sh is used from the downloaded artifact, not from your local JAR
#COPY hazelcast-management-center-4.2020.10-SNAPSHOT.jar ${MC_HOME}/${MC_JAR}

# Start Management Center
WORKDIR ${MC_HOME}
CMD ["bash", "/mc-start.sh"]
