{
  # ===========================================================
  # 🎨 Waybar - Default Bar Configuration
  # ===========================================================
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [ "hyprland/window" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "tray" "cpu" "memory" "network" "pulseaudio" "battery" "clock" ];
        
        clock = {
          format = "{: %Y-%m-%d %H:%M}";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Noto Sans";
        font-size: 13px;
        min-height: 0;
      }
      window#waybar {
        background: rgba(26, 27, 38, 0.5);
        border-bottom: 1px solid rgba(100, 100, 100, 0.3);
        color: white;
      }
      #workspaces button.focused {
        background: rgba(0, 150, 255, 0.6);
      }
      #workspaces button {
        padding: 0 10px;
      }
    '';
  };
}

