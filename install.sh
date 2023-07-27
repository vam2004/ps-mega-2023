#!/bin/sh

POSTGRESQL_JDBC_VERSION=42.6.0
POSTGRESQL_JDBC_HASH=b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461
POSTGRESQL_JDBC_SIZE=1081604
# @description: "get size of file" @args: path
get_size(){
	return $(($(du -b "$1" 2> /dev/null | cut -f1) +0))
}
# @description: "gets the hash of file" @args: path
get_hash(){
	return $(sha256sum "$1" | cut -d " " -f1);
}
# @description: "checks the integrity of file" @args: path hash size
check_file(){
	local size=$(get_size "$1");
	if [ "$size" -ne "$3" ]; then
		return 1;
	fi
	local hash=$(get_hash "$1");
	if [ "$hash" -ne "$2" ]; then
		return 1;
	fi
	return 0;
}
# @description: "continues a download": @args url temp_path hash size
check_and_continue(){
	local size=$(get_size "$2");
	if [ "$size" -ne "$4" ]; then
		echo "[DEBUG] continuing download at byte $size";
		#curl -C - -o "$2" --silent "$1";
		return 1;
	fi
	local hash=$(get_hash "$2");
	if [ "$hash" -ne "$3" ]; then
		echo "[DEBUG] redownloading: cache poisioned";
		#curl -o "$2" --silent "$1";
	fi
	return 0;
}

#  url path hash size
download_link() {
	if [ -f "$4" ]; then
		if check_file "$2" "$3" "$4"; then
			echo "[DEBUG] ignoring: file exists";
			return 0;
		else
			echo "[DEBUG] file exists and checksum failed";
			return 1;
		fi
	else
		local tmpfile="$DOWNLOADS_CACHE/$3.bin";
		if [ -f "$tmpfile" ]; then
		 	if check_and_continue "$1" "$tempfile" "$3" "$4"; then
				return 0;
			fi
		else
			echo "[EXEC] curl -o '$tmpfile' --silent '$1'"; # sensible operation
			# curl -o "$tmpfile" --silent "$1"; # downloads '$1' into '$tmpfile'
		fi
		echo "[DEBUG] checking download";
		if check_file "$tempfile" "$3" "$4"; then
			echo "[DEBUG] download verified!";
			echo "[EXEC] mv '$tmpfile' '$2'"; # sensible operation
			# return $(mv "$tmpfile" "$2");
		else
			echo "[ERROR] corrupted file found: '$tmpfile'"
			return 1;
		fi
	fi
}

main(){
	mkdir .build;
	mkdir .libs;
	local FILENAME="postgresql-$POSTGRESQL_JDBC_VERSION.jar";
	local MIRROR="https://jdbc.postgresql.org/download";
	local URL="$MIRROR/$FILENAME";
	local PERMPATH=".libs/$FILENAME"
	#return $(download_link "$URL" "$FILENAME" "$POSTGRESQL_JDBC_HASH" "$POSTGRESQL_JDBC_SIZE");
	echo "[EXEC] download_link '$URL' '$FILENAME' '$POSTGRESQL_JDBC_HASH' '$POSTGRESQL_JDBC_SIZE'" # sensible operation
}

main
