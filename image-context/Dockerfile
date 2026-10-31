FROM ghcr.io/steamcmd/steamcmd:ubuntu-26

# Overwrite the base container's labels, which aren't relevant here.
LABEL org.opencontainers.image.description="https://github.com/tsuereth/steamcmd-install-app"
LABEL org.opencontainers.image.title="steamcmd-install-app"
LABEL org.opencontainers.image.created=""
LABEL org.opencontainers.image.version=""

# This file path to Steam/steamcmd metadata is
# based on the parent image's installation steps.
ENV STEAM_DATADIR=/root/.local/share/Steam

# Run steamcmd once to bootstrap / self-update it.
RUN steamcmd +login anonymous +quit

# Create a volume for installing an app with steamcmd.
# Install an app to this volume on the host like:
#   docker run --rm -v myapp-volume:/install-dir-volume steamcmd-install-app MYAPPID
# Then use the installed application in another container like:
#   docker run -v myapp-volume:/myapp ubuntu
ENV APP_INSTALL_DIR=/install-dir-volume
VOLUME $APP_INSTALL_DIR

COPY steamcmd-get-version.sh /
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD []
