#cloud-config
autoinstall:
  version: 1
  early-commands:
  - systemctl stop ssh # Prevent Packer connecting untill rebooted
  locale: nb_NO
  keyboard:
    layout: 'no'
  refresh-installer:
    update: true
    channel: stable
  apt:
    geoip: true
    preserve_sources_list: false
    primary:
    - arches: [amd64, i386]
      uri: http://no.archive.ubuntu.com/ubuntu
    - arches: [default]
      uri: http://ports.ubuntu.com/ubuntu-ports
  packages:
  - open-vm-tools
  storage: # https://curtin.readthedocs.io/en/latest/topics/storage.html
    layout:
      name: direct
  network:
    network:
      version: 2
      renderer: networkd
      ethernets:
        nics:
          match:
            name: ens*
          dhcp4: false
          dhcp6: false
          addresses:
          - ${ address }
          routes:
          - to: default
            via: ${ gateway }
          nameservers:
            addresses:
            %{~ for addr in nameservers ~}
            - ${ addr }
            %{~ endfor ~}
  identity:
    hostname: ${ hostname }
    username: ${ username }
    password: ${ password }
  ssh:
    install-server: true
    allow-pw: true
    %{~ if  length(ssh_keys) > 0 ~}
    authorized-keys:
    %{~ for key in ssh_keys ~}
    - ${ key }
    %{~ endfor ~}
    %{~ endif ~}
  user-data:
    timezone: "Europe/Oslo"
    disable_root: false
    package_update: true
    package_upgrade: false
    power_state:
      delay: 5
      mode: reboot
  late-commands: # OS mounted in /target
  - "sed -i -e \"2s/^.*/datasource_list: [ VMware,None ]/g\" /target/etc/cloud/cloud.cfg.d/90_dpkg.cfg"
  - curtin in-target --target=/target -- dpkg-reconfigure -f noninteractive cloud-init
  - curtin in-target --target=/target -- systemctl stop systemd-networkd-wait-online
  #- curtin in-target --target=/target -- systemctl stop systemd-networkd
  #- curtin in-target --target=/target -- systemctl disable systemd-networkd-wait-online
  #- curtin in-target --target=/target -- systemctl mask systemd-networkd-wait-online
  #- shutdown -r +5 # Force restart after 5m (security updates managed by provisioner).
