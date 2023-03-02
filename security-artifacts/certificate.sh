#! /bin/bash

FILE=$1
SUBJECT=$2
EXTENSIONS=$3
CACERT=${4:-ca}
CERTIFICATEPASS=$5
CACHAINPASS=$6
DAYS=$7

[[ ! -f $FILE.key  ]] \
    && openssl genrsa \
    -des3 \
    -out $FILE.key \
    -passout pass:$CERTIFICATEPASS \
    4096 \
    && rm -f $FILE.csr \
    && echo "$FILE.key has been generated" || echo "$FILE.key has already been generated"

[[ ! -f $FILE.csr  ]] \
    && openssl req \
    -new \
    -key $FILE.key \
    -passin pass:$CERTIFICATEPASS \
    -sha256 \
    -subj $SUBJECT \
    -out $FILE.csr \
    && rm -f $FILE.crt \
    && echo "$FILE.csr has been generated" || echo "$FILE.csr has already been generated"

[[ ! -f $FILE.crt  ]] \
    && openssl x509 \
    -req \
    -CA $CACERT.crt \
    -CAkey $CACERT.key \
    -CAcreateserial \
    -in $FILE.csr \
    -out $FILE.crt \
    -passin pass:$CACHAINPASS \
    -days $DAYS \
    -sha256 \
    -extfile <(printf "$EXTENSIONS") \
    && rm -f $FILE.p12 \
    && echo "$FILE.crt has been generated" || echo "$FILE.crt has already been generated"

[[ ! -f $FILE.p12  ]] \
    && openssl pkcs12 \
    -export \
    -name ${FILE} \
    -in $FILE.crt \
    -inkey $FILE.key \
    -passin pass:$CERTIFICATEPASS \
    -passout pass:$CERTIFICATEPASS \
    -out $FILE.p12 \
    && echo "$FILE.p12 has been generated" || echo "$FILE.p12 has already been generated"
