# leadlab
Homelab application stack.

Repository of the docker components of my current homelab, cloned onto each Docker host in ProxmoxVE, with a crontab addition in each invoking start.sh at reboot.
The hostnames of each server are set in /etc/hosts & /etc/hostname, and static IPs are set in the file in /etc/netplan/. The goal of this repository is to provide a portable template for building out a homelab virtual environment, as well as to provide documentation on some of the nitty gritties of the setup process.
