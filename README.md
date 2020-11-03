# zimbra-letsencrypt
Create, Prepare and Deploy a new Letsencrypt certificate for a Zimbra domain
Cf. https://wiki.zimbra.com/wiki/Installing_a_LetsEncrypt_SSL_Certificate

## Procedure
### (One time action) Create zimbra's certificate with certbot (need 80 port opened, stop zimbra)
``` certbot certonly --standalone --preferred-challenges http -d example.com ```

### Run the script zimbra-letsencrypt.sh
1. Get the certificate (git clone) and add your emails to the emails.txt file (notification)
2. In sudo, ```chmod +x /path/to/file/zimbra-letsencrypt.sh``` 
3. In sudo, ```/path/to/file/zimbra-letsencrypt.sh```

### Automate this task with crontab
Append your crontab in sudo with the following (sudo crontab -e)  
```0 2 * * * root /usr/bin/certbot renew --deploy-hook "/path/to/file/zimbra-letsencrypt.sh"```
