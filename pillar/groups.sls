{% if grains['os_family'] == 'Debian' %}
sudo_group: sudo
docker_group: docker
{% endif %}
