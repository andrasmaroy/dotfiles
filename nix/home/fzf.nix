_: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f";
    fileWidget.command = "fd --hidden --follow --exclude .git . \"$1\"";
    changeDirWidget.command = "fd --type d --hidden --follow --exclude .git . \"$1\"";
    # Disable history widget in favor of atuin
    historyWidget.command = "";

    # Tomorrow Night Eighties
    colors = {
      fg = "#cccccc:regular";
      "fg+" = "#cccccc:regular";
      bg = "#2d2d2d";
      "bg+" = "#515151";
      hl = "#b777e0";
      "hl+" = "#b777e0";
      info = "#999999";
      marker = "#ffcc66";
      prompt = "#9ec400";
      spinner = "#54ced6";
      pointer = "#6699cc";
      header = "#6699cc";
      gutter = "#2d2d2d";
      border = "#515151";
      scrollbar = "#999999";
      preview-scrollbar = "#999999";
      preview-label = "#6699cc";
      label = "#f99157";
      query = "#cccccc:regular";
      preview-border = "#515151";
      separator = "#515151";
    };
  };
}
