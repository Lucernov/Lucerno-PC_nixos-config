# pkgs/pkg_proton-authenticator.nix
{ symlinkJoin, makeWrapper, proton-authenticator }:
symlinkJoin {
  name = "proton-authenticator-wrapped";
  paths = [ proton-authenticator ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/proton-authenticator \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';
}
