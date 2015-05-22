{% from "github/map.jinja" import github with context %}



git:
  pkg.installed


{{ github.target }}/{{ github.repository }}:
  file.directory:
    - user: {{ github.user }}


get_{{ github.repository }}:
  git.latest:
    - name: git@github.com:{{ github.gh_user }}/{{ github.repository }}.git
    - target: {{ github.target }}/{{ github.repository }}
    - user: {{ github.user }}
    - require:
      - file: {{ github.target }}/{{ github.repository }}
      - pkg: git
      - file: github_sshpriv
      - file: github_sshpub
      - ssh_known_hosts: github.com

{{ github.user }}:
  user.present:
    - shell: /bin/bash
    - password: {{ github.user_password }}
    - home: {{ github.target }}



ssh-folder:
  file.directory:
    - name: {{ github.target }}/.ssh
    - user: {{ github.user }}
    - group: {{ github.user }}
    - mode: 0700
    - require_in:
      - file: github_sshpriv
      - file: github_sshpub
      - ssh_known_hosts: github.com
    - require:
      - user: {{ github.user }}

github.com:
  ssh_known_hosts:
    - present
    - name: 'github.com'
    - user: {{ github.user }}
    - enc: ssh-rsa
    - fingerprint: {{ salt['pillar.get']('github:fingerprint') }}

github_sshpriv:
  file.managed:
    - name: {{ github.target }}/.ssh/id_rsa
    - user: {{ github.user }}
    - group: {{ github.user }}
    - mode: 0600
    - contents_pillar: github:sshpriv

github_sshpub:
  file.managed:
    - name: {{ github.target }}/.ssh/id_rsa.pub
    - user: {{ github.user }}
    - group: {{ github.user }}
    - mode: 0600
    - contents_pillar: github:sshpub


