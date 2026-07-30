{
  host,
  pkgs,
  lib,
  startupApps,
  barChoice,
  ...
}:
''
  spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
  spawn-at-startup "bash" "-c" "awww-daemon && sleep 1 && awww clear 000000"
  spawn-at-startup "wal" "-R"
  spawn-at-startup "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
  hotkey-overlay {
      skip-at-startup
  }
''
