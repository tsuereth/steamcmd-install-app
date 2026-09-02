#!/usr/bin/env sh

# Check that the first command-line argument STEAM_APP_ID only contains numeric digits.
STEAM_APP_ID=$1
if [ -z "${STEAM_APP_ID}" ]; then
	echo Usage error: missing required argument for STEAM_APP_ID.
	exit 1
fi
if [ -z "${STEAM_APP_ID##*[!0-9]*}" ]; then
	echo Usage error: a non-numeric STEAM_APP_ID was provided.
	exit 1
fi

# Check an optional ENV variable for setting uid+gid ownership of the installed application.
if [ ! -z "${CHOWN_UID_GID}" ]; then
	CHOWN_UID="${CHOWN_UID_GID%:*}" # substring without ":..."
	CHOWN_GID=
	if [ "${CHOWN_UID}" != "${CHOWN_UID_GID}" ]; then
		CHOWN_GID="${CHOWN_UID_GID#*:}" # substring without "...:"
	fi
	# Validate that if a UID was provided, it only contains numeric digits.
	if [ ! -z "${CHOWN_UID}" ] && [ -z "${CHOWN_UID##*[!0-9]*}" ]; then
		echo Usage error: a non-numeric UID was provided in CHOWN_UID_GID
		exit 1
	fi
	# Validate that if a GID was provided, it only contains numeric digits.
	if [ ! -z "${CHOWN_GID}" ] && [ -z "${CHOWN_GID##*[!0-9]*}" ]; then
		echo Usage error: a non-numeric GID was provided in CHOWN_UID_GID
		exit 1
	fi
fi

if [ ! -d "${APP_INSTALL_DIR}" ]; then
	echo Creating installation directory: ${APP_INSTALL_DIR}
	mkdir -p ${APP_INSTALL_DIR}
fi

# steamcmd should already have been installed, and its wrapper script
# `steamcmd.sh` should be available in the current working directory.
# If not, then the environment has been screwed up somehow!
if [ ! -x "./steamcmd.sh" ]; then
	echo Unexpected error: ./steamcmd.sh is not executable
	exit 255
fi

# Often, a steam service error will block an app-update check, but
# steamcmd will "recover" by canceling the check and exiting successfully.
# We need to look at steam's content_log to verify that it actually worked;
# and if it DIDN'T work, try again (hopefully overcoming a temporary outage).
ATTEMPT_MAX=5
ATTEMPT_NUM=0
ATTEMPT_SUCCEEDED=false
while [ $ATTEMPT_NUM -lt $ATTEMPT_MAX ]; do
	ATTEMPT_NUM=$(( ATTEMPT_NUM + 1 ))
	ATTEMPT_TIMESTAMP=$(date +%s)
	echo Beginning attempt $ATTEMPT_NUM of $ATTEMPT_MAX

	STEAMCMD_INSTALLARGS="+force_install_dir ${APP_INSTALL_DIR} +login anonymous +app_update ${STEAM_APP_ID} validate +quit"
	echo Running steamcmd with arguments: ${STEAMCMD_INSTALLARGS}
	./steamcmd.sh ${STEAMCMD_INSTALLARGS}

	CONTENT_LOG_FILEPATH=${HOME}/Steam/logs/content_log.txt
	if [ ! -f "${CONTENT_LOG_FILEPATH}" ]; then
		echo No content log file found at ${CONTENT_LOG_FILEPATH}
		continue
	fi
	CONTENT_LOG_TIMESTAMP=$(date -r ${CONTENT_LOG_FILEPATH} +%s)
	if [ $CONTENT_LOG_TIMESTAMP -lt $ATTEMPT_TIMESTAMP ]; then
		echo Missing new content log messages at ${CONTENT_LOG_FILEPATH}
		continue
	fi
	INSTALL_RESULT_LOGLINE=$(grep "AppID ${STEAM_APP_ID} scheduler finished" ${CONTENT_LOG_FILEPATH} | tail -1)
	if [ -z "${INSTALL_RESULT_LOGLINE}" ]; then
		echo Missing results for app ID ${STEAM_APP_ID} in ${CONTENT_LOG_FILEPATH}
		continue
	fi
	INSTALL_RESULT_NOERROR=$(printf %s "${INSTALL_RESULT_LOGLINE}" | grep '(result No Error,')
	if [ -z "${INSTALL_RESULT_NOERROR}" ]; then
		echo Non-success result: ${INSTALL_RESULT_LOGLINE}
		continue
	fi

	# If all the above checks succeeded, then FINALLY, we've confirmed the install/update.
	ATTEMPT_SUCCEEDED=true
	break
done
if [ $ATTEMPT_SUCCEEDED = false ]; then
	echo Unable to install app after ${ATTEMPT_MAX} attempts
	exit 255
fi

if [ ! -z "${CHOWN_UID_GID}" ]; then
	echo Changing ownership of ${APP_INSTALL_DIR} to ${CHOWN_UID_GID}
	chown -R ${CHOWN_UID_GID} ${APP_INSTALL_DIR}
fi
