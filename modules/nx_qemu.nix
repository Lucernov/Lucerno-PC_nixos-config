{ pkgs, ... }:

let
  networkXML = ''
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
in

{
  virtualisation = {
    libvirtd.enable = true;                                       # Включает сервис libvirtd (демон для управления QEMU/KVM)
    spiceUSBRedirection.enable = true;                            # Включает проброс USB-устройств через протокол SPICE (для виртуальных машин)
  };

  # Создаём XML-файл сети, но не запускаем и не включаем автозапуск
  environment.etc."libvirt/qemu/networks/default.xml".text = networkXML;

  # При активации системы определяем сеть (если её нет)
  system.activationScripts.libvirt-define-network = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.libvirt}/bin/virsh net-define /etc/libvirt/qemu/networks/default.xml 2>/dev/null || true
    '';
  };
}

# sudo virsh net-start default (Запуск виртуальной сети)
# sudo virsh net-list --all (статус сети)
# sudo virsh net-destroy default (остановка сети)
