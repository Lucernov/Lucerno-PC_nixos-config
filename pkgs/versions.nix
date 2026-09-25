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
    hash      = "sha256-YPf3ZCVPP4qgVPdj0t5odSQLK1KhnwzrPuJIHF90tL0=";
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

  lostSamplers = {                                                      # SuperflyDSP Lost Samplers – эмуляция шумов сэмплеров
    version = "1.1.5";
    url     = "https://superflydsp.com/wp-content/uploads/2023/04/LostSamplers_1.1.5_Linux.zip";
    hash    = "sha256-dvHrEaDT9pLZMPPFv98/J2eAHSRWJS4F4d7a+gnVzoo=";
  };

  lostTapes = {                                                         # SuperflyDSP Lost Tapes – эмуляция магнитофона
    version = "1.0";
    url     = "https://superflydsp.com/wp-content/uploads/2022/05/LostTapes_Linux.zip";
    hash    = "sha256-c/LJcmJzS0cxB9uZTskfnkh/AM69qHmQh2wHum7yqbU=";
  };

  lostVinyls = {                                                        # SuperflyDSP Lost Vinyls – эмуляция винилового проигрывателя
    version = "1.3.0";
    url     = "https://superflydsp.com/wp-content/uploads/2023/04/Lost-vinyls_v1.3.0_Linux.zip";
    hash    = "sha256-QT3WIh2wBiD6xnKINWvsV/jn7rA1GN/jj/B1OqFBwzs=";
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
