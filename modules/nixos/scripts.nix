# modules/scripts.nix
{ pkgs, ... }:

let
  videoPlayerScript = pkgs.writeShellScriptBin "video-player" ''
    #!/usr/bin/env bash
    CODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null)
    if [[ "$CODEC" == "av1" ]]; then
        exec mpv --hwdec=nvdec "$@"
    else
        exec vlc "$@"
    fi
  '';

  # Создаём .desktop-файл как отдельный пакет
  videoPlayerDesktop = pkgs.writeTextFile {
    name = "video-player-desktop";
    destination = "/share/applications/video-player.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Video Player (AV1-aware)
      Exec=video-player %F
      MimeType=video/mp4;video/x-matroska;video/avi;video/quicktime;video/webm;
      Icon=video-x-generic
      Terminal=false
      Categories=AudioVideo;Player;
    '';
  };
in {
  environment.systemPackages = [ videoPlayerScript videoPlayerDesktop ];
}
