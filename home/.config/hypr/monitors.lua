-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Global monitor names for easy reuse across other configuration files
_G.MY_MONITORS = {
  LOWER = "DP-4",
  UPPER = "HDMI-A-3"
}

-- Scaling factors for applications and the compositor
local omarchy_gdk_scale = 1     -- Scale factor for GTK applications via GDK_SCALE env var
local omarchy_monitor_scale = 1 -- Scale factor for Hyprland monitor output

-- Set environment variable for GTK application scaling
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Explicit monitor configurations
-- We define specific monitors to ensure precise positioning and scaling.

-- The following line is commented out to avoid conflicts with our specific manual layout:
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure the lower monitor
hl.monitor({ output = _G.MY_MONITORS.LOWER, mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- Configure the upper monitor
hl.monitor({ output = _G.MY_MONITORS.UPPER, mode = "preferred", position = "0x-1080", scale = omarchy_monitor_scale })
