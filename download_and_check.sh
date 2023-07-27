#!/bin/sh

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
	mv "$1" "$2";
	return $?;
}
# @description: "download a file from url": @args url path
fresh_download(){
	./download_http.sh "fresh" "$1" "$2";
	return $?;
}
# @description: "continue downloading the url": @args url path
continue_download(){
	./download_http.sh "continue" "$1" "$2";
	return $?;
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
			return 2;
		fi
		return 1;
	fi
	local hash=$(get_hash "$2");
	if [ ! "$hash" = "$3" ]; then
		echo "[DEBUG] redownloading: cache poisioned";
		if ! fresh_download "$1" "$2"; then
			return 2;
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
	echo "[ARGS] download_and_check.\$5='$5'";
	if [ -f "$2" ]; then
		if check_file "$2" "$3" "$4"; then
			echo "[DEBUG] ignoring: file exists";
			return 0;
		else
			echo "[DEBUG] file exists and checksum failed";
			return 1;
		fi
	else
		local tmpfile="$5/$3.bin";
		if [ -f "$tmpfile" ]; then
			check_and_continue "$1" "$tmpfile" "$3" "$4"
			local download_status=$?;
		 	if [ $download_status -eq 0 ]; then
				log_and_move "$tmpfile" "$2";
				return $?;
			fi
			if [ $download_status -eq 2 ]; then
				return 1;
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
			log_and_move "$tmpfile" "$2";
			return $?;
		else
			echo "[ERROR] corrupted file found: '$tmpfile'"
			return 1;
		fi
	fi
}
download_and_check "$1" "$2" "$3" "$4" "$5"
