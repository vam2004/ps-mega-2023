#! /bin/bash
LIBDIR=".libs"
OUTDIR=".build"
POSTGRESQL_VERSION="42.6.0"
# set classpath
if [ ! -z ${CLASSPATH+x} ]; then
	echo "[DEBUG] previuos classpath was $CLASSPATH" 
fi
PSQL_JSBC="$LIBDIR/postgresql-$POSTGRESQL_VERSION.jar"
ADD_CLASSPATH="$PSQL_JSBC:$OUTDIR"
if [ -f "$PSQL_JSBC" ]; then
	if [ ! -z ${CLASSPATH+x} ]; then
		CLASSPATH="$CLASSPATH:$ADD_CLASSPATH"
	else
		CLASSPATH="$ADD_CLASSPATH"
	fi
else
	echo "Library not found: $PSQL_JSBC"
	exit
fi
echo "[DEBUG] new classpath is $CLASSPATH"

# build files
if javac -cp "$CLASSPATH" -d "$OUTDIR" database/*.java; then
	java -cp "$CLASSPATH" database.Main
fi
# javac -classpath .libs/postgresql-42.6.0.jar -d .build/ database/*.java
# java -verbose -classpath .build database.Main

