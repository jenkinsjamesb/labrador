# Labrador

<img src="https://jenkinsjamesb.github.io/src/images/zeke.jpg" width="33%"><img src="https://jenkinsjamesb.github.io/src/images/heep.jpg" width="33%"><img src="https://jenkinsjamesb.github.io/src/images/luke.jpg" width="33%">

Repository of the docker components and documentation of my current homelab setup, cloned onto each Docker host in ProxmoxVE, with a crontab addition in each invoking start.sh at reboot.
The hostnames of each server are set in /etc/hosts & /etc/hostname, and static IPs are set in the file in /etc/netplan/. The goal of this repository is to provide a portable template for building out a homelab virtual environment, as well as to provide documentation on some of the nitty gritties of the setup process.

<h3>what (and how) are we deploying?</h3>
Labrador is the nickname of a Proxmox cluster of 2 Dell PowerEdge R620s, providing a pool of 64 threads, 256 GiB of RAM, around 6TiB of usuable storage in RAID 5, and 2 Nvidia Quadro K1200s for good measure. This is beyond overkill, and could likely be done with one or two SBCs, but I like to keep it futureproof.

The subdirectories provided each correspond to a cloned docker host, a VM running Ubuntu Server LTS configured with hostnames matching their directories and their static IPv4 address' least significant bits match their VM IDs in Proxmox (e.g. the media directory docker config is running on VM 102 "labrador-media" @ xxx.xxx.xxx.102). Other self-hosting methods are used, however, such as a TrueNAS Scale VM for managing large blocks of storage, an OPNSense VM providing networking services, and a Windows Server VM hosting various game servers.

The subdirectories each contain a docker-compose.yml file which configures a specific set of services for that host. The docker containers can be easily re-pulled and started with the correct compose file and environment with ./start.sh &lt;subdirectory&gt;. A single global .env file is provided with the lab suite as the philosophy of the lab is such that the number of environment values should be minimal and the names should be descriptive enough to be easily distinguishable out of context.

The Docker hosts are configured with networking information in /etc/hosts, /etc/hostname, and /etc/netplan/00-installer-config.yaml, /etc/fstab entries to mount the necessary remote storage, and a crontab entry that automatically invokes start.sh with the correct subdirectory @reboot, as well as a crontab entry to periodically remount storage, as it is likely for the Docker hosts to finish rebooting before TrueNAS, resulting in the network drives being unmounted and thus inaccessible.

<h5>netplan config:</h5>
<pre><code>network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: no
      addresses:
        - &lt;ipv4-host&gt;/24
      routes:
        - to: default
          via: &lt;ipv4-router&gt;
      nameservers:
        addresses: [&lt;DNS-server-list&gt;]</code></pre>
          
<h5>fstab example entry:</h5>
<pre><code>//&lt;ipv4-storageserver&gt;/jellyfin-media /media/jellyfin-media cifs username=&lt;user&gt;,password=&lt;password&gt;,iocharset=utf8,uid=&lt;uid&gt; 0 0</code></pre>
  
<h5>example crontab:</h5>
<pre><code>@reboot ~/labrador/start.sh &lt;subdir&gt;</code></pre>

<h3>list of services</h3>

<h5>storage (truenas @ 100 - TrueNAS Scale)</h5>
This TrueNAS VM provides easier management of bulk storage for various services, allowing the growing and shrinking of allocated storage space (e.g. a media drive) without having to expand filesystem partitions and manage drives through Proxmox. While slower, using Samba shares through TrueNAS makes accessing and maintaining important data much easier.

<h5>management (labrador-manager @ 101 - Ubuntu Server/Docker)</h5>
The manager for Labrador provides mission-critical services for tending the homelab. Most notably, Tailscale allows for remote access from any device. This still relies on Tailscale servers and services however, so a fully self-hosted solution may become necessary in future. Additionally, Portainer is deployed to easily access and control containers on the various Docker hosts across the lab, and Grafana and GraphiteDB are used for metrics collection and monitoring. 

<h5>media (labrador-media @ 102 - Ubuntu Server/Docker)</h5>
The media Docker host runs both Jellyfin and Nextcloud AIO alongside Portainer Agent. Jellyfin provides a rich feature set and is FOSS in contrast to the typical Plex home media server, which is why it's used here. Nextcloud AIO is the current cloud storage solution in use, although it has its fair share of setup headaches and issues and may be swapped for OwnCloud or SeaFile.

<h5>hosting (labrador-hosting @ 103 - Windows Server)</h5>
This server provides general-purpose hosting for services that don't play nicely with Docker. This tends to be used for game servers (e.g. Minecraft, DayZ, Single-Player Tarkov).

<h5>failover (labrador-failover @ 104 - Ubuntu Server)</h5>
Failovers are an important part of high availability computing, and perhaps the most critical component of my homelab is the Tailscale subnet router that provides remote access to the labrador VLAN. As such, a failover instance of Tailscale is hosted on this server to provide a fallback if the primary container fails (or, more likely, I break it while not at home ;)).

<h5>testenv (labrador-testenv @ 123 - Ubuntu Desktop)</h5>
The testenv VM is simply a remote development and testing environment used for school assignments and any other software projects, allowing me to develop from any device (even an iPad) and transition seamlessly between devices without needing to go through a git repository or other file sharing service.

<h5>opnsense (opnsense @ 192 - OPNsense)</h5>
OPNsense is my choice of routing software, as it supports VLANs and allows me to use my cheap TPLink router as a simple access point, while leveraging OPNsense's rich featureset to do all of the important stuff. While it has a learning curve, it's certainly worth the effort for the homelab environment.

<h3>to do (in no particular order):</h3>
<ul>
  <li>Get rid of the hosting subdirectory, and document some better ways to host miscellaneous services.</li>
  <li>Drop NextCloud and replace with something simpler and easier to deploy.</li>
  <li>Document VLAN setup and management for an isolated homelab network.</li>
  <li>Find a cheap 4u rackmount case and add more compute power to the cluster.</li>
</ul>

