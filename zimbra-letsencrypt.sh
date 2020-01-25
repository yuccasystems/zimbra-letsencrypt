#
# !/bin/bash
# Yucca Systems Inc
# Description: 
# *** This script is intented to deploy automatically a new letsencrypt certificate for Zimbra
# *** Implementation of the Zimbra doc https://wiki.zimbra.com/wiki/Installing_a_LetsEncrypt_SSL_Certificate

#Set the domain & Ticket number
DOMAIN="mx.example.com"
TICKET=0000
ZIMBRA_USER="zimbra"

# Function to prepare the copy of the new letsencrypt files
PrepareCert () {

echo "Creating /opt/zimbra/ssl/letsencrypt"
mkdir /opt/zimbra/ssl/letsencrypt


echo "Copying new letsencrypt files of $DOMAIN into /opt/zimbra/ssl/letsencrypt/"
cp -Lv /etc/letsencrypt/live/$DOMAIN/* /opt/zimbra/ssl/letsencrypt/


echo "New files details copied:"
ll /opt/zimbra/ssl/letsencrypt/


echo "Merging the new chain.pem with Identrust root CA certificate..."
echo """
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
""" | tee -a /opt/zimbra/ssl/letsencrypt/chain.pem

echo "Assigning the zimbra permissions to /opt/zimbra/ssl/letsencrypt/*"
chown -R $ZIMBRA_USER:$ZIMBRA_USER /opt/zimbra/ssl/letsencrypt/*

sleep 2

echo "Validating letsencrypt files within zimbra..."
runuser -l $ZIMBRA_USER -c "cd /opt/zimbra/ssl/letsencrypt/ && /opt/zimbra/bin/zmcertmgr verifycrt comm privkey.pem cert.pem chain.pem"

sleep 2

if [[ $? -eq 0 ]]
then
	echo "[OK] the new certificate is ready to be deployed"
	DeployCertificate

else
	echo "[ERROR] Try again, see above error"
	exit 0
fi

}

# Deploy the new files to Zimbra and restart the service

DeployCertificate() {

echo "Creating a backup of the old /opt/zimbra/ssl/zimbra to /opt/zimbra/ssl/zimbra.$(date "+%Y%m%d")_$TICKET"
cp -av /opt/zimbra/ssl/zimbra /opt/zimbra/ssl/zimbra.$(date "+%Y%m%d")_$TICKET

echo "Copying the privkey under zimbra ssl path.."
cp -v /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/zimbra/commercial/commercial.key

sleep 2

echo "Deploying the new certificate...!"
runuser -l $ZIMBRA_USER -c "cd /opt/zimbra/ssl/letsencrypt/ && /opt/zimbra/bin/zmcertmgr deploycrt comm cert.pem chain.pem"

sleep 2

if [[ $? -eq 0 ]]
then
	echo "[OK] The new certificate has been successfuly deployed !"
	echo "Restarting Zimbra services..."
	runuser -l $ZIMBRA_USER -c "zmcontrol restart"

else
	echo "[ERROR] Try again, see above error"
	exit 0
fi

}

main () {

	PrepareCert
}

main

exit 0
