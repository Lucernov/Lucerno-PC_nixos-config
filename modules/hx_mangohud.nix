{ ... }:
{
  programs.mangohud = {
    enable = true;
    package = null;
    enableSessionWide = false;
    settings = {
      fps = true;
      cpu_temp = true;
      gpu_temp = true;
      ram = true;
      vram = true;
      winesync = true;
      position = "top-right";
      font_size = 24;
      background_alpha = 0.5;
      full = true;
    };
  };
}
