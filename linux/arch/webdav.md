

```
server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate     /etc/nginx/ssl/webdav.crt;
    ssl_certificate_key /etc/nginx/ssl/webdav.key;

    client_max_body_size 0;
    dav_methods PUT DELETE MKCOL COPY MOVE;
    dav_ext_methods PROPFIND OPTIONS;

    auth_basic "WebDAV";
    auth_basic_user_file /etc/nginx/webdav.passwd;

    location /webdav/ {
        alias /srv/webdav/;
        autoindex on;
        dav_methods PUT DELETE MKCOL COPY MOVE;
        dav_access user:rw group:rw all:r;
    }
}
```