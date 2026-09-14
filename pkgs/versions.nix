# pkgs/versions.nix шаблон sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
{
  air-g-plugins = {                                                     # не обновляется (локальный репозиторий)
    version     = "1.0";
  };

  audioAssault = {                                                      # Общий сегмент пути для всех плагинов Audio Assault
    urlVersion = "109";
  };

  amp-locker = {                                                        # обновляется иногда
    version  = "1.5.6";                                                 # https://audioassault.mx/downloadAudioAssault
    hash     = "sha256-pHh4SN6Vb7CFOOQD+9VFLlNch0lv4dU8EWXjSE68iv8=";
  };

  drum-locker = {                                                       # обновляется иногда
    version   = "1.0.3";                                                # https://audioassault.mx/downloadAudioAssault
    hash      = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  drumlabooh  = {                                                       # обновляется иногда
    version   = "12.2.0";                                               # https://github.com/psemiletov/drumlabooh/releases
    hash      = "sha256-IQ0XzIwJqGg+6FynmJBllyBIzWD3dgFfllOTEx0cMDM=";  # одноканальный
    hashMulti = "sha256-qdZJvXsUlEmmlTwUwO/C47OXM+gwRlu2cNRFGrJDi1A=";  # мультиканальный
  };

  je8086    = {                                                         # обновляется активно
    version = "2.2.16";                                                 # https://theusualsuspects.io/builds/downloads?product=JE8086&format=All&os=Linux_x86_64
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
    version = "2.2.16";                                                 # https://theusualsuspects.io/builds/downloads?product=OsTIrus&format=All&os=Linux_x86_64
    hash    = "sha256-+3g9yEOb2Psjj/K9ZIY6GXYeIwIsRCtIEOrcUZ980eY=";
  };

  ot-piano-s = {                                                        # не обновляется (локальный репозиторий)
    version  = "1.0";
  };

  sforzando = {                                                         # обновляется иногда
    version = "1.982";                                                  # https://www.plogue.com/downloads.html
    hash    = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };

  shortcircuit-xt = {                                                   # обновляется активно
    version       = "2026-09-14-8cda0ce";                               # https://github.com/surge-synthesizer/shortcircuit-xt/releases/
    releaseTag    = "Nightly";
    hash          = "sha256-wOCqKyDl/AjpZGsTUOWjFlkXMVZoiEavJpFHv/N6ksw=";
  };
}
