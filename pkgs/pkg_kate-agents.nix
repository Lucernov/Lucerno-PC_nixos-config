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

  # 🔥 НАДЕЖНЫЙ ПАТЧ
  # Заменяем ВСЕ объявления QMutex на QRecursiveMutex в заголовочном файле.
  # QMutexLocker автоматически подстроится под тип, так как у него есть шаблонный конструктор.
  postPatch = ''
    if [ -f src/agentloop.h ]; then
      substituteInPlace src/agentloop.h \
        --replace 'QMutex m_' 'QRecursiveMutex m_'
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
