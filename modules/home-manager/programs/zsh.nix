{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
# Полезные команды:
# показать историю - history
# повторить последнюю команду - !!
# выполнить команду под номером 123 - !123
# выполнить последнюю команду начинающуюся с ls - !ls
# поиск по истории - Ctrl+R
    };

    shellAliases = {
      ll = "ls -la";
      la = "ls -a";
      l = "ls -l";
      gs = "git status";
      gp = "git pull";
      gc = "git commit -m";
      gco = "git checkout";
      gb = "git branch";
      hm = "export NIXPKGS_ALLOW_UNFREE=1 && nix run github:nix-community/home-manager -- switch --flake .#lucerno --impure";
      sync = "cd /home/lucerno/nixos-config && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";
      update = "cd /home/lucerno/nixos-config && git add -A && git commit -m \"pre-rebuild\" && git push && sudo nixos-rebuild switch --impure --flake .#Lucerno-PC";
      upgrade = "cd /home/lucerno/nixos-config && nix flake update && git add -A && (git commit -m \"upgrade: $(date)\" || true) && git push && sudo nixos-rebuild switch --impure --flake .#Lucerno-PC";
      #steam = "taskset -c 0-11 steam";
      #reaper = "taskset -c 0-11 reaper";
    };

    initContent = ''
      # Переменные окружения для игр
      export PROTON_USE_NTSYNC=1
      export PROTON_NO_ESYNC=1
      export PROTON_NO_FSYNC=1

      # Разрешение unfree пакетов для home-manager
      export NIXPKGS_ALLOW_UNFREE=1

      # Путь к локальным скриптам
      export PATH="$HOME/.local/bin:$PATH"

      # Утилиты для удобства
      alias cat="bat"
      alias top="btop"

      # Промпт
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
      RPROMPT='%F{red}$(git branch --show-current 2>/dev/null)%f'
    '';
  };
}
