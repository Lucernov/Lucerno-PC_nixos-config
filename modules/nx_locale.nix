{ ... }:

{
  # ========== Настройки времени и локали ==========
  time.timeZone = "Europe/Moscow";      # Часовой пояс (Europe/Moscow)
  i18n.defaultLocale = "ru_RU.UTF-8";   # Основная локаль системы – русская, кодировка UTF-8
  i18n.extraLocaleSettings = {          # Дополнительные настройки локализации для отдельных категорий
    LC_ADDRESS = "ru_RU.UTF-8";         # Формат адресов
    LC_IDENTIFICATION = "ru_RU.UTF-8";  # Метаданные локали
    LC_MEASUREMENT = "ru_RU.UTF-8";     # Единицы измерения (метрическая система)
    LC_MONETARY = "ru_RU.UTF-8";        # Формат денежных единиц (рубли)
    LC_NAME = "ru_RU.UTF-8";            # Формат имён
    LC_NUMERIC = "ru_RU.UTF-8";         # Формат чисел (разделители десятичной части и тысяч)
    LC_PAPER = "ru_RU.UTF-8";           # Формат бумаги (A4)
    LC_TELEPHONE = "ru_RU.UTF-8";       # Формат телефонных номеров
    LC_TIME = "ru_RU.UTF-8";            # Формат времени (24-часовой, день.месяц.год)
  };
}
