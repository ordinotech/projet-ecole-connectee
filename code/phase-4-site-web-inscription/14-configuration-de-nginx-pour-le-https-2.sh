server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name inscription.udem.lan;

    ssl_certificate /etc/ssl/certs/inscription.cer;
    ssl_certificate_key /etc/ssl/private/inscription.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    root /var/www/html/inscription;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
 }
