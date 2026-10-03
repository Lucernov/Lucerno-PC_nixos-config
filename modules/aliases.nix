# modules/aliases.nix
{ myLib, ... }:

{
    programs.zsh.shellAliases = {
      # ========== Навигация и файлы ==========
      l  = "lsd -l --color=always";                              # подробный список файлов
      ll = "lsd -la --color=always";                             # подробный список со скрытыми файлами
      ls = "lsd --icon always --color=always";                   # обычный список с иконками
      la = "lsd -a --color=always";                              # показать все файлы (включая скрытые)
      lt = "lsd --tree --color=always";                          # древовидный вывод
      cd = "z";                                                  # умная навигация через zoxide (запоминает посещённые папки)

      # ========== Git ==========
      gs  = "git status";                                        # статус репозитория
      gp  = "git pull";                                          # скачать изменения из удалённого репозитория
      gc  = "git commit -m";                                     # создать коммит с сообщением (использовать: gc "message")
      gco = "git checkout";                                      # переключиться на ветку или восстановить файл
      gb  = "git branch";                                        # показать ветки

      # ========== Мониторинг ==========
      mon = "kitty @ launch --location=vsplit -- pw-top; sleep 0.2; kitty @ launch --location=hsplit -- nvtop"; # открыть pw-top и nvtop в сплитах Kitty

      # ========== Управление конфигурацией Nix ==========
      sync   = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push"; # синхронизировать конфиг с Git
      update = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"pre-rebuild\" || true) && git push && nh os switch";  # пересобрать NixOS без обновления входов
      local-up = "cd ${myLib.home}/${myLib.configDirName} && sudo nixos-rebuild switch --flake .#Lucerno-PC --offline 2>&1 | tee /tmp/rebuild.log | tail -60";  # пересобрать NixOS без обращений в интернет
      upgrade = "cd ${myLib.home}/${myLib.configDirName} && git add -A && (git commit -m \"pre-upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push && (nh os switch --update && git add flake.lock && (git commit -m \"upgrade: $(date '+%Y-%m-%d %H:%M:%S')\" || true) && git push) || (echo '⚠️  Сборка упала! Откатываю flake.lock...' && git checkout HEAD -- flake.lock && nh os switch)";  # пересобрать NixOS с обновлением flake.lock
      clean = "nh clean all --keep 2 && nh os switch";  # очистить старые поколения и переключиться

      # ========== Проверка конфига без сборки ==========
      checknix = "cd ${myLib.home}/${myLib.configDirName} && time nix eval .#nixosConfigurations.Lucerno-PC.config.system.build.toplevel";
      # Полный dry-run (вычисляет + показывает, что будет собрано, но НЕ применяет)
      check-dry = "cd ${myLib.home}/${myLib.configDirName} && nixos-rebuild dry-build --flake .#Lucerno-PC --option substitute false";
      # Проверка flake целиком (линтер + сборка всех outputs)
      check-flake = "cd ${myLib.home}/${myLib.configDirName} && nix flake check --no-build";

      # ========== Автообновление плагинов ==========
      # под finalAttrs + flake output.
      update-plugins = "cd ${myLib.home}/${myLib.configDirName} && \
        for pkg in je8086 ostirus drumlabooh drumlabooh-multi pitchnet; do \
          echo \"━━━ $pkg ━━━\"; \
          nix-update \"$pkg\" --flake || echo \"  ⚠️ $pkg: пропущен\"; \
        done && \
        echo '' && \
        git diff --stat pkgs/";
      # обновит оба пакета (скачает, посчитает хеши, поправит файлы) - update-plugins
      # посмотреть, что поменялось (опционально) - git diff pkgs/
      # собрать и применить - local-up
      # закоммитить - sync

      # ========== Приложения ==========
      parabolic = "org.nickvision.tubeconverter";                # запустить Parabolic (загрузчик видео/аудио с YouTube)

      # ========== Софт ==========
      bt = "btop";                                               # использовать btop

      # ========== Замена софта ==========
      cat = "bat --paging=never";                                # bat с подсветкой, но БЕЗ pager (чтобы вести себя как cat)

      # ========== Список всех музыкальных плагинов ==========
      plugins = ''
        for fmt in clap lv2 vst vst3; do
          echo ""
          echo "=== .$fmt ==="

          echo "--- system ---"
          result=$(ls "/run/current-system/sw/lib/$fmt" 2>/dev/null)
          [ -n "$result" ] && echo "$result" || echo "  (пусто)"

          echo "--- wine (yabridge) ---"
          result=$(find "$HOME/.$fmt/yabridge" -maxdepth 3 \
            \( -type d -name "*.vst3" -o -type f -name "*.so" -o -type f -name "*.clap" -o -type f -name "*.lv2" \) \
            -printf '  %f\n' 2>/dev/null | sort -u)
          [ -n "$result" ] && echo "$result" || echo "  (пусто)"
        done
      '';

      # ========== NVIDIA диагностика ==========
      nvcheck = ''
        echo "━━━ NVIDIA Driver ━━━"
        nvidia-smi --query-gpu=driver_version,name,temperature.gpu,utilization.gpu,memory.used,memory.total \
          --format=csv,noheader 2>/dev/null || echo "  nvidia-smi не отвечает!"

        echo ""
        echo "━━━ Segfaults in driver (7d) ━━━"
        result=$(journalctl --since "7 days ago" 2>/dev/null \
          | grep -iE 'segfault.*(nvidia|libnvidia)' | tail -10)
        [ -n "$result" ] && echo "$result" || echo "  ✅ нет"

        echo ""
        echo "━━━ NVRM Xid errors (7d) ━━━"
        result=$(journalctl -k --since "7 days ago" 2>/dev/null \
          | grep -iE 'NVRM: Xid|NVRM: GPU has fallen' | tail -10)
        [ -n "$result" ] && echo "$result" || echo "  ✅ нет"

        echo ""
        echo "━━━ Kernel warnings from NVIDIA (24h) ━━━"
        result=$(journalctl -k --since "24 hours ago" 2>/dev/null \
          | grep -iE 'NVRM|nvidia' \
          | grep -viE 'loading|module license|uses symbols|Command line|vgaarb|Initialized nvidia-drm|frame buffer device|nvlink|HDA NVidia|input:' \
          | tail -10)
        [ -n "$result" ] && echo "$result" || echo "  ✅ нет"
      '';

      # ========== Эффекты ==========
      neo- = "neo --defaultbg";                                  # матричный дождь на фоне терминала
    };
}


