stream {
    upstream mariadb_backend {
        server 10.0.1.3:3306;
    }

    server {
        listen 3306;
        proxy_pass mariadb_backend;
        proxy_timeout 10m;
        proxy_connect_timeout 5s;
    }
}
