DOMAIN=yyyy.xxxx.yyy
openssl pkcs12 -export -out $DOMAIN.pfx -in cert1.pem -inkey privkey1.pem