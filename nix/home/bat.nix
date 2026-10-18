{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      map-syntax = [
        "TODO:Tasks"
      ];
      theme = "Tomorrow-Night-Eighties";
    };

    syntaxes = {
      Tasks = {
        src = pkgs.fetchFromGitHub {
          owner = "aziz";
          repo = "PlainTasks";
          rev = "6563925";
          hash = "sha256-pShS5KMU1fjeKBmrgdVaW8TmE+c1I3NOQL0jFhMEDbs=";
        };
        file = "PlainTasks.sublime-syntax";
      };
    };

    themes = {
      Tomorrow-Night-Eighties = {
        src = pkgs.fetchFromGitHub {
          owner = "chriskempson";
          repo = "tomorrow-theme";
          rev = "ccf6666d888198d341b26b3a99d0bc96500ad503";
          hash = "sha256-G9NOFKP9GX8lKIoHVska6xAY9AKKMenZuVkx0YgfQyA=";
        };
        file = "textmate/Tomorrow-Night-Eighties.tmTheme";
      };
    };
  };
}
