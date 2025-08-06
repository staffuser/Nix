# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages/development.nix
    ./packages/addon.nix
    <home-manager/nixos>
  ];

# Bootloader with recovery support
boot.loader = {
  systemd-boot = {
    enable = true;
    configurationLimit = 10; # Limit to 10 generations
  };
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  timeout = 5;
};

# Enable snapshots for recovery
boot.initrd.systemd = {
  enable = true;
  emergencyAccess = true; # Allow root access in initrd for recovery
};
boot.initrd.luks.devices = {
  root = {
    device = "/dev/disk/by-uuid/8efb79fa-83f9-4599-8200-462f57dc165f";
    preLVM = true;
    allowDiscards = true;
  };
};

boot.kernelPackages = pkgs.linuxPackages_latest;

boot.kernelParams = [ 
  "nvidia_drm.modeset=1" 
  "intel_iommu=on" 
  "iommu=pt"
  "mitigations=off"
  "transparent_hugepage=always"
  "default_hugepagesz=1G"
];

boot.blacklistedKernelModules = [ "nouveau" ];

networking.hostName = "nixos"; # Define your hostname.
networking.networkmanager.enable = true;
networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
networking.networkmanager.enable = true;

# Set your time zone.
time.timeZone = "Europe/Moscow";

# Select internationalisation properties.
i18n.defaultLocale = "en_US.UTF-8";

i18n.extraLocaleSettings = {
  LC_ADDRESS = "ru_RU.UTF-8";
  LC_IDENTIFICATION = "ru_RU.UTF-8";
  LC_MEASUREMENT = "ru_RU.UTF-8";
  LC_MONETARY = "ru_RU.UTF-8";
  LC_NAME = "ru_RU.UTF-8";
  LC_NUMERIC = "ru_RU.UTF-8";
  LC_PAPER = "ru_RU.UTF-8";
  LC_TELEPHONE = "ru_RU.UTF-8";
  LC_TIME = "ru_RU.UTF-8";
};

console = {
  font = "Lat2-Terminus16";
  keyMap = "us";
};

# NVIDIA
services.xserver.videoDrivers = [ "nvidia" ];
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
  extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
    nvidia-vaapi-driver
  ];
};
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = true;
  powerManagement.finegrained = false;
  open = false;
  nvidiaSettings = true;
  forceFullCompositionPipeline = true; 
  nvidiaPersistenced = true; 
  package = config.boot.kernelPackages.nvidiaPackages.stable;
  prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
};

# X11 и GNOME
services.xserver = {
  enable = true;
  xkb = {
    variant = "";
    layout = "us,ru";
    options = "grp:alt_shift_toggle,eurosign:e";
  };
  displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  desktopManager = {
    gnome.enable = true;
    plasma6.enable = true; # Use Plasma 6 for modern KDE
  };
};

#Optimiz
environment.variables = {
  VDPAU_DRIVER = "nvidia";
  LIBVA_DRIVER_NAME = "nvidia";
};

powerManagement = {
  cpuFreqGovernor = "performance";
  powertop.enable = true; # Для мониторинга энергопотребления
};
services.thermald.enable = true; 

fileSystems."/".options = ["noatime" "nodiratime" "discard"];

# Enable the X11 windowing system.
services.xserver.enable = true;

# Enable the GNOME Desktop Environment.
services.xserver.displayManager.gdm.enable = true;
services.xserver.desktopManager.gnome.enable = true;
services.xserver.desktopManager.plasma5.enable = true;
# Configure keymap in X11
services.xserver.xkb = {
  layout = "us";
  variant = "";
};

# Enable CUPS to print documents.
services.printing.enable = true;

# Sound 
sound.enable = true;
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  jack.enable = true;

  # use the example session manager (no others are packaged yet so this is enabled by default,
  # no need to redefine it in your config for now)
  #media-session.enable = true;
};

