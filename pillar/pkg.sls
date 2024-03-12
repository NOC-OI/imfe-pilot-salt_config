{% if grains['os'] == 'Ubuntu' %}
ntp_pkg: ntp
mc_pkg: mc
ifconfig_pkg: net-tools
iptables-persist_pkg: iptables-persistent
ufw-pkg: ufw
alien_pkg: alien
netstat_pkg: net-tools
bwmng_pkg: bwm-ng
lwp_pkg: libwww-perl
postfix_pkg: postfix
fail2ban_pkg: fail2ban
clamav_pkg: clamav
rkhunter_pkg: rkhunter
mailx_pkg: bsd-mailx
msmtp_pkg: msmtp
msmtp_mta_pkg: msmtp-mta
pwgen_pkg: pwgen
docker_pkg: docker.io
docker_compose_pkg: docker-compose
wget_pkg: wget
apache_pkg: apache2
certbot_pkg: python3-certbot-apache
jq_pkg: jq
{% endif %}

