#  Redirection 
server {
    listen 80;
    server_name itsupport.udem.lan;
    return 301 https://$server_name$request_uri;
}

#  Serveur HTTPS 
server {
    listen 443 ssl;
    server_name itsupport.udem.lan;

    # Certificats ADCS 
    ssl_certificate     /etc/nginx/ssl/itsupport.crt;
    ssl_certificate_key /etc/nginx/ssl/itsupport.key;

    # Protocoles et chiffrements modernes 
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;

    # Timeouts élevés pour les réponses LLM
    proxy_read_timeout    600s;
    proxy_connect_timeout  60s;
    proxy_send_timeout    600s;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;

        # WebSocket pour le streaming des réponses LLM
        proxy_set_header Upgrade    $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Headers standards
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        # Désactiver le buffering 
        proxy_buffering off;
        proxy_cache     off;
    }

