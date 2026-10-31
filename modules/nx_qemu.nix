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
    libvirtd.enable = true;                                       # Включить сервис libvirtd (демон для управления QEMU/KVM)
    spiceUSBRedirection.enable = true;                            # Включить проброс USB-устройств через протокол SPICE (для виртуальных машин)
  };

  # Создаём XML-файл сети
  environment.etc."libvirt/qemu/networks/default.xml".text = networkXML;

  # ─────────────────────────────────────────────────────────────────────────
  # СЕТЬ default ДЛЯ QEMU/KVM
  # Oneshot-сервис создаёт и поднимает NAT-сеть default. Стартует после libvirtd.service (after/requires), потому что virsh работает только через готовый сокет /var/run/libvirt/libvirt-sock
  # Все шаги идемпотентны: net-define — только если сети нет, net-start — только если не активна, net-autostart — всегда (повтор не ломает)
  # Ошибки не глушатся через `|| true` — причина видна в `systemctl status libvirt-default-network`
  # ─────────────────────────────────────────────────────────────────────────
  systemd.services.libvirt-default-network = {
    description = "Define and start libvirt default NAT network"; # Имя сервиса в systemctl (видно в systemctl status/list-units)
    after = [ "libvirtd.service" ];                               # Порядок запуска: стартовать ТОЛЬКО после libvirtd (иначе virsh не найдёт сокет)
    requires = [ "libvirtd.service" ];                            # Жёсткая зависимость: без libvirtd сервис не запускается
    wantedBy = [ "multi-user.target" ];                           # Автозапуск при загрузке

    serviceConfig = {
      Type = "oneshot";                                           # Одноразовый сервис (выполнился и завершился)
      RemainAfterExit = true;                                     # После успешного выполнения считать сервис активным, а не «exited»
    };

    script = ''
      set -e

      # Определить сеть, только если её ещё нет.
      # virsh net-info default возвращает 0, если сеть существует,
      # и ненулевой код, если нет. Идемпотентно: повторный запуск
      # на уже определённой сети ничего не ломает.
      ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 \
        || ${pkgs.libvirt}/bin/virsh net-define /etc/libvirt/qemu/networks/default.xml

      # Запустить сеть, если она ещё не активна.
      # Проверяем через net-info, чтобы не глушить реальные ошибки
      # (например, конфликт bridge-имени virbr0 с другим интерфейсом)
      # через `|| true`. Если сеть уже active — просто пропускаем.
      if ! ${pkgs.libvirt}/bin/virsh net-info default \
             | ${pkgs.gnugrep}/bin/grep -q "Active:.*yes"; then
        ${pkgs.libvirt}/bin/virsh net-start default
      fi

      # Включить автозапуск (идемпотентно: net-autostart на уже
      # автозапущенной сети возвращает 0).
      ${pkgs.libvirt}/bin/virsh net-autostart default
    '';
  };
}

# sudo virsh net-start default (Запуск виртуальной сети)
# sudo virsh net-list --all (статус сети)
# sudo virsh net-destroy default (остановка сети)

# sudo qemu-img create -f qcow2 /mnt/sys_archiv/windows/win11.qcow2 60G (создание диска для виртуалки)
