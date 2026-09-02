FROM ubuntu:26.04

# Overwrite the base container's labels, which aren't relevant here.
LABEL org.opencontainers.image.description="https://github.com/tsuereth/steamcmd-install-app"
LABEL org.opencontainers.image.title="steamcmd-install-app"
LABEL org.opencontainers.image.created=""
LABEL org.opencontainers.image.version=""

# Install dependencies:
# - curl to download the steamcmd package.
# - lib32gcc as a runtime dependency of steamcmd.
# - locale-gen to set up a default locale for steamcmd.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt install -y curl lib32gcc-s1 locales && \
	rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

# steamcmd must run in a non-root directory, as it insists on a chdir(..) at runtime.
# (Why? ... who knows! but it sure does.)
RUN mkdir /steamcmd-workdir
WORKDIR /steamcmd-workdir

# Download and unpack the steamcmd bootstrap package.
# Ref: https://developer.valvesoftware.com/wiki/SteamCMD
RUN curl --location --fail --silent --show-error "https://client-update.steamstatic.com/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Run steamcmd once to bootstrap / self-update it.
RUN ./steamcmd.sh +login anonymous +quit

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
