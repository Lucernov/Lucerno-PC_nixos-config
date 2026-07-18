{ pkgs, myLib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" "docker" "sudo" "extract" "web-search"
        "command-not-found" "colored-man-pages" "history"
        "npm" "node" "python"
      ];
    };
    histFile = "$HOME/.zsh_history";
    histSize = 10000;
    saveHist = 10000;
    shellAliases = {
      l  = "lsd -l";
      ll = "lsd -la";
      ls = "lsd --icon always";
      la = "lsd -a";
      lt = "lsd --tree";
      cd = "z";
      gs  = "git status";
      gp  = "git pull";
      gc  = "git commit -m";
      gco = "git checkout";
      gb  = "git branch";
      mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop";
      sync   = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";
      update = "cd ${myLib.home}/${myLib.configDirName} && git add -A && git commit -m \"pre-rebuild\" && git push && nh os switch";
      upgrade = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && nh os switch --update";
      clean   = "nh clean all --keep 2 && nh os boot --update";
      parabolic = "org.nickvision.tubeconverter";
      chrome    = "google-chrome-stable --ozone-platform=x11";
      cat = "bat";
      top = "btop";
      neo- = "neo --defaultbg";
      discord-fix   = "find ~/.config/discord -type d -name modules -exec rm -rf {} \\; 2>/dev/null; rm -rf ~/.config/discord/Cache ~/.config/discord/Code\\ Cache ~/.config/discord/GPUCache ~/.config/discord/Service\\ Worker ~/.cache/discord; discord";
      discord-clean = "rm -rf ~/.config/discord ~/.cache/discord && discord";
    };
    interactiveShellInit = ''
      # Разрешение unfree пакетов
      export NIXPKGS_ALLOW_UNFREE=1

      # Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # Zoxide
      eval "$(zoxide init zsh)"

      # Ctrl+F для fzf+zoxide
      fzf-zoxide-widget() {
        local selected=$(zoxide query -l | fzf --preview 'tree -C {} | head -200')
        if [ -n "$selected" ]; then
          LBUFFER="cd $selected"
          zle accept-line
        fi
      }
      zle -N fzf-zoxide-widget
      bindkey '^F' fzf-zoxide-widget

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
}
