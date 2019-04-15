{# linux-headers #}
{# for Wireguard #}
{% from 'config.jinja' import kernel_release, kernel_pkg_check %}

{# install only than Kernel Package available #}
{% if kernel_pkg_check >= '1' %}

linux-headers:
  pkg.installed:
    - name: linux-headers-{{ kernel_release }}
    - refresh: True
