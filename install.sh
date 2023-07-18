POSTGRESQL_VERSION=42.6.0
POSTGRESQL_HASH=b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461
POSTGRESQL_DIR="$(pwd)/psql-jdbc"
download_link() {
	if [ -f "$3" ]; then
		echo "[DEBUG] skipping installation of '$3'"
	else
		echo "[DEBUG] downloading from '$1'"
		local tmpfile="./downloads/$2.tmp"
		echo "[DEBUG] downloading into '$tmpfile'"
		if [ -f "$tmpfile" ]; then
			echo "[DEBUG] skipping download: the file '$tmpfile' already exit"
		else
			curl "$1" -o "$tmpfile"	--silent
		fi
			echo "[DEBUG] expected sha256 '$2'"
		local hash=$(sha256sum "$tmpfile" | cut -d " " -f1)
		if [ "$hash" == "$2" ]; then
			echo "[DEBUG] cloning into '$3'"
			cp "$tmpfile" "$3"
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
