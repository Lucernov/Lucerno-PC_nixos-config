{ myLib, ... }:
{
  programs.zsh.shellAliases = {
    l = "lsd -l";
    ll = "lsd -la";
    la = "lsd -a";
    lt = "lsd --tree";
    gs = "git status";
    gp = "git pull";
    gc = "git commit -m";
    gco = "git checkout";
    gb = "git branch";
    mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop";
    sync = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push";
    hm = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"hm: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && export NIXPKGS_ALLOW_UNFREE=1 && nh home switch";
    update = "cd ${myLib.home}/${myLib.configDirName} && git add -A && git commit -m \"pre-rebuild\" && git push && nh os switch";
    upgrade = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && nh os switch --update";
    clean = "nh clean all --keep 2 && nh os boot --update";
    parabolic = "org.nickvision.tubeconverter";
    chrome = "google-chrome-stable --ozone-platform=x11";
    cat="bat";
    top="btop";
    neo- = "neo --defaultbg";   # Использует фон терминала (прозрачный, если включён в Kitty)
    discord-clean = "rm -rf ~/.config/discord ~/.cache/discord && discord";   # ПОЛНАЯ очистка кеша Discord перед запуском
    discord-fix = "find ~/.config/discord -type d -name modules -exec rm -rf {} \\; 2>/dev/null; rm -rf ~/.config/discord/Cache ~/.config/discord/Code\\ Cache ~/.config/discord/GPUCache ~/.config/discord/Service\\ Worker ~/.cache/discord; discord";   # Очистка кеша Discord перед запуском с сохранением токена
  };
}
