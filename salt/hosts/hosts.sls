gateway:
  host.present:
    - ip: {{pillar['gateway_ip']}}

web:
  host.present:
    - ip: {{pillar['web_ip']}}

build:
  host.present:
    - ip: {{pillar['build_ip']}}
