#! /bin/bash
ROOT_DIR="$(pwd)/.build"
OUT="$ROOT_DIR/classes"
POSTGRESQL_VERSION="42.6.0"
# set classpath

if [ ! -z ${CLASSPATH+x} ]; then
	echo "[DEBUG] previuos classpath was $CLASSPATH" 
fi
PSQL_JSBC="$ROOT_DIR/psql-jdbc/postgresql-$POSTGRESQL_VERSION.jar"
if [ -f "$PSQL_JSBC" ]; then
	if [ ! -z ${CLASSPATH+x} ]; then
		CLASSPATH="$CLASSPATH;$PSQL_JSBC;$OUT/src"
	else
		CLASSPATH="$PSQL_JSBC;$OUT/src"
	fi
else
	echo "Library not found: $PSQL_JSBC"
	exit
fi
echo "[DEBUG] new classpath is $CLASSPATH"

# build files
javac -cp $CLASSPATH -./src/Database.java -d "$OUT"
javac -cp $CLASSPATH ./src/Main.java -d "$OUT"
java -cp $CLASSPATH Main

