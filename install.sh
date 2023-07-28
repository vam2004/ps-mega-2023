POSTGRESQL_JDBC_VERSION=42.6.0
POSTGRESQL_JDBC_HASH=b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461
POSTGRESQL_JDBC_SIZE=1081604
INSTALL_DOWNLOAD_CACHE=".dynimport"

main() {
mkdir -p .build;
mkdir -p .libs;
if [ ! -d "$INSTALL_DOWNLOAD_CACHE" ]; then
	echo "Error: Cannot find the cache";
	return 1;
fi
local FILENAME="postgresql-$POSTGRESQL_JDBC_VERSION.jar";
local MIRROR="https://jdbc.postgresql.org/download";
local URL="$MIRROR/$FILENAME";
local PERMPATH=".libs/$FILENAME";
./download_and_check.sh "$URL" "$PERMPATH" "$POSTGRESQL_JDBC_HASH" "$POSTGRESQL_JDBC_SIZE" "$INSTALL_DOWNLOAD_CACHE";
}

main
