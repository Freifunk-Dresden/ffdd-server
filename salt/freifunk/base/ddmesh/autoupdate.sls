{# Freifunk Dresden - Autoupdate #}
{% from 'config.jinja' import freifunk_repo, branch, install_dir, autoupdate, custom_freifunk_repo, custom_branch %}

{% if autoupdate == 'xNEWx' %}
ffdd-server_repo:
  git.latest:

{% if custom_freifunk_repo != '' and custom_freifunk_repo != freifunk_repo %}
    - name: {{ custom_freifunk_repo }}
{% else %}
    - name: {{ freifunk_repo }}
{% endif %}

{% if custom_branch != '' and custom_branch != branch %}
    - rev: {{ custom_branch }}
{% else %}
    - rev: {{ branch }}
{% endif %}

    - target: {{ install_dir }}
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

apply_ffdd-server_update:
  cmd.run:
    - name: echo 'salt-call state.highstate --local -l error' | sudo at now + 1 min
    - onchanges:
        - ffdd-server_repo
{% endif %}
