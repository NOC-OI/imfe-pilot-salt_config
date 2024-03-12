docker installed:
    pkg.installed:
        - name: {{ pillar['docker_pkg'] }}

docker-compose installed:
    pkg.installed:
        - name: {{ pillar['docker_compose_pkg'] }}


docker permissions:
    file.managed:
        - name: '/var/run/docker.sock'
        - mode: '0660'
        - user: root
        - group: docker
        - replace: False
