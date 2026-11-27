{ pkgs, ... }:
let
  tideConfigs = "${pkgs.fishPlugins.tide.src}/functions/tide/configure";
in
{
  programs.fish = {
    plugins = [
      {
        name = "tide";
        inherit (pkgs.fishPlugins.tide) src;
      }
    ];

    shellInit = ''
      # Tide defaults: same as `tide configure` -> Lean style
      for file in ${tideConfigs}/icons.fish ${tideConfigs}/configs/lean.fish
          string replace -r '^' 'set -g ' <$file | source
      end
      set --global tide_time_format %T
      set --global tide_prompt_add_newline_before false
      set --global tide_prompt_transient_enabled false
      set --global tide_left_prompt_suffix ' '
      set --global tide_left_prompt_frame_enabled true
      set --global tide_right_prompt_frame_enabled true

      set --global tide_left_prompt_items time context pwd fishgit newline symbol
      set --global tide_right_prompt_items (string match -rv '(time|context)' $tide_right_prompt_items)

      set --global tide_jobs_number_threshold 1
      set --global tide_cmd_duration_threshold 1000
      set --global tide_pwd_color_anchors white
      set --global tide_pwd_color_dirs white
      set --global tide_pwd_color_truncated_dirs normal
      set --global tide_time_color normal

      set --global tide_character_color normal
      set --global tide_character_color_failure red

      set --global __fish_git_prompt_showcolorhints 1
      set --global __fish_git_prompt_showdirtystate 1
      set --global __fish_git_prompt_showuntrackedfiles 1
      set --global __fish_git_prompt_showupstream auto

      set -gx VIRTUAL_ENV_DISABLE_PROMPT true
    '';

    binds = {
      enter-default = {
        name = "enter";
        mode = "default";
        setsMode = "insert";
        command = "_tide_time_execute";
      };
      enter-insert = {
        name = "enter";
        mode = "insert";
        command = "_tide_time_execute";
      };
      enter-replace = {
        name = "enter";
        mode = "replace";
        setsMode = "insert";
        command = "_tide_time_execute";
      };
    };

    functions = {
      _tide_time_execute = ''
        if commandline --is-valid || test -z "$(commandline)" && not commandline --paging-mode
            set -l prompt_var _tide_prompt_$fish_pid
            if set -q $prompt_var
                set $prompt_var (string replace -r '\d\d:\d\d:\d\d' (date +$tide_time_format) -- $$prompt_var[1][1]) $$prompt_var[1][2..]
            end
        end
        commandline -f execute
      '';

      _tide_item_symbol = ''
        test $_tide_status = 0 && set_color --bold $tide_character_color || set_color --bold $tide_character_color_failure
        test "$EUID" = 0 && set -l symbol '#' || set -l symbol '$'
        set -q add_prefix || printf ' '

        printf '%s' $symbol
      '';

      _tide_item_fishgit = ''
        printf '%s' (fish_git_prompt)
      '';
    };
  };
}
