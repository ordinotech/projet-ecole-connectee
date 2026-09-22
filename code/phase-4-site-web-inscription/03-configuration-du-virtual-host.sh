ln -s /etc/nginx/sites-available/inscription /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default 
nginx -t 
systemctl restart nginx
