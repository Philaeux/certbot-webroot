# Certbot Webroot

This project is a simple ```nginx``` docker with a specific volume to ease the generation of certificates using ```certbot``` and serving services with ```haproxy```.

### Haproxy config

```
frontend http-in
        bind :80

        # DevOps routes
        use_backend letsencrypt if { path_beg /.well-known/acme-challenge }

        # Redirect to HTTPS
        redirect scheme https code 301

frontend https-in
        bind :443 ssl crt /etc/letsencrypt/live/example.fr/haproxy.pem 
        http-request set-header X-Forwarded-Proto https if { ssl_fc }

        # DevOps routes
        use_backend letsencrypt if { path_beg /.well-known/acme-challenge }

        # Application routes
        use_backend example if { hdr(host) -i example.fr }

# DevOps services
backend letsencrypt
        option httpclose
        server node1 127.0.0.1:10001 cookie A check

# Application services
backend example
        option httpclose
        server node1 127.0.0.1:10002 cookie A check
```

### Certbot webroot docker

Deploy using ```make certbot_webroot``` and let the service listen for file requests.

### Create a new certificate for a domain

Use the following command to generate a certificate using the webroot.

```sudo certbot certonly --webroot -w /home/docker/certbot_webroot -d example.fr --non-interactive --agree-tos --email adress@mail```

### Renew certificates

A simple ``certbot renew`` will run the same challenge that during the creatuib, so it will be intercepted by the webroot which will ensure the renewal.
 
### Haproxy refresh certificates

Haproxy expects a single file to contain the full certificate for a domain. For each domain in ``/etc/letsencrypt/live/``, you need to generate a single ``haproxy.pem`` containing the content of ``fullchain.pem`` and ``privkey.pem``. A bash script can do the job:
 
`` aze ``

This script is saved in ```make refresh```

### Reload Haproxy

Reloading haproxy ensure the new certificate is loaded in memory, which is done with a simple service restart.
 
 ``service haproxy restart``

### Full process

A makefile is inside the project to fully refresh the certificate: with 

```make refresh_certificates```

Add the command to a cron job to do it every month

``0 0 1 * * make -f <path makefile> refresh_certificates``
