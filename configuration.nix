{ config, pkgs, ... }:


{

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1u"
		"python-2.7.18.6"
   ];


  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  networking.hostName = "adaptiv"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.


  # Set your time zone.
  time.timeZone = "Australia/Melbourne";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.openbox.enable = true;
  services.xserver.layout = "us";


  #Configure LightDM
  services.xserver.displayManager = {
	lightdm.enable = true;
  	autoLogin = {
		enable = true;
		user = "adaptiv";
	};
  };


# Disable Sleep
  services.xserver.displayManager.sessionCommands = ''
    xset -dpms
    xset s off
    xset s noblank
   '';


# Enable and Configure Compositor  
 services.picom.enable = true;
 services.picom.vSync = true;
 services.picom.backend = "glx";


# Enable sound.
 sound.enable = true;
 hardware.pulseaudio.enable = true;


# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adaptiv = {
     isNormalUser = true;
     extraGroups = [ "wheel" "kvm" "input" "disk" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };


# List packages installed
  environment.systemPackages = with pkgs; [
	  wget
    openbox
    openbox-menu
    lightdm
    lightdm-gtk-greeter
    neofetch
    htop
	  neovim
	  chromium
	  feh
    gnome.gedit
	  git
    nfs-utils
    openssl
    pavucontrol
    picom
    polkit_gnome
    python3Full
    adapta-gtk-theme
    tela-icon-theme
	  unzip
    unclutter-xfixes
    xdg-user-dirs
	  xdg-desktop-portal-gtk
	  xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.xfce4-terminal
    xfce.xfce4-settings
    gvfs
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
	  xorg.xinit
    xorg.xinput
    touchegg
    bluez
    blueman
  ];

  # Enable Services
  services.gvfs.enable = true;

  # Disable the firewall altogether.
  networking.firewall.enable = false;
  networking.enableIPv6 = false;


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.autoUpgrade.enable = false;  
  system.autoUpgrade.allowReboot = false; 
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-23.05";
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

