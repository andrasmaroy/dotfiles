{ ... }:
{
  # git config, ported from roles/git/files/gitconfig into programs.git.
  # This is the "native" half of the hybrid git handling: the executable
  # helper (~/.githelpers) and the hook template dir (~/.git_template) stay
  # raw symlinks (see home/default.nix). user.name/email/signingkey are NOT
  # set here on purpose -- they come from the private dotoverrides include.
  programs.git = {
    enable = true;

    aliases = {
      amend = "commit --amend";
      ci = "commit --verbose";
      co = "checkout";
      dh1 = "diff HEAD~1";
      ds = "diff --stat";
      ff = "pull --ff-only";
      st = "status";
      hp = "!bash -c '. ~/.githelpers && show_git_head $*' $*";
      l = "!bash -c '. ~/.githelpers && pretty_git_log HEAD @{u} --not $(git merge-base HEAD @{u})~3 $*' $*";
      la = "!bash -c '. ~/.githelpers && pretty_git_log --all $*' $*";
      lb = "!bash -c '. ~/.githelpers && show_branch_history $*' $*";
      ss = "status --short --branch";
      d = "difftool";
      dg = "difftool --gui";
      ctags = "!.git/hooks/ctags";
      unstage = "reset HEAD";
      smu = "submodule update --init --recursive";
      prettylog = "!bash -c '. ~/.githelpers && pretty_git_log $*' $*";
      prunebranches = "!git fetch --prune --all && git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d";
      conflicts = "diff --name-only --diff-filter=U";
    };

    # was core.excludesfile = ~/.gitignore_global
    ignores = [
      ".project_env"
      ".DS_Store"
      "TODO"
    ];

    # was core.attributesfile = ~/.gitattributes_global
    attributes = [
      "*.c     diff=cpp"
      "*.h     diff=cpp"
      "*.c++   diff=cpp"
      "*.h++   diff=cpp"
      "*.cpp   diff=cpp"
      "*.hpp   diff=cpp"
      "*.cc    diff=cpp"
      "*.hh    diff=cpp"
      "*.m     diff=objc"
      "*.mm    diff=objc"
      "*.cs    diff=csharp"
      "*.css   diff=css"
      "*.html  diff=html"
      "*.xhtml diff=html"
      "*.ex    diff=elixir"
      "*.exs   diff=elixir"
      "*.go    diff=golang"
      "*.php   diff=php"
      "*.pl    diff=perl"
      "*.py    diff=python"
      "*.md    diff=markdown"
      "*.rb    diff=ruby"
      "*.rake  diff=ruby"
      "*.rs    diff=rust"
      "*.lisp  diff=lisp"
      "*.el    diff=lisp"
    ];

    # was [include] path = ~/.dotoverrides/gitconfig -- supplies user.* and the
    # per-directory instructure include from the private submodule.
    includes = [
      { path = "~/.dotoverrides/gitconfig"; }
    ];

    # Everything else verbatim. delta is wired by hand (not delta.enable) to
    # keep the original per-command [pager] setup rather than core.pager.
    extraConfig = {
      core = {
        editor = "vim";
        trustctime = false;
      };
      color = {
        branch = "auto";
        status = "auto";
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
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        compactionHeuristic = true;
        guitool = "p4mergetool";
        tool = "vimdiff";
        mnemonicPrefix = true;
        renames = true;
      };
      difftool = {
        prompt = false;
      };
      "difftool \"p4mergetool\"" = {
        cmd = "/Applications/p4merge.app/Contents/Resources/launchp4merge $LOCAL $REMOTE";
      };
      pager = {
        diff = "delta";
        log = "delta";
        reflog = "delta";
        show = "delta --side-by-side";
      };
      delta = {
        hunk-header-decoration-style = "";
        line-numbers = true;
        minus-style = "syntax 52";
        navigate = true;
        syntax-theme = "Tomorrow-Night-Eighties";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      merge = {
        tool = "p4mergetool";
      };
      "mergetool \"p4mergetool\"" = {
        cmd = "/Applications/p4merge.app/Contents/Resources/launchp4merge $PWD/$BASE $PWD/$REMOTE $PWD/$LOCAL $PWD/$MERGED";
        keepTemporaries = false;
        trustExitCode = false;
      };
      mergetool = {
        keepBackup = false;
      };
      init = {
        templatedir = "~/.git_template";
        defaultBranch = "main";
      };
      pull = {
        rebase = false;
      };
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      column = {
        branch = "auto";
        tag = "auto";
      };
      branch = {
        sort = "-commiterdate";
      };
      tag = {
        sort = "version:refname";
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      commit = {
        verbose = true;
      };
      rebase = {
        autoStash = true;
      };
    };
  };
}
