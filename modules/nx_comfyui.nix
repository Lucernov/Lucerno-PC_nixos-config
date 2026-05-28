# modules/nx_comfyui.nix
{ config, pkgs, myLib, ... }: {
  services.comfyui = {
    enable = true;
    gpuSupport = "cuda";               # RTX 3070
    enableManager = true;              # ComfyUI Manager
    port = 8188;
    listenAddress = "127.0.0.1";
    # Используем вашу существующую папку с данными
    dataDir = "/mnt/ai/ComfyUI";
    openFirewall = true;               # если нужно с других устройств
    extraArgs = [ "--lowvram" ];       # для 8 ГБ — обязательно
    # Запускаем от вашего пользователя, чтобы не было проблем с правами
    user = "lucerno";
    group = "lucerno";
    createUser = false;                # пользователь уже существует
  };
}
