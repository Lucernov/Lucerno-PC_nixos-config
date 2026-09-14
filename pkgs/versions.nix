# pkgs/versions.nix
{
  air-g-plugins = {                                                     # не обновляется (локальный репозиторий)
    version     = "1.0";
  };

  audioAssault = {                                                      # Общий сегмент пути для всех плагинов Audio Assault
    urlVersion = "109";
  };

  amp-locker = {                                                        # обновляется активно (Audio Assault)
    version  = "1.5.6";
    hash     = "sha256-pHh4SN6Vb7CFOOQD+9VFLlNch0lv4dU8EWXjSE68iv8=";
  };

  drum-locker = {
    version   = "1.0.2";
    hash      = "sha256-fX6k5C64wNlHK1QsrdClitWlFR33jymEdVO7QIVFNGs=";
  };

  drumlabooh  = {
    version   = "12.2.0";
    hash      = "sha256-IQ0XzIwJqGg+6FynmJBllyBIzWD3dgFfllOTEx0cMDM=";  # одноканальный
    hashMulti = "sha256-qdZJvXsUlEmmlTwUwO/C47OXM+gwRlu2cNRFGrJDi1A=";  # мультиканальный
  };

  je8086    = {                                                         # обновляется активно
    version = "2.2.16";
    hash    = "sha256-KoBRwHO2YJLl/bpAtzB/TPKYn2abiZ+hDaCjVqI+LFU=";
  };

  mtpdk        = {
    urlVersion = "2.1.5";
    version    = "2.1.5.1";
    hash       = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
  };

  orchestools = {                                                       # не обновляется (локальный репозиторий)
    version   = "1.0";
  };

  ostirus   = {                                                         # обновляется активно
    version = "2.2.16";
    hash    = "sha256-+3g9yEOb2Psjj/K9ZIY6GXYeIwIsRCtIEOrcUZ980eY=";
  };

  ot-piano-s = {                                                        # не обновляется (локальный репозиторий)
    version  = "1.0";
  };

  sforzando = {
    version = "1.982";
    hash    = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };

  shortcircuit-xt = {
    version       = "2026-07-31-7d79b3a";
    releaseTag    = "Nightly";
    hash          = "sha256-dbod6Bc7W2+ul0IUXFg9Olai75VhLAtXMobj3kgdklI=";
  };
}
