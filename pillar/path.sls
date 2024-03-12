{% if grains['os'] == 'Ubuntu' %}
rkhunter_default_file: /etc/default/rkhunter
{% endif %}

ntp_conf_file: /etc/ntp.conf
ntp_conf_dir: /etc/ntp
fail2ban_config_directory: /etc/fail2ban
rkhunter_config_file: /etc/rkhunter.conf
aliases: /etc/aliases
swapfile: /var/lib/docker/swapfile
