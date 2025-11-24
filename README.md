# Labrador

<img src="https://jenkinsjamesb.github.io/src/images/zeke.jpg" width="33%"><img src="https://jenkinsjamesb.github.io/src/images/heep.jpg" width="33%"><img src="https://jenkinsjamesb.github.io/src/images/luke.jpg" width="33%">

---

### Overview

Repository of the Docker components and documentation of my current homelab setup, cloned onto each applicable virtual host, with a focus on few simple, practical services.

The hostnames of each server are set with hostnamectl, and static IPs are set in the file with nmtui. The goal of this repository is to provide a portable template for building out a homelab virtual environment, as well as to provide documentation on some of the nitty gritties of the setup process.

### What (and how) are we deploying?

Labrador is the nickname of a Proxmox cluster with a Dell PowerEdge R620 and R540, providing a pool of 64 threads, ~600 GiB of RAM, around 7TiB of usuable storage in RAID 5, and 2 Nvidia Quadro K1200s for good measure. This is beyond overkill, and could likely be done with one or two SBCs, but I like to keep it futureproof.

The subdirectories provided each correspond to a cloned Docker host, a VM running Rocky Linux 10 configured with hostnames matching their directories. Other self-hosting methods are used, however, such as a TrueNAS Scale VM for managing large blocks of storage, an OPNSense VM providing networking services, etc. These will be covered alongside the container hosts.

The subdirectories each contain a docker-compose.yml file which configures a specific set of services for that host. The Docker containers can be easily pulled and started with the correct compose file and environment using `docker compose up`. Each subdirectory contains a .env.sample file that provides the necessary options to configure your own host where applicable. This isn't the only configuration however, and you will need to occasionally create a config file or setup a directory for a specific service if you choose.

### Network storage

As systems like TrueNAS make managing lots of storage safely easy, they are an attractive option for storing important bulk information like media and Git repositories. However, to use this in conjunction with other Proxmox VMs, an entry must be made in /etc/fstab to mount any network shares you need to use.

##### fstab example entry:

```
//<ipv4-storageserver>/jellyfin-media /media/jellyfin-media cifs username=<user>,password=<password>,iocharset=utf8,uid=<uid> 0 0
```
  
### Hosts & services

##### portunus - OPNsense

OPNsense is my choice of routing software, as it supports VLANs and allowed me to use my cheap TPLink router as a simple access point, while leveraging OPNsense's rich featureset to do all of the important stuff. While it has a learning curve, it's certainly worth the effort for the homelab environment. Now that I have a Unifi stack, this is less necessary, but OPNSense is still great.

##### consus - TrueNAS Scale

This TrueNAS VM provides easier management of bulk storage for various services, allowing the growing and shrinking of allocated storage space (e.g. a media drive) without having to expand filesystem partitions and manage drives through Proxmox. While slower, using Samba shares through TrueNAS makes accessing and maintaining important data much easier.

##### vesta - Home Assistant OS

Home Assistant is pretty great and pretty hands-off. If you have interest in home automation, I would recommend spinning up a VM from the good folks over at [helper-scripts](https://github.com/community-scripts/ProxmoxVE).

##### janus - Rocky Linux

The manager for Labrador provides mission-critical services for tending the homelab. Most notably, Tailscale allows for remote access from any device. This still relies on Tailscale servers and services however, so a fully self-hosted solution may become necessary in future. Additionally, Portainer is deployed to easily access and control containers on the various Docker hosts across the lab, and Grafana and GraphiteDB are used for metrics collection and monitoring. 

##### bacchus - Rocky Linux

The media Docker host runs both Jellyfin and Copyparty. I prefer Jellyfin to the typical Plex home media server, which is why it's used here. Copyparty is a simple and effective means of hosting basic file storage for all of your devices, so I recommend setting it up (think Google Drive but good).

##### somnus - Rocky Linux

This VM is for general-purpose internet-shared hosting. This tends to be used for game servers (e.g. Minecraft, DayZ, Single-Player Tarkov).

##### vulcan - Rocky Linux

The vulcan VM provides a source control server using its namesake forgeware, [Vulcan](https://github.com/jenkinsjamesb/vulcan).

##### averruncus - Rocky Linux

Failovers are an important part of high availability computing, and perhaps the most critical component of my homelab is the Tailscale subnet router that provides remote access to the Labrador VLAN. As such, a failover instance of Tailscale is hosted on this server to provide a fallback if the primary container fails (or, more likely, I break it while not at home ;)).

##### fontus - Ubuntu Desktop

This VM is simply a remote development and testing environment used for school assignments and any other software projects, allowing me to develop from any device (even an iPad) and transition seamlessly between devices without needing to go through a git repository or other file sharing service.

### Exposing services

One thing you will likely want to do with your homelab is access it from outside its network. If you have the ability and desire, you can punch a hole in your firewall and go crazy. I do not recommend this. Instead, I use a combination of two services:

##### Cloudflare tunnel

For "truly" externally accessible services I use cloudflared running on janus to create a link to Cloudflare, which manages my domain, [jenkinsjamesb.xyz](jenkinsjamesb.xyz). From there, a couple things are configured:

1. A CNAME record is created pointing the desired host to the tunnel.
2. In the Zero Trust tunnel settings, a published application route is created that forwards tunnel traffic (*.jenkinsjamesb.xyz) to https://<janus-ip>, which is served by nginx.
3. In domain settings, TLS is configured to strict, and origin and client certificates are generated. Nginx uses the origin certificates to secure cloudflare-lab traffic, and the client cert is installed on my devices to grant access to private services. 
4. In the client certificate settings, mTLS is enabled for *.jenkins.jamesb.xyz 
5. In security rules, a rule is created to enforce mTLS on non www domains. This looks like:

```
IF
        Client Certificate Verified IS False
        AND
        Hostname DOES NOT CONTAIN www

THEN

        BLOCK
```

6. In nginx.conf, a server block points to the desired service based on hostname.

This allows your individual lab services to be accessible remotely and securely with little more hassle than the client cert installation. Hooray!

##### Tailscale

But say you want to access everything in the lab network. That's great for getting work done on the go, but getting *everything* out through Clouflare would be a real mess. Instead, I reccommend setting up a Tailscale subnet router. This is so easy I don't even feel the need to explain it here, and gives you a VPN that you can use to access your home network from anywhere.

##### Network

When all is said and done, the network for lab traffic looks a little something like this:

![](https://jenkinsjamesb.github.io/src/images/labnet.png)
