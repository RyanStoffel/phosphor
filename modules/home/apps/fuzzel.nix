{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty -e";
        layer = "overlay";
        lines = 10;
        width = 40;
        border-radius = 0;
      };
      border = {
        width = 1;
        radius = 0;
      };
    };
  };
}
