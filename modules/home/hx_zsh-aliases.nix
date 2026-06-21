{ myLib, ... }:
{
  programs.zsh.shellAliases = {
    ll = "ls -la";
    la = "ls -a";
    l = "ls -l";
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
  };
}
