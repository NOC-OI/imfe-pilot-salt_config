make docker service dir:
    file.directory:
        - name: /etc/systemd/system/docker.service.d
        - mode: '0660'
        - user: root
        - group: root

configure docker proxy:
    file.managed:
        - name: /etc/systemd/system/docker.service.d/proxy.conf
        - mode: '0660'
        - user: root
        - group: root
        - source: salt://docker/files/proxy.conf
        - template: jinja

reload docker:
     cmd.run:
         - name: |
             systemctl daemon-reload
             systemctl restart docker
