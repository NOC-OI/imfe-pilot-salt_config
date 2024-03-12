configure docker proxy:
    file.absent:
        - name: /etc/systemd/system/docker.service.d/proxy.conf

reload docker:
     cmd.run:
         - name: |
             systemctl daemon-reload
             systemctl restart docker
