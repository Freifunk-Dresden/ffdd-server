dev:
  # To use the Development Enviroment
  # * disable autoupdate in /etc/nvram.conf
  # * change our /etc/salt/minion.d/ffdd-masterless.conf to:
  #
  # env_order: ['base', 'dev']
  # file_client: local
  # file_roots:
  # base:
  #   - $INSTALL_DIR/salt/freifunk/base
  # dev:
  #   - $INSTALL_DIR/salt/freifunk/dev
  #
  '*':
    - hostname

    # to use this Packages disable the Package in base/top.sls!
#    - ddmesh

#    - devel
#    - bmxd
#    - fastd
