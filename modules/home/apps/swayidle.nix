{ config, lib, ... }:
{
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${lib.getExe config.programs.swaylock.package} -f";
      lock = "${lib.getExe config.programs.swaylock.package} -f";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe config.programs.swaylock.package} -f";
      }
      {
        timeout = 600;
        command = "${lib.getExe config.programs.niri.package} msg action power-off-monitors";
      }
    ];
  };
}
