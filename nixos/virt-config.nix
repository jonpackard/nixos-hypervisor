{ config, pkgs, ... }:

{

  #Enable libvirt
  virtualisation.libvirtd.enable = true;

  #Define bridges libvirt can access
  virtualisation.libvirtd.allowedBridges = [
     "vmnic0"
     "vmnic1"
     "vmnic2"
     "vmnic3"
     "vmnic4"
  ];

  #Enable virt-manager
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];

  #Group memberships
  users.users.onyx.extraGroups = [ "libvirtd" "qemu-libvirtd" "kvm" ];

}
