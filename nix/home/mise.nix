_: {
  programs.mise = {
    enable = true;
    enableFishIntegration = true;

    globalConfig = {
      settings = {
        idiomatic_version_file_enable_tools = [
          "pnpm"
          "python"
          "ruby"
        ];

        python.uv_venv_auto = "create|source";
      };

      tools = {
        python = "latest";
      };
    };
    mutableSettings = true;
  };
}
