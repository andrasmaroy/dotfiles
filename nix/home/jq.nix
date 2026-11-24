_: {
  programs.jq = {
    enable = true;

    colors = {
      arrays = "0;38;5;188";
      false = "0;38;5;209";
      null = "0;38;5;209";
      numbers = "0;38;5;209";
      objectKeys = "0;38;5;114";
      objects = "0;38;5;188";
      strings = "0;38;5;114";
      true = "0;38;5;209";
    };
  };
}
