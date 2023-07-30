#! /bin/sh
CURL_DOWNLOAD_OPTIONS="--ssl-no-revoke"
# @description "(continue the) download the url" @args operation url path
download_http(){
        echo "[ARGS] download_http \$1='$1'"
        echo "[ARGS] download_http \$2='$2'"
        echo "[ARGS] download_http \$3='$3'"
        if [ "$1" == "continue" ]; then
                echo "[EXEC] curl -o '$3' $CURL_DOWNLOAD_OPTIONS -sS '$2'"; # sensible operation
                curl -o "$3" $CURL_DOWNLOAD_OPTIONS -sS "$2";
                return $?;
        fi
        if [ "$1" == "fresh" ]; then
                echo "[EXEC] curl -C - -o '$3' $CURL_DOWNLOAD_OPTIONS -sS '$2'"; # sensible operation
                curl -C - -o "$3" $CURL_DOWNLOAD_OPTIONS -sS "$2";
                return $?;
        fi
        return $1
}

download_http "$1" "$2" "$3"
