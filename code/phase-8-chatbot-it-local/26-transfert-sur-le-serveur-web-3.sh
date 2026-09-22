openssl x509 -in /etc/nginx/ssl/itsupport.crt -noout -text | grep -E "Subject:|Not After"
chmod 644 /etc/nginx/ssl/itsupport.crt
chmod 600 /etc/nginx/ssl/itsupport.key
