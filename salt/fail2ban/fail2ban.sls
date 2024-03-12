Install fail2ban:
  pkg.installed:
    - pkgs:
      - {{pillar['fail2ban_pkg']}}
  service.running:
    - name: {{pillar['fail2ban_service']}}
    - enable: True
    - require:
      - pkg: Install fail2ban

fail2ban config:
  file.managed:
     - name: {{pillar['fail2ban_config_directory']}}/jail.local
     - user: root
     - group: root
     - mode: 644
     - template: jinja
{% if pillar['apache_server'] == True %}
     - source: salt://fail2ban/files/jail.local.apache
{% else %}
     - source: salt://fail2ban/files/jail.local.ssh
{% endif %}

#these stop fail2ban emailing when it starts and stops

fail2ban startstopmail:
  file.managed:
     - name: {{pillar['fail2ban_config_directory']}}/action.d/mail.local
     - user: root
     - group: root
     - mode: 644
     - source: salt://fail2ban/files/mail.local

mail-whois.local:
  file.symlink:
    - name: {{pillar['fail2ban_config_directory']}}/action.d/mail-whois.local
    - target: mail.local

mail-whois-common.local:
  file.symlink:
    - name: {{pillar['fail2ban_config_directory']}}/action.d/mail-whois-common.local
    - target: mail.local

mail-whois-lines.local:
  file.symlink:
    - name: {{pillar['fail2ban_config_directory']}}/action.d/mail-whois-lines.local
    - target: mail.local

mail-buffered.local:
  file.symlink:
    - name: {{pillar['fail2ban_config_directory']}}/action.d/mail-buffered.local
    - target: mail.local

Restart fail2ban on config file change:
  cmd.run:
    - name: {{pillar['fail2ban_service_restart']}}
    - onchanges:
      - file: {{pillar['fail2ban_config_directory']}}/jail.local

