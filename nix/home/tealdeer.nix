_: {
  programs.tealdeer = {
    enable = true;

    enableAutoUpdates = true;

    settings = {
      display = {
        compact = true;
        show_title = true;
      };

      # Colors from the Tomorrow Night Eighties palette:
      # https://github.com/chriskempson/tomorrow-theme
      style = {
        # Foreground (#cccccc)
        description = {
          foreground = {
            rgb = {
              r = 204;
              g = 204;
              b = 204;
            };
          };
          underline = false;
          bold = false;
          italic = false;
        };
        # Aqua (#66cccc)
        command_name = {
          foreground = {
            rgb = {
              r = 102;
              g = 204;
              b = 204;
            };
          };
          underline = false;
          bold = true;
          italic = false;
        };
        # Comment (#999999)
        example_text = {
          foreground = {
            rgb = {
              r = 153;
              g = 153;
              b = 153;
            };
          };
          underline = false;
          bold = false;
          italic = true;
        };
        # Foreground (#cccccc)
        example_code = {
          foreground = {
            rgb = {
              r = 204;
              g = 204;
              b = 204;
            };
          };
          underline = false;
          bold = false;
          italic = false;
        };
        # Orange (#f99157)
        example_variable = {
          foreground = {
            rgb = {
              r = 249;
              g = 145;
              b = 87;
            };
          };
          underline = true;
          bold = false;
          italic = false;
        };
      };

      updates = {
        auto_update = true;
      };
    };
  };
}
