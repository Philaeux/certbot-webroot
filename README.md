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

Use certbot renew with the webroot

```make renew```

### Haproxy refresh certificates

Haproxy expects a single file to contain the full certificate for a domain. This commands generate this file for each domain (make sur to load it into your haproxy cfg):

```make refresh```

### Reload Haproxy

Reload haproxy to load the new certificates.

```make reload```

### Full process

This command do the full renew process, requesting certificate renew, generating new files and reloading haproxy.

```make full```
