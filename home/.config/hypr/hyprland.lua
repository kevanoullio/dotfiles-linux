-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- NVIDIA GPU and Session Optimizations
-- Informs applications that the current session is using Wayland;
-- this ensures they use native Wayland protocols for better efficiency
-- rather than falling back to the older X11/XWayland protocols.
hl.env("XDG_SESSION_TYPE", "wayland")

-- Enables VA-API hardware video acceleration via the NVIDIA driver;
-- this prevents high CPU usage during video playback by offloading
-- video decoding tasks directly to the GPU.
hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- Directs legacy applications using the VDPAU API to use NVIDIA's driver;
-- this ensures that older video playback software still benefits from
-- your GPU's hardware decoding capabilities rather than using your CPU.
hl.env("VDPAU_DRIVER", "nvidia")

-- Configures Generic Buffer Management (GBM) to use NVIDIA DRM
-- (Direct Rendering Manager); this is crucial for flicker-free,
-- smooth window compositing in a Wayland session.
hl.env("GBM_BACKEND", "nvidia-drm")

-- Ensures applications running via the XWayland compatibility layer
-- use NVIDIA's proprietary OpenGL libraries instead of default Mesa
-- drivers, providing maximum 3D rendering performance.
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Toolkit Wayland Enforcement
-- Forces GTK applications to prefer Wayland over XWayland;
-- this ensures crisp text and better scaling, while providing a
-- fallback for older applications that haven't been updated for Wayland.
hl.env("GDK_BACKEND", "wayland,x11")

-- Forces Qt applications to use the Wayland backend;
-- this significantly improves window management and responsiveness for
-- Qt-based tools, preventing them from running via the XWayland layer.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Tells SDL-based applications and many modern games to use Wayland;
-- this reduces input latency and provides much smoother mouse movement
-- and window resizing compared to running through XWayland.
hl.env("SDL_VIDEODRIVER", "wayland,x11")

-- Explicit Hardware Selection
-- Explicitly tells the Vulkan loader to prioritize the NVIDIA driver;
-- this ensures that high-demand 3D workloads always utilize the power
-- of the RTX 5070 Ti instead of the Intel integrated graphics.
hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/nvidia_icd.json")

-- Workspace rules using the global monitor definitions from monitors.lua
-- Lower Monitor (DP-4)
hl.workspace_rule({ workspace = "1", monitor = _G.MY_MONITORS.LOWER, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = _G.MY_MONITORS.LOWER, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = _G.MY_MONITORS.LOWER, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = _G.MY_MONITORS.LOWER, persistent = true })
hl.workspace_rule({ workspace = "5", monitor = _G.MY_MONITORS.LOWER, persistent = true })

-- Upper Monitor (HDMI-A-3)
hl.workspace_rule({ workspace = "6", monitor = _G.MY_MONITORS.UPPER, default = true, persistent = true })
hl.workspace_rule({ workspace = "7", monitor = _G.MY_MONITORS.UPPER, persistent = true })
hl.workspace_rule({ workspace = "8", monitor = _G.MY_MONITORS.UPPER, persistent = true })
hl.workspace_rule({ workspace = "9", monitor = _G.MY_MONITORS.UPPER, persistent = true })
hl.workspace_rule({ workspace = "10", monitor = _G.MY_MONITORS.UPPER, persistent = true })