# Enable touchpad support (enabled default in most desktopManager).
# services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.s336 = {
  isNormalUser = true;
  description = "s336";
  extraGroups = ["video" "audio" "storage" "libvirtd" "networkmanager" "wheel" ];
  packages = with pkgs; [
  #  thunderbird
  firefox
  thunderbird
  mpv # For video wallpapers
  hyprpaper # For Wayland wallpapers
  ];
  shell = pkgs.zsh;
};

# pack
environment.systemPackages = with pkgs; [
  vim
  wget
  curl
  git
  htop
  neofetch
  pciutils
  usbutils
  intel-gpu-tools
  psensor
  goverlay #test
  flatpak
  gnome.gnome-tweaks
  kdePackages.plasma-workspace # For live wallpapers in KDE
];

# Install firefox.
programs.firefox.enable = true;


# List packages installed in system profile. To search, run:
# $ nix search wget
environment.systemPackages = with pkgs; [
#  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#  wget
];


services.fstrim.enable = true;
services.udisks2.enable = true;
services.earlyoom.enable = true;  

services.gnome.gnome-keyring.enable = true;
programs.seahorse.enable = true;

services.flatpak = {
  enable = true;
  remotes = [
    { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
  ];
};

qt = {
  enable = true;
  platformTheme = "gnome";
  style = "adwaita-dark";
};

programs.dconf.enable = true;

programs.zsh = {
  enable = true;
  ohMyZsh = {
    enable = true;
    plugins = ["git" "docker" "sudo" "systemd"];
    theme = "agnoster";
  };
  shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch";
    clean = "sudo nix-collect-garbage -d";
  };
};

# Garbage Collection
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};

system.autoUpgrade = {
  enable = true;
  channel = "https://nixos.org/channels/nixos-unstable";
};

# Это нужно для некоторых GNOME расширений
nixpkgs.config.allowUnfree = true;


fonts = {
  enableDefaultFonts = true;
  fonts = with pkgs; [
    # Стандартные шрифты
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    ubuntu_font_family 
    cantarell-fonts
    roboto
];

  fontconfig = {
  defaultFonts = {
    serif = [ "DejaVu Serif" "Noto Serif" "PT Sans" ];
    sansSerif = [ "DejaVu Sans" "Noto Sans" "PT Sans" ];
    monospace = [ "DejaVu Sans Mono" "Fira Code" ]; # or "Fira Code" "JetBrains Mono"
  };
  };
};
services.xserver = {
  desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      font-name='DejaVu Sans 10'
      document-font-name='DejaVu Serif 11'
      monospace-font-name='Fira Code 10'
    '';
  };
}; 
}

# ---------------------------------------- Custom -----------------------------------------------------

# GNOME Customizations
services.xserver.desktopManager.gnome = {
  extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    font-name='Noto Sans 10'
    document-font-name='Noto Serif 11'
    monospace-font-name='Fira Code 10'
    color-scheme='prefer-dark'

    [org.gnome.desktop.background]
    picture-uri='file:///home/s336/.local/share/backgrounds/wallpaper.mp4'
    picture-options='zoom'

    [org.gnome.shell]
    enabled-extensions=[
      'appindicator@ubuntu.com',
      'dash-to-dock@micxgx.gmail.com',
      'arc-menu@arc.oscillate.io',
      'blur-my-shell@aunetx',
      'caffeine@patapon.info',
      'clipboard-indicator@tudmotu.com',
      'gsconnect@andyholmes.github.io',
      'hidetopbar@mathieu.bidon.ca',
      'tray-icons-reloaded@selfmade.pl',
      'user-theme@gnome-shell-extensions.gcampax.github.com',
      'vitals@corecoding.com',
      'window-is-ready-remover@nunofarruca@gmail.com',
      'workspace-indicator-2@killown.github.com',
      'pop-shell@system76.com',
      'forge@jmmaranan.com',
      'just-perfection-desktop@just-perfection',
      'burn-my-windows@schneegans.github.com',
      'tiling-assistant@leleat-on-github'
    ]
  '';
};

