_: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      enter_accept = true;
      inline_height = 14;
      style = "compact";
      workspaces = true;
      search.filters = [
        "workspace"
        "directory"
        "session"
        "host"
        "global"
      ];
      theme.name = "Tomorrow-Night-Eighties";
    };
    themes = {
      Tomorrow-Night-Eighties = {
        theme.name = "Tomorrow-Night-Eighties";
        colors = {
          AlertInfo = "#6699cc";
          AlertWarn = "#ffcc66";
          AlertError = "#f2777a";
          Annotation = "#999999";
          Base = "#cccccc";
          Guidance = "#99cc99";
          Important = "#f99157";
          Title = "#cc99cc";
          Muted = "#999999";
          SyntaxCommand = "#6699cc";
          SyntaxFlag = "#cc99cc";
          SyntaxString = "#99cc99";
          SyntaxVariable = "#f2777a";
          SyntaxOperator = "#66cccc";
          SyntaxComment = "#999999";
        };
      };
    };
  };
}
