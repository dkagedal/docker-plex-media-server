FROM ubuntu:15.04

# Install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python-yaml

# Create the plex user first with a well-known uid and gid
ENV PLEX_UID 1030
RUN adduser --system --uid $PLEX_UID --shell /bin/bash --home /var/lib/plexmediaserver --group plex

# Hack to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN touch /bin/start
RUN chmod +x /bin/start

# Add the manually downloaded deb
ADD plexmediaserver.deb /
RUN dpkg -i plexmediaserver.deb
RUN rm -f plexmediaserver.deb

# Compatibility hack
RUN mkdir /vault && ln -s /film /vault/Film
RUN rm -r /var/lib/plexmediaserver && ln -s /config /var/lib/plexmediaserver

# Hack clean-up
RUN rm -f /bin/start

VOLUME /config
VOLUME /film

USER plex

EXPOSE 32400

# the number of plugins that can run at the same time
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

# location of configuration, default is
# "${HOME}/Library/Application Support"
#ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_TMPDIR=/tmp
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp
ENV LC_CTYPE C.UTF-8

WORKDIR /usr/lib/plexmediaserver
CMD test -f /config/Plex\ Media\ Server/plexmediaserver.pid && rm -f /config/Plex\ Media\ Server/plexmediaserver.pid; \
    ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
