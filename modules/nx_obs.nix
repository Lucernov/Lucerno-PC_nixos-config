{ config, pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    # Включаем аппаратное ускорение NVENC на NVIDIA
    package = pkgs.obs-studio.override { cudaSupport = true; };
    # Список плагинов
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vaapi
      obs-pipewire-audio-capture
      obs-multi-rtmp
      obs-backgroundremoval
      obs-vintage-filter
      obs-source-clone
    ];
  };
}
