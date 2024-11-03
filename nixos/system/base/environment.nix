{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit
    (lib)
    ldTernary
    mkEnableOption
    mkOption
    types
    ;
in {
  options.garden.environment = {
    useHomeManager =
      mkEnableOption "Whether to use home-manager or not"
      // {
        default = true;
      };

    flakePath = mkOption {
      type = types.str;
      default = "/${ldTernary pkgs "home" "Users"}/rafaribe/code/rafaribe/home-ops/nixos";
      description = "The path to the configuration";
    };
  };

  config.assertions = [
    {
      assertion = config.garden.environment.useHomeManager -> config.garden.system.mainUser != null;
      message = "system.mainUser must be set while useHomeManager is enabled";
    }
    {
      assertion = config.garden.environment.flakePath != null -> config.garden.system.mainUser != null;
      message = "system.mainUser must be set if a flakePath is specified";
    }
  ];
}
