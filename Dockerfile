# Create a build stage
FROM golang:1.20 AS build-stage
RUN apt-get update && apt-get install -y git build-essential libsecret-1-dev

# Build the bridge from source
WORKDIR /build/
COPY build.sh /build/
RUN bash build.sh

# Create the final stage
FROM debian:12

# Some environment variables
ENV TZ=America/Toronto \
    PUID=1000 \
    PGID=1000
    
VOLUME [ "/config" ]
EXPOSE 25/tcp
EXPOSE 143/tcp
    
# Copy required files
COPY init /opt/init/
RUN chmod +x /opt/init/*.sh

# Copy protonmail
COPY --from=build-stage /build/proton-bridge/bridge /protonmail/
COPY --from=build-stage /build/proton-bridge/proton-bridge /protonmail/
    
# Install required packages
RUN apt-get -y update && apt-get -y dist-upgrade \
        && apt-get install -y tini screen net-tools gnupg socat pass libsecret-1-0 ca-certificates \
        && addgroup --system docker_group && adduser --system --shell /bin/bash --home /config docker_user && usermod -g docker_group docker_user \
        && apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
        
# Enable the health check for the VPN and app
# HEALTHCHECK --interval=1m --timeout=30s --start-period=45s --start-interval=5s \
HEALTHCHECK --interval=1m --timeout=30s --start-period=30s \
  CMD /bin/bash /opt/init/health-check.sh || exit 1

# Run the container
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/init/run.sh"]

