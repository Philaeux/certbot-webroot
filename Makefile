certbot_webroot:
	docker-compose up -d

refresh_certificates:
	certbot renew
    echo 'lul'
	service haproxy restart
