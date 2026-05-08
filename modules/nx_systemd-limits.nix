{ ... }:

{
  # ========== Увеличение лимитов для сервисов KDE Plasma ==========
  # Эти настройки решают проблему "Too many open files" (слишком много открытых файлов), из-за которой KDE Plasma могла падать при большом количестве открытых дескрипторов (например, из-за утечек в виджетах или драйвере NVIDIA)
  systemd.user.services.plasma-plasmashell = {
    overrideStrategy = "asDropin";    # Переопределяем сервис, добавляя только изменения (asDropin), чтобы не копировать весь оригинальный файл service
    serviceConfig = {
      LimitNOFILE = 16384;            # Увеличиваем мягкий и жёсткий лимит на количество открытых файлов до 16384. Выбрано как безопасный запас (обычно достаточно 1024-4096)
      # Переопределяем PATH для plasmashell, чтобы он мог находить команды из профиля пользователя и системных каталогов. Без этого при запуске из меню KDE некоторые приложения не находились
      #Environment = "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/lucerno/bin:/nix/var/nix/profiles/default/bin:/home/lucerno/.local/bin";
    };
  };

  systemd.user.services.kwin_wayland = {
    serviceConfig = {
      LimitNOFILE = 16384;            # Аналогично увеличиваем лимиты для оконного менеджера KWin
    };
  };
}
