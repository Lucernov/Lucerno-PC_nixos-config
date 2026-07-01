{ myLib, ... }:

{
  programs.zsh.shellAliases = {
    # ========== Навигация и файлы ==========
    l  = "lsd -l";                                             # подробный список файлов
    ll = "lsd -la";                                            # подробный список со скрытыми файлами
    ls = "lsd --icon always";                                  # обычный список с иконками
    la = "lsd -a";                                             # показать все файлы (включая скрытые)
    lt = "lsd --tree";                                         # древовидный вывод
    cd = "z";                                                  # умная навигация через zoxide (запоминает посещённые папки)

    # ========== Git ==========
    gs  = "git status";                                        # статус репозитория
    gp  = "git pull";                                          # скачать изменения из удалённого репозитория
    gc  = "git commit -m";                                     # создать коммит с сообщением (использовать: gc "message")
    gco = "git checkout";                                      # переключиться на ветку или восстановить файл
    gb  = "git branch";                                        # показать ветки

    # ========== Мониторинг ==========
    mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop";   # открыть pw-top и nvtop в сплитах Kitty

    # ========== Управление конфигурацией Nix ==========
    sync   = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";   # синхронизировать конфиг с Git
    hm     = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"hm: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && export NIXPKGS_ALLOW_UNFREE=1 && nh home switch";   # пересобрать home-manager и записать изменения
    update = "cd ${myLib.home}/${myLib.configDirName} && git add -A && git commit -m \"pre-rebuild\" && git push && nh os switch";   # пересобрать NixOS без обновления входов
    upgrade = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && nh os switch --update";   # пересобрать NixOS с обновлением flake.lock
    clean   = "nh clean all --keep 2 && nh os boot --update";  # очистить старые поколения, обновить входы и переключиться

    # ========== Приложения ==========
    parabolic = "org.nickvision.tubeconverter";                # запустить Parabolic (загрузчик видео/аудио с YouTube)
    chrome    = "google-chrome-stable --ozone-platform=x11";   # запустить Chrome в X11-режиме (чтобы избежать проблем с Wayland)

    # ========== Замена утилит ==========
    cat = "bat";                                               # использовать bat вместо cat (подсветка синтаксиса)
    top = "btop";                                              # использовать btop вместо top (красивый мониторинг)

    # ========== Эффекты ==========
    neo- = "neo --defaultbg";                                  # матричный дождь на фоне терминала

    # ========== Discord ==========
    discord-fix   = "find ~/.config/discord -type d -name modules -exec rm -rf {} \\; 2>/dev/null; rm -rf ~/.config/discord/Cache ~/.config/discord/Code\\ Cache ~/.config/discord/GPUCache ~/.config/discord/Service\\ Worker ~/.cache/discord; discord";   # очистка кеша Discord без потери токена
    discord-clean = "rm -rf ~/.config/discord ~/.cache/discord && discord";   # полная очистка кеша Discord перед запуском
  };
}
