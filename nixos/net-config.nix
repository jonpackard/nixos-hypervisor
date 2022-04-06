{ config, pkgs, ... }:

{

  networking.hostName = "onyx"; # Define your hostname.

  # Enable DHCP on specific interfaces
  # IMPORTANT - Do not enable DHCP or assign IP addresses to more than one bridge interface on the same VLAN!
  networking.useDHCP = false; # Disable DHCP on any interface not specified
  networking.interfaces.vmnic0.useDHCP = true; # This interface is used by the host, and can also be used by VMs
  #networking.interfaces.vmnic1.useDHCP = true; 
  #networking.interfaces.vmnic2.useDHCP = true;
  #networking.interfaces.vmnic3.useDHCP = true;
  #networking.interfaces.vmnic4.useDHCP = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  #Bridging
  networking.iproute2.enable = true;
  networking.bridges =
  {
    vmnic0 = {
      interfaces = [ "eno1" ];
    };
    vmnic1 = {
      interfaces = [ "eno2" ];
    };
    vmnic2 = {
      interfaces = [ "eno3" ];
    };
    vmnic3 = {
      interfaces = [ "eno4" ];
    };
    vmnic4 = {
      interfaces = [ "eno5" ];
    };
  };

}
