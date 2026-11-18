{ pkgs, ... }:
{
  programs.fish = {
    plugins = [
      {
        name = "async-prompt";
        src = pkgs.fetchFromGitHub {
          owner = "andrasmaroy";
          repo = "fish-async-prompt";
          rev = "41c7a16fec0339ba9e55ea66183fda8504e290fa";
          hash = "sha256-u+E5jd2IvBB0C6cXeP1o0SqKm+SXdCfxbGmYZiPXkyg=";
        };
      }
    ];

    shellInit = ''
      # Reference: https://fishshell.com/docs/current/cmds/fish_git_prompt.html
      set -g __fish_git_prompt_showcolorhints 1
      set -g __fish_git_prompt_showdirtystate 1
      set -g __fish_git_prompt_showuntrackedfiles 1
      set -g __fish_git_prompt_showupstream auto
    '';

    interactiveShellInit = ''
      set -g async_prompt_inherit_variables status pipestatus SHLVL CMD_DURATION fish_bind_mode VIRTUAL_ENV SSH_CONNECTION
      set -g async_prompt_functions fish_right_prompt _prompt_git _prompt_hostname _prompt_pwd _prompt_user _prompt_virtualenv
    '';

    # Repaint prompt before executing
    # Reference: https://github.com/IlanCosman/tide/issues/85#issuecomment-1409875980
    binds = {
      enter-default = {
        name = "enter";
        mode = "default";
        setsMode = "insert";
        command = "transient_execute";
      };
      enter-insert = {
        name = "enter";
        mode = "insert";
        command = "transient_execute";
      };
      enter-replace = {
        name = "enter";
        mode = "replace";
        setsMode = "insert";
        command = "transient_execute";
      };
    };

    functions = {
      fish_prompt = ''
        set --local exit_code $status # save previous exit code

        _prompt_time
        _prompt_status $exit_code
        _prompt_jobs
        _prompt_virtualenv
        _prompt_user
        _prompt_hostname
        _prompt_pwd
        _prompt_git
        _prompt_symbol
      '';
      fish_right_prompt = ''
        if test $CMD_DURATION -ge 1000
            set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
            set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
            set --local hours (math --scale=0 $CMD_DURATION/3600000)

            set --local duration

            test $hours -gt 0 && set --local --append duration $hours"h"
            test $mins -gt 0 && set --local --append duration $mins"m"
            test $secs -gt 0 && set --local --append duration $secs"s"

            echo $duration
        end
      '';
      fish_mode_prompt = "";
      _prompt_git = ''
        printf '%s' (fish_git_prompt)
      '';
      _prompt_hostname = ''
        set -l username "$(id -u -n)"
        if test "$username" = root
            set_color red
        end
        if test "$username" != "$LC_LOGINUSER"
            echo -n "$username"
        end
        set_color normal

        if test "$SSH_CONNECTION" != ""
            if test "$username" != "$LC_LOGINUSER"
                echo -n '@'
            end
            echo -n "$(set_color --bold red)$(hostname -s)$(set_color normal):"
        else if test "$username" != "$LC_LOGINUSER"
            echo -n ':'
        end
      '';
      _prompt_jobs = ''
        set --local stopped_jobs (count (jobs | awk '{print $3}' | grep stopped))
        set --local running_jobs (count (jobs | awk '{print $3}' | grep running))

        if test $stopped_jobs -gt 0 -o $running_jobs -gt 0
            set_color --bold white
            printf '[%sr/%ss] ' $running_jobs $stopped_jobs
            set_color normal
        end
      '';
      _prompt_pwd = ''
        set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
        set --function pwd (prompt_pwd)

        if test -n $git_root
            set --local git_root_shortened (prompt_pwd "$git_root")
            set --local git_root_placeholder (prompt_pwd -D 0 "$git_root")

            if test $pwd != $git_root_shortened
                set --function pwd (string replace -- "$git_root_placeholder" "$git_root_shortened" "$pwd")
            end
        end
        echo -n "$(set_color --bold white)$pwd$(set_color normal)"
      '';
      _prompt_status = {
        argumentNames = [ "exit_code" ];
        body = ''
          if test $exit_code -ne 0 -a $exit_code -ne 146
              echo -n "[$(set_color red)$exit_code$(set_color normal)] "
          end
        '';
      };
      _prompt_symbol = ''
        if test "$(id -u -n)" = root
            printf '\n# '
        else
            printf '\n$ '
        end
      '';
      _prompt_time = ''
        echo -n "$(set_color --bold white)$(date '+%T') $(set_color normal)"
      '';
      _prompt_user = "";
      _prompt_virtualenv = ''
        if test -n "$VIRTUAL_ENV"
            echo -n -s '(' (set_color blue) (basename "$VIRTUAL_ENV") (set_color normal) ') '
        end
      '';

      # Transient prompt
      reset-transient = {
        onEvent = "fish_postexec";
        body = ''
          set -g TRANSIENT 0
        '';
      };
      transient_execute = ''
        if commandline --is-valid
            set --global TRANSIENT 1
            commandline --function repaint
        else if test "$(commandline -b)" = "" # fix empty enter
            set --global TRANSIENT 2
            commandline --function repaint
        else
            set --global TRANSIENT 0
        end
        commandline --function execute
      '';
    };
  };
}
