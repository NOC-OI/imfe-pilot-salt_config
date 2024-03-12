base:
  '*':
    - hosts.hosts
    - misc_pkgs.misc_pkgs
    - docker.docker
    - user.sudo
    - user.example
    - salt.init
    - iptables.iptables
    - clamav.clamav
    - rkhunter.rkhunter
    - fail2ban.fail2ban

  'gateway':
    - certbot.certbot
    - apache.apache
    - user.gitlab-runner

  'web':
    - user.gitlab-runner
    - docker.swapspace
    - docker.noproxy

  'build':
    - docker.swapspace
    - gitlabrunner.gitlabrunner
    - docker.noproxy

