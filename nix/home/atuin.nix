_: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      inline_height = 14;
      enter_accept = true;
      filters = [
        "workspace"
        "directory"
        "session"
        "host"
        "global"
      ];
    };
  };
}
