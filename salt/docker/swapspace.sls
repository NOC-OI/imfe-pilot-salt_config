{{ pillar['swapfile'] }}:
  cmd.run:
    - name: |
        [ -f {{ pillar['swapfile'] }} ] || dd if=/dev/zero of={{ pillar['swapfile'] }} bs=1M count={{ grains["mem_total"] }}
        chmod 0600 {{ pillar['swapfile'] }}
        mkswap {{ pillar['swapfile'] }}
        swapon -a
    - unless:
      - file {{ pillar['swapfile'] }} 2>&1 | grep -q "Linux swap file"
  mount.swap:
    - persist: true
