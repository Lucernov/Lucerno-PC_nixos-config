{ ... }:
{
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      max-jobs = 6;
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
