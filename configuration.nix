{ config, pkgs, ... }:
let
  domain-name = "knedlsepp.at";
in {
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    gc = {
      automatic = true;
      dates = "14:09";
    };
    useSandbox = true;
    extraOptions = ''
      auto-optimise-store = true
    '';
  };
  nixpkgs.overlays = [
    (import (fetchGit https://github.com/knedlsepp/nixpkgs-overlays.git))
  ];
  time.timeZone = "Europe/Vienna";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
  };

  environment.systemPackages = with pkgs; [
    vim
    gitMinimal
    lsof
    htop
    duc
    fzf
  ];

  programs.vim.defaultEditor = true;

  programs.bash = {
    enableCompletion = true;
    shellAliases = {
      l = "ls -rltah";
    };
    loginShellInit = ''
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.bash"
      fi
    '';
  };

  security.hideProcessInformation = true;

  services.openssh.forwardX11 = true;

  services.journald.extraConfig = ''
    SystemMaxUse=300M
  '';

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."${domain-name}" = {
      serverAliases = [ "www.${domain-name}" ];
      enableACME = true;
      forceSSL = true;
      root = builtins.fetchGit {
        url = "https://github.com/knedlsepp/knedlsepp.at-landing-page.git";
        rev = "6bb09bcca1bd39344d4e568c70b2ad31fd29f1bf";
      };
    };
    virtualHosts."xn--qeiaa.${domain-name}" = { # ❤❤❤.${domain-name} - Punycoded
      serverAliases = [
        "xn--c6haa.${domain-name}"
        "xn--yr8haa.${domain-name}"
        "xn--0r8haa.${domain-name}"
        "xn--1r8haa.${domain-name}"
        "xn--2r8haa.${domain-name}"
        "xn--3r8haa.${domain-name}"
        "xn--4r8haa.${domain-name}"
        "xn--5r8haa.${domain-name}"
        "xn--6r8haa.${domain-name}"
        "xn--7r8haa.${domain-name}"
        "xn--8r8haa.${domain-name}"
        "xn--9r8haa.${domain-name}"
        "xn--g6haa.${domain-name}"
        "xn--r28haa.${domain-name}"
      ];
      enableACME = true;
      forceSSL = true;
      root = let
        site = pkgs.writeTextFile {
          name = "index.html";
          destination = "/share/www/index.html";
          text = ''
            <!DOCTYPE html>
            <html lang="de">
            <head>
              <meta charset="utf-8">
              <title>❤️❤️❤️.${domain-name}</title>
              <style>
              h1 {
                  display: block;
                  font-size: 8em;
                  font-weight: bold;
              }
              </style>
            </head>
            <body>
            <body><br><br><h1><center><div>I ❤️ 🐰</div></center></h1></body>
            </html>
          '';
        }; in
      "${site}/share/www/";
    };
    virtualHosts."party.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      root = let
        site = pkgs.writeTextFile {
          name = "index.html";
          destination = "/share/www/index.html";
          text = ''
            <!DOCTYPE html>
            <html><head><meta charset=utf-8>
            <title>KnödelZ Activity Generator</title>
            <meta name="viewport" content="width=device-width">
            <style type="text/css">
                html, body {
                    height: 100%;
                    margin: 0px;
                    text-align: center;
                    vertical-align: middle;
                    font-size: 100pt;
                    background-color:#0388fc;
                }
                .container {
                    height: 100%;
                    text-align: center;
                    vertical-align: middle;
                    font-size: 100pt;
                    color: #003fa3;

                }
            </style>
            <script>
            window.addEventListener('load', function() {
            // sleep time expects milliseconds
            function sleep (time) {
              return new Promise((resolve) => setTimeout(resolve, time));
            }
                var waitingMessage = "Wir berechnen deinen Partyaszendenten";
                var b = document.getElementById('b');
                var o = document.getElementById('o'),
                report = function(e) {
                    var textArray = [
                        'am 90s Dancefloor abshaken.',
                        'mit einer Personen gleichen Sternzeichen schnapseln.',
                        'jemanden zum Beer pong herausfordern.',
                        'eine Runde Looping Louie anzetteln. ',
                    ];
                    var randomNumber = Math.floor(Math.random()*textArray.length);

                    var s = textArray[randomNumber];

                    delayedInnerHTML(waitingMessage);
                    sleep(2000).then(() => {
                    setTimeout(function() { delayedInnerHTML(s) }, 0);
                      sleep(8000).then(() => {
                         delayedInnerHTML("???");
                      });
                    });
                }

                /* Hack to work around new iOS8 behavior where innerHTML counts as a content change - previously, it was safe to use, see http://www.quirksmode.org/blog/archives/2014/02/the_ios_event_c.html */
                delayedInnerHTML = function(s) {
                    o.innerHTML = s;
                }
                
                /* and here we have it...the naive approach to handling touch */
                var clickEvent = ('ontouchstart' in window ? 'touchend' : 'click');
                b.addEventListener(clickEvent, report, false);

            }, false);
            </script>
            </head><body id="b" style="">
            <output class="container" id="o" >Drück mich</output>
            </body></html>
          '';
        }; in
      "${site}/share/www/";
    };
    virtualHosts."gogs.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3000";
    };
    virtualHosts."hydra.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3001";
    };
    virtualHosts."uwsgi-example.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = ''
          uwsgi_pass unix://${config.services.uwsgi.instance.vassals.flask-helloworld.socket};
          include ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
    virtualHosts."shell.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:4200";
    };
    virtualHosts."mattermost.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8065";
        proxyWebsockets = true;
      };
    };
  };

  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    instance = {
      type = "emperor";
      vassals = {
        flask-helloworld = {
          type = "normal";
          pythonPackages = self: with self; [ flask-helloworld ];
          socket = "${config.services.uwsgi.runDir}/flask-helloworld.sock";
          wsgi-file = "${pkgs.pythonPackages.flask-helloworld}/${pkgs.python.sitePackages}/helloworld/share/flask-helloworld.wsgi";
        };
      };
    };
    plugins = [ "python2" ];
  };

  services.shellinabox = {
    enable = true;
    extraOptions = [ "--localhost-only" ]; # Nginx makes sure it's https
  };

  services.mattermost = {
    enable = true;
    siteUrl = "https://mattermost.${domain-name}";
    extraConfig = {
      EmailSettings = {
        SendEmailNotifications = true; # TODO: Set up SMTP server
        EnablePreviewModeBanner = true;
      };
    };
  };

  services.gogs = {
    appName = "Knedlgit";
    enable = true;
    rootUrl = "https://gogs.${domain-name}/";
    extraConfig = ''
      [service]
      DISABLE_REGISTRATION = true
      [server]
      DISABLE_SSH = true
      LANDING_PAGE = explore
    '';
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.${domain-name}";
    notificationSender = "hydra@${domain-name}";
    port = 3001;
    minimumDiskFree = 1; #GiB
    useSubstitutes = true;
  };
  nix.buildMachines = [
    {
      hostName = "localhost";
      systems = [ "i686-linux" "x86_64-linux" ];
      maxJobs = 6;
      supportedFeatures = [ "kvm" "nixos-test" ];
    }
  ];

  virtualisation.docker.enable = false;

  system.autoUpgrade = {
    enable = false;
    channel = "https://nixos.org/channels/nixos-18.03";
  };
  networking.hostName = "knedlsepp-aws";
  networking.firewall.allowedTCPPorts = [ 80 443
   5900 5901 # VNC
  ];

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 2048;
    }
  ];

  users.extraUsers.sepp = {
    isNormalUser = true;
    description = "Josef Knedlmüller";
    initialPassword = "foo";
    extraGroups = [ "docker" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}

