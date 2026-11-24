_: {
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    colors = "auto";
    icons = "auto";

    theme = {
      colourful = true;

      filekinds = {
        normal = {
          foreground = "#cccccc";
        };
        directory = {
          foreground = "#6699cc";
        };
        symlink = {
          foreground = "#66cccc";
        };
        pipe = {
          foreground = "#515151";
        };
        block_device = {
          foreground = "#ffcc66";
        };
        char_device = {
          foreground = "#ffcc66";
        };
        socket = {
          foreground = "#515151";
        };
        special = {
          foreground = "#cc99cc";
        };
        executable = {
          foreground = "#99cc99";
        };
        mount_point = {
          foreground = "#66cccc";
        };
      };

      perms = {
        user_read = {
          foreground = "#66cccc";
        };
        user_write = {
          foreground = "#cc99cc";
        };
        user_execute_file = {
          foreground = "#99cc99";
        };
        user_execute_other = {
          foreground = "#99cc99";
        };
        group_read = {
          foreground = "#66cccc";
        };
        group_write = {
          foreground = "#f99157";
        };
        group_execute = {
          foreground = "#99cc99";
        };
        other_read = {
          foreground = "#66cccc";
        };
        other_write = {
          foreground = "#f2777a";
        };
        other_execute = {
          foreground = "#99cc99";
        };
        special_user_file = {
          foreground = "#f2777a";
        };
        special_other = {
          foreground = "#f2777a";
        };
        attribute = {
          foreground = "#999999";
        };
      };

      size = {
        major = {
          foreground = "#66cccc";
        };
        minor = {
          foreground = "#cc99cc";
        };
        number_byte = {
          foreground = "#cccccc";
        };
        number_kilo = {
          foreground = "#66cccc";
        };
        number_mega = {
          foreground = "#66cccc";
        };
        number_giga = {
          foreground = "#f99157";
        };
        number_huge = {
          foreground = "#f2777a";
        };
        unit_byte = {
          foreground = "#cccccc";
        };
        unit_kilo = {
          foreground = "#66cccc";
        };
        unit_mega = {
          foreground = "#66cccc";
        };
        unit_giga = {
          foreground = "#f99157";
        };
        unit_huge = {
          foreground = "#f2777a";
        };
      };

      users = {
        user_you = {
          foreground = "#6699cc";
        };
        user_root = {
          foreground = "#cc99cc";
        };
        user_other = {
          foreground = "#66cccc";
        };
        group_yours = {
          foreground = "#66cccc";
        };
        group_root = {
          foreground = "#cc99cc";
        };
        group_other = {
          foreground = "#cccccc";
        };
      };

      links = {
        normal = {
          foreground = "#66cccc";
        };
        multi_link_file = {
          foreground = "#66cccc";
        };
      };

      git = {
        new = {
          foreground = "#99cc99";
        };
        modified = {
          foreground = "#cc99cc";
        };
        deleted = {
          foreground = "#f2777a";
        };
        renamed = {
          foreground = "#66cccc";
        };
        typechange = {
          foreground = "#66cccc";
        };
        ignored = {
          foreground = "#999999";
        };
        conflicted = {
          foreground = "#f99157";
        };
      };

      git_repo = {
        branch_main = {
          foreground = "#999999";
        };
        branch_other = {
          foreground = "#66cccc";
        };
        git_clean = {
          foreground = "#393939";
        };
        git_dirty = {
          foreground = "#cc99cc";
        };
      };

      security_context = {
        colon = {
          foreground = "#999999";
        };
        user = {
          foreground = "#999999";
        };
        role = {
          foreground = "#66cccc";
        };
        typ = {
          foreground = "#6699cc";
        };
        range = {
          foreground = "#cc99cc";
        };
      };

      file_type = {
        image = {
          foreground = "#66cccc";
        };
        video = {
          foreground = "#66cccc";
        };
        music = {
          foreground = "#66cccc";
        };
        lossless = {
          foreground = "#66cccc";
        };
        crypto = {
          foreground = "#f2777a";
        };
        document = {
          foreground = "#cccccc";
        };
        compressed = {
          foreground = "#f99157";
        };
        temp = {
          foreground = "#999999";
        };
        compiled = {
          foreground = "#999999";
        };
        build = {
          foreground = "#66cccc";
        };
        source = {
          foreground = "#cc99cc";
        };
      };

      punctuation = {
        foreground = "#515151";
      };
      date = {
        foreground = "#ffcc66";
      };
      inode = {
        foreground = "#999999";
      };
      blocks = {
        foreground = "#999999";
      };
      header = {
        foreground = "#cccccc";
      };
      octal = {
        foreground = "#f99157";
      };
      flags = {
        foreground = "#cc99cc";
      };

      symlink_path = {
        foreground = "#66cccc";
      };
      control_char = {
        foreground = "#f99157";
      };
      broken_symlink = {
        foreground = "#f2777a";
      };
      broken_path_overlay = {
        foreground = "#f2777a";
      };
    };
  };
}
