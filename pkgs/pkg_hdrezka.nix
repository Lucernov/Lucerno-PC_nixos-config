{ lib
, python3Packages
, fetchurl
, fetchPypi
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

  # 2. Консольный клиент
  rezka-fzf =
    let
      pyDeps = [
        python3Packages.aiohttp
        python3Packages.pyyaml
        hdrezkaapi
      ];
    in
    python3Packages.buildPythonApplication {
      pname = "rezka-fzf";
      version = "git";

      src = fetchurl {
        url = "https://gist.githubusercontent.com/unazikx/844a2104703e1d9382ca91dfc08a5607/raw/135aadfeaff6d7e7e70c22e9780149b0260376be/gistfile1.txt";
        sha256 = "sha256-df9oGzEKGWcU/cNBALAOf+LZ544dqraCoGBhXOIqC00=";
      };

      propagatedBuildInputs = pyDeps;
      nativeBuildInputs = [ makeWrapper ];

      dontUnpack = true;
      format = "other";

      # Шаг 1: Просто копируем исходный скрипт
      installPhase = ''
        mkdir -p $out/bin
        install -Dm755 $src $out/bin/.rezka-fzf-unwrapped
      '';

      # Шаг 2: Создаем обертку ПОСЛЕ patchShebangs
      postFixup = ''
        makeWrapper ${python3Packages.python.interpreter} $out/bin/rezka-fzf \
          --add-flags $out/bin/.rezka-fzf-unwrapped \
          --prefix PATH : ${lib.makeBinPath [ fzf mpv ]} \
          --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:${python3Packages.makePythonPath pyDeps}"
      '';

      allowSubstitutes = false;
      preferLocalBuild = true;

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
