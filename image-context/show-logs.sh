#!/usr/bin/env sh

echo Showing log files in ${HOME}/Steam/logs/
echo ---

for LOGFILE in $(find ${HOME}/Steam/logs/ -type f); do
	echo ${LOGFILE}
	echo ---
	cat ${LOGFILE}
	echo ---
done

echo Done showing log files
