mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl

openssl req -new -newkey rsa:2048 -nodes \
  -keyout itsupport.key \
  -out itsupport.csr \
  -subj "/CN=itsupport.udem.lan/O=UDEM/C=CA"

cat itsupport.csr
