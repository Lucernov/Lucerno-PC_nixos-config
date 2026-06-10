{ config, pkgs, ... }:

{
  # ========== Включение и базовые настройки btop ==========
  programs.btop = {
    enable = true;
    settings = {

      # ----- Внешний вид и тема -----
      color_theme = "adapta";            # название темы (системная или из ~/.config/btop/themes/)
      truecolor = true;                  # 24-битный цвет
      theme_background = true;           # показывать фон темы (иначе прозрачность терминала)
      graph_symbol = "braille";          # символы для графиков (braille / block / tty)

      # ----- Поведение при выходе -----
      save_config_on_exit = false;       # не перезаписывать конфиг при выходе (важно для декларативности)

      # ----- Какие блоки показывать (вкладки) -----
      shown_boxes = "cpu mem net proc gpu0";   # добавляем GPU как отдельную вкладку

      # ----- Сортировка процессов -----
      proc_sorting = "cpu direct";       # сортировка по загрузке CPU (прямая, без сглаживания)

      # ----- Настройки GPU (NVIDIA) -----
      show_gpu_info = "On";              # принудительно показать блок GPU (On / Auto / Off)
      shown_gpus = "nvidia";             # какие GPU отображать (только NVIDIA)
      gpu_mirror_graph = true;           # зеркальное отображение графика GPU
      nvml_measure_pcie_speeds = true;   # замерять скорость PCIe через NVML

      # ----- Процессы -----
      proc_cpu_graphs = true;            # показывать мини‑графики CPU у каждого процесса
      proc_mem_bytes = true;             # память процессов в байтах, а не в процентах
      proc_gradient = true;              # затемнение в списке процессов
      proc_tree = false;                 # не показывать дерево процессов
      proc_reversed = false;             # обычный порядок сортировки (не обратный)
      proc_left = false;                 # список процессов справа (false = справа, true = слева)
      proc_aggregate = false;            # не накапливать ресурсы дочерних процессов

      # ----- Память и диски -----
      mem_graphs = true;                 # показывать графики вместо метров
      show_swap = true;                  # отображать swap
      swap_disk = true;                  # показывать swap как диск (отдельно)
      show_disks = true;                 # показывать диски в блоке памяти
      use_fstab = true;                  # использовать /etc/fstab для списка дисков
      only_physical = true;              # только физические диски (исключить сетевые, RAM‑диски)
      show_io_stat = true;               # показывать активность ввода‑вывода (busy time)

      # ----- Температура CPU -----
      check_temp = true;                 # включить мониторинг температуры
      show_coretemp = true;              # показывать температуру каждого ядра
      temp_scale = "celsius";            # шкала Цельсия

      # ----- Сеть -----
      net_auto = true;                   # автоматически масштабировать графики сети
      net_sync = true;                   # синхронизировать масштаб загрузки и отдачи
      swap_upload_download = false;      # не менять местами графики (отдача сверху)

      # ----- Часы и время работы -----
      clock_format = "%X";               # формат времени (локальный, например, 23:59:59)
      show_uptime = true;                # показывать время работы системы (uptime)

    };
  };
}
