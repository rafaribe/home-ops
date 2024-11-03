{...}: {
  users.users = {
    rafaribe = {
      isNormalUser = true;
      extraGroups = ["wheel" "video" "nginx" "docker"];
    };
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraConfig = ''
      Defaults        timestamp_timeout=600
    '';
  };
}
