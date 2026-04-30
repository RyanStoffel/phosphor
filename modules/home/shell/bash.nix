{ pkgs, ... }:
{
  programs.bash = {
    enable = true;

    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      grep = "rg";
    };

    initExtra = ''
      set -o vi

      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

      eval "$(direnv hook bash)"
    '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "bat";
  };
}
