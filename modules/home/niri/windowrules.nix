{ host, ... }:
''
  // Work around WezTerm's initial configure bug
  window-rule {
      match app-id=r#"^org\.wezfurlong\.wezterm$"#
      default-column-width {}
  }

  // Open the Firefox picture-in-picture player as floating by default
  window-rule {
      match app-id=r#"firefox$"# title="^Picture-in-Picture$"
      open-floating true
  }

  // Example: enable rounded corners for all windows
  window-rule {
      geometry-corner-radius 9
      clip-to-geometry true
      draw-border-with-background false
  }

  window-rule {
      match app-id=r#"^com\.obsproject\.Studio$"#
      default-column-width { proportion 0.7; }
  }

  // Floating kitty window centered on screen
  window-rule {
      match app-id=r#"^floating-kitty$"#
      open-floating true
      opacity 0.97
      default-column-width { fixed 1000; }
      default-window-height { fixed 700; }
  }

  // Transparency rules for various applications
  window-rule {
      match app-id=r#"^dev\.zed\.Zed$"#
      opacity 0.97
      focus-ring { off; }
  }

  window-rule {
      match app-id=r#"^dev\.zed\.Zed$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^vesktop$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^vesktop$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^org\.kde\.dolphin$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^org\.kde\.dolphin$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^kitty$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^kitty$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^org\.telegram\.desktop$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^org\.telegram\.desktop$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^zen$"#
      opacity 0.97
  }

  window-rule {
      match app-id=r#"^zen$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^steam$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^steam$"# is-focused=false
      opacity 0.85
  }

  window-rule {
      match app-id=r#"^obsidian$"#
      opacity 0.95
  }

  window-rule {
      match app-id=r#"^obsidian$"# is-focused=false
      opacity 0.85
  }
''
