{
  config,
  lib,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    package = null;
    settings = {
      command = lib.getExe config.programs.fish.package;

      font-family = "Menlo Nerd Font";
      font-size = 13;
      font-thicken = true;

      # --- Cursor ---
      cursor-style = "block";
      cursor-style-blink = "false";

      theme = "Tomorrow Night Eighties";

      macos-option-as-alt = "true";
      quit-after-last-window-closed = "true";
      window-inherit-working-directory = "false";
      tab-inherit-working-directory = "false";
      selection-clear-on-copy = "true";

      # --- Performance ---
      # Generous scrollback (100MB)
      scrollback-limit = 100000000;

      # ref: https://ghostty.org/docs/config/reference
      # source: https://gist.github.com/davila7/5b07f55a6e65a06c121da9702d10c2e2
      # --- Window and Appearance ---
      macos-titlebar-style = "tabs";
      window-padding-x = 10;
      window-padding-y = 8;
      window-save-state = "always";

      # --- Mouse ---
      mouse-hide-while-typing = "true";
      copy-on-select = "clipboard";
      mouse-scroll-multiplier = "discrete:1";

      # --- Quick Terminal (Quake-style dropdown) ---
      # Activate with the global keybind configured below
      # quick-terminal-position = top
      # quick-terminal-screen = mouse
      # quick-terminal-autohide = true
      # quick-terminal-animation-duration = 0.15

      # --- Security ---
      clipboard-paste-protection = "true";
      clipboard-paste-bracketed-safe = "true";

      # --- Shell Integration ---
      shell-integration = "detect";

      # --- Keybindings ---
      # Tabs
      keybind = [
        "cmd+t=new_tab"
        "ctrl+b>c=new_tab"
        "ctrl+b>shift+5=new_split:right"
        "ctrl+b>shift+'=new_split:down"

        "alt+h=goto_split:left"
        "alt+l=goto_split:right"
        "alt+j=goto_split:top"
        "alt+k=goto_split:bottom"

        "ctrl+b>z=toggle_split_zoom"
      ];

      # keybind = cmd+shift+left=previous_tab
      # keybind = cmd+shift+right=next_tab
      # keybind = cmd+w=close_surface

      # Splits
      # keybind = cmd+d=new_split:right
      # keybind = cmd+shift+d=new_split:down
      # keybind = cmd+alt+left=goto_split:left
      # keybind = cmd+alt+right=goto_split:right
      # keybind = cmd+alt+up=goto_split:top
      # keybind = cmd+alt+down=goto_split:bottom

      # Font size
      # keybind = cmd+plus=increase_font_size:1
      # keybind = cmd+minus=decrease_font_size:1
      # keybind = cmd+zero=reset_font_size

      # Quick terminal global hotkey
      # keybind = global:ctrl+grave_accent=toggle_quick_terminal

      # Splits management
      # keybind = cmd+shift+e=equalize_splits
      # keybind = cmd+shift+f=toggle_split_zoom

      # Reload config
      # keybind = cmd+shift+comma=reload_config

      # keybind = vim/
      # keybind = copy-mode/
    };
  };
}
