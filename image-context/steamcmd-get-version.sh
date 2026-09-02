#!/usr/bin/env sh

# ASSUMPTIONS:
# - steamcmd has already been installed, including a self-update check.
# - CWD is the same as the directory where `steamcmd.sh` was unpacked.
# - steamcmd's update has generated this metadata file:
#     package/steam_cmd_linux.manifest
# - This manifest file resembles JSON, but without colons!?

STEAMCMD_VERSION=$(grep '"version"' ./package/steam_cmd_linux.manifest | grep --only-matching '[0-9]*')
printf ${STEAMCMD_VERSION}
