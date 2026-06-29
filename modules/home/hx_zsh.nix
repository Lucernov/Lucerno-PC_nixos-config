{ myLib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;                          # Включает настройку Zsh через home-manager (генерирует ~/.zshrc)
    enableCompletion = true;                # Включает автодополнение команд (обычные completion)
    autosuggestion.enable = true;           # Включает автоматические подсказки (as-you-type) на основе истории
    syntaxHighlighting.enable = true;       # Включает подсветку синтаксиса команд в терминале

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;                        # Включает Oh My Zsh (коллекция тем и плагинов)
      #theme = "agnoster";                   # тема с информацией о git ветке
      plugins = [                           # Список плагинов
        "git"                               # Алиасы для Git (сокращает время набора) - gst, ga, gc, gp
        "docker"                            # Алиасы для Docker - dps, drm, dstop
        "sudo"                              # Добавляет sudo перед последней командой [Esc][Esc]
        "extract"                           # Распаковывает любой архив (7z, rar, zip, tar...) extract file.zip
        "web-search"                        # Поиск в браузере прямо из терминала - google nixos, youtube linux
        "command-not-found"                 # Предлагает установить пакет через nix - неизвестная_команда
        "colored-man-pages"                 # Цветные man страницы - man ls
        "history"                           # Показывает историю команд - h или history
        "npm"                               # Автодополнения
        "node"                              # Автодополнения
        "python"                            # Автодополнения
      ];
    };

    # Настройки истории
    history = {
      size = 10000;                         # Сколько команд хранить в памяти
      path = "$HOME/.zsh_history";          # Файл с историей
      share = true;                         # Общая история между всеми терминалами
      save = 10000;                         # Сколько команд сохранять в файл
      extended = true;                      # Включает расширенный формат истории с временными метками
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

      # Подключаем Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      # Загружаем пользовательскую конфигурацию, если она есть
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

  # Инициализация zoxide (без замены cd)
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

      # Путь к локальным скриптам
      #export PATH="$HOME/.local/bin:$PATH"

      # Промпт
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
      RPROMPT='%F{red}$(git branch --show-current 2>/dev/null)%f'
    '';

  };
}
