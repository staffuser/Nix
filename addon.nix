# Дополнительные кастомизаторы и эффекты
environment.systemPackages = lib.mkAfter [
  pkgs.conky # System monitor widget
  pkgs.picom # Compositor for X11
  pkgs.lxappearance # GTK theme switcher
  pkgs.qt5ct # Qt theme configuration
  pkgs.plasma5Packages.latte-dock # Advanced dock for KDE
  pkgs.kdeconnect # KDE Connect for device integration
  pkgs.plasma-browser-integration # Browser integration for KDE
  pkgs.compiz # Window manager effects (X11 only)
  pkgs.iconpack-obsidian # Additional icon theme
  pkgs.arc-theme # Additional GTK theme
];

# Fonts for better customization
fonts = {
  fonts = lib.mkAfter [
    pkgs.cantarell-fonts
    pkgs.roboto
    pkgs.material-design-icons
    pkgs.google-fonts
  ];
  fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Serif" "Roboto" ];
      sansSerif = [ "Noto Sans" "Roboto" ];
      monospace = [ "Fira Code" "JetBrains Mono" ];
    };
  };
};

# Firewall configuration with nftables
networking = {
  nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority 0; policy drop;
          ct state established,related accept
          iifname "lo" accept
          tcp dport { 22, 80, 443 } accept # Allow SSH, HTTP, HTTPS
          udp dport { 53, 123 } accept # Allow DNS, NTP
          ip saddr { 127.0.0.1 } accept
          counter drop
        }
        chain forward {
          type filter hook forward priority 0; policy drop;
          ct state established,related accept
          counter drop
        }
        chain output {
          type filter hook output priority 0; policy accept;
        }
      }
      table inet blocklist {
        set trackers {
          type ipv4_addr
          flags interval
          elements = { 
            104.28.0.0/16, # Example tracker IPs
            172.64.0.0/13,
            173.245.48.0/20
          }
        }
        chain input {
          type filter hook input priority -10;
          ip saddr @trackers drop
        }
        chain output {
          type filter hook output priority -10;
          ip daddr @trackers drop
        }
      }
    '';
  };
  firewall = {
    enable = false; # Disable iptables to use nftables
    trustedInterfaces = [ "lo" ];
  };
};

# DNS-based tracker blocking
services.unbound = {
  enable = true;
  settings = {
    server = {
      interface = [ "0.0.0.0" "::0" ];
      access-control = [ "127.0.0.0/8 allow" "::1 allow" ];
      harden-dnssec-stripped = true;
      harden-referral-path = true;
      do-not-query-localhost = false;
    };
    forward-zone = {
      name = ".";
      forward-addr = [ "8.8.8.8" "8.8.4.4" ]; # Google DNS as fallback
    };
    local-zone = [
      ''"doubleclick.net" redirect''
      ''"googleadservices.com" redirect''
      ''"adservice.google.com" redirect''
    ];
    local-data = [
      ''"doubleclick.net A 0.0.0.0"''
      ''"googleadservices.com A 0.0.0.0"''
      ''"adservice.google.com A 0.0.0.0"''
    ];
  };
};

# Pi-hole for network-wide ad and tracker blocking (optional)
virtualisation.oci-containers = {
  backend = "docker";
  containers = {
    pihole = {
      image = "pihole/pihole:latest";
      ports = [ "53:53/tcp" "53:53/udp" "80:80/tcp" ];
      environment = {
        TZ = "Europe/Moscow";
        WEBPASSWORD = "your_secure_password";
      };
      volumes = [
        "/etc/pihole:/etc/pihole"
        "/etc/dnsmasq.d:/etc/dnsmasq.d"
      ];
    };
  };
};

# Security tools
environment.systemPackages = lib.mkAfter [
  pkgs.wireshark
  pkgs.burpsuite
  pkgs.mitmproxy
  pkgs.zaproxy # OWASP ZAP
  pkgs.nmap
  pkgs.metasploit-framework
  pkgs.sqlmap
  pkgs.hydra
  pkgs. john # Password cracker
  pkgs.aircrack-ng
  pkgs.kismet
  pkgs.tor
  pkgs.i2p
  pkgs.clamav
];

# Custom overlay for Kali/BlackArch/Parrot/Dracon packages
nixpkgs.overlays = [
  (self: super: {
    blackarch = import (fetchTarball "https://github.com/BlackArch/blackarch-nix/archive/master.tar.gz") { pkgs = super; };
    kali-tools = super.callPackage (fetchTarball "https://github.com/JJJollyjim/arewehackersyet/archive/master.tar.gz") {};
  })
];

# Fail2ban for brute-force protection
services.fail2ban = {
  enable = true;
  maxretry = 5;
  bantime = "3600";
  jails = {
    sshd = ''
      enabled = true
      port = ssh
      filter = sshd
      action = nftables-multiport[name=ssh, port="ssh", protocol=tcp]
      maxretry = 3
    '';
  };
};

# AppArmor for application confinement
security.apparmor = {
  enable = true;
  profiles = [
    "${pkgs.apparmor-profiles}/usr.bin.firefox"
    "${pkgs.apparmor-profiles}/usr.bin.wireshark"
  ];
};

# Tor service
services.tor = {
  enable = true;
  client.enable = true;
  settings = {
    UseBridges = false;
    ExitPolicy = [ "reject *:*" ];
  };
};

# I2P service
services.i2p = {
  enable = true;
};

# ClamAV antivirus
services.clamav = {
  daemon.enable = true;
  updater.enable = true;
  updater.frequency = 12;
};

# Conky configuration
environment.etc."conky/conky.conf".text = ''
  conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans:size=12',
    gap_x = 5,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
  }

  conky.text = [[
  $nodename - $sysname $kernel on $machine
  $hr
  ${color grey}Uptime:$color $uptime
  ${color grey}Frequency (in MHz):$color $freq
  ${color grey}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
  ${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
  ${color grey}CPU Usage:$color $cpu% ${cpubar 4}
  ${color grey}Processes:$color $processes  ${color grey}Running:$color $running_processes
  $hr
  ${color grey}File systems:
  / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
  ${color grey}Networking:
  Up:$color ${upspeed eth0} ${color grey} - Down:$color ${downspeed eth0}
  $hr
  ${color grey}Name              PID    CPU%   MEM%
  ${color lightgrey} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
  ${color lightgrey} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
  ${color lightgrey} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
  ${color lightgrey} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
  ]]
'';