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

  # Создаём XML-файл сети
  environment.etc."libvirt/qemu/networks/default.xml".text = networkXML;

  # При активации системы определяем, запускаем и включаем автозапуск сети
  system.activationScripts.libvirt-network = {
    supportsDryActivation = true;
    text = ''
      # Определяем сеть (если её нет)
      ${pkgs.libvirt}/bin/virsh net-define /etc/libvirt/qemu/networks/default.xml 2>/dev/null || true
      # Запускаем сеть (если не активна)
      ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
      # Включаем автозапуск
      ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
    '';
  };
}

# sudo virsh net-start default (Запуск виртуальной сети)
# sudo virsh net-list --all (статус сети)
# sudo virsh net-destroy default (остановка сети)

# sudo qemu-img create -f qcow2 /mnt/sys_archiv/windows/win11.qcow2 60G (создание диска для виртуалки)
