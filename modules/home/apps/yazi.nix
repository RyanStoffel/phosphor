{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    package = pkgs.yazi;
    shellWrapperName = "yy";
  };
}
