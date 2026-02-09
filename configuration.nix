{ lib, pkgs, ... }:

let
  crostiniPath =
    "/opt/google/cros-containers/bin"
    + ":/run/wrappers/bin"
    + ":/etc/profiles/per-user/chronos/bin"
    + ":/nix/var/nix/profiles/default/bin"
    + ":/run/current-system/sw/bin";
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    micro
    git gh
    podman
	dconf
	glib
    nerd-fonts.jetbrains-mono
  ];

  environment.sessionVariables = {
    PATH = crostiniPath;
    GDK_BACKEND = "wayland";
    WAYLAND_DISPLAY = "wayland-0";
    VK_ICD_FILENAMES = "/dev/null";
    VK_DRIVER_FILES = "/dev/null";
   
    XDG_DATA_DIRS =
      "/run/current-system/sw/share:" 
      + "/var/lib/flatpak/exports/share:"
      + "/home/chronos/.local/share/flatpak/exports/share";
  };

  users.users.chronos = {
    isNormalUser = true;
    linger = true;
    extraGroups = [ "wheel" "video" "render" ];
  };

  security.sudo.wheelNeedsPassword = false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  services.dbus.enable = true;
  services.flatpak.enable = true;

  hardware.graphics.enable = true;

  virtualisation.podman.enable = true;

  systemd.user.services.garcon.environment.PATH = lib.mkForce crostiniPath;
  systemd.user.services.xdg-desktop-portal.environment.PATH = lib.mkForce crostiniPath;
  systemd.user.services.xdg-desktop-portal-gtk.environment.PATH = lib.mkForce crostiniPath;

  system.stateVersion = "25.11";
}
