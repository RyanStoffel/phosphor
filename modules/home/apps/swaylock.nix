{ ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      indicator-radius = 80;
      indicator-thickness = 4;
      show-failed-attempts = true;
      ignore-empty-password = true;
    };
  };
}
