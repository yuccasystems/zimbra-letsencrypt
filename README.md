# zimbra-letsencrypt
Create, Prepare and Deploy a new Letsencrypt certificate for a Zimbra domain
Cf. https://wiki.zimbra.com/wiki/Installing_a_LetsEncrypt_SSL_Certificate

# To add this to crontab

0 2 * * * root /usr/bin/certbot renew --deploy-hook "/path/to/file/zimbra-letsencrypt.sh"
