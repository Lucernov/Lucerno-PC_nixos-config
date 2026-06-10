{ config, pkgs, ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "adapta";
      save_config_on_exit = false;

      # Основные настройки из старого конфига
      truecolor = true;
      theme_background = true;
      graph_symbol = "braille";
      proc_sorting = "cpu direct";

      # ----- Настройки GPU -----
      show_gpu_info = "On";               # или "Auto" — но "On" гарантирует отображение
      shown_gpus = "nvidia amd intel apple";  # оставьте только "nvidia", если другие не нужны
      gpu_mirror_graph = true;            # зеркалирование графика (как у вас было)
      nvml_measure_pcie_speeds = true;    # измерение PCIe для NVIDIA
      # Опционально: если нужны графики температур и загрузки, они обычно идут автоматически
    };
  };
}
