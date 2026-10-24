{ lib
, stdenv
, fetchurl
, fetchPypi
, python3Packages
, fzf
, mpv
, makeWrapper
}:

let
  # 1. Библиотека-парсер
  hdrezkaapi = python3Packages.buildPythonPackage rec {
    pname = "hdrezkaapi";
    version = "11.2.3";
    pyproject = true;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-nPQM/dFVl7xHgQ3SUidSZPE4ch/q8cz/O0kpUFxrlkw=";
    };
    build-system = [ python3Packages.setuptools ];
    propagatedBuildInputs = [
      python3Packages.requests
      python3Packages.beautifulsoup4
    ];
    allowSubstitutes = false;
    preferLocalBuild = true;
    meta = {
      description = "Unofficial Python library for parsing content from HDRezka";
      homepage = "https://github.com/SuperZombi/HdRezkaApi";
      license = lib.licenses.mit;
    };
  };

  # 2. Создаем изолированное Python-окружение со всеми нужными библиотеками
  pythonEnv = python3Packages.python.withPackages (ps: with ps; [
    aiohttp
    pyyaml
    hdrezkaapi
  ]);

  # 3. Собираем сам клиент
  rezka-fzf = stdenv.mkDerivation {
    pname = "rezka-fzf";
    version = "git";

    src = fetchurl {
      url = "https://gist.githubusercontent.com/unazikx/844a2104703e1d9382ca91dfc08a5607/raw/135aadfeaff6d7e7e70c22e9780149b0260376be/gistfile1.txt";
      sha256 = "sha256-df9oGzEKGWcU/cNBALAOf+LZ544dqraCoGBhXOIqC00=";
    };

    # makeWrapper нужен для создания финального скрипта-обертки
    nativeBuildInputs = [ makeWrapper ];

    # Отключаем распаковку, так как src - это просто текстовый файл
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      # Копируем оригинальный питон-скрипт
      install -Dm755 $src $out/bin/rezka-fzf-unwrapped

      # Создаем bash-обертку, которая запускает скрипт через наше pythonEnv
      # и добавляет fzf и mpv в PATH
      makeWrapper ${pythonEnv}/bin/python3 $out/bin/rezka-fzf \
        --add-flags $out/bin/rezka-fzf-unwrapped \
        --prefix PATH : ${lib.makeBinPath [ fzf mpv ]}
    '';

    meta = {
      description = "Terminal client for HDRezka using fzf and mpv";
      license = lib.licenses.wtfpl;
      mainProgram = "rezka-fzf";
    };
  };
in
{
  inherit hdrezkaapi rezka-fzf;
  api = hdrezkaapi;
  client = rezka-fzf;
  default = rezka-fzf;
}
