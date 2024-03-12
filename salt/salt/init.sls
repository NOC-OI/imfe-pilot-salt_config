{% set version = "latest" %}


salt_repo:
  pkgrepo.managed:
    - humanname: SaltStack Repo
    - name: {{ "deb [arch=%s] https://repo.saltproject.io/salt/py3/ubuntu/%s/%s/%s %s main" % (grains['osarch'],grains['osrelease'],grains['osarch'],version,grains['oscodename'])}}
    - file: /etc/apt/sources.list.d/salt.list
    - keyurl: {{ "https://repo.saltproject.io/salt/py3/ubuntu/%s/%s/SALT-PROJECT-GPG-PUBKEY-2023.pub" % (grains['osarch'],grains['osrelease'])}}
    - clean_file: True

salt_pkgs:
  pkg.latest:
    - name: salt-minion
    - require:
      - pkgrepo: salt_repo
