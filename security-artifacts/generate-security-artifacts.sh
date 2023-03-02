#! /bin/bash
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEFAULT_PASS=changeit

#Root cert
$CURRENT_DIR/certificate-chain.sh \
    $CURRENT_DIR/rootca \
    "/C=CA/ST=Quebec/L=Montreal/O=LOCAL_KAFKA/OU=TEST/CN=ROOTCA" \
    nUpraEjeGav5dqo07yHX

#SSL Intermediate Cert
$CURRENT_DIR/certificate.sh \
    $CURRENT_DIR/intca \
    "/C=CA/ST=Quebec/L=Montreal/O=LOCAL_KAFKA/OU=TEST/CN=INTCA" \
    "basicConstraints=CA:true\nkeyUsage=digitalSignature,keyCertSign" \
    $CURRENT_DIR/rootca \
    bS89m8436bmn2sM37XVN \
    nUpraEjeGav5dqo07yHX \
    1825

# Truststores
[ ! -f $CURRENT_DIR/truststore.jks ] && keytool -import -v --noprompt -file $CURRENT_DIR/rootca.crt -alias Root -keystore $CURRENT_DIR/truststore.jks -storepass $DEFAULT_PASS -storetype JKS && \
keytool -import -v --noprompt -file $CURRENT_DIR/intca.crt -alias Int -keystore $CURRENT_DIR/truststore.jks -storepass $DEFAULT_PASS -storetype JKS || echo "Truststore JKS already exists"

[ ! -f $CURRENT_DIR/truststore.pem ] && cat $CURRENT_DIR/rootca.crt $CURRENT_DIR/intca.crt > $CURRENT_DIR/truststore.pem || echo "Truststore PEM already exists"

[ ! -f $CURRENT_DIR/truststore.p12 ] && openssl pkcs12 -passout pass:$DEFAULT_PASS -export -nokeys -in $CURRENT_DIR/truststore.pem -out $CURRENT_DIR/truststore.p12 || echo "Truststore PKCS12 already exists"


# Generate SSL artifacts for services
for service in $CURRENT_DIR/broker1,$CURRENT_DIR/intca,E8t4AKCzHDO9VMyo97YX,bS89m8436bmn2sM37XVN,365 \
    $CURRENT_DIR/broker2,$CURRENT_DIR/intca,E8t4AKCzHDO9VMyo97YX,bS89m8436bmn2sM37XVN,365 \
    $CURRENT_DIR/broker3,$CURRENT_DIR/intca,E8t4AKCzHDO9VMyo97YX,bS89m8436bmn2sM37XVN,365 \
    ; do
    readarray -d ',' -t service_config <<< "${service}"
    CN=${service_config[0]##*/}
    $CURRENT_DIR/certificate.sh \
        ${service_config[0]} \
        "/C=CA/ST=Quebec/L=Montreal/O=LOCAL_KAFKA/OU=TEST/CN=$CN" \
        "basicConstraints=CA:false\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth,clientAuth\nsubjectAltName=DNS:localhost,IP:127.0.0.1" \
        ${service_config[1]} \
        ${service_config[2]} \
        ${service_config[3]} \
        ${service_config[4]}

    mkdir -p $CURRENT_DIR/../services/$CN/ssl/
    cp -f $CURRENT_DIR/$CN.p12 $CURRENT_DIR/../services/$CN/ssl/
    cp -f $CURRENT_DIR/truststore.p12 $CURRENT_DIR/../services/$CN/ssl/
done
