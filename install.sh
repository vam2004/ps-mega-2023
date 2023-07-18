ROOT_DIR="$(pwd)/build"
POSTGRESQL_VERSION=42.6.0
POSTGRESQL_HASH=b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461
POSTGRESQL_DIR="$ROOT_DIR/psql-jdbc"
if [ -d "$ROOT_DIR/downloads" ]; then 
	echo "[DEBUG] already downloaded"
	exit
else
	mkdir "$ROOT_DIR/downloads" || exit
	mkdir "$ROOT_DIR/psql-jdbc" || exit
fi
download_link() {
	if [ -f "$3" ]; then
		echo "[DEBUG] skipping installation of '$3'"
	else
		echo "[DEBUG] downloading from '$1'"
		local tmpfile="$ROOT_DIR/downloads/$2.tmp"
		echo "[DEBUG] downloading into '$2.tmp'"
		if [ -f "$tmpfile" ]; then
			echo "[DEBUG] skipping download"
		else
			curl "$1" -o "$tmpfile"	--silent
		fi
		echo "[DEBUG] verifying download"
		local hash=$(sha256sum "$tmpfile" | cut -d " " -f1)
		if [ "$hash" == "$2" ]; then
			echo "[DEBUG] download verified!"
			echo "[DEBUG] cloning into '$3'"
			cp "$tmpfile" "$3" || exit
		else
			echo "[ERROR] corrupted file found: '$tmpfile'"
			exit
		fi
	fi
}
# download postgresql
if [ -d $POSTGRESQL_DIR ]; then
	FILENAME="postgresql-$POSTGRESQL_VERSION.jar"
	MIRROR="https://jdbc.postgresql.org/download"
	download_link "$MIRROR/$FILENAME" "$POSTGRESQL_HASH" "$POSTGRESQL_DIR/$FILENAME"
else
	echo "Invalid Working Directory: $(pwd)"
fi	
# verify javac version
JAVAC_VERSION=$(javac --version | cut -d " " -f2)
JAVAC_MAJOR_VERSION=$(echo $JAVAC_VERSION | cut -d "." -f1)
if (( $JAVAC_MAJOR_VERSION > 8 )); then
	echo "[DEBUG] javac version: $JAVAC_VERSION"
else
	echo "[ERROR] invalid javac version: $JAVAC_VERSION"	
fi
