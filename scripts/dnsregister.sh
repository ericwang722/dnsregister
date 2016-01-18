#!/bin/bash

#this file is to update the DNS in route 53 point to the current host ip

#DNS_NAME passed in as a parameter
TMP_DIR='/tmp/'

#copy configuration scripts from AWS S3 and execute it
aws s3 cp s3://$S3_BUNDLE_NAME/setup-config.sh /dnsregister/setup-config.sh \
&& chmod 777 /dnsregister/setup-config.sh \
&& . /dnsregister/setup-config.sh;

if   [ -z $DNS_NAME ]; 
then 
echo   "$DNS_NAME not set in the ENV " 
exit 1
fi

#get the current host ip using http://instance-data
HOST_IP=$(curl http://instance-data/latest/meta-data/public-ipv4)

#remove all the current registry of the DNS_NAME
echo "{\"Changes\": [{ \"Action\": \"DELETE\",\"ResourceRecordSet\":"$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE --query "ResourceRecordSets[?Name=='${DNS_NAME}.']" | sed '1d;$d')"}]}" > ${TMP_DIR}tmp_r53_a_recordsets.json

#if the record is not found, the json coinfiguration will error out, let it go
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch file://${TMP_DIR}tmp_r53_a_recordsets.json

#add the new a record
cat /dnsregister/route53_action_template.json | \
sed -e "s/_DNS_NAME_/${DNS_NAME}/g" -e "s/_HOST_IP_/${HOST_IP}/g" > \
${TMP_DIR}/tmp_route53_create.json

aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch file://${TMP_DIR}/tmp_route53_create.json

rm ${TMP_DIR}tmp_r53_a_recordsets.json
rm ${TMP_DIR}/tmp_route53_create.json
