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
        command = "kitten quick-access-terminal";
      };
      "kitty-new-tab" = {
        name = "Kitty New Tab";
        key = "Ctrl+T";
        command = "kitty @ --to unix:/tmp/kitty-sock new-tab";
      };
      "kitty-close-tab" = {
        name = "Kitty Close Tab";
        key = "Ctrl+W";
        command = "kitty @ --to unix:/tmp/kitty-sock close-tab";
      };
    };
  };
}
