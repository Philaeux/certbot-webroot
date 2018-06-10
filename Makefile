full:
	make certbot_webroot
	make renew
	make refresh
	make reload

certbot_webroot:
	docker-compose up -d

renew:
	sudo certbot renew --webroot -w /home/docker/certbot_webroot

refresh:
	ls

reload:
	sudo service haproxy restart
