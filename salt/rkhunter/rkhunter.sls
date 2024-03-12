Install rkhunter packages:
  pkg.installed:
    - pkgs:
      - {{pillar['rkhunter_pkg']}}


# hack to stop rkhunter breaking when it can't find /usr/bin/lwp-request
{% if grains.os_family == 'Debian' %}
Install lwp:
  pkg.installed:
    - pkgs:
      - {{ pillar['lwp_pkg'] }}
{% endif %}

{% if grains.os_family == 'RedHat' %}
rkhunter_tmp:
  file.directory:
    - name: /var/lib/rkhunter/tmp
    - user: root
    - group: root
    - mode: 755
{% endif %}

rkhunter config:
  file.managed:
     - name: {{pillar['rkhunter_config_file']}}
     - user: root
     - group: root
     - mode: 644
     - source: salt://rkhunter/files/rkhunter-conf


rkhunter default:
  file.managed:
     - name: {{pillar['rkhunter_default_file']}}
     - user: root
     - group: root
     - mode: 644
     - source: salt://rkhunter/files/rkhunter-default

