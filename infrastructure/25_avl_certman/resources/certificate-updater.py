#!/usr/bin/env python
# coding=utf-8

import configparser
import json
import socket
import subprocess
import sys
import time

from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.request import CommonRequest

# Read the configuration
config = configparser.ConfigParser()
config.read("/etc/certificate-updater/config.ini")

accessKeyId = config.get("AlibabaCloud", "AccessKeyId")
accessKeySecret = config.get("AlibabaCloud", "AccessKeySecret")
regionId = config.get("AlibabaCloud", "RegionId")
publicIpAddress = config.get("Certificate", "PublicIpAddress")
pullTopDomain = config.get("Certificate", "PullTopDomain")
pullSubDomain = config.get("Certificate", "PullSubDomain")
emailAddress = config.get("Certificate", "EmailAddress")

print("Certificate Updater started (publicIpAddress: " + publicIpAddress + ", " +
      "pullTopDomain: " + pullTopDomain + ", pullSubDomain: " + pullSubDomain + ", email address: " + emailAddress + ")")

# Get the existing DNS record for the pull domain
client = AcsClient(accessKeyId, accessKeySecret, regionId)
request = CommonRequest()
request.set_accept_format('json')
request.set_domain('alidns.aliyuncs.com')
request.set_method('POST')
request.set_version('2015-01-09')
request.set_action_name('DescribeDomainRecords')
request.add_query_param('DomainName', pullTopDomain)
request.add_query_param('RRKeyWord', pullSubDomain)
request.add_query_param('OrderBy', 'Line')
jsonResponse = client.do_action_with_exception(request)
response = json.loads(jsonResponse)
# We expect 2 records, the first one must be for oversea
if response["TotalCount"] != 2:
    print("Unable to find the DNS domain record. Response:")
    print(response)
    sys.exit(1)
recordInfo = response["DomainRecords"]["Record"][0]
recordValue = recordInfo["Value"]
recordType = recordInfo["Type"]
recordId = recordInfo["RecordId"]
print(
    "Current record for " + pullSubDomain + ": " + recordValue + " (type = " + recordType + ", id = " + recordId + ")")

# Update the DNS record to direct to this server
request = CommonRequest()
request.set_accept_format('json')
request.set_domain('alidns.aliyuncs.com')
request.set_method('POST')
request.set_version('2015-01-09')
request.set_action_name('UpdateDomainRecord')
request.add_query_param('RR', pullSubDomain)
request.add_query_param('Type', 'A')
request.add_query_param('Line', 'oversea')
request.add_query_param('Value', publicIpAddress)
request.add_query_param('TTL', '600')
request.add_query_param('RecordId', recordId)
jsonResponse = client.do_action(request)
response = json.loads(jsonResponse)
if "Code" in response:
    if response["Code"] == "DomainRecordDuplicate":
        print("Warning: the current domain record has already been set to this value.")
    else:
        print("Unable to update the DNS domain record to " + publicIpAddress + ". Response:")
        print(response)
        sys.exit(1)
print("Current record for " + pullSubDomain + ": " + publicIpAddress + " (type = A, id = " + recordId + ")")

# Wait for the domain record to be effectively updated
effectiveDomainRecordValue = ""
nbRemainingLoops = 300
while effectiveDomainRecordValue != publicIpAddress and nbRemainingLoops > 0:
    print(f"Waiting for the DNS record change to be effective (nbRemainingLoops = {nbRemainingLoops})...")
    time.sleep(2)
    effectiveDomainRecordValue = socket.gethostbyname(pullSubDomain + "." + pullTopDomain)
    print("Effective record value: " + effectiveDomainRecordValue)
    nbRemainingLoops = nbRemainingLoops - 1

if nbRemainingLoops <= 0:
    print("Warning: unable to confirm that the DNS record change is effective.")

# Run certbot to obtain the certificate
returnCode = subprocess.call(
    "certbot certonly --standalone -d \"%s.%s\" --non-interactive "
    "--agree-tos --email \"%s\"" % (pullSubDomain, pullTopDomain, emailAddress), shell=True)
if returnCode != 0:
    print("Unable to run certbot, quitting...")
    sys.exit(1)

# Restore DNS domain record for the pull domain
cnameValue = recordValue
if recordType != "CNAME":
    cnameValue = pullSubDomain + "." + pullTopDomain + ".w.kunlunsl.com"
    print("The original record type is not CNAME, try to reconstruct the value to: " + cnameValue)

request = CommonRequest()
request.set_accept_format('json')
request.set_domain('alidns.aliyuncs.com')
request.set_method('POST')
request.set_version('2015-01-09')
request.set_action_name('UpdateDomainRecord')
request.add_query_param('RR', pullSubDomain)
request.add_query_param('Type', 'CNAME')
request.add_query_param('Line', 'oversea')
request.add_query_param('Value', cnameValue)
request.add_query_param('TTL', '600')
request.add_query_param('RecordId', recordId)
jsonResponse = client.do_action_with_exception(request)
response = json.loads(jsonResponse)
if response["RecordId"] == "":
    print("Unable to update the DNS domain record to " + cnameValue + ". Response:")
    print(response)
    sys.exit(1)
print("Current record for " + pullSubDomain + ": " + cnameValue + " (type = CNAME, id = " + recordId + ")")

# Update the pull domain CDN certificate
privateKeyPath = "/etc/letsencrypt/live/" + pullSubDomain + "." + pullTopDomain + "/privkey.pem"
publicKeyPath = "/etc/letsencrypt/live/" + pullSubDomain + "." + pullTopDomain + "/cert.pem"
privateKey = open(privateKeyPath, "rt").read()
publicKey = open(publicKeyPath, "rt").read()
request = CommonRequest()
request.set_accept_format('json')
request.set_domain('cdn.aliyuncs.com')
request.set_method('POST')
request.set_version('2018-05-10')
request.set_action_name('SetDomainServerCertificate')
request.add_query_param('CertType', 'upload')
request.add_query_param('DomainName', pullSubDomain + "." + pullTopDomain)
request.add_query_param('ServerCertificateStatus', 'on')
request.add_query_param('CertName', 'cert-' + time.strftime("%Y-%m-%d-%H-%M-%S", time.gmtime()))
request.add_query_param('PrivateKey', privateKey)
request.add_query_param('ServerCertificate', publicKey)
request.add_query_param('Region', regionId)
jsonResponse = client.do_action_with_exception(request)
response = json.loads(jsonResponse)
if "RequestId" not in response:
    print("Unable to update the pull-domain certificate. Response:")
    print(response)
    sys.exit(1)
print("TLS / SSL certificate updated with success!")
