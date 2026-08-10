_ :

{
  # ========== Виртуализация ==========
  virtualisation = {
    libvirtd.enable = true;                                       # Включает сервис libvirtd (демон для управления QEMU/KVM)
    spiceUSBRedirection.enable = true;                            # Включает проброс USB-устройств через протокол SPICE (для виртуальных машин)

    # Определяем сеть default для NAT-подключения виртуальных машин
    libvirtd.networks = [
      {
        name = "default";
        xml = ''
          <network>
            <name>default</name>
            <forward mode='nat'>
              <nat>
                <port start='1024' end='65535'/>
              </nat>
            </forward>
            <bridge name='virbr0' stp='on' delay='0'/>
            <domain name='default'/>
            <ip address='192.168.122.1' netmask='255.255.255.0'>
              <dhcp>
                <range start='192.168.122.2' end='192.168.122.254'/>
              </dhcp>
            </ip>
          </network>
        '';
      }
    ];
  };
}
