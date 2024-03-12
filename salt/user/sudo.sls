Ensure sudo-group exists:
  group.present:
    - name: {{pillar['sudo_group']}}
    - system: True

Ensure sudo-group has sudo:
  file.managed:
    - name: /etc/sudoers.d/sudo_group
    - source: salt://sudoers/sudo_group
    - template: jinja
    - user: root
    - group: root
    - mode: 0440
    - check_cmd: /usr/sbin/visudo -c -f
