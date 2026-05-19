# modules/hx_git.nix
# Модуль home-manager для настройки Git (конфигурация и глобальный .gitignore)
{ ... }:
{
  # Управление файлами в домашней директории
  home.file = {
    # Конфигурационный файл Git (~/.gitconfig)
    ".gitconfig".text = ''
      [user]
        name = Lucernov                      # Имя автора коммитов
        email = jin.riv@gmail.com            # Email автора коммитов
      [core]
        excludesfile = ~/.gitignore          # Глобальный файл с игнорируемыми паттернами
      [credential]
        helper = store                       # Сохранять учётные данные в открытом виде (небезопасно, но удобно)
    '';
    ".gitconfig".force = true;               # Принудительно перезаписывать файл при каждом применении

    # Глобальный файл игнорирования Git (~/.gitignore)
    ".gitignore".text = ''
      *.swp                                  # Файлы swap Vim
      *~                                     # Резервные копии
      .Trash-*                               # Корзина KDE
      result                                 # Симлинк результата сборки Nix
    '';
    ".gitignore".force = true;               # Принудительно перезаписывать файл при каждом применении
  };
}
