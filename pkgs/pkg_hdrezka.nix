{ lib
, python3Packages
, fetchurl
, fetchPypi
, fzf
, mpv
, makeWrapper # Оставляем, но не используем для обертки
, bash        # Добавляем bash для создания ручной обертки
}:

let
  # 1. Библиотека-парсер (как в оригинальном api.nix)
  hdrezkaapi = python3Packages.buildPythonPackage rec {
    pname = "hdrezkaapi";
    version = "11.2.3";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-nPQM/dFVl7xHgQ3SUidSZPE4ch/q8cz/O0kpUFxrlkw=";
    };

    build-system = [ python3Packages.setuptools ];

    # В оригинале используется dependencies, в современных nixpkgs лучше propagatedBuildInputs
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

  # 2. Консольный клиент (как в оригинальном client.nix, но с ручной оберткой)
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

      # Зависимости Python (будут добавлены в PYTHONPATH)
      propagatedBuildInputs = pyDeps;

      # makeWrapper больше не нужен, но пусть будет (не мешает)
      nativeBuildInputs = [ makeWrapper ];

      dontUnpack = true;
      format = "other";

      # Создаем обертку вручную через bash heredoc
      installPhase = ''
        mkdir -p $out/bin
        install -Dm755 $src $out/bin/.rezka-fzf-unwrapped

        cat > $out/bin/rezka-fzf <<EOF
#!${bash}/bin/bash
export PATH="${lib.makeBinPath [ fzf mpv ]}:\$PATH"
export PYTHONPATH="${python3Packages.makePythonPath pyDeps}:\$PYTHONPATH"
exec ${python3Packages.python.interpreter} $out/bin/.rezka-fzf-unwrapped "\$@"
EOF
        chmod +x $out/bin/rezka-fzf
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
