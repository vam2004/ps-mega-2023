#! /bin/bash

# set classpath

if [ ! -z ${CLASSPATH+x} ]; then
	echo "[DEBUG] previuos classpath was $CLASSPATH" 
fi
JAVA_POSTGRESQL_PATH="$(pwd)/psql-jdbc/"
if [ -d "$JAVA_POSTGRESQL_PATH" ]; then
	if [ ! -z ${CLASSPATH+x} ]; then
		CLASSPATH=$CLASSPATH:$JAVA_POSTGRESQL_PATH
	else
		CLASSPATH=$JAVA_POSTGRESQL_PATH
	fi
else
	echo "Invalid Working Directory: $JAVA_POSTGRESQL_PATH"
	exit
fi
echo "[DEBUG] new classpath is $CLASSPATH"

# build files
