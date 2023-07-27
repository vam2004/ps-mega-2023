#!/bin/sh

POSTGRESQL_JDBC_VERSION=42.6.0
POSTGRESQL_JDBC_HASH=b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461
POSTGRESQL_JDBC_SIZE=1081604
INSTALL_DOWNLOADS_CACHE=".dynimport"
# @description: "get size of file" @args: path
get_size(){
	echo $(($(du -b "$1" 2> /dev/null | cut -f1) +0))
}
# @description: "gets the hash of file" @args: path
get_hash(){
	sha256sum "$1" | cut -d " " -f1;
}
# @description: "checks the integrity of file" @args: path hash size
check_file(){
	echo "[ARGS] check_file.\$1='$1'";
	echo "[ARGS] check_file.\$2='$2'";
	echo "[ARGS] check_file.\$3='$3'";
	local size=$(get_size "$1");
	if [ "$size" -ne "$3" ]; then
		echo "[SILENT ERROR] check_file: invalid size '$size'"
		return 1;
	fi
	local hash=$(get_hash "$1");
	if [ ! "$hash" = "$2" ]; then
		echo "[SILENT ERROR] check_file: invalid hash '$hash'"
		return 1;
	fi
	return 0;
}
log_and_move(){
	echo "[EXEC] mv '$1' '$2'"; # sensible operation
	# return $(mv "$1" "$2");
	return 1;
}
CURL_DOWNLOAD_OPTIONS="--ssl-no-revoke"
# @description: "download a file from url": @args url path
fresh_download(){
	echo "[EXEC] curl -o '$2' $CURL_DOWNLOAD_OPTIONS -sS '$1'"; # sensible operation
	return $(curl -o "$2" $CURL_DOWNLOAD_OPTIONS -sS "$1");
}
# @description: "continue downloading the url": @args url path
continue_download(){
	echo "[EXEC] curl -C - -o '$2' $CURL_DOWNLOAD_OPTIONS -sS '$1'"; # sensible operation
	return $(curl -C - -o "$2" $CURL_DOWNLOAD_OPTIONS -sS "$1");
}
# @description: "continues a download": @args url temp_path hash size
check_and_continue(){
	echo "[ARGS] check_and_continue.\$1='$1'";
	echo "[ARGS] check_and_continue.\$2='$2'";
	echo "[ARGS] check_and_continue.\$3='$3'";
	echo "[ARGS] check_and_continue.\$4='$4'";
	local size=$(get_size "$2");
	if [ "$size" -ne "$4" ]; then
		echo "[DEBUG] continuing download at byte $size";
		if ! continue_download "$1" "$2"; then
			exit 1;
		fi
		return 1;
	fi
	local hash=$(get_hash "$2");
	if [ ! "$hash" = "$3" ]; then
		echo "[DEBUG] redownloading: cache poisioned";
		if ! fresh_download "$1" "$2"; then
			exit 1;
		fi
	fi
	return 0;
}
#  url path hash size
download_and_check() {
	echo "[ARGS] download_and_check.\$1='$1'";
	echo "[ARGS] download_and_check.\$2='$2'";
	echo "[ARGS] download_and_check.\$3='$3'";
	echo "[ARGS] download_and_check.\$4='$4'";
	if [ -f "$2" ]; then
		if check_file "$2" "$3" "$4"; then
			echo "[DEBUG] ignoring: file exists";
			return 0;
		else
			echo "[DEBUG] file exists and checksum failed";
			return 1;
		fi
	else
		local tmpfile="$INSTALL_DOWNLOADS_CACHE/$3.bin";
		if [ -f "$tmpfile" ]; then
		 	if check_and_continue "$1" "$tmpfile" "$3" "$4"; then
				return $(log_and_move "$tmpfile" "$2");
			fi
		else
			echo "[DEBUG] download_and_check: first download"
			if ! fresh_download "$1" "$tmpfile"; then
				return 1;
			fi
		fi
		echo "[DEBUG] checking download";
		if check_file "$tmpfile" "$3" "$4"; then
			echo "[DEBUG] download verified!";
			return $(log_and_move "$tmpfile" "$2");
		else
			echo "[ERROR] corrupted file found: '$tmpfile'"
			return 1;
		fi
	fi
}

main(){
	mkdir -p .build;
	mkdir -p .libs;
	if [ ! -d "$INSTALL_DOWNLOADS_CACHE" ]; then
		echo "Error: Cannot find the cache";
		return 1;
	fi
	local FILENAME="postgresql-$POSTGRESQL_JDBC_VERSION.jar";
	local MIRROR="https://jdbc.postgresql.org/download";
	local URL="$MIRROR/$FILENAME";
	local PERMPATH=".libs/$FILENAME";
	download_and_check "$URL" "$PERMPATH" "$POSTGRESQL_JDBC_HASH" "$POSTGRESQL_JDBC_SIZE";
}

main
