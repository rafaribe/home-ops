{
  lib,
  inputs,
  ...
}: let
  inherit (builtins) attrValues mapAttrs;
  inherit (lib) filterAttrs;

  flakeInputs = filterAttrs (name: value: (value ? outputs) && (name != "self")) inputs;
in {
  nix.nixPath = attrValues (mapAttrs (k: v: "${k}=${v.outPath}") flakeInputs);
}
