mc installed:
    pkg.installed:
        - name: {{pillar['mc_pkg']}}

netstat installed:
    pkg.installed:
        - name: {{pillar['netstat_pkg']}}

alien installed:
    pkg.installed:
        - name: {{pillar['alien_pkg']}}

bwm_ng installed:
    pkg.installed:
        - name: {{pillar['bwmng_pkg']}}

pwgen installed:
    pkg.installed:
        - name: {{pillar['pwgen_pkg']}}

jq installed:
    pkg.installed:
        - name: {{pillar['jq_pkg']}}
