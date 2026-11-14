# pkgs/pkg_kate-agents.nix
{ lib
, stdenv
, fetchFromGitHub
, cmake
, kdePackages
, qt6
}:

stdenv.mkDerivation {
  pname = "kate-agents";
  version = "unstable-2026-07-29";

  src = fetchFromGitHub {
    owner = "Mte90";
    repo = "kate-agents";
    rev = "b3732eb4221284f913f4bb2966eccecec54e31b6";
    hash = "sha256-bLXnCaMHxOnaRvblz4RWNTtooq/Yc5l3puc5mDVKOak=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.ktexteditor
    kdePackages.kxmlgui
    kdePackages.kconfigwidgets
  ];

  # 🔥 ПАТЧ ДЛЯ ОБХОДА ДЕДЛОКА
  # Отключаем стриминг, чтобы плагин не зависал на многопоточности Qt
  postPatch = ''
    # Патчим провайдер OpenAI (там формируется JSON запроса)
    if [ -f src/openaiprovider.cpp ]; then
      substituteInPlace src/openaiprovider.cpp \
        --replace '"stream": true' '"stream": false' \
        --replace '"stream":true' '"stream":false' \
        --replace 'stream = true' 'stream = false'
    fi
    # На всякий случай патчим и сам цикл агента, если настройка вынесена туда
    if [ -f src/agentloop.cpp ]; then
      substituteInPlace src/agentloop.cpp \
        --replace '"stream": true' '"stream": false' \
        --replace '"stream":true' '"stream":false'
    fi
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_WITH_QT6=ON"
  ];

  meta = with lib; {
    description = "Replicate Zed Agents feature in Kate editor";
    homepage = "https://github.com/Mte90/kate-agents";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
