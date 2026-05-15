{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vaapi
      obs-pipewire-audio-capture
      obs-multi-rtmp
      obs-backgroundremoval
      obs-vintage-filter
      obs-streamlabs
      obs-source-clone
    ];
  };

# ========== MANGO HUD ==========
  programs.mangohud = {
    enable = true;
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