# KDE Customizations
qt = {
  enable = true;
  platformTheme = "gnome";
  style = "adwaita-dark";
};
environment.sessionVariables = {
  NIX_PROFILES = "${pkgs.lib.concatStringsSep " " (pkgs.lib.reverseList config.environment.profiles)}";
};

# Home Manager for user-specific configurations
home-manager.users.s336 = { pkgs, ... }: {
  home.stateVersion = "23.05";
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/s336/.local/share/backgrounds/wallpaper.mp4";
      picture-options = "zoom";
    };
  };
  home.packages = with pkgs; [
    mpv
    hyprpaper
    kdePackages.plasma-workspace
  ];
  # KDE Plasma Manager
  programs.plasma = {
    enable = true;
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursorTheme = "Breeze_Snow";
      iconTheme = "breeze-dark";
      wallpaper = "/home/s336/.local/share/backgrounds/wallpaper.mp4";
    };
    kwin = {
      effects = {
        translucency.enable = true;
        translucency.opacity = 0.8;
        blur.enable = true;
        wobblyWindows.enable = true;
        cube.enable = true;
      };
    };
  };
};

# Automatic Updates
system.autoUpgrade = {
  enable = true;
  allowReboot = false;
  channel = "https://nixos.org/channels/nixos-unstable";
  dates = "daily";
};

# Garbage Collection
nix = {
  settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
};

# Flatpak
services.flatpak = {
  enable = true;
  remotes = [
    { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
  ];
};

# Printing
services.printing.enable = true;

# GNOME Keyring and Seahorse
services.gnome.gnome-keyring.enable = true;
programs.seahorse.enable = true;

# ZSH
programs.zsh = {
  enable = true;
  ohMyZsh = {
    enable = true;
    plugins = [ "git" "docker" "sudo" "systemd" ];
    theme = "agnoster";
  };
  shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch --upgrade";
    clean = "sudo nix-collect-garbage -d";
  };
};

# Recovery with Timeshift
services.timeshift = {
  enable = true;
  settings = {
    schedule = {
      daily = true;
      weekly = true;
    };
    include = [
      "/home"
      "/etc/nixos"
    ];
    exclude = [
      "/home/*/.cache"
      "/home/*/.local/share/Trash"
    ];
  };
};


# Allow unfree packages
nixpkgs.config.allowUnfree = true;

# Systemd optimizations
systemd.enableStrictShellChecks = true;
systemd.services."userborn" = {
  enable = true;
  description = "Userborn user management";
  serviceConfig = {
    ExecStart = "${pkgs.userborn}/bin/userborn";
  };
  wantedBy = [ "multi-user.target" ];
};

# Live Wallpapers with mpvpaper
environment.etc."mpvpaper.conf".text = ''
  [default]
  input-ipc-server=/tmp/mpvpaper
  loop-file=inf
  hwdec=auto
  vo=gpu
  profile=high
'';

# System state version
system.stateVersion = "23.05";

# ------------------------------------------security-----------------------------------------------

# Firewall Configuration with nftables
networking.nftables = {
  enable = true;
  ruleset = ''
    table inet filter {
      chain input {
        type filter hook input priority 0; policy drop;
        iif "lo" accept
        ct state established,related accept
        tcp dport { 22, 80, 443 } accept # Allow SSH, HTTP, HTTPS
        udp dport { 53 } accept # Allow DNS
        ip protocol icmp accept # Allow ICMP
        ip6 protocol ipv6-icmp accept
        drop
      }
      chain output {
        type filter hook output priority 0; policy accept;
        oif "lo" accept
        ct state established,related accept
        tcp dport { 80, 443 } accept # Allow HTTP, HTTPS
        udp dport { 53 } accept # Allow DNS
        drop
      }
      chain forward {
        type filter hook forward priority 0; policy drop;
      }
    }
    table inet nat {
      chain prerouting {
        type nat hook prerouting priority 0;
      }
      chain postrouting {
        type nat hook postrouting priority 100;
      }
    }
  '';
};

