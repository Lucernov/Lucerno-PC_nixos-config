{ myLib, ... }:
{
  programs.zsh = {
    enable = true;                          # Включает настройку Zsh через home-manager (генерирует ~/.zshrc)
    enableCompletion = true;                # Включает автодополнение команд (обычные completion)
    autosuggestion.enable = true;           # Включает автоматические подсказки (as-you-type) на основе истории
    syntaxHighlighting.enable = true;       # Включает подсветку синтаксиса команд в терминале

    shellAliases = {
      ll = "ls -la";
      la = "ls -a";
      l = "ls -l";
      gs = "git status";
      gp = "git pull";
      gc = "git commit -m";
      gco = "git checkout";
      gb = "git branch";
      mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop";
      sync = "cd /home/lucerno/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";
      hm = "cd /home/lucerno/${myLib.configDirName} && git add -A && (git commit -m \"hm: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && export NIXPKGS_ALLOW_UNFREE=1 && nh home switch";
      update = "cd /home/lucerno/${myLib.configDirName} && git add -A && git commit -m \"pre-rebuild\" && git push && nh os switch";
      upgrade = "cd /home/lucerno/${myLib.configDirName} && git add -A && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && nh os switch --update";
      clean = "nh clean all --keep 2 && nh os boot --update";
      parabolic = "org.nickvision.tubeconverter";
      chrome = "google-chrome-stable --ozone-platform=x11";
      cat="bat";
      top="btop";
    };

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;                      # Включает Oh My Zsh (коллекция тем и плагинов)
      theme = "agnoster";                 # тема с информацией о git ветке
      plugins = [                         # Список плагинов
        "git"                             # Алиасы для Git (сокращает время набора) - gst, ga, gc, gp
        "docker"                          # Алиасы для Docker - dps, drm, dstop
        "sudo"                            # Добавляет sudo перед последней командой [Esc][Esc]
        "extract"                         # Распаковывает любой архив (7z, rar, zip, tar...) extract file.zip
        "web-search"                      # Поиск в браузере прямо из терминала - google nixos, youtube linux
        "command-not-found"               # Предлагает установить пакет через nix - неизвестная_команда
        "colored-man-pages"               # Цветные man страницы - man ls
        "history"                         # Показывает историю команд - h или history
        "npm"                             # Автодополнения
        "node"                            # Автодополнения
        "python"                          # Автодополнения
      ];
    };

    # Настройки истории
    history = {
      size = 10000;                       # Сколько команд хранить в памяти
      path = "$HOME/.zsh_history";        # Файл с историей
      share = true;                       # Общая история между всеми терминалами
      save = 10000;                       # Сколько команд сохранять в файл
      extended = true;                    # Включает расширенный формат истории с временными метками
    # Полезные команды:
    # показать историю - history
    # повторить последнюю команду - !!
    # выполнить команду под номером 123 - !123
    # выполнить последнюю команду начинающуюся с ls - !ls
    # поиск по истории - Ctrl+R
    };

    initContent = ''
      # Разрешение unfree пакетов для home-manager
      export NIXPKGS_ALLOW_UNFREE=1

      # Путь к локальным скриптам
      #export PATH="$HOME/.local/bin:$PATH"

      # Промпт
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
      RPROMPT='%F{red}$(git branch --show-current 2>/dev/null)%f'
    '';

  };
}
