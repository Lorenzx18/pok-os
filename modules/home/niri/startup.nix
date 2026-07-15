{
  host,
  pkgs,
  stylixImage,
  startupApps,
  barChoice,
  ...
}:
let
  # Determine which bar to launch
  # Note: waybar and dms are handled by systemd services, not spawn-at-startup
  barStartupCommand =
    if barChoice == "noctalia" then
      ''spawn-at-startup "noctalia" "--daemon"''
    else
      ''// ${barChoice} started via systemd service'';
in
''
  spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
  ${barStartupCommand}
  spawn-at-startup "bash" "-c" "awww-daemon && sleep 1 && awww img '${stylixImage}'"
  spawn-at-startup "wal" "-R"
  spawn-at-startup "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
''
