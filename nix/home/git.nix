{
  config,
  pkgs,
  ...
}:
let
  xdgGit = "${config.xdg.configHome}/git";
in
{
  home.packages = [ pkgs.delta ];

  xdg.configFile = {
    "git/githelpers".source = ./git/githelpers;
    "git/ctags".source = ./git/ctags;
  };

  programs.git = {
    enable = true;

    ignores = [
      ".project_env"
      ".DS_Store"
      "TODO"
      "**/mise.local.toml"
      "**/.mise.local.toml"
      "**/.claude/settings.local.json"
    ];

    attributes = [
      "*.c diff=cpp"
      "*.c++ diff=cpp"
      "*.cc diff=cpp"
      "*.cpp diff=cpp"
      "*.h diff=cpp"
      "*.h++ diff=cpp"
      "*.hh diff=cpp"
      "*.hpp diff=cpp"
      "*.cs diff=csharp"
      "*.css diff=css"
      "*.ex diff=elixir"
      "*.exs diff=elixir"
      "*.go diff=golang"
      "*.html diff=html"
      "*.xhtml diff=html"
      "*.md diff=markdown"
      "*.m diff=objc"
      "*.mm diff=objc"
      "*.php diff=php"
      "*.pl diff=perl"
      "*.py diff=python"
      "*.rb diff=ruby"
      "*.rake diff=ruby"
      "*.rs diff=rust"
      # No dedicated builtin driver for JS/TS; cpp's brace/identifier
      # heuristics are the closest fit among what git ships.
      "*.js diff=cpp"
      "*.jsx diff=cpp"
      "*.mjs diff=cpp"
      "*.cjs diff=cpp"
      "*.ts diff=cpp"
      "*.tsx diff=cpp"
      "*.mts diff=cpp"
      "*.cts diff=cpp"
      # No dedicated builtin driver for these either; css's hunk-header
      # pattern still matches their selector/declaration syntax well enough.
      "*.scss diff=css"
      "*.sass diff=css"
      "*.less diff=css"
    ];

    hooks = {
      post-checkout = ./git/hooks/post-checkout;
      post-commit = ./git/hooks/post-commit;
      post-merge = ./git/hooks/post-merge;
      post-rewrite = ./git/hooks/post-rewrite;
    };

    includes = [ { path = "~/.dotoverrides/gitconfig"; } ];

    settings = {
      core = {
        editor = "vim";
        trustctime = false;
        fsmonitor = true;
        untrackedCache = true;
      };

      "color \"branch\"" = {
        current = "yellow reverse";
        local = "yellow";
        remote = "green";
      };
      "color \"status\"" = {
        added = "yellow";
        changed = "green";
        untracked = "cyan";
      };

      alias = {
        amend = "commit --amend";
        ci = "commit --verbose";
        co = "checkout";
        dh1 = "diff HEAD~1";
        ds = "diff --stat";
        ff = "pull --ff-only";
        st = "status";
        # Show the HEAD commit and its contents
        hp = "!bash -c '. ${xdgGit}/githelpers && show_git_head $*' $*";
        # Show commits local to this branch (not pushed/reachable from a
        # remote), plus up to 3 ancestor commits of context
        l = "!bash -c '. ${xdgGit}/githelpers && pretty_local_log $*' $*";
        # Show all commits
        la = "!bash -c '. ${xdgGit}/githelpers && pretty_git_log --all $*' $*";
        # Show current branch history
        lb = "!bash -c '. ${xdgGit}/githelpers && show_branch_history $*' $*";
        ss = "status --short --branch";
        d = "difftool";
        dg = "difftool --gui";
        ctags = "!${xdgGit}/ctags";
        unstage = "restore --staged";
        smu = "submodule update --init --recursive";
        prettylog = "!bash -c '. ${xdgGit}/githelpers && pretty_git_log $*' $*";
        prunebranches = "!git fetch --prune --all && git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d";
        conflicts = "diff --name-only --diff-filter=U";
      };

      push = {
        autoSetupRemote = true;
        followTags = true;
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        guitool = "p4mergetool";
        tool = "vimdiff";
        mnemonicPrefix = true;
      };

      difftool.prompt = false;
      "difftool \"p4mergetool\"".cmd =
        "/Applications/p4merge.app/Contents/Resources/launchp4merge $LOCAL $REMOTE";

      pager = {
        diff = "delta";
        log = "delta";
        reflog = "delta";
        show = "delta --side-by-side=150";
      };
      delta = {
        "hunk-header-decoration-style" = "";
        line-numbers = true;
        minus-style = "syntax 52";
        navigate = true;
        syntax-theme = "Tomorrow-Night-Eighties";
        hyperlinks = true;
      };
      interactive = {
        diffFilter = "delta --color-only";
        singleKey = true;
      };

      merge.tool = "p4mergetool";
      merge.conflictStyle = "zdiff3";
      "mergetool \"p4mergetool\"" = {
        cmd = "/Applications/p4merge.app/Contents/Resources/launchp4merge $PWD/$BASE $PWD/$REMOTE $PWD/$LOCAL $PWD/$MERGED";
        keepTemporaries = false;
      };
      mergetool.keepBackup = false;

      init.defaultBranch = "main";

      pull.rebase = false;

      rerere = {
        enabled = true;
        autoUpdate = true;
      };

      column = {
        branch = "auto";
        tag = "auto";
      };

      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      fetch = {
        prune = true;
        pruneTags = true;
      };

      commit.verbose = true;
      rebase.autoStash = true;
    };

    maintenance.enable = true;
  };
}
