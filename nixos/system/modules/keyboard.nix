{pkgs, ...}: {
  services.xserver = {
    xkb = {
      layout = "pt";
      variant = "nodeadkeys";
    };
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";
}