# Block trackers using hosts file
networking.hosts = let
  blocklist = builtins.readFile (pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update SHA256 after fetching
  });
in
  lib.mkMerge [
    { "127.0.0.1" = [ "localhost" ]; }
    (lib.listToAttrs (map (line: let
      parts = lib.splitString " " line;
    in
      if (length parts) >= 2 && (elemAt parts 0) != "#" then
        { name = elemAt parts 1; value = [ (elemAt parts 0) ]; }
      else
        {}
    ) (lib.splitString "\n" blocklist)))
  ];

# Enable Burp Suite proxy settings
environment.etc."burp-proxy.conf".text = ''
  [proxy]
  listener_port=8080
  bind_address=127.0.0.1
'';

# Systemd service for updating blocklist
systemd.services.update-blocklist = {
  description = "Update tracker blocklist";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c 'curl -o /etc/hosts.blocklist https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts && systemctl restart networking'";
  };
  startAt = "daily";
};

# Additional repositories for pentesting tools
nixpkgs.overlays = [
  (self: super: {
    blackarch = import (pkgs.fetchFromGitHub {
      owner = "BlackArch";
      repo = "blackarch";
      rev = "master";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update SHA256
    }) { inherit (super) lib stdenv fetchurl; };
    parrot-tools = import (pkgs.fetchFromGitHub {
      owner = "ParrotSec";
      repo = "parrot-tools";
      rev = "master";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update SHA256
    }) { inherit (super) lib stdenv fetchurl; };
    kali-tools = import (pkgs.fetchFromGitHub {
      owner = "kali-linux";
      repo = "kali-tools";
      rev = "master";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update SHA256
    }) { inherit (super) lib stdenv fetchurl; };
    dracos-tools = super.runCommand "dracos-tools" {} ''
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/dracos
      echo "${pkgs.podman}/bin/podman run --rm -it dracoslinux/dracos:latest" >> $out/bin/dracos
      chmod +x $out/bin/dracos
    ''; # Dracos via container
  })
];

# Additional customization for Hyprland
services.xserver.windowManager.hyprland = {
  enable = true;
  extraConfig = ''
    monitor=,preferred,auto,1
    exec-once=waybar & swaybg -i /home/s336/.local/share/backgrounds/wallpaper.png
    input {
      kb_layout=us,ru
      kb_options=grp:alt_shift_toggle
    }
    general {
      gaps_in=5
      gaps_out=10
      border_size=2
      col.active_border=rgba(33ccffee) rgba(00ff99ee) 45deg
    }
    decoration {
      rounding=10
      blur=true
      blur_size=8
      blur_passes=3
      blur_new_optimizations=true
      drop_shadow=true
      shadow_range=10
    }
    animations {
      enabled=true
      bezier=overshot,0.13,0.99,0.29,1.1
      animation=windows,1,5,overshot,slide
      animation=border,1,10,default
      animation=fade,1,7,overshot
      animation=workspaces,1,6,overshot,slide
    }
  '';
};

# Additional KDE customization
environment.plasma6.excludePackages = with pkgs.kdePackages; [
  khelpcenter
  plasma-welcome
];
services.xserver.desktopManager.plasma6.extraConfig = ''
  [kwin]
  Effect-translucency=true
  Effect-blur=true
  Effect-wobblywindows=true
  Effect-cube=true
  Opacity=0.8
'';

# Enable penetration testing repositories
nixpkgs.config.packageOverrides = pkgs: {
  allowUnfree = true;
  allowBroken = true;
  pentest = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-pentest";
    rev = "master";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update SHA256
  }) {};
};

# -------------------------------------------------------------------------------------------------

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).