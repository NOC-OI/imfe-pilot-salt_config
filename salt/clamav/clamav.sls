Install clamav related packages:
  pkg.installed:
    - pkgs:
      - {{pillar['clamav_pkg']}}

Clamav cronjob:
  file.managed:
     - name: /etc/cron.d/clamav
     - user: root
     - group: root
     - mode: 644
     - source: salt://clamav/files/clamav-cron

Clamav logrotate:
  file.managed:
     - name: /etc/logrotate.d/clamav
     - user: root
     - group: root
     - mode: 644
     - source: salt://clamav/files/clamav-logrotate

Clamscan script:
  file.managed:
     - name: /usr/local/bin/clamscan.sh
     - user: root
     - group: root
     - mode: 755
     - source: salt://clamav/files/clamscan.sh


