{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      window-decoration = false;
      resize-overlay = "never";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
    };
  };
}
