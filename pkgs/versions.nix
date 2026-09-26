# pkgs/versions.nix шаблон sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
{
  air-g-plugins = {                                                     # не обновляется (локальный репозиторий)
    version     = "1.0";
  };

  amp-locker = {                                                        # обновляется иногда
    version  = "1.5.6";                                                 # https://audioassault.mx/downloadAudioAssault
    url      = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/AmpLockerLinux.zip";
    hash     = "sha256-pHh4SN6Vb7CFOOQD+9VFLlNch0lv4dU8EWXjSE68iv8=";
  };

  drum-locker = {                                                       # обновляется иногда
    version   = "1.0.3";                                                # https://audioassault.mx/downloadAudioAssault
    url       = "https://audioassaultdownloads.s3.amazonaws.com/AmpLocker/AmpLocker109/DrumLockerLinux.zip";
    hash      = "sha256-YPf3ZCVPP4qgVPdj0t5odSQLK1KhnwzrPuJIHF90tL0=";
  };

  drumlabooh  = {                                                       # обновляется иногда
    version   = "12.2.0";                                               # https://github.com/psemiletov/drumlabooh/releases
    url       = "https://github.com/psemiletov/drumlabooh/releases/download/12.2.0/drumlabooh.lv2.zip";
    urlMulti  = "https://github.com/psemiletov/drumlabooh/releases/download/12.2.0/drumlabooh-multi.lv2.zip";
    hash      = "sha256-IQ0XzIwJqGg+6FynmJBllyBIzWD3dgFfllOTEx0cMDM=";  # одноканальный
    hashMulti = "sha256-qdZJvXsUlEmmlTwUwO/C47OXM+gwRlu2cNRFGrJDi1A=";  # мультиканальный
  };

  je8086    = {                                                         # обновляется активно
    version = "2.2.16";                                                 # https://theusualsuspects.io/builds/downloads?product=JE8086&format=All&os=Linux_x86_64
    url     = "https://github.com/dsp56300/gearmulator/releases/download/2.2.16/TheUsualSuspects-JE8086-CLAP-2.2.16-Linux_x86_64.zip";
    hash    = "sha256-KoBRwHO2YJLl/bpAtzB/TPKYn2abiZ+hDaCjVqI+LFU=";
  };

  lostSamplers = {                                                      # SuperflyDSP Lost Samplers – эмуляция шумов сэмплеров
    version    = "1.1.5";
    url        = "https://superflydsp.com/wp-content/uploads/2023/04/LostSamplers_1.1.5_Linux.zip";
    hash       = "sha256-dvHrEaDT9pLZMPPFv98/J2eAHSRWJS4F4d7a+gnVzoo=";
  };

  lostTapes = {                                                         # SuperflyDSP Lost Tapes – эмуляция магнитофона
    version = "1.0";
    url     = "https://superflydsp.com/wp-content/uploads/2022/05/LostTapes_Linux.zip";
    hash    = "sha256-c/LJcmJzS0cxB9uZTskfnkh/AM69qHmQh2wHum7yqbU=";
  };

  lostVinyls = {                                                        # SuperflyDSP Lost Vinyls – эмуляция винилового проигрывателя
    version  = "1.3.0";
    url      = "https://superflydsp.com/wp-content/uploads/2023/04/Lost-vinyls_v1.3.0_Linux.zip";
    hash     = "sha256-QT3WIh2wBiD6xnKINWvsV/jn7rA1GN/jj/B1OqFBwzs=";
  };

  mtpdk        = {
    version    = "2.1.5.1";
    url        = "https://resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-2.1.5.1-VST3-64bit-Linux-FULL.zip";
    hash       = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
  };

  music-pattern-generator = {                                           # обновляется редко
    version = "2.2.0";                                                  # https://github.com/hisschemoller/music-pattern-generator/releases
    url     = "https://github.com/hisschemoller/music-pattern-generator/releases/download/v2.2.0/mpg_2_2_installer_lin.deb";
    hash    = "sha256-L83MCo1TqSbt+4MwRXWCVgegpuYEYNLrjrJnzPMwLwE=";
  };

  numa-player = {
    version = "2.2.2";                                                  # https://www.studiologic-music.com/products/numaplayer/
    url     = "https://www.studiologic-music.com/api/get-files/NumaPlayer_2.2.2.deb";
    hash    = "sha256-+3PvtSDyjhStYux+1Qd1azRpnAwRbRibAxK7kWLVM8o=";
  };

  orchestools = {                                                       # не обновляется (локальный репозиторий)
    version   = "1.0";
  };

  ostirus   = {                                                         # обновляется активно
    version = "2.2.16";                                                 # https://theusualsuspects.io/builds/downloads?product=OsTIrus&format=All&os=Linux_x86_64
    url     = "https://github.com/dsp56300/gearmulator/releases/download/2.2.16/TheUsualSuspects-OsTIrus-CLAP-2.2.16-Linux_x86_64.zip";
    hash    = "sha256-+3g9yEOb2Psjj/K9ZIY6GXYeIwIsRCtIEOrcUZ980eY=";
  };

  ot-piano-s = {                                                        # не обновляется (локальный репозиторий)
    version  = "1.0";
  };

  pitchnet  = {
    version = "0.6.1";                                                  # https://github.com/SessionLoops/PitchNet/releases
    url     = "https://github.com/SessionLoops/PitchNet/releases/download/v0.6.1/PitchNet-Linux-x86_64.run";
    hash    = "sha256-3nXBa/tmfM/KSQ9YBJ/Tcmr5+Pk47BRprZDWYTz2ujA=";
  };

  sforzando = {                                                         # обновляется иногда
    version = "1.982";                                                  # https://www.plogue.com/downloads.html
    url     = "https://sforzando.s3.us-east-1.amazonaws.com/LINUX_plogue-sforzando_1.982_x86_64.zip";
    hash    = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
  };

  shortcircuit-xt = {                                                   # обновляется активно
    version       = "2026-09-14-8cda0ce";                               # https://github.com/surge-synthesizer/shortcircuit-xt/releases/
    url           = "https://github.com/surge-synthesizer/shortcircuit-xt/releases/download/Nightly/shortcircuit-xt-linux-2026-09-14-8cda0ce.zip";
    hash          = "sha256-wOCqKyDl/AjpZGsTUOWjFlkXMVZoiEavJpFHv/N6ksw=";
  };

  tal-vocoder-2 = {                                                     # TAL-Vocoder-2 (VST3 + CLAP)
    version     = "2";                                                  # https://tal-software.com/products/tal-vocoder
    url         = "https://tal-software.com/downloads/plugins/TAL-Vocoder-2_64_linux.zip";
    hash        = "sha256-vOSpQqN8DEK4f5vISeQnZBpxhW3AaW1+/0ImajeoPsY=";
  };

  tape-echo-2 = {                                                       # Dusk Audio, GPL-3, обновляется активно
    version   = "1.0.7";                                                # https://github.com/dusk-audio/dusk-audio-plugins/releases
    url       = "https://github.com/dusk-audio/dusk-audio-plugins/releases/download/tape-echo-2-v1.0.7/tape-echo-2-linux.zip";
    hash      = "sha256-8KJ/qGzGKhGRGpKvrdu3Mbs+8A4gPGIovTKrfDCpL0g=";
  };

}
