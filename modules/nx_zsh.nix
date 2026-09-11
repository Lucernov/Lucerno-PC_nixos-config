# modules/nx_zsh.nix
{ config, pkgs, myLib, lib, ... }:

let
  configDir = myLib.configDirName;

  # Получаем алиасы из модуля aliases.nix (они определены как programs.zsh.shellAliases)
  aliases = config.programs.zsh.shellAliases or {};
  # Превращаем атрибуты в строки alias
  aliasLines = lib.mapAttrsToList (name: value: "alias ${name}='${builtins.replaceStrings ["'"] ["'\\''"] value}'") aliases;
  aliasString = builtins.concatStringsSep "\n" aliasLines;

  # Генерируем .zshrc без системного файла
  zshrcContent = pkgs.writeText ".zshrc" ''
    # ====== PATH ======
    # В этом файле PATH НЕ задаётся — это сделано осознанно, чтобы не плодить дубли.
    # Источники PATH в системе:
    #   1. ~/.zshenv                                    — ~/.local/bin для ВСЕХ zsh
    #   2. ~/.config/plasma-workspace/env/path.sh      — ~/.local/bin для всех KDE приложений
    #   3. NixOS PAM (/etc/pam/environment)            — базовые системные пути
    #   4. kitty wrapper nixpkgs                        — хвост nix-store внутри kitty
    #                                                      (см. modules/nx_kitty.nix)
    # Проверка:  echo $PATH | tr ':' '\n'

    # ====== Oh My Zsh ======
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
    ZSH_THEME=""   # Отключаем тему Oh My Zsh, используем Powerlevel10k отдельно
    plugins=(
      git
      docker
      sudo
      extract
      web-search
      command-not-found
      colored-man-pages
      history
      npm
      node
      python
    )
    source $ZSH/oh-my-zsh.sh

    # ====== Nix окружение - nix-shell запускает zsh вместо bash ======
    export NIX_BUILD_SHELL=zsh

    # ====== Powerlevel10k ======
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # ====== zoxide ======
    eval "$(zoxide init zsh)"

    # ====== Виджет fzf+zoxide (Ctrl+F) ======
    fzf-zoxide-widget() {
      local selected=$(zoxide query -l | fzf --preview 'tree -C {} | head -200')
      if [ -n "$selected" ]; then
        LBUFFER="cd $selected"
        zle accept-line
      fi
    }
    zle -N fzf-zoxide-widget
    bindkey '^F' fzf-zoxide-widget

    # ====== Настройки истории ======
    setopt EXTENDED_HISTORY
    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_VERIFY
    setopt SHARE_HISTORY
    HISTFILE=$HOME/.zsh_history
    SAVEHIST=10000
    HISTSIZE=10000

    # ====== Автодополнение ======
    autoload -Uz compinit && compinit

    # ====== Подсветка синтаксиса ======
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # ====== Автоподсказки ======
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    # ====== Алиасы (из aliases.nix) ======
    ${aliasString}
  '';

  # Генерируем ~/.zshenv: отключает глобальные rc-файлы и добавляет ~/.local/bin в PATH.
  # Читается ВСЕМИ zsh-шеллами (login и non-login), поэтому покрывает TTY/SSH.
  zshenvContent = pkgs.writeText ".zshenv" ''
    setopt no_global_rcs

    # Идемпотентное добавление ~/.local/bin в PATH.
    # Проверка нужна, чтобы повторный source не создал дубль.
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi
  '';

in

{
  systemd.tmpfiles.rules = [
    # Создаём симлинк на наш .zshrc
    "L+ ${myLib.home}/.zshrc - ${myLib.userName} ${myLib.userName} - ${zshrcContent}"
    # Создаём симлинк на .zshenv (отключает системные файлы)
    "L+ ${myLib.home}/.zshenv - ${myLib.userName} ${myLib.userName} - ${zshenvContent}"
    # Симлинк для пользовательского .p10k.zsh (если есть)
    "L+ ${myLib.home}/.p10k.zsh - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/zsh/.p10k.zsh"
  ];
}
