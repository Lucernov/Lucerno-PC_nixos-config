{ zapret-rust, ... }:

{
  imports = [ zapret-rust.nixosModules.zapret-rust ];

  services.zapret-rust = {
    enable = true;
    interface = "any";              # или конкретный, например "enp5s0"
    strategy = "general.bat";       # стратегия (можно подобрать)
    backend = "nftables";           # ← ключевой параметр
  };
}
