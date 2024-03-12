{% if 'web' in grains['fqdn'] %}
open_ports:
  tcp:
    - 8080
    - 8081
    - 8082
    - 8083
{% else %}
open_ports:
  tcp:
    - 80
    - 443
{% endif %}

iptables-persist_service: iptables
iptables-persist_path: /etc/sysconfig/iptables
