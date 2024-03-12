certbot installed:
    pkg.installed:
        - name: {{ pillar['certbot_pkg'] }}

certbot config:
    cmd.run:
        - name: service apache2 stop && certbot certonly --standalone -m colin.sauze@noc.ac.uk --agree-tos -n --domains {{ pillar['frontend-hostname'] }},{{ pillar['tileserver-hostname'] }},{{ pillar['mbtiles-hostname'] }},{{ pillar['api-hostname'] }} && service apache2 start
        #- name: certbot --apache -m colin.sauze@noc.ac.uk --agree-tos -n renew
#not sure if this should be renew or run the first time, but its renew on subsequent attempts and renew sets up the vhost config to use the certificate correctly

