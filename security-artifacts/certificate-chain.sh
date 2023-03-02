#! /bin/bash

FILE=$1
SUBJECT=$2
CACHAINPASS=$3

[[ ! -f $FILE.key  ]] \
    && openssl genrsa \
    -des3 \
    -out $FILE.key \
    -passout pass:$CACHAINPASS \
    4096 \
    && rm -f $FILE.crt \
    && echo "$FILE.key has been generated" || echo "$FILE.key has already been generated"

[[ ! -f $FILE.crt  ]] \
    && openssl req -x509 \
    -new \
    -key $FILE.key \
    -passin pass:$CACHAINPASS \
    -days 3652 \
    -sha256 \
    -subj $SUBJECT \
    -out $FILE.crt \
    && echo "$FILE.crt has been generated" || echo "$FILE.crt has already been generated"
