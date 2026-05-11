{ inputs, ... }:

let
  myLib = import ../lib.nix;
in
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  programs.plasma = {
    enable = true;
    workspace = {
      wallpaper = myLib.wallpaperPath;
    };
    configFile."kxkbrc".Layout = {
      LayoutList = "us,ru";
      LayoutLoopCount = "-1";
      ResetOldOptions = "true";
      Options = "grp:ctrl_shift_toggle,grp_led:scroll";
      ShowLayoutIndicator = "true";
      SwitchMode = "Global";
      Use = "true";
      VariantList = "";
    };
    hotkeys.commands = {
      "kitty-quake" = {
        name = "Kitty Quake Mode";
        key = "Meta+Z";
        #command = "kitten quick-access-terminal";
        #command = "kitten quick-access-terminal --config /home/lucerno/.config/kitty/quick-access-terminal.conf";
        command = "kitten quick-access-terminal --config /home/lucerno/.config/kitty/quick-access-terminal.conf --size 70% 50% --position center,center";
      };
    };
  };
}
