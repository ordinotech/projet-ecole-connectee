server {
    listen 8080;

    location / {
        proxy_pass http://archive.ubuntu.com;
        proxy_set_header Host archive.ubuntu.com;
        proxy_cache_valid 200 302 60m;
        allow 10.0.1.3;
				deny all;
    }
}
