# pkgs/pkg_teamspeak.nix
{ symlinkJoin, teamspeak6-client, coreutils }:

symlinkJoin {
  name = "teamspeak6-client-wrapped";
  paths = [ teamspeak6-client ];
  buildInputs = [ coreutils ];
  postBuild = ''
    rm -f $out/share/teamspeak6-client/hotkey_helper
    ln -s ${coreutils}/bin/true $out/share/teamspeak6-client/hotkey_helper
  '';
}
