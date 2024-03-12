remove ufw:
  pkg.removed:
    - name: {{pillar['ufw-pkg']}}

iptables-persistent:
  pkg.installed:
    - name: {{pillar['iptables-persist_pkg']}}

ensure starting from empty:
  iptables.flush:
    - table: filter
    - family: ipv4

flush user chains:
  cmd.run:
    - name: iptables -X

ensure UDP chain:
  iptables.chain_present:
    - table: filter
    - name: UDP

ensure TCP chain: 
  iptables.chain_present:
    - table: filter
    - name: TCP

ensure DOCKER chain:
   iptables.chain_present:
    - table: filter
    - name: DOCKER

ensure DOCKER-ISOLATION chain:
   iptables.chain_present:
    - table: filter
    - name: DOCKER-ISOLATION

allow DOCKER-ISOLATION return:
  iptables.append:
    - table: filter
    - chain: DOCKER-ISOLATION
    - protocol: all
    - jump: RETURN
    - save: True

drop forwards:
  iptables.set_policy:
    - chain: FORWARD
    - policy: DROP
    - save: True

allow outgoing:
  iptables.set_policy:
    - chain: OUTPUT
    - policy: ACCEPT
    - save: True

drop incoming:
  iptables.set_policy:
    - chain: INPUT
    - policy: DROP
    - save: True

allow established:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - ctstate: RELATED,ESTABLISHED
    - match: conntrack
    - save: True

allow loopback:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo
    - save: True    

drop invalid:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: conntrack
    - ctstate: INVALID
    - jump: DROP
    - save: True    

allow new pings:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: icmp
    - icmp-type: 8
    - match: conntrack
    - ctstate: NEW
    - jump: ACCEPT
    - save: True    

forward new udp to udp chain:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: udp
    - match: conntrack
    - ctstate: NEW
    - jump: UDP
    - save: True

forward new tcp to tcp chain:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: tcp
    - syn: ""
    - match: conntrack
    - ctstate: NEW
    - jump: TCP
    - save: True

forward docker-isolation:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: all
    - out: any
    - in-interface: any
    - jump: DOCKER-ISOLATION

forward docker:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: all
    - out: docker0
    - in-interface: any
    - jump: DOCKER

forward docker related and established:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: all
    - out: docker0
    - in-interface: any
    - match: conntrack
    - ctstate: RELATED,ESTABLISHED
    - jump: ACCEPT

forward docker to not docker:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: all
    - out: "!docker0"
    - in-interface: docker0
    - jump: ACCEPT

forward docker to docker:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: all
    - out: docker0
    - in-interface: docker0
    - jump: ACCEPT

reject other udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: udp
    - jump: REJECT
    - reject-with: icmp-port-unreachable
    - save: True    

reject other tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: tcp
    - jump: REJECT
    - reject-with: tcp-reset
    - save: True    

reject other:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: REJECT
    - reject-with: icmp-proto-unreachable
    - save: True    

accept ssh:
  iptables.append:
    - table: filter
    - chain: TCP
    - jump: ACCEPT
    - protocol: TCP
    - dport: 22
    - save: True    

{% if 'open_ports' in pillar %}

{% if 'tcp' in pillar['open_ports'] %}
  {% for port in pillar['open_ports']['tcp'] %}
    {% if port is iterable and 'dport' in port %}
open tcp {{port['dport']}}:
  iptables.append:
    - table: filter
    - chain: TCP
    - jump: ACCEPT
    - protocol: TCP
    - dport: {{port['dport']}}
    - source: {{port['source']}}
    - save: True
    {% else %}
open tcp {{port}}:
  iptables.append:
    - table: filter
    - chain: TCP
    - jump: ACCEPT
    - protocol: TCP
    - dport: {{port}}
    - save: True
    {% endif %}
  {% endfor %}
{% endif %}

{% if 'udp' in pillar['open_ports'] %}
  {% for port in pillar['open_ports']['udp'] %}
    {% if port is iterable and 'dport' in port %}
open ucp {{port['dport']}}:
  iptables.append:
    - table: filter
    - chain: UDP
    - jump: ACCEPT
    - protocol: UDP
    - dport: {{port['dport']}}
    - source: {{port['source']}}
    - save: True
    {% else %}
open udp {{port}}:
  iptables.append:
    - table: filter
    - chain: UDP
    - jump: ACCEPT
    - protocol: UDP
    - dport: {{port}}
    - save: True
    {% endif %}
  {% endfor %}
{% endif %}

{% endif %}

iptables:
   service.running:
     - enable: True
     - reload: True
