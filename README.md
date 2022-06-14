# Certbot Webroot

This project is a simple snippet to use ```certbot``` with ```haproxy```.

### Haproxy config

```
frontend http-in
        bind *:80

        # Let's encrypt challenge
        acl letsencrypt-acl path_beg /.well-known/acme-challenge/
        use_backend letsencrypt if letsencrypt-acl

        # Go to HTTPS otherwise
        http-request redirect scheme https code 301 if ! letsencrypt-acl

frontend https-in
        bind *:443 ssl crt-list /etc/letsencrypt/live_list.txt
        use_backend domain if { hdr(host) -i domain.org }

backend letsencrypt
        server certbot 127.0.0.1:8899

backend domain
	server domain 127.0.0.1:XXXX
```

### Create a new certificate for a domain

Use the following command to generate a certificate using the webroot.

```sudo certbot certonly --standalone -d domain.com --non-interactive --agree-tos --email address@email --http-01-port=8899```

### Renew certificates

A simple ``certbot renew`` will run the same challenge that during the creation.
 
### Haproxy refresh certificates

Haproxy expects a single file to contain the full certificate for a domain. For each domain in ``/etc/letsencrypt/live/``, you need to generate a single ``haproxy.pem`` containing the content of ``fullchain.pem`` and ``privkey.pem``.  

The file ``/etc/letsencrypt/live_list.txt`` should contain the list of all domains with a path with their certificate for haproxy to load, in this format:
```
/etc/letsencrypt/domain1/haproxy.pem domain1
/etc/letsencrypt/domain2/haproxy.pem domain2
```

### Reload Haproxy

Reloading haproxy ensure the new certificate is loaded in memory, which is done with a simple service reload: ``sudo systemctl reload haproxy``.

### Full process

``certbot_refresh.py`` contains the full refresh process in a python script. The haproxy is not reloaded if there is nothing updated.

Add a call as CRON job to do it every week:

``sudo crontab -u root -e``

``0 1 * * 0 python3 /<path to this directory>/certbot_refresh.py``
