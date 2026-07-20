{ pkgs, myLib, ... }:

let
  configDir = myLib.configDirName;
in

{
  programs.zsh = {
    enable = true;                                               # Включает настройку Zsh через home-manager (генерирует ~/.zshrc)
    enableCompletion = true;                                     # Включает автодополнение команд (обычные completion)
    autosuggestions.enable = true;                               # Включает автоматические подсказки (as-you-type) на основе истории
    syntaxHighlighting.enable = true;                            # Включает подсветку синтаксиса команд в терминале
    ohMyZsh = {
      enable = true;                                             # Включает Oh My Zsh (коллекция тем и плагинов)
      plugins = [                                                # Список плагинов
        "git"                                                    # Алиасы для Git (сокращает время набора) - gst, ga, gc, gp
        "docker"                                                 # Алиасы для Docker - dps, drm, dstop
        "sudo"                                                   # Добавляет sudo перед последней командой [Esc][Esc]
        "extract"                                                # Распаковывает любой архив (7z, rar, zip, tar...) extract file.zip
        "web-search"                                             # Поиск в браузере прямо из терминала - google nixos, youtube linux
        "command-not-found"                                      # Предлагает установить пакет через nix - неизвестная_команда
        "colored-man-pages"                                      # Цветные man страницы - man ls
        "history"                                                # Показывает историю команд - h или history
        "npm"                                                    # Автодополнения
        "node"                                                   # Автодополнения
        "python"                                                 # Автодополнения
      ];
    };
    histFile = "$HOME/.zsh_history";                             # Файл с историей
    histSize = 10000;                                            # Сколько команд хранить в памяти

    shellAliases = {
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
      mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop"; # открыть pw-top и nvtop в сплитах Kitty

      # ========== Управление конфигурацией Nix ==========
      sync   = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push"; # синхронизировать конфиг с Git
      update = "cd ${myLib.home}/${myLib.configDirName} && git add -A && git commit -m \"pre-rebuild\" && git push && nh os switch";  # пересобрать NixOS без обновления входов
      upgrade = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"pre-upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && nh os switch --update && git add flake.lock && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";  # пересобрать NixOS с обновлением flake.lock
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
      discord-fix   = "find ~/.config/discord -type d -name modules -exec rm -rf {} \\; 2>/dev/null; rm -rf ~/.config/discord/Cache ~/.config/discord/Code\\ Cache ~/.config/discord/GPUCache ~/.config/discord/Service\\ Worker ~/.cache/discord; discord";  # очистка кеша Discord без потери токена
      discord-clean = "rm -rf ~/.config/discord ~/.cache/discord && discord"; # полная очистка кеша Discord перед запуском
    };

    # ========== Интерактивная инициализация Zsh ==========
    interactiveShellInit = ''
      # Разрешение unfree пакетов
      export NIXPKGS_ALLOW_UNFREE=1

      # Подключаем Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # Инициализация zoxide
      eval "$(zoxide init zsh)"

      # ---------- Интеграция zoxide + fzf (Ctrl+F) ----------
      # Виджет для быстрого перехода в папку через fzf
      fzf-zoxide-widget() {
        local selected=$(zoxide query -l | fzf --preview 'tree -C {} | head -200')
        if [ -n "$selected" ]; then
          LBUFFER="cd $selected"
          zle accept-line
        fi
      }
      zle -N fzf-zoxide-widget
      bindkey '^F' fzf-zoxide-widget
      # -----------------------------------------------------

      # Промпт
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
      RPROMPT='%F{red}$(git branch --show-current 2>/dev/null)%f'

      # Настройка истории
      setopt EXTENDED_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
    '';
  };

    # ========== Правила tmpfiles для zsh ==========
  systemd.tmpfiles.rules = [
    # .zshrc
    "L+ ${myLib.home}/.zshrc - lucerno lucerno - ${pkgs.writeText ".zshrc" "source /etc/zshrc"}"
    # Симлинк для Powerlevel10k
    "L+ ${myLib.home}/.p10k.zsh - lucerno lucerno - ${myLib.home}/${configDir}/dotfiles/config/zsh/.p10k.zsh"
  ];
}

    # Полезные команды:
    # показать историю - history
    # повторить последнюю команду - !!
    # выполнить команду под номером 123 - !123
    # выполнить последнюю команду начинающуюся с ls - !ls
    # поиск по истории - Ctrl+R
