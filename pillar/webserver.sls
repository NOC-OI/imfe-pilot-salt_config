{% if grains['host'] in ['gateway', 'arm-test2'] %}
apache_server: true

tileserver_webserver_ip: web
tileserver_webserver_port: 8083
tileserver-hostname: tileserver.haigfras-arm.dynv6.net

mbtiles_webserver_ip: web
mbtiles_webserver_port: 8082
mbtiles-hostname: mbtiles.haigfras-arm.dynv6.net

api_webserver_ip: web
api_webserver_port: 8081
api-hostname: api.haigfras-arm.dynv6.net

frontend_webserver_ip: web
frontend_webserver_port: 8080
frontend-hostname: haigfras-arm.dynv6.net

apache_frontend_virtualserver_config: /etc/apache2/sites-available/frontend.conf
apache_api_virtualserver_config: /etc/apache2/sites-available/api.conf
apache_mbtiles_virtualserver_config: /etc/apache2/sites-available/mbtiles.conf
apache_tileserver_virtualserver_config: /etc/apache2/sites-available/tileserver.conf

apache_frontend_ssl_virtualserver_config: /etc/apache2/sites-available/frontend-ssl.conf
apache_api_ssl_virtualserver_config: /etc/apache2/sites-available/api-ssl.conf
apache_mbtiles_ssl_virtualserver_config: /etc/apache2/sites-available/mbtiles-ssl.conf
apache_tileserver_ssl_virtualserver_config: /etc/apache2/sites-available/tileserver-ssl.conf

certificate_path: /etc/letsencrypt/live/haigfras-arm.dynv6.net

{% else %}
apache_server: false
{% endif %}
