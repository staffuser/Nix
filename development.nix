{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Additional Customization Tools
    compiz
    lxappearance
    nitrogen
    kdePackages.plasma-desktop
    hyprland
    waybar # For Wayland bar customization
    rofi-wayland # For Wayland launcher
    swaylock-effects # For lock screen effects
    swaybg # For Wayland background

    # Pentesting Tools
    burpsuite
    wireshark
    metasploit
    nmap
    aircrack-ng
    sqlmap
    john
    hashcat
    hydra
    nikto
    dirb
    wifite2
    kismet
    ettercap
    bettercap
    responder
    sslscan
    whatweb
    theharvester
    fierce
    recon-ng
    maltego
    volatility3
    autopsy
    sleuthkit
    foremost
    tor
    torsocks
    proxychains-ng
    anonsurf
    macchanger
    openvas
    ghidra
    radare2
    gdb-multiarch
    binwalk
    exiftool
    steghide
    zsteg

    # Security and Monitoring
    fail2ban
    clamav
    apparmor-profiles
    firejail
    lynis
    chkrootkit
    rkhunter

    # GUI and Themes
    arc-theme
    papirus-icon-theme
    materia-theme
    adwaita-qt
    qt5.qtwayland
    qt6.qtwayland

    # Development Tools
    vscode
    jetbrains.idea-ultimate
    python3Full
    nodejs
    jdk
    rustc
    cargo
    go
    gcc
    docker
    docker-compose
    postman
    dbeaver
    insomnia
    gnumake
    cmake
    gdb
    clang
    llvm
    maven
    gradle
    kubernetes
    helm
    terraform
    ansible
    vagrant

    # System Monitoring and Management
    nvtop
    lm_sensors
    psensor
    gnome.gnome-system-monitor
    baobab
    gparted
    timeshift
    pavucontrol
    gnome.gnome-disk-utility
    htop
    btop
    glances

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    powerline-fonts
    (nerdfonts.override { fonts = [ "FiraCode" "Hack" "JetBrainsMono" "Meslo" ]; })

    # GNOME Extensions
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.arc-menu
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.gsconnect
    gnomeExtensions.hidetopbar
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
    gnomeExtensions.window-is-ready-remover
    gnomeExtensions.workspace-indicator-2
    gnomeExtensions.pop-shell
    gnomeExtensions.forge
    gnomeExtensions.just-perfection
    gnomeExtensions.burn-my-windows
    gnomeExtensions.tiling-assistant

    # KDE Packages for Hybrid System
    kdePackages.kate
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.ark
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.spectacle
    kdePackages.partitionmanager
    kdePackages.kcolorchooser
    kdePackages.kolourpaint
    kdePackages.ksystemlog
    kdePackages.isoimagewriter
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.haruna
  ];

  environment.variables = {
    EDITOR = "nano";
    VISUAL = "nano";
    BROWSER = "firefox";
  };

  # Enable AppArmor for application sandboxing
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles ];
  };

  # Enable ClamAV for antivirus
  services.clamav = {
    enable = true;
    daemon.enable = true;
    updater.enable = true;
    updater.frequency = 12; # Update every 12 hours
  };

  # Enable Fail2Ban for brute-force protection
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "24h";
    jails = {
      sshd = ''
        enabled = true
        port = ssh
        filter = sshd
        maxretry = 3
      '';
    };
  };

  # Enable Anonsurf for anonymity
  services.anonsurf = {
    enable = true;
    autoStart = true;
  };

  # Enable Tor for anonymity
  services.tor = {
    enable = true;
    client.enable = true;
    settings = {
      UseBridges = false;
      ExitPolicy = [ "reject *:*" ];
    };
  };

  # Enable Wireshark with GUI
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Docker
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableNvidia = true;
    };
    libvirtd.enable = true; # For virtual machines
  };

  # Weekly Cleanup Service
  systemd.services.cleanup = {
    description = "Weekly system cleanup";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'nix-collect-garbage -d && rm -rf /tmp/*'";
    };
    startAt = "weekly";
  };

  # Enable Wine for running Windows applications
  programs.wine.enable = true;
}