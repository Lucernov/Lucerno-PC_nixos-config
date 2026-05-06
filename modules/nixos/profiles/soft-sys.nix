{ pkgs, ... }:

{
  # ========== Базовые системные настройки ==========
  nixpkgs.config.allowUnfree = true;    # Разрешает установку проприетарных (не free) пакетов, например, google-chrome, nvidia driver и др.

  # ========== Включение системных модулей для программ ==========
  programs.git.enable = true;           # Включает поддержку Git (утилита системы контроля версий)
  programs.dconf.enable = true;         # Включает dconf – базу данных настроек для GTK-приложений (необходим для тем, шрифтов и т.п.)
  programs.zsh.enable = true;           # Устанавливает Zsh как системную оболочку (для всех пользователей)
  programs.vim.enable = true;           # Устанавливает Vim (текстовый редактор) системно
  programs.nano.enable = true;          # Устанавливает Nano (простой текстовый редактор) системно
  programs.htop.enable = true;          # Устанавливает htop (интерактивный монитор процессов) системно
  programs.amnezia-vpn.enable = true;   # Включает сервис AmneziaVPN (VPN-клиент)

  # ========== Дополнительные системные пакеты (устанавливаются вручную) ==========
  environment.systemPackages = with pkgs; [
    lf                                  # "List Files" – быстрый файловый менеджер на Go с vim-подобным управлением
    mc                                  # Midnight Commander – классический двухпанельный файловый менеджер (FTP, просмотр, редактор)
    unzip                               # Утилита для распаковки ZIP-архивов
    curl                                # Инструмент для передачи данных по сети (HTTP, FTP и др.)
    wget                                # Утилита для загрузки файлов из интернета
    # carbonyl                          # Консольный браузер
    nvtopPackages.nvidia                # Монитор использования видеокарты NVIDIA в консоли
    wayland-utils                       # Набор утилит для диагностики Wayland (например, wayland-info)
    gsettings-desktop-schemas           # Схемы настроек для GSettings (используются GTK-приложениями)
    glib                                # Базовая библиотека GLib (низкоуровневые структуры данных)
    libva-utils                         # Утилиты для VA-API (аппаратное ускорение видео)

    google-chrome                       # Браузер Google Chrome
  ];
}
