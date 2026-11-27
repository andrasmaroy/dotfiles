{ lib, pkgs, ... }:
{
  imports = [ ./fish-tide-prompt.nix ];

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "fzf-fish";
        inherit (pkgs.fishPlugins.fzf-fish) src;
      }
      {
        name = "puffer";
        # Drop the '.' expansion binding, keep the rest
        src = pkgs.applyPatches {
          name = "puffer-fish-source";
          inherit (pkgs.fishPlugins.puffer) src;
          postPatch = ''
            substituteInPlace conf.d/puffer_fish_key_bindings.fish \
              --replace-fail "bind --mode \$modes[1] '.' _puffer_fish_expand_dot" "" \
              --replace-fail "erase '.' '!'" "erase '!'" \
              --replace-fail "bind -e '.'" ""
          '';
        };
      }
      {
        name = "done";
        inherit (pkgs.fishPlugins.done) src;
      }
    ];

    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      # Used by the fzf.fish plugin when previewing changed files
      set -g fzf_diff_highlighter delta --paging=never --width=20

      fish_add_path --move "$HOME/.nix-profile/bin"
      fish_add_path --move "/etc/profiles/per-user/$USER/bin"
      fish_add_path --move /run/current-system/sw/bin
      fish_add_path --move /nix/var/nix/profiles/default/bin

      fish_add_path /usr/local/sbin
      fish_add_path "$HOME/.bin"
      fish_add_path "$HOME/.bin/$(uname -s)"
      fish_add_path "$HOME/trigger-cli"
      if test -n "$SSH_CONNECTION"
          fish_add_path -g "$HOME/.bin/remote_utils"
      end
      fish_add_path "$REX_BIN_DIR"

      fish_config theme choose 'Tomorrow Night Eighties'
      set -g fish_color_search_match white

      # Vi mode with vim-like cursor shapes
      fish_vi_key_bindings
      # Force setting cursor shape
      set -g fish_vi_force_cursor 1
      # Emulates vim's cursor shape behavior
      # Set the normal and visual mode cursors to a block
      set -g fish_cursor_default block
      # Set the insert mode cursor to a line
      set -g fish_cursor_insert line
      # Set the replace mode cursor to an underscore
      set -g fish_cursor_replace underscore
      # The following variable can be used to configure cursor shape in
      # visual mode, but due to fish_cursor_default, is redundant here
      set -g fish_cursor_visual block
    '';

    binds = {
      "^" = {
        mode = "insert";
        command = "_expand_quick_substitution";
      };

      up-insert = {
        name = "up";
        mode = "insert";
        command = "history-prefix-search-backward";
      };
      down-insert = {
        name = "down";
        mode = "insert";
        command = "history-prefix-search-forward";
      };
      up-default = {
        name = "up";
        mode = "default";
        command = "history-prefix-search-backward";
      };
      down-default = {
        name = "down";
        mode = "default";
        command = "history-prefix-search-forward";
      };
    };

    shellAliases = {
      ll = "eza --long --all --header --classify=auto";
      mkdir = "mkdir -pv";
    };

    functions = {
      # History
      histignore = {
        onEvent = "fish_prompt";
        body = ''
          echo all | history --delete --prefix pwd history exit bg fg clear >/dev/null
        '';
      };
      fish_should_add_to_history = ''
        for cmd in pwd history exit bg fg clear
            string match -qr "^$cmd" -- $argv; and return 1
        end
        return 0
      '';

      # Expand '**' into fzf directory search, overrides the puffer-fish plugin version
      _puffer_fish_expand_star = ''
        if commandline --search-field >/dev/null
            commandline --search-field --insert '*'
        else if string match --quiet -- '!' "$(commandline --current-token)"
            set -l prev_cmd $history[1]
            set -l prev_args (string split ' ' $prev_cmd)
            set -e prev_args[1] # remove command name
            set -l arg_str (string join ' ' $prev_args)
            # replace !* with all arguments
            commandline --current-token '''
            commandline --insert $arg_str
        else if string match --quiet --regex -- '\*$' "$(commandline --current-token)" and functions --query _fzf_search_directory
            commandline --current-token '''
            _fzf_search_directory
        else
            commandline --insert '*'
        end
      '';

      # Bash-style quick substitution: '^old^new' replaces 'old' with 'new' in the previous command
      # Based on https://github.com/nickeb96/puffer-fish/pull/20
      _expand_quick_substitution = ''
        if commandline --search-field >/dev/null
            commandline --search-field --insert '^'
        else
            set -l current_token (commandline --current-token)
            if string match --quiet --regex -- '^\^([^^]+)\^([^^]*)$' "$current_token"
                set -l matches (string match --regex -- '^\^([^^]+)\^([^^]*)$' "$current_token")
                set -l old $matches[2]
                set -l new $matches[3]
                set -l prev_cmd $history[1]
                if string match --quiet -- "*$old*" "$prev_cmd"
                    set -l expanded (string replace -- "$old" "$new" "$prev_cmd")
                    commandline --current-token -- $expanded
                else
                    commandline --insert '^'
                end
            else
                commandline --insert '^'
            end
        end
      '';

      # Utilities
      dirs = {
        description = "Print directory stack";
        body = ''
          set -l options h/help c
          argparse -n dirs --max-args=0 $options -- $argv
          or return

          if set -q _flag_help
              __fish_print_help dirs
              return 0
          end

          if set -q _flag_c
              # Clear directory stack.
              set -e -g dirstack
              return 0
          end

          set -l index 0
          for dir in $PWD $dirstack
              echo -n " $index  "
              # Replace $HOME with ~.
              string replace -r '^'"$HOME"'($|/)' '~$1' -- $dir
              set index (math $index + 1)
          end
          return 0
        '';
      };
      docker-clean = {
        description = "Remove stopped docker containers and noname images";
        body = ''
          docker container prune -f
          docker volume prune -f
          docker images | grep '^<none>' | awk '{print $3}' | xargs docker rmi
        '';
      };
      escape = {
        description = "Print escape sequence for a given character";
        argumentNames = [ "char" ];
        body = ''
          printf "\\\\x%s" "$(printf '%s' "$argv" | xxd -p -c1 -u)"
        '';
      };
      extract = {
        description = "Extract the given file";
        argumentNames = [ "target" ];
        body = ''
          if test -f $target
              switch $target
                  case '*.tar.bz2'
                      tar xjf "$target"
                  case '*.tar.gz'
                      tar xzf "$target"
                  case '*.bz2'
                      bunzip2 "$target"
                  case '*.rar'
                      unrar e "$target"
                  case '*.gz'
                      gunzip "$target"
                  case '*.tar'
                      tar xf "$target"
                  case '*.tbz2'
                      tar xjf "$target"
                  case '*.tgz'
                      tar xzf "$target"
                  case '*.zip'
                      unzip "$target"
                  case '*.Z'
                      uncompress "$target"
                  case '*'
                      echo "'$target' cannot be extracted via extract()"
              end
          else
              echo "'$target' is not a valid file"
          end
        '';
      };
      fe = {
        description = "Fuzzy find files to edit";
        body = ''
          set -fx fzf_fd_opts --hidden --follow --exclude '.git' --type f
          set -fx fzf_directory_opts --select-1 --exit-0 --query=$argv[1] --preview=''' --layout=default --prompt='> '
          _fzf_search_directory
          set -f files $(commandline --tokenize)
          if test -n "$files"
              commandline -br "vim $files"
              commandline --function execute
          else
              return 1
          end
        '';
      };
      lstree = {
        wraps = "ls";
        description = "Show directory tree in folder";
        body = ''
          eza --tree --only-dirs --color=always --short-nix --show-symlinks $argv | less -EFRSX
        '';
      };
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      f = {
        description = "Open Finder in the specified folder";
        body = ''
          if test (count $argv) -eq 0
              open -a Finder .
          else
              open -a Finder $argv
          end
        '';
      };
      flushdns = {
        description = "Flush OS DNS cache";
        body = ''
          sudo dscacheutil -flushcache
          sudo killall -HUP mDNSResponder
        '';
      };
    };
  };

  xdg.configFile = {
    "fish/themes/Tomorrow Night Eighties.theme" = {
      source = "${
        pkgs.fetchFromGitHub {
          owner = "mattmc3";
          repo = "themepak.fish";
          rev = "4260ea529f4252ed28a743a43e2665ad18f52657";
          hash = "sha256-/pb7ZcUhUXYNDtIkPOZZs7Y2tE59txYG1YoydnX3Iw8=";
        }
      }/themes/Tomorrow Night Eighties.theme";
    };
  };
}
