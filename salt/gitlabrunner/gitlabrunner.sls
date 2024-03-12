gitlabrunner installed:
    pkg.installed:
     - sources:
       - url: https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_{{grains['osarch']}}.deb

gitlabrunner docker:
  user.present:
    - name: gitlab-runner
    - groups:
      - {{pillar['docker_group']}}
