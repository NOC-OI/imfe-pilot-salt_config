Ensure user example:
  user.present:
    - name: example
    - password: $6$yk/Ma8WeRbfPy984$1AtwOexmlE7JsyBOTAur18Hc2DppS8HX.2R79hLz17Nr/1LXdRZhHSq6WOq4D/dQGFiyrIwyZocjDrMtHgBeJ2
    - enforce_password: false
    - shell: /bin/bash
    - home: /home/example
    - groups:
      - {{pillar['sudo_group']}}
      - {{pillar['docker_group']}}

example ssh key:
   ssh_auth.present:
     - user: example
     - enc: ssh-ed25519
     - names:
       - ssh-ed25519 AAAAC3M example@laptop

