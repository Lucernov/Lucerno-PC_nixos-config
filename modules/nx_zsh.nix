# modules/nx_zsh.nix
{ pkgs, myLib, ... }:

let
  configDir = myLib.configDirName;

  # Генерируем .zshrc — сначала загружаем системный файл, затем наши дополнения
  zshrcContent = pkgs.writeText ".zshrc" ''
    # Загружаем системные настройки (включая алиасы из aliases.nix)
    source /etc/zshrc

    # ====== Дополнительные настройки поверх системных ======
    # Подключаем Oh My Zsh (если системный не подключает)
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

    # Подключаем Powerlevel10k (если системный не подключает)
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # Инициализация zoxide (если системный не инициализирует)
    eval "$(zoxide init zsh)"

    # Виджет fzf+zoxide (Ctrl+F)
    fzf-zoxide-widget() {
      local selected=$(zoxide query -l | fzf --preview 'tree -C {} | head -200')
      if [ -n "$selected" ]; then
        LBUFFER="cd $selected"
        zle accept-line
      fi
    }
    zle -N fzf-zoxide-widget
    bindkey '^F' fzf-zoxide-widget

    # Дополнительные настройки истории (если системные не устраивают)
    setopt EXTENDED_HISTORY
    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_VERIFY
    setopt SHARE_HISTORY
    HISTFILE=$HOME/.zsh_history
    SAVEHIST=10000
    HISTSIZE=10000

    # Автодополнение (если системное не включено)
    autoload -Uz compinit && compinit
  '';
in
{
  programs.zsh.enable = true;  # регистрируем Zsh как оболочку

  systemd.tmpfiles.rules = [
    # Создаём симлинк на наш .zshrc
    "L+ ${myLib.home}/.zshrc - ${myLib.userName} ${myLib.userName} - ${zshrcContent}"
    # Симлинк для пользовательского .p10k.zsh (если есть)
    "L+ ${myLib.home}/.p10k.zsh - ${myLib.userName} ${myLib.userName} - ${myLib.home}/${configDir}/dotfiles/config/zsh/.p10k.zsh"
  ];
}
