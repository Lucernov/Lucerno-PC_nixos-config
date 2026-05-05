{ ... }:
{
  nix = {
    settings.auto-optimise-store = true;         # Автоматически оптимизировать store (удалять дубликаты)

    # Автоматическая очистка старых поколений
    gc = {
      automatic = true;                          # Автоматически запускать сборку мусора
      dates = "weekly";                          # Раз в неделю
      options = "--delete-older-than 7d";        # Удалять поколения старше 7 дней
    };

    # Дополнительные настройки для оптимизации
    settings = {
      max-jobs = 6;                              # Параллельные сборки
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
