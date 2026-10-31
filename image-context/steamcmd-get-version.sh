#!/usr/bin/env sh

if [ -z "${STEAM_DATADIR}" ]; then
	STEAM_DATADIR=${HOME}/Steam
	echo STEAM_DATADIR was undefined, defaulting to ${STEAM_DATADIR}
fi

# ASSUMPTIONS:
# - steamcmd has already been installed, including a self-update check.
# - steamcmd metadata files are in the location noted by $STEAMCMD_DATADIR
# - Within that location, steamcmd updates generated this file:
#     package/steam_cmd_linux.manifest
# - This manifest file resembles JSON, but without colons!?

STEAMCMD_DATADIR=${STEAM_DATADIR}/steamcmd
STEAMCMD_VERSION=$(grep '"version"' ${STEAMCMD_DATADIR}/package/steam_cmd_linux.manifest | grep --only-matching '[0-9]*')
printf ${STEAMCMD_VERSION}
