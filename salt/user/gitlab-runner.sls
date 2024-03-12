Ensure user gitlab-runner:
  user.present:
    - name: gitlab-runner
    - enforce_password: false
    - shell: /bin/bash
    - home: /home/gitlab-runner
    - groups:
      - {{pillar['docker_group']}}

#note this key is manually generated, it will need changing if you reinstall the build vm
#ssh key gitlab-runner:
#   ssh_auth.present:
#     - user: gitlab-runner
#     - enc: ssh-ed25519
#     - names:
#       - ssh-ed25519 AAAAC4 gitlab-runner@build
#       - ssh-ed25519 AAAAD3 gitlab-runner@web


