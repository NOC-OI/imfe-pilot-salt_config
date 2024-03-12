{% if grains['os'] == 'Ubuntu' %}
ntp_service: ntp
nrpe_service: nagios-nrpe-server

openssh_service: sshd
openssh_service_restart: service sshd restart

postfix_service: postfix
postfix_service_restart: service postfix restart

fail2ban_service: fail2ban
fail2ban_service_restart: service fail2ban restart

nrpe_service_restart: systemctl restart nrpe
ntp_service_restart: systemctl restart ntpd

{% endif %}

#email to send any system messages to
dest_email: colin.sauze@noc.ac.uk
