apache installed:
    pkg.installed:
        - name: {{ pillar['apache_pkg'] }}

enable ssl:
    cmd.run:
        - name: a2enmod ssl

enable modrewrite:
    cmd.run:
        - name: a2enmod rewrite

enable proxy:
    cmd.run:
        - name: a2enmod proxy proxy_http proxy_wstunnel

enable modheaders:
    cmd.run:
        - name: a2enmod headers

create frontend virtualserver:
    file.managed:
        - name: {{ pillar['apache_frontend_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/frontend.conf
        - template: jinja

create frontend ssl virtualserver:
    file.managed:
        - name: {{ pillar['apache_frontend_ssl_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/frontend-ssl.conf
        - template: jinja

create mbtiles virtualserver:
    file.managed:
        - name: {{ pillar['apache_mbtiles_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/mbtiles.conf
        - template: jinja

create mbtiles ssl virtualserver:
    file.managed:
        - name: {{ pillar['apache_mbtiles_ssl_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/mbtiles-ssl.conf
        - template: jinja


create api virtualserver:
    file.managed:
        - name: {{ pillar['apache_api_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/api.conf
        - template: jinja

create api ssl virtualserver:
    file.managed:
        - name: {{ pillar['apache_api_ssl_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/api-ssl.conf
        - template: jinja

create tileserver virtualserver:
    file.managed:
        - name: {{ pillar['apache_tileserver_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/tileserver.conf
        - template: jinja

create tileserver ssl virtualserver:
    file.managed:
        - name: {{ pillar['apache_tileserver_ssl_virtualserver_config'] }}
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://apache/files/tileserver-ssl.conf
        - template: jinja

enable frontend site:
    apache_site.enabled:
        - name: frontend

enable frontend ssl site:
    apache_site.enabled:
        - name: frontend-ssl

enable mbtiles site:
    apache_site.enabled:
        - name: mbtiles

enable mbtiles ssl site:
    apache_site.enabled:
        - name: mbtiles-ssl

enable api site:
    apache_site.enabled:
        - name: api

enable api ssl site:
    apache_site.enabled:
        - name: api-ssl

enable tileserver site:
    apache_site.enabled:
        - name: tileserver

enable tileserver ssl site:
    apache_site.enabled:
        - name: tileserver-ssl

disable default site:
    apache_site.disabled:
        - name: 000-default
        - name: 000-default-ssl
