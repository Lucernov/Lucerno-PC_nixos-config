_ :

{
  services.zapret = {
    enable = true;
    params = [
      "--dpi-desync=fake,disorder2"
      "--dpi-desync-ttl=1"
      "--dpi-desync-autottl=2"
    ];
    # whitelist = [ "youtube.com" "googlevideo.com" ]; # Раскомментируйте для обхода только этих доменов
    # httpMode = "full"; # Раскомментируйте, если http не работает
  };
}
