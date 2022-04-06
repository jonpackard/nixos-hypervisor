#!/bin/bash

# This script could be called by putting it on a webserver (preferrably on the local LAN) and
# running the following command from the nixos user shell in the nixos minimal installer.
# !!needs testing!!
# curl -s "http://10.0.0.80/nixos-installation.sh" | bash

# Define variables
export userSpaceDependencies="nixos.screenfetch nixos.htop" # Packages to be installed in the temp environment
export repoName="nixos-hypervisor-main" # This should match the repo-branch name format.
export repoArchivePath="https://codeload.github.com/jonpackard/nixos-hypervisor/zip/refs/heads/main" # The path where the repo archive is hosted.
export targetDisk="/dev/vda"

# User confirmation before making changes.
echo -e "\n<<< Disk Configuration >>>\n"
lsblk # Show disks
echo -e "\n<<< Running this script will completely overwrite the contents of "$targetDisk"! >>>\n"
read -p " Are you sure? Type YES (all caps) to continue or NO to abort. " -r
echo    # (optional) move to a new line
if [ "$REPLY" != "YES" ]
then
    echo -e "\n<<< Script aborted! >>>\n"
    exit 1
fi

# Install user-space dependencies.
echo -e "\n<<< Installing dependencies. >>>\n"
nix-env -iAP $userSpaceDependencies && \
 echo -e "\n<<< Dependencies installed successfully. >>>\n" || { echo -e "\n<<< Dependencies failed to install! >>>\n" && exit 1; }

# Download and extract repo archive.
echo -e "\n<<< Downloading and extracing repo archive. >>>\n"
curl -o ./"$repoName".zip "$repoArchivePath" && unzip -o ./"$repoName".zip && \
 echo -e "\n<<< Repo archive download and extracted. >>>\n" || { echo -e "\n<<< Unable to download files! >>>\n" && exit 1; }

# Partition disk
echo -e "\n<<< Partitioning disk "$targetDisk". >>>\n"
sudo parted --script "$targetDisk" -- mklabel gpt && \
sudo parted --script "$targetDisk" -- mkpart primary 512MiB -8GiB && \
sudo parted --script "$targetDisk" -- mkpart primary linux-swap -8GiB 100% && \
sudo parted --script "$targetDisk" -- mkpart ESP fat32 1MiB 512MiB && \
sudo parted --script "$targetDisk" -- set 3 esp on && \
echo -e "\n<<< Partitioning successful. >>>\n" || { echo -e "\n<<< Partitioning failed! >>>\n" && exit 1; }

# Update partition table
echo -e "\n<<< Re-reading partition table. >>>\n"
sudo partprobe

# Format partitions
echo -e "\n<<< Formatting partitions. >>>\n"
sudo mkfs.ext4 -F -L nixos "$targetDisk"1 && \
sudo mkswap -L swap "$targetDisk"2 && \

sudo mkfs.fat -F 32 -n boot "$targetDisk"3 && \
echo -e "\n<<< Formatting successful. >>>\n" || { echo -e "\n<<< Formatting failed! >>>\n" && exit 1; }

# Update partition table
echo -e "\n<<< Re-reading partition table. >>>\n"
sudo partprobe

# Mount partitions
echo -e "\n<<< Mounting partitions. >>>\n"
sudo mount /dev/disk/by-label/nixos /mnt && \
sudo mkdir -p /mnt/boot && \
sudo mount /dev/disk/by-label/boot /mnt/boot && \
sudo swapon "$targetDisk"2 && \
echo -e "\n<<< Mounting successful. >>>\n" || { echo -e "\n<<< Mounting failed! >>>\n" && exit 1; }

# Generate NixOS config files
echo -e "\n<<< Generating NixOS config files. >>>\n"
sudo nixos-generate-config --force --root /mnt && \
echo -e "\n<<< Config files generated successfully. >>>\n" || { echo -e "\n<<< Config files generation failed! >>>\n" && exit 1; }

# Import configs from repo archive
echo -e "\n<<< Importing config files from repo archive. >>>\n"
sudo cp -fv ./"$repoName"/nixos/*.nix /mnt/etc/nixos/ && \
sudo chmod 644 /mnt/etc/nixos/*.nix && \




