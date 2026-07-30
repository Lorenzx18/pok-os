{ barChoice ? "waybar" }:
let
  noctalia = barChoice == "noctalia";
in
''
  config-notification {
      disable-failed
  }

  gestures {
      hot-corners {
          off
      }
  }

  input {
      keyboard {
          xkb {
          }
      }
      touchpad {
          // Natural scrolling inverts scroll direction
          // Up swipe scrolls down, down swipe scrolls up (natural direction)
          natural-scroll
          // Tap-to-click
          tap
      }
      mouse {
          accel-profile "adaptive"
          accel-speed 1.0
      }
      trackpoint {
      }

      focus-follows-mouse max-scroll-amount="0%"
      warp-mouse-to-focus
  }

  layout {
      gaps 9

      center-focused-column "never"
      always-center-single-column

      preset-column-widths {
          proportion 0.5
          proportion 0.66667
          proportion 1.0
      }

      default-column-width { proportion 0.5; }

      border {
          width 2
          ${if noctalia then "" else ''active-color   "#cba6f7"''}
          ${if noctalia then "" else ''inactive-color "#45475b"''}
          ${if noctalia then "" else ''urgent-color   "#f5c2e7"''}
      }

      focus-ring {
          off
          width 6
          ${if noctalia then "" else ''active-color   "#7fc8ff"''}
          ${if noctalia then "" else ''inactive-color "#505050"''}
          ${if noctalia then ''urgent-color "#cd736b"'' else ""}
      }

      shadow {
          color "#00000060"
          softness 30
          spread 5
          offset x=0 y=5
      }

      ${if noctalia then "" else ''
      tab-indicator {
          active-color   "#cba6f7"
          inactive-color "#45475b"
          urgent-color   "#f5c2e7"
      }

      insert-hint {
          color "#cba6f780"
      }
      ''}

      struts {
      }
  }

  ${if noctalia then "" else ''
  recent-windows {
      highlight {
          active-color "#cba6f7"
          urgent-color "#f5c2e7"
      }
  }
  ''}

  /-layer-rule {
      match namespace="^quickshell$"
      place-within-backdrop true
  }

  overview {
      backdrop-color "#1e1e2e"

      workspace-shadow {
          softness 40
          spread 10
          offset x=0 y=10
          color "#00000050"
      }

      zoom 0.5
  }

  animations {
      workspace-switch {
          spring damping-ratio=0.80 stiffness=523 epsilon=0.0001
      }
      window-open {
          duration-ms 150
          curve "ease-out-expo"
      }
      window-close {
          duration-ms 150
          curve "ease-out-quad"
      }
      horizontal-view-movement {
          spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
      }
      window-movement {
          spring damping-ratio=0.75 stiffness=323 epsilon=0.0001
      }
      window-resize {
          spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
      }
      config-notification-open-close {
          spring damping-ratio=0.65 stiffness=923 epsilon=0.001
      }
      screenshot-ui-open {
          duration-ms 200
          curve "ease-out-quad"
      }
      overview-open-close {
          spring damping-ratio=0.85 stiffness=800 epsilon=0.0001
      }
  }
''
