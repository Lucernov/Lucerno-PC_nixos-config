# modules/nx_kate.nix
{ myLib, ... }:

let
  # Корень ваших dotfiles для Kate
  dotfilesKate = "${myLib.home}/${myLib.configDirName}/dotfiles/config/kate";
in
{
  systemd.tmpfiles.rules = [    # ---------- Симлинки для настроек Kate ----------
    # Основной файл конфигурации Kate
    "L+ ${myLib.home}/.config/katerc - lucerno lucerno - ${dotfilesKate}/katerc"
    # Настройки плагина внешних инструментов (глобальные)
    "L+ ${myLib.home}/.config/kate-externaltoolspluginrc - lucerno lucerno - ${dotfilesKate}/kate-externaltoolspluginrc"
    # Настройки Vi-режима
    "L+ ${myLib.home}/.config/katevirc - lucerno lucerno - ${dotfilesKate}/katevirc"
    # Папка с внешними инструментами (рекурсивный симлинк) и файл настроек LSP-клиента .config/kate/lspclient/settings.json
    "L+ ${myLib.home}/.config/kate - lucerno lucerno - ${dotfilesKate}/kate"
  ];
}
