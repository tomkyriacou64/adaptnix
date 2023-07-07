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
  networking.networkmanager.enable = true; 


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

  # environment.variables = {
  #   DISPLAY = ":0";
  # };


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
    tailscale
    neofetch
    htop
	  feh
	  git
    nfs-utils
    openssh
    openssl
    polkit
    pavucontrol
    picom
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
    appimage-run
    touchegg
  ];

  # Enable Services
  services.gvfs.enable = true;
  services.sshd.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "openbox";


  # Setup and Configure Tailscale

    # Enable the Tailscale service
    services.tailscale.enable = true;

    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kYHftE6CNTRL-Jd8VUSFtyegMTL2AE1V4fg71FNJNeMcTK
    '';
  };


  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };


# Enable polkit
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  }; 



# Enable cron service
services.cron = {
  enable = true;
  systemCronJobs = [
    "0 2 1,16 * * if ping -c 1 google.com > /dev/null 2>&1; then \
      reboot \
    fi"
  ];
};




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

