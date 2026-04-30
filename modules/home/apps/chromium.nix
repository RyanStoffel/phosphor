{ ... }:
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations"
      "--disable-features=UseChromeOSDirectVideoDecoder"
    ];
  };
}
