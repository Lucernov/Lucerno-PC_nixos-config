# Модуль home-manager для настройки Git (конфигурация и глобальный .gitignore)
_:

{
  home.file = {                               # Управление файлами в домашней директории
    # Конфигурационный файл Git (~/.gitconfig)
    ".gitconfig".text = ''
      [user]
        # Имя автора коммитов
        name = Lucernov
        # Email автора коммитов
        email = jin.riv@gmail.com
      [core]
        # Глобальный файл с игнорируемыми паттернами
        excludesfile = ~/.gitignore
        # Путь к папке с глобальными Git-хуками (активирует pre-commit)
        hooksPath = ~/.git/hooks
      [credential]
        # Сохранять учётные данные в открытом виде (небезопасно, но удобно)
        helper = store
    '';
    ".gitconfig".force = true;               # Принудительно перезаписывать файл при каждом применении

    # Глобальный файл игнорирования Git (~/.gitignore)
    ".gitignore".text = ''
      # Файлы swap Vim
      *.swp
      # Резервные копии
      *~
      # Корзина KDE
      .Trash-*
      # Симлинк результата сборки Nix
      result
    '';
    ".gitignore".force = true;               # Принудительно перезаписывать файл при каждом применении
  };
}


# упаковка объектов гит (git gc)
