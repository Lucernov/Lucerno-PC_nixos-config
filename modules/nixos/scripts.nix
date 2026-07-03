# modules/scripts.nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "video-player" ''
      #!/usr/bin/env bash
      CODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null)
      if [[ "$CODEC" == "av1" ]]; then
          exec mpv --hwdec=nvdec "$@"
      else
          exec vlc "$@"
      fi
    '')
  ];
}
