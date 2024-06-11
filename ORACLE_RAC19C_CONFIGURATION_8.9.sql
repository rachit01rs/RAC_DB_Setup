-- 2 Node rac on VM( Oracle Linux 8.9) -->> On both Node
[root@oracle19c1/oracle19c2 ~]# df -Th
/*

Filesystem          Type      Size  Used Avail Use% Mounted on
devtmpfs            devtmpfs  1.8G     0  1.8G   0% /dev
tmpfs               tmpfs     1.8G     0  1.8G   0% /dev/shm
tmpfs               tmpfs     1.8G  9.3M  1.8G   1% /run
tmpfs               tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
/dev/mapper/ol-root xfs        22G  449M   22G   2% /
/dev/mapper/ol-usr  xfs        16G  7.4G  8.7G  46% /usr
/dev/mapper/ol-tmp  xfs       8.0G   90M  8.0G   2% /tmp
/dev/mapper/ol-var  xfs       8.0G  1.1G  7.0G  14% /var
/dev/mapper/ol-u01  xfs        27G  225M   27G   1% /u01
/dev/mapper/ol-home xfs       8.0G   90M  8.0G   2% /home
/dev/nvme0n1p1      xfs      1014M  513M  502M  51% /boot
tmpfs               tmpfs     363M   12K  363M   1% /run/user/42
tmpfs               tmpfs     363M  4.0K  363M   1% /run/user/0

*/

-- Step 1 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# vi /etc/hosts
/*
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               openfiler.mydomain openfiler localhost.localdomain localhost openfiler
::1             localhost6.localdomain6 localhost6

# Public
192.168.120.61   oracle19c1.racdomain.com        oracle19c1
192.168.120.62   oracle19c2.racdomain.com        oracle19c2

# Private
10.0.1.61        oracle19c1-priv.racdomain.com   oracle19c1-priv
10.0.1.62        oracle19c2-priv.racdomain.com   oracle19c2-priv

# Virtual
192.168.120.63   oracle19c1-vip.racdomain.com    oracle19c1-vip
192.168.120.64   oracle19c2-vip.racdomain.com    oracle19c2-vip

# Openfiler (SAN/NAS Storage)
192.168.120.60  sanstorage.racdomain.com   sanstorage

# SCAN
192.168.120.65   oracle19c-scan.racdomain.com    oracle19c-scan
192.168.120.66   oracle19c-scan.racdomain.com    oracle19c-scan
192.168.120.67   oracle19c-scan.racdomain.com    oracle19c-scan
*/


-- Step 2 -->> On both Node
-- Disable secure linux by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set as follows.
[root@oracle19c1/oracle19c2 ~]# vi /etc/selinux/config
/*
[root@oracle19c1 ~]# cat /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
#SELINUX=enforcing
SELINUX=disabled
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted

*/

-- Step 3 -->> On Node 1
[root@oracle19c1 ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=oracle19c1.racdomain.com
*/

-- Step 4 -->> On Node 2
[root@oracle19c2 ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=oracle19c2.racdomain.com
*/
-- Step 5 -->> On Node 1
[root@oracle19c2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens160 
/*
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
NAME=ens160
UUID=c48266be-2127-4b1e-9301-f170bf168650
DEVICE=ens160
ONBOOT=yes
IPADDR=192.168.120.61
PREFIX=24
GATEWAY=192.168.120.254
DNS1=192.168.120.100

*/

-- Step 6 -->> On Node 1
[root@oracle19c2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens224
/*
DEVICE=ens224
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.61
NETMASK=255.255.255.0
GATEWAY=10.0.1.1
#DNS=192.168.120.100
DEFROUTE=yes

*/

-- Step 7 -->> On Node 2
[root@oracle19c2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens160
/*

TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
NAME=ens160
UUID=29ca7892-1bf7-49e9-ba3d-98d9834b71c9
DEVICE=ens160
ONBOOT=yes
IPADDR=192.168.120.62
PREFIX=24
GATEWAY=192.168.120.254
DNS1=192.168.120.100

*/

-- Step 8 -->> On Node 2
[root@oracle19c2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens224
/*
DEVICE=ens224
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.62
NETMASK=255.255.255.0
GATEWAY=10.0.1.1
#DNS=192.168.120.100
DEFROUTE=yes

*/


-- Step 9 -->> On Both Node

[root@oracle19c1/oracle19c2 ~] # systemctl restart network-online.target

-- Step 10 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# dnf repolist
/*
repo id                                          repo name
ol8_UEKR7                                        Latest Unbreakable Enterprise Kernel Release 7 for Oracle Linux 8 (x86_64)
ol8_appstream                                    Oracle Linux 8 Application Stream (x86_64)
ol8_baseos_latest                                Oracle Linux 8 BaseOS Latest (x86_64)

*/
-- Step 10.1 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# uname -a
/*
Linux oracle19c1.racdomain.com 5.15.0-206.153.7.el8uek.x86_64 #2 SMP Thu May 9 15:52:29 PDT 2024 x86_64 x86_64 x86_64 GNU/Linux
Linux oracle19c2.racdomain.com 5.15.0-206.153.7.el8uek.x86_64 #2 SMP Thu May 9 15:52:29 PDT 2024 x86_64 x86_64 x86_64 GNU/Linux
*/

-- Step 10.2 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# uname -r
/*
5.15.0-206.153.7.el8uek.x86_64
*/

-- Step 10.3 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# grubby --info=ALL | grep ^kernel
/*
kernel="/boot/vmlinuz-5.15.0-206.153.7.el8uek.x86_64"
kernel="/boot/vmlinuz-5.15.0-200.131.27.el8uek.x86_64"
kernel="/boot/vmlinuz-4.18.0-513.24.1.el8_9.x86_64"
kernel="/boot/vmlinuz-4.18.0-513.5.1.el8_9.x86_64"
kernel="/boot/vmlinuz-0-rescue-7e06b1afb4164a17ab671322c99b6ed5"


*/

-- Step 10.4 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# grubby --default-kernel
/*
/boot/vmlinuz-5.4.17-2136.330.7.1.el8uek.x86_64
*/


-- Step 11 -->> On Node 1
[root@oracle19c1 ~]# hostnamectl set-hostname oracle19c1.racdomain.com
[root@oracle19c1 ~]# hostnamectl
/*
   Static hostname: oracle19c1.racdomain.com
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 7e06b1afb4164a17ab671322c99b6ed5
           Boot ID: 052bde41db5c468b8941d9366a1f0f4f
    Virtualization: vmware
  Operating System: Oracle Linux Server 8.9
       CPE OS Name: cpe:/o:oracle:linux:8:9:server
            Kernel: Linux 5.15.0-206.153.7.el8uek.x86_64
      Architecture: x86-64

*/
-- Step 12 -->> On Node 2
[root@oracle19c2 ~]# hostnamectl set-hostname rac2.mydomain
[root@oracle19c2 ~]# hostnamectl
/*
    Static hostname: oracle19c2.racdomain.com
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 3228b92775b24ccebec382d108a2e0fe
           Boot ID: 0a42d7c5455340f596de1551f29e692b
    Virtualization: vmware
  Operating System: Oracle Linux Server 8.9
       CPE OS Name: cpe:/o:oracle:linux:8:9:server
            Kernel: Linux 5.15.0-206.153.7.el8uek.x86_64
      Architecture: x86-64

*/


-- Step 13  -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl stop firewalld
[root@oracle19c1/oracle19c2 ~]# systemctl disable firewalld
/*
Removed /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
*/

-- Step 14 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl stop ntpd
/*
Failed to stop ntpd.service: Unit ntpd.service not loaded.
*/
[root@oracle19c1/oracle19c2 ~]# systemctl disable ntpd
/*
Failed to disable unit: Unit file ntpd.service does not exist.
*/

[root@oracle19c1/oracle19c2 ~]# cd /etc/
[root@oracle19c1/oracle19c2 ~]#  mv /etc/ntp.conf /etc/ntp.conf.backup
[root@oracle19c1/oracle19c2 ~]#  ls | grep ntp

[root@oracle19c1/oracle19c2 ~]# rm -rf /etc/ntp.conf
[root@oracle19c1/oracle19c2 ~]# rm -rf /var/run/ntpd.pid

-- Step 15 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# iptables -F
[root@oracle19c1/oracle19c2 ~]# iptables -X
[root@oracle19c1/oracle19c2 ~]# iptables -t nat -F
[root@oracle19c1/oracle19c2 ~]# iptables -t nat -X
[root@oracle19c1/oracle19c2 ~]# iptables -t mangle -F
[root@oracle19c1/oracle19c2 ~]# iptables -t mangle -X
[root@oracle19c1/oracle19c2 ~]# iptables -P INPUT ACCEPT
[root@oracle19c1/oracle19c2 ~]# iptables -P FORWARD ACCEPT
[root@oracle19c1/oracle19c2 ~]# iptables -P OUTPUT ACCEPT
[root@oracle19c1/oracle19c2 ~]# iptables -L -nv
/*
Chain INPUT (policy ACCEPT 16 packets, 1068 bytes)
 pkts bytes target     prot u01 in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot u01 in     out     source               destination

Chain OUTPUT (policy ACCEPT 5 packets, 380 bytes)
 pkts bytes target     prot u01 in     out     source               destination

*/
-- Step 16 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl stop named
/*
Failed to stop named.service: Unit named.service not loaded.
*/
[root@oracle19c1/oracle19c2 ~]# systemctl disable named
/*
Failed to disable unit: Unit file named.service does not exist.
*/

-- Step 17 -->> On Both Node
-- Enable chronyd service." `date`
[root@oracle19c1/oracle19c2 ~]# systemctl enable chronyd
[root@oracle19c1/oracle19c2 ~]# systemctl restart chronyd
[root@oracle19c1/oracle19c2 ~]# chronyc -a 'burst 4/4'
/*
200 OK
*/
[root@oracle19c1/oracle19c2 ~]#  chronyc -a makestep
/*
200 OK
*/

[root@oracle19c1/oracle19c2 ~]# systemctl status chronyd
/*
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2024-05-29 10:54:03 +0545; 6min ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
  Process: 6317 ExecStopPost=/usr/libexec/chrony-helper remove-daemon-state (code=exited, status=0/SUCCESS)
  Process: 6327 ExecStartPost=/usr/libexec/chrony-helper update-daemon (code=exited, status=0/SUCCESS)
  Process: 6322 ExecStart=/usr/sbin/chronyd $u01IONS (code=exited, status=0/SUCCESS)
 Main PID: 6325 (chronyd)
    Tasks: 1 (limit: 22836)
   Memory: 948.0K
   CGroup: /system.slice/chronyd.service
           └─6325 /usr/sbin/chronyd

May 29 10:54:03 oracle19c1.racdomain.com systemd[1]: Starting NTP client/server...
May 29 10:54:03 oracle19c1.racdomain.com chronyd[6325]: chronyd version 4.2 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +>
May 29 10:54:03 oracle19c1.racdomain.com chronyd[6325]: Frequency -3.609 +/- 0.448 ppm read from /var/lib/chrony/drift
May 29 10:54:03 oracle19c1.racdomain.com chronyd[6325]: Using right/UTC timezone to obtain leap second data
May 29 10:54:03 oracle19c1.racdomain.com systemd[1]: Started NTP client/server.
May 29 10:54:08 oracle19c1.racdomain.com chronyd[6325]: Selected source 162.159.200.1 (2.pool.ntp.org)
May 29 10:54:08 oracle19c1.racdomain.com chronyd[6325]: System clock TAI offset set to 37 seconds
May 29 10:55:19 oracle19c1.racdomain.com chronyd[6325]: System clock was stepped by 0.000000 seconds

*/


-- Step 18 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# cd /etc/yum.repos.d/
[root@oracle19c1 yum.repos.d]# ll
/*
-rw-r--r--. 1 root root 3882 Nov 17  2023 oracle-linux-ol8.repo
-rw-r--r--. 1 root root  941 May 23 21:42 uek-ol8.repo
-rw-r--r--. 1 root root  243 Nov 18  2023 virt-ol8.repo

*/

-- Step 18.1 -->> On Both Node
[root@oracle19c1 ~]# cd /etc/yum.repos.d/
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y update
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y bind
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y dnsmasq

-- Step 18.2 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl enable dnsmasq
/*
Created symlink /etc/systemd/system/multi-user.target.wants/dnsmasq.service → /usr/lib/systemd/system/dnsmasq.service.
*/

[root@oracle19c1/oracle19c2 ~]# systemctl restart dnsmasq
[root@oracle19c1/oracle19c2 ~]# vi /etc/dnsmasq.conf
/*
listen-address=::1,127.0.0.1

#Add the following Lines
except-interface=virbr0
bind-interfaces
*/

-- Step 18.3 -->> On Both Node
[root@oracle19c1 ~]# cat /etc/dnsmasq.conf | grep -E 'listen-address|except-interface|bind-interfaces'
/*
except-interface=virbr0
listen-address=::1,127.0.0.1
bind-interfaces
*/

-- Step 18.4 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl restart dnsmasq
[root@oracle19c1/oracle19c2 ~]# systemctl restart network-online.target
[root@oracle19c1/oracle19c2 ~]# systemctl status dnsmasq
/*
● dnsmasq.service - DNS caching server.
   Loaded: loaded (/usr/lib/systemd/system/dnsmasq.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2024-05-29 12:06:21 +0545; 15s ago
 Main PID: 124940 (dnsmasq)
    Tasks: 1 (limit: 22836)
   Memory: 704.0K
   CGroup: /system.slice/dnsmasq.service
           └─124940 /usr/sbin/dnsmasq -k

May 29 12:06:21 oracle19c1.racdomain.com systemd[1]: Started DNS caching server..
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: listening on lo(#1): 127.0.0.1
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: listening on lo(#1): ::1
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: started, version 2.79 cachesize 150
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: compile time u01ions: IPv6 GNU-getu01 DBus no-i18n IDN2 DHCP DHCPv6 no-Lua TFTP no-conntrack i>
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: reading /etc/resolv.conf
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: using nameserver 192.168.120.100#53
May 29 12:06:21 oracle19c1.racdomain.com dnsmasq[124940]: read /etc/hosts - 12 addresses

*/

-- Step 19 -->> On Node 1
[root@oracle19c1 ~]# nslookup 192.168.120.61
/*
61.120.168.192.in-addr.arpa     name = oracle19c1.racdomain.com.
*/

-- Step 19.1 -->> On Node 1
[root@oracle19c1 ~]# nslookup 192.168.120.62
/*
62.120.168.192.in-addr.arpa     name = oracle19c2.racdomain.com.
*/

-- Step 20 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c1
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c1.racdomain.com
Address: 192.168.120.61

*/

-- Step 20.1 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c2
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c2.racdomain.com
Address: 192.168.120.62

*/

-- Step 20.2 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c-scan
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.66
Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.67
Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.65

*/

-- Step 21 -->> On Both Node
--Stop avahi-daemon damon if it not configured
[root@oracle19c1/oracle19c2 ~]# systemctl stop avahi-daemon
/*
Warning: Stopping avahi-daemon.service, but it can still be activated by:
  avahi-daemon.socket
*/
[root@oracle19c1/oracle19c2 ~]# systemctl disable avahi-daemon
/*
Removed /etc/systemd/system/multi-user.target.wants/avahi-daemon.service.
Removed /etc/systemd/system/sockets.target.wants/avahi-daemon.socket.
Removed /etc/systemd/system/dbus-org.freedesktop.Avahi.service.

*/

-- Step 22 -->> On Both Node
--To Remove virbr0 and lxcbr0 Network Interfac
[root@oracle19c1/oracle19c2 ~]# systemctl stop libvirtd.service
/*
Warning: Stopping libvirtd.service, but it can still be activated by:
  libvirtd.socket
  libvirtd-ro.socket
  libvirtd-admin.socket
*/
[root@oracle19c1/oracle19c2 ~]# systemctl disable libvirtd.service
/*
Removed /etc/systemd/system/multi-user.target.wants/libvirtd.service.
Removed /etc/systemd/system/sockets.target.wants/virtlogd.socket.
Removed /etc/systemd/system/sockets.target.wants/virtlockd.socket.
Removed /etc/systemd/system/sockets.target.wants/libvirtd.socket.
Removed /etc/systemd/system/sockets.target.wants/libvirtd-ro.socket.
*/

[root@oracle19c1/oracle19c2 ~]# virsh net-list
/*
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
 
 */

-- Step 22.1 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# virsh net-destroy default
/*
Network default destroyed
*/

-- Step 22.2 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# ifconfig virbr0
/*
virbr0: error fetching interface information: Device not found
*/

-- Step 22.3 -->> On Node One
[root@oracle19c1 ~]# ifconfig
/*
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.120.61  netmask 255.255.255.0  broadcast 192.168.120.255
        inet6 fe80::20c:29ff:fe62:9fba  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:62:9f:ba  txqueuelen 1000  (Ethernet)
        RX packets 957006  bytes 1427124417 (1.3 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 121676  bytes 8369450 (7.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens224: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.61  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::20c:29ff:fe62:9fc4  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:62:9f:c4  txqueuelen 1000  (Ethernet)
        RX packets 88  bytes 13143 (12.8 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 118  bytes 13732 (13.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 2160  bytes 238824 (233.2 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2160  bytes 238824 (233.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

*/

-- Step 22.4 -->> On Node Two
[root@oracle19c2 ~]# ifconfig
/*
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.120.62  netmask 255.255.255.0  broadcast 192.168.120.255
        inet6 fe80::20c:29ff:fe0b:7f40  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:0b:7f:40  txqueuelen 1000  (Ethernet)
        RX packets 826592  bytes 1231108897 (1.1 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 98423  bytes 6915172 (6.5 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens224: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.62  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::20c:29ff:fe0b:7f4a  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:0b:7f:4a  txqueuelen 1000  (Ethernet)
        RX packets 83  bytes 11497 (11.2 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 103  bytes 12392 (12.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1987  bytes 158638 (154.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1987  bytes 158638 (154.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

*/
-- Step 23 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# init 6


-- Step 24 -->> On Node One
[root@oracle19c1 ~]# ifconfig
/*
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.120.61  netmask 255.255.255.0  broadcast 192.168.120.255
        inet6 fe80::20c:29ff:fe62:9fba  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:62:9f:ba  txqueuelen 1000  (Ethernet)
        RX packets 122511  bytes 184665116 (176.1 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 20692  bytes 1145154 (1.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens224: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.61  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::20c:29ff:fe62:9fc4  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:62:9f:c4  txqueuelen 1000  (Ethernet)
        RX packets 3  bytes 192 (192.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 14  bytes 992 (992.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 77  bytes 7676 (7.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 77  bytes 7676 (7.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

*/

-- Step 24.1 -->> On Node Two
[root@oracle19c2 ~]# ifconfig
/*
ens160: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.120.62  netmask 255.255.255.0  broadcast 192.168.120.255
        inet6 fe80::20c:29ff:fe0b:7f40  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:0b:7f:40  txqueuelen 1000  (Ethernet)
        RX packets 125306  bytes 188511933 (179.7 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 20539  bytes 1140116 (1.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens224: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.62  netmask 255.255.255.0  broadcast 10.0.1.255
        inet6 fe80::20c:29ff:fe0b:7f4a  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:0b:7f:4a  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 14  bytes 992 (992.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 76  bytes 7652 (7.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 76  bytes 7652 (7.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

*/

-- Step 25 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl status libvirtd.service
/*
● libvirtd.service - Virtualization daemon
   Loaded: loaded (/usr/lib/systemd/system/libvirtd.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:libvirtd(8)
           https://libvirt.org

*/

-- Step 26 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# firewall-cmd --list-all
/*
FirewallD is not running
*/

-- Step 27 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl status firewalld
/*
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
*/

-- Step 28 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl status named
/*
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
*/

-- Step 29 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl status avahi-daemon
/*
● avahi-daemon.service - Avahi mDNS/DNS-SD Stack
   Loaded: loaded (/usr/lib/systemd/system/avahi-daemon.service; disabled; vendor preset: enabled)
   Active: inactive (dead)

*/

-- Step 30 -->> On Both Node
[root@oracle19c1/oracle19c2 ~ ]# systemctl status chronyd
/*
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2024-05-29 12:18:16 +0545; 6min ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
  Process: 1246 ExecStartPost=/usr/libexec/chrony-helper update-daemon (code=exited, status=0/SUCCESS)
  Process: 1206 ExecStart=/usr/sbin/chronyd $u01IONS (code=exited, status=0/SUCCESS)
 Main PID: 1232 (chronyd)
    Tasks: 1 (limit: 22836)
   Memory: 2.2M
   CGroup: /system.slice/chronyd.service
           └─1232 /usr/sbin/chronyd

May 29 12:18:15 oracle19c1.racdomain.com systemd[1]: Starting NTP client/server...
May 29 12:18:15 oracle19c1.racdomain.com chronyd[1232]: chronyd version 4.5 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +>
May 29 12:18:15 oracle19c1.racdomain.com chronyd[1232]: Loaded 0 symmetric keys
May 29 12:18:15 oracle19c1.racdomain.com chronyd[1232]: Frequency -4.824 +/- 0.598 ppm read from /var/lib/chrony/drift
May 29 12:18:15 oracle19c1.racdomain.com chronyd[1232]: Using right/UTC timezone to obtain leap second data
May 29 12:18:16 oracle19c1.racdomain.com systemd[1]: Started NTP client/server.
May 29 12:18:21 oracle19c1.racdomain.com chronyd[1232]: Selected source 162.159.200.1 (2.pool.ntp.org)
May 29 12:18:21 oracle19c1.racdomain.com chronyd[1232]: System clock TAI offset set to 37 seconds
May 29 12:18:25 oracle19c1.racdomain.com chronyd[1232]: Received KoD RATE from 103.104.28.105

*/

-- Step 31 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# systemctl status dnsmasq
/*
● dnsmasq.service - DNS caching server.
   Loaded: loaded (/usr/lib/systemd/system/dnsmasq.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2024-05-29 12:18:16 +0545; 7min ago
 Main PID: 1271 (dnsmasq)
    Tasks: 1 (limit: 22836)
   Memory: 1.3M
   CGroup: /system.slice/dnsmasq.service
           └─1271 /usr/sbin/dnsmasq -k

May 29 12:18:16 oracle19c1.racdomain.com systemd[1]: Started DNS caching server..
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: listening on lo(#1): 127.0.0.1
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: listening on lo(#1): ::1
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: started, version 2.79 cachesize 150
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: compile time u01ions: IPv6 GNU-getu01 DBus no-i18n IDN2 DHCP DHCPv6 no-Lua TFTP no-conntrack ips>
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: reading /etc/resolv.conf
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: using nameserver 192.168.120.100#53
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: read /etc/hosts - 12 addresses
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: reading /etc/resolv.conf
May 29 12:18:16 oracle19c1.racdomain.com dnsmasq[1271]: using nameserver 192.168.120.100#53
*/

-- Step 31.1 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]#  nslookup 192.168.120.61
/*
61.120.168.192.in-addr.arpa     name = oracle19c1.racdomain.com.

*/

-- Step 31.2 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup 192.168.120.62
/*
262.120.168.192.in-addr.arpa     name = oracle19c2.racdomain.com.
*/

-- Step 31.3 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c1
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c1.racdomain.com
Address: 192.168.120.61
*/

-- Step 31.4 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c2
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c2.racdomain.com
Address: 192.168.120.62

*/

-- Step 31.5 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c-scan
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.65
Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.66
Name:   oracle19c-scan.racdomain.com
Address: 192.168.120.67

*/

-- Step 31.6 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c1-vip
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c1-vip.racdomain.com
Address: 192.168.120.63

*/

-- Step 31.7 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# nslookup oracle19c2-vip
/*
Server:         192.168.120.100
Address:        192.168.120.100#53

Name:   oracle19c2-vip.racdomain.com
Address: 192.168.120.64

*/

-- Step 31.8 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# iptables -L -nv
/*
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot u01 in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot u01 in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot u01 in     out     source               destination
*/


-- Step 32 -->> On Both Node
-- Perform either the Automatic Setup or the Manual Setup to complete the basic prerequisites. 
[root@oracle19c1/oracle19c2 ~]# cd /etc/yum.repos.d/
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y update

-- Step 32.1 -->> On Both Node
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y yum-utils
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y dnf-utils
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y oracle-epel-release-el8
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y sshpass zip unzip
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y oracle-database-preinstall-19c 
or
[root@oracle19c1/oracle19c2 yum.repos.d]# curl -o oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm 
[root@oracle19c1/oracle19c2 yum.repos.d]#yum -y localinstall oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm

-- Step 32.2 -->> On Both Node
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y bc    
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y binutils
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y compat-libcap1
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y compat-libstdc++-33
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y dtrace-utils
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y elfutils-libelf
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y elfutils-libelf-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y fontconfig-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y glibc
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y glibc-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y ksh
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libaio
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libaio-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libdtrace-ctf-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libXrender
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libXrender-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libX11
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libXau
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libXi
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libXtst
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libgcc
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y librdmacm-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libstdc++
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libstdc++-devel
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libxcb
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y make
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y net-tools
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y nfs-utils
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y python
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y python-configshell
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y python-rtslib
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y python-six
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y targetcli
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y smartmontools
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y sysstat
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y unixODBC
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libnsl
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libnsl.i686
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libnsl2
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y libnsl2.i686
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y chrony
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y unixODBC
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf install -y kmod-redhat-oracleasm
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y update

-- Step 32.3 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# cd /tmp
--Bug 29772579
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/compat-libcap1-1.10-7.el7.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/compat-libcap1-1.10-7.el7.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/compat-libstdc++-33-3.2.3-72.el7.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm

-- Step 32.4 -->> On Both Node
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/elfutils-libelf-devel-0.189-3.el8.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/elfutils-libelf-devel-0.189-3.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/numactl-2.0.12-13.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/numactl-devel-2.0.12-13.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/numactl-devel-2.0.12-13.el8.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/python3-libs-3.6.8-56.0.1.el8_9.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/python3-libs-3.6.8-56.0.1.el8_9.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://download.oracle.com/otn_software/asmlib/oracleasmlib-2.0.17-1.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://public-yum.oracle.com/repo/OracleLinux/OL8/addons/x86_64/getPackage/oracleasm-support-2.1.12-1.el8.x86_64.rpm

-- Step 32.5 -->> On Both Node
--Bug 29772579
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./compat-libcap1-1.10-7.el7.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./compat-libcap1-1.10-7.el7.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./compat-libstdc++-33-3.2.3-72.el7.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm

-- Step 33 -->> On Both Node
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./elfutils-libelf-devel-0.189-3.el8.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./elfutils-libelf-devel-0.189-3.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./numactl-2.0.12-13.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./numactl-devel-2.0.12-13.el8.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./numactl-devel-2.0.12-13.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./python3-libs-3.6.8-56.0.1.el8_9.i686.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./python3-libs-3.6.8-56.0.1.el8_9.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./oracleasm-support-2.1.12-1.el8.x86_64.rpm 
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./oracleasmlib-2.0.17-1.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# rm -rf *.rpm

-- Step 34 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# cd /etc/yum.repos.d/
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y install compat-libcap1 compat-libstdc++-33 bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libgcc libnsl librdmacm-devel libstdc++ libstdc++-devel libX11 libXau libxcb libXi libXrender libXrender-devel libXtst make net-tools nfs-utils python3 python3-configshell python3-rtslib python3-six smartmontools sysstat targetcli unzip
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y install bash bc bind-utils binutils ethtool glibc glibc-devel initscripts ksh libaio libaio-devel libgcc libnsl libstdc++ libstdc++-devel make module-init-tools net-tools nfs-utils openssh-clients openssl-libs pam procps psmisc smartmontools sysstat tar unzip util-linux-ng xorg-x11-utils xorg-x11-xauth 
[root@oracle19c1/oracle19c2 yum.repos.d]# dnf -y update

-- Step 35 -->> On Both Node
[root@oracle19c1/oracle19c2 yum.repos.d]# rpm -q binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static \
[root@oracle19c1/oracle19c2 yum.repos.d]# rpm -q gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers kernel-headers ksh libaio libaio-devel \
[root@oracle19c1/oracle19c2 yum.repos.d]# rpm -q libgcc libgomp libstdc++ libstdc++-devel make numactl-devel sysstat unixODBC unixODBC-devel \

-- Step 36.3 -->> On Both Node
--Remove the previous kmod-redhat-oracleasm version using rpm with --noscripts u01ion.
[root@oracle19c1/oracle19c2 ~]# rpm -e kmod-redhat-oracleasm-2.0.8-12.2.0.1.el8.x86_64 --noscripts 
[root@oracle19c1/oracle19c2 ~]# rpm -e oracleasmlib-2.0.17-1.el8.x86_64
[root@oracle19c1/oracle19c2 ~]# rpm -e oracleasm-support-2.1.12-1.el8.x86_64
warning: /etc/sysconfig/oracleasm saved as /etc/sysconfig/oracleasm.rpmsave
--Verify the packages and make sure that the latest version is available on the server.
# rpm -qa | grep kmod-redhat-oracleasm
 
[root@oracle19c1/oracle19c2 ~]# rpm -qa | grep oracleasm
/*
oracleasmlib-2.0.17-1.el8.x86_64
oracleasm-support-2.1.12-1.el8.x86_64
kmod-redhat-oracleasm-2.0.8-18.0.1.el8.x86_64

*/

-- Step 37 -->> On Both Node
-- Add the kernel parameters file "/etc/sysctl.conf" and add oracle recommended kernel parameters
[root@oracle19c1/oracle19c2 ~]# vi /etc/sysctl.conf
/*
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
*/

-- Step 37.1 -->> On Both Node
-- Run the following command to change the current kernel parameters.
[root@oracle19c1/oracle19c2 ~]# sysctl -p /etc/sysctl.conf

-- Step 38 -->> On Both Node
-- Edit “/etc/security/limits.d/oracle-database-preinstall-19c.conf” file to limit user processes
[root@oracle19c1/oracle19c2 ~]# vi /etc/security/limits.d/oracle-database-preinstall-19c.conf
/*
oracle   soft   nofile  65536
oracle   hard   nofile  65536
oracle   soft   nproc   16384
oracle   hard   nproc   16384
oracle   soft   stack   10240
oracle   hard   stack   32768
oracle   hard   memlock 134217728
oracle   soft   memlock 134217728
oracle   soft   data    unlimited
oracle   hard   data    unlimited

grid    soft    nofile   65536
grid    hard    nofile   65536
grid    soft    nproc    16384
grid    hard    nproc    16384
grid    soft    stack    10240
grid    hard    stack    32768
grid    soft    memlock  134217728
grid    hard    memlock  134217728
grid    soft    data     unlimited
grid    hard    data     unlimited
*/

-- Step 39 -->> On Both Node
-- Add the following line to the "/etc/pam.d/login" file, if it does not already exist.
[root@oracle19c1/oracle19c2 ~]# vi /etc/pam.d/login
/*

auth       substack     system-auth
auth       include      postlogin
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    u01ional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    u01ional     pam_keyinit.so force revoke
session    include      system-auth
session    include      postlogin
-session   u01ional     pam_ck_connector.so

*/

-- Step 40 -->> On both Node
-- Create the new groups and users.
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:
*/

-- Step 40.1 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i dba
/*
dba:x:54322:
backupdba:x:54324:
dgdba:x:54325:
kmdba:x:54326:
racdba:x:54330:
*/

-- Step 40.2 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oracle
/*

oinstall:x:54321:oracle
dba:x:54322:oracle
oper:x:54323:oracle
backupdba:x:54324:oracle
dgdba:x:54325:oracle
kmdba:x:54326:oracle
racdba:x:54330:oracle
*/

-- Step 40.3 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oper
/*
oper:x:54323:oracle
*/

-- Step 40.4 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i asm

-- Step 40.5 -->> On both Node
-- 1.Create OS groups using the command below. Enter these commands as the 'root' user:
--[root@oracle19c1/oracle19c2 ~]# /usr/sbin/groupadd -g 503 oper
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/groupadd -g 504 asmadmin
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/groupadd -g 506 asmdba
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/groupadd -g 507 asmoper
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/groupadd -g 508 beoper

-- Step 40.6 -->> On both Node
-- 2.Create the users that will own the Oracle software using the commands:
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/useradd  -g oinstall -G oinstall,dba,asmadmin,asmdba,asmoper,beoper grid
[root@oracle19c1/oracle19c2 ~]# /usr/sbin/usermod -g oinstall -G oinstall,dba,oper,asmdba,asmadmin,backupdba,dgdba,kmdba,racdba oracle

-- Step 40.7 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i asm
/*
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/

-- Step 40.8 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oracle
/*
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
oper:x:54323:oracle
backupdba:x:54324:oracle
dgdba:x:54325:oracle
kmdba:x:54326:oracle
racdba:x:54330:oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
*/

-- Step 40.9 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i grid
/*
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

-- Step 40.10 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oper
/*
oper:x:54323:oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

-- Step 40.11 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:grid,oracle
*/

-- Step 40.12 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i dba
/*
dba:x:54322:grid,oracle
backupdba:x:54324:oracle
dgdba:x:54325:oracle
kmdba:x:54326:oracle
pdbdba:x:54330:oracle
asmdba:x:506:grid,oracle
*/

-- Step 40.13 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# cat /etc/group | grep -i asm
/*
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/

-- Step 41 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# passwd oracle
/*
Changing password for user oracle.
New password: oracle
Retype new password: oracle
passwd: all authentication tokens updated successfully.
*/

-- Step 42 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# passwd grid
/*
Changing password for user grid.
New password: grid
Retype new password: grid
passwd: all authentication tokens updated successfully.
*/

-- Step 42.1 -->> On both Node
[root@oracle19c1/oracle19c2 ~]# su - oracle

-- Step 42.2 -->> On both Node
[oracle@oracle19c1/oracle19c2 ~]$ su - grid
/*
Password: grid
*/

-- Step 42.3 -->> On both Node
[grid@oracle19c1/oracle19c2 ~]$ su - oracle
/*
Password: oracle
*/

-- Step 42.4 -->> On both Node
[oracle@oracle19c1/oracle19c2 ~]$ exit
/*
logout
*/

-- Step 42.5 -->> On both Node
[grid@oracle19c1/oracle19c2 ~]$ exit
/*
logout
*/

-- Step 42.6 -->> On both Node
[oracle@oracle19c1/oracle19c2 ~]$ exit
/*
logout
*/

-- Step 43 -->> On both Node
--Create the Oracle Inventory Director:
[root@oracle19c1/oracle19c2 ~]# mkdir -p /u01/app/oraInventory
[root@oracle19c1/oracle19c2 ~]# chown -R grid:oinstall /u01/app/oraInventory
[root@oracle19c1/oracle19c2 ~]# chmod -R 775 /u01/app/oraInventory

-- Step 44 -->> On both Node
--Creating the Oracle Grid Infrastructure Home Directory:
[root@oracle19c1/oracle19c2 ~]# mkdir -p /u01/app/19c/grid
[root@oracle19c1/oracle19c2 ~]# chown -R grid:oinstall /u01/app/19c/grid
[root@oracle19c1/oracle19c2 ~]# chmod -R 775 /u01/app/19c/grid

-- Step 45 -->> On both Node
--Creating the Oracle Base Directory
[root@oracle19c1/oracle19c2 ~]#  mkdir -p /u01/app/oracle
[root@oracle19c1/oracle19c2 ~]#  chmod -R 775 /u01/app/oracle
[root@oracle19c1/oracle19c2 ~]#  cd /u01/app/
[root@oracle19c1/oracle19c2 app]# chown -R oracle:oinstall /u01/app/oracle

-- Step 46 -->> On Node 1
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@oracle19c1 ~]# su - oracle
[oracle@oracle19c1 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=oracle19c1.racdomain.com; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/19c/db_1; export ORACLE_HOME
ORACLE_SID=racdb1; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 47 -->> On Node 1
[oracle@oracle19c1 ~]$ . .bash_profile

-- Step 48 -->> On Node 1
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@oracle19c1 ~]# su - grid
[grid@oracle19c1 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Grid Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_SID=+ASM1; export ORACLE_SID
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
GRID_HOME=/u01/app/19c/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 49 -->> On Node 1
[grid@oracle19c1 ~]$ . .bash_profile

-- Step 50 -->> On Node 2
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@oracle19c2 ~]# su - oracle
[oracle@oracle19c2 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=oracle19c2.racdomain.com; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/19c/db_1; export ORACLE_HOME
ORACLE_SID=racdb2; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 51 -->> On Node 2
[oracle@oracle19c2 ~]$ . .bash_profile

-- Step 52 -->> On Node 2
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@oracle19c2 ~]# su - grid
[grid@oracle19c2 ~]$ vi .bash_profile
/*
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]: then
        . ~/.bashrc
fi

# User specfic environment and startup programs
#PATH=$PATH:$HOME/bin
#export PATH

# Grid Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_SID=+ASM2; export ORACLE_SID
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
GRID_HOME=/u01/app/19c/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 53 -->> On Node 2
[grid@oracle19c2 ~]$ . .bash_profile

-- Step 54 -->> On Node 1
-- To Unzio The Oracle Grid Software and lateset Opatch
[root@oracle19c1 ~]# cd /u01/app/19c/grid/
[root@oracle19c1 grid]# unzip -oq /root/Oracle_19C/19.3.0.0.0_Grid_Binary/LINUX.X64_193000_grid_home.zip
[root@oracle19c1 grid]# unzip -oq /root/Oracle_19C/OPATCH_19c/p6880880_190000_Linux-x86-64.zip

-- Step 55 -->> On Node 1
-- To Unzio The Oracle PSU
[root@oracle19c1 ~]# cd /tmp/
[root@oracle19c1 tmp]# unzip -oq /root/Oracle_19C/PSU_19.22.0.0.0/p36031453_190000_Linux-x86-64.zip
[root@oracle19c1 tmp]# chown -R oracle:oinstall 36031453
[root@oracle19c1 tmp]# chmod -R 775 36031453
[root@oracle19c1 tmp]# ls -ltr | grep 36031453
/*
drwxrwxr-x  4 oracle oinstall      57 Jan 16 13:07 36031453
*/

-- Step 56 -->> On Node 1
-- Login as root user and issue the following command at oracle19c1
[root@oracle19c1 ~]# chown -R grid:oinstall /u01/app/19c/grid/
[root@oracle19c1 ~]# chmod -R 775 /u01/app/19c/grid/

[root@oracle19c1 tmp]# su - grid
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/OPatch/
[grid@oracle19c1 OPatch]$ ./opatch version
/*
OPatch Version: 12.2.0.1.42

OPatch succeeded.
*/

-- Step 57 -->> On Node 1
[root@oracle19c1 ~]# scp -r /u01/app/19c/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm root@oracle19c2:/tmp/
/*
The authenticity of host 'oracle19c2 (192.168.120.62)' can't be established.
ECDSA key fingerprint is SHA256:2TEBT/PGpPPiGCg3k1TQD66qTWuO8N9nHae409YcmWE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'oracle19c2,192.168.120.62' (ECDSA) to the list of known hosts.
root@oracle19c2's password:
cvuqdisk-1.0.10-1.rpm                                                                                                  100%   11KB   3.5MB/s   00:00

*/

-- Step 58 -->> On Node 1
-- To install the cvuqdisk-1.0.10-1.rpm
-- Login from root user
[root@oracle19c1 ~]# cd /u01/app/19c/grid/cv/rpm/

-- Step 58.1 -->> On Node 1
[root@oracle19c1 rpm]# ls -ltr
/*
-rwxrwxr-x 1 grid oinstall 11412 Mar 13  2019 cvuqdisk-1.0.10-1.rpm
*/

-- Step 58.2 -->> On Node 1
[root@oracle19c1 rpm]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP

-- Step 58.3 -->> On Node 1
[root@oracle19c1 rpm]# rpm -iUvh cvuqdisk-1.0.10-1.rpm 
/*
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:cvuqdisk-1.0.10-1                ################################# [100%]

*/

-- Step 59 -->> On Node 2
[root@oracle19c2 ~]# cd /tmp/
[root@oracle19c2 tmp]# chown -R grid:oinstall cvuqdisk-1.0.10-1.rpm
[root@oracle19c2 tmp]# chmod -R 775 cvuqdisk-1.0.10-1.rpm
[root@oracle19c2 tmp]# ls -ltr | grep cvuqdisk-1.0.10-1.rpm
/*
-rwxrwxr-x  1 grid oinstall 11412 May  2 14:06 cvuqdisk-1.0.10-1.rpm
*/

-- Step 60 -->> On Node 2
-- To install the cvuqdisk-1.0.10-1.rpm
-- Login from root user
[root@oracle19c2 ~]# cd /tmp/
[root@oracle19c2 tmp]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
[root@oracle19c2 tmp]# rpm -iUvh cvuqdisk-1.0.10-1.rpm 
/*
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:cvuqdisk-1.0.10-1                ################################# [100%]
*/

-- Step 61 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# which oracleasm
/*
/usr/sbin/oracleasm
*/

-- Step 62 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm configure
/*
OracLEASM_ENABLED=false
OracLEASM_UID=
OracLEASM_GID=
OracLEASM_SCANBOOT=true
OracLEASM_SCANORDER=""
OracLEASM_SCANEXCLUDE=""
OracLEASM_SCAN_DIRECTORIES=""
OracLEASM_USE_LOGICAL_BLOCK_SIZE="false"
*/

-- Step 63 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm status
/*
Checking if ASM is loaded: no
Checking if /dev/oracleasm is mounted: no
*/

-- Step 64 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm configure -i
/*
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting <ENTER> without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface []: grid
Default group to own the driver interface []: asmadmin
Start Oracle ASM library driver on boot (y/n) [n]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
Writing Oracle ASM library driver configuration: done
*/

-- Step 65 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm configure
/*
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_SCAN_DIRECTORIES=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"
*/

-- Step 66 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm init
/*
Creating /dev/oracleasm mount point: /dev/oracleasm
Loading module "oracleasm": failed
Unable to load module "oracleasm"
Mounting ASMlib driver filesystem: failed
Unable to mount ASMlib driver filesystem

*/

--resolve this problem to change the Kernel Version and UEKR7
An Oracle Linux 8 system is running Unbreakable Enterprise Kernel Release 7 (UEKR7) i.e. 5.15.0.

--from oracle support 
The module continues to be provided as part of earlier UEK Releases e.g. UEKR5 (4.14.35), UEKR6 5.4.17).
From UEKR7, the io_uring Asynchronous I/O Framework includes support for Oracle ASMLib v3 (pending) and oracleasm-support. 
For UEKR7, Oracle ASMLib uses the io_uring in place of the traditional oracleasm driver interface, 
which has been removed from UEKR7.


--to check repo on both nodes
[root@oracle19c1/oracle19c2  ~]# dnf repolist
repo id                                              repo name
ol8_UEKR7                                            Latest Unbreakable Enterprise Kernel Release 7 for Oracle Linux 8 (x86_64)
ol8_appstream                                        Oracle Linux 8 Application Stream (x86_64)
ol8_baseos_latest                                    Oracle Linux 8 BaseOS Latest (x86_64)
ol8_developer_EPEL                                   Oracle Linux 8 EPEL Packages for Development (x86_64)
ol8_developer_EPEL_modular                           Oracle Linux 8 EPEL Modular Packages for Development (x86_64)


[root@oracle19c1/oracle19c2  ~]# uname -a
Linux oracle19c1.racdomain.com 5.15.0-206.153.7.1.el8uek.x86_64 #2 SMP Wed May 22 20:49:34 PDT 2024 x86_64 x86_64 x86_64 GNU/Linux

--now downgrade the kernel UEKR6 which support the ASMlib
--https://docs.oracle.com/en/operating-systems/oracle-linux/8/relnotes8.7/ol8-NewFeaturesandChanges.html#ol8-features-install
[root@oracle19c1/oracle19c2 ~]# dnf config-manager --set-disabled ol8_UEKR7
[root@oracle19c1/oracle19c2 ~]# dnf config-manager --set-enabled ol8_UEKR6
[root@oracle19c1/oracle19c2 ~]# dnf repolist
repo id                                              repo name
ol8_UEKR6                                            Latest Unbreakable Enterprise Kernel Release 6 for Oracle Linux 8 (x86_64)
ol8_appstream                                        Oracle Linux 8 Application Stream (x86_64)
ol8_baseos_latest                                    Oracle Linux 8 BaseOS Latest (x86_64)
ol8_developer_EPEL                                   Oracle Linux 8 EPEL Packages for Development (x86_64)
ol8_developer_EPEL_modular                           Oracle Linux 8 EPEL Modular Packages for Development (x86_64)

--https://docs.oracle.com/en/operating-systems/oracle-linux/6/install/ol6-installuek.html
[root@oracle19c1/oracle19c2 ~]# dnf install -y kernel-uek
Latest Unbreakable Enterprise Kernel Release 6 for Oracle Linux 8 (x86_64)                                                18 MB/s |  93 MB     00:05
Last metadata expiration check: 0:00:31 ago on Sun 02 Jun 2024 10:19:27 AM +0545.
Package kernel-uek-5.15.0-200.131.27.el8uek.x86_64 is already installed.
Package kernel-uek-5.15.0-206.153.7.el8uek.x86_64 is already installed.
Package kernel-uek-5.15.0-206.153.7.1.el8uek.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!


--https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader

[root@oracle19c1/oracle19c2 ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
done

[root@oracle19c1/oracle19c2 ~]# cat /etc/sysconfig/kernel
# UPDATEDEFAULT specifies if kernel-install should make
# new kernels the default
UPDATEDEFAULT=yes

# DEFAULTKERNEL specifies the default kernel package type
DEFAULTKERNEL=kernel-uek-core


[root@oracle19c1/oracle19c2 ~]# grubby --default-kernel
/boot/vmlinuz-5.15.0-206.153.7.1.el8uek.x86_64


[root@oracle19c1/oracle19c2 ~]# grubby --info=ALL | grep ^kernel
kernel="/boot/vmlinuz-5.15.0-206.153.7.1.el8uek.x86_64"
kernel="/boot/vmlinuz-5.15.0-206.153.7.el8uek.x86_64"
kernel="/boot/vmlinuz-5.15.0-200.131.27.el8uek.x86_64"
kernel="/boot/vmlinuz-4.18.0-553.el8_10.x86_64"
kernel="/boot/vmlinuz-4.18.0-513.24.1.el8_9.x86_64"
kernel="/boot/vmlinuz-4.18.0-513.5.1.el8_9.x86_64"
kernel="/boot/vmlinuz-0-rescue-7e06b1afb4164a17ab671322c99b6ed5"


[root@oracle19c1/oracle19c2 ~]# grubby --set-default /boot/vmlinuz-4.18.0-513.24.1.el8_9.x86_64
The default is /boot/loader/entries/7e06b1afb4164a17ab671322c99b6ed5-4.18.0-553.el8_10.x86_64.conf with index 3 and kernel /boot/vmlinuz-4.18.0-553.el8_10.x86_64


[root@oracle19c1/oracle19c2 ~]# init 6

[root@oracle19c1/oracle19c2 ~]# dnf repolist
/*
repo id                                              repo name
ol8_UEKR6                                            Latest Unbreakable Enterprise Kernel Release 6 for Oracle Linux 8 (x86_64)
ol8_appstream                                        Oracle Linux 8 Application Stream (x86_64)
ol8_baseos_latest                                    Oracle Linux 8 BaseOS Latest (x86_64)
ol8_developer_EPEL                                   Oracle Linux 8 EPEL Packages for Development (x86_64)
ol8_developer_EPEL_modular                           Oracle Linux 8 EPEL Modular Packages for Development (x86_64)

*/

[root@oracle19c1/oracle19c2 ~]# uname -a
/*
Linux oracle19c1.racdomain.com 4.18.0-513.24.1.el8_9.x86_64 #1 SMP Wed Apr 10 08:10:12 PDT 2024 x86_64 x86_64 x86_64 GNU/Linux

*/

[root@oracle19c1/oracle19c2 ~]# uname -r
/*
4.18.0-513.24.1.el8_9.x86_64
*/

[root@oracle19c1/oracle19c2 ~]# grubby --default-kernel
/*
/boot/vmlinuz-4.18.0-513.24.1.el8_9.x86_64
*/
[root@oracle19c1/oracle19c2 ~]# cat /etc/sysconfig/kernel | grep -E 'DEFAULTKERNEL'
/*
# DEFAULTKERNEL specifies the default kernel package type
DEFAULTKERNEL=kernel-uek-core
*/

--Remove the previous oracleasm version using rpm with --noscripts u01ion.
[root@oracle19c1/oracle19c2 ~]# rpm -e kmod-redhat-oracleasm-2.0.8-18.0.1.el8.x86_64 --noscripts 
[root@oracle19c1/oracle19c2 ~]# rpm -e oracleasmlib-2.0.17-1.el8.x86_64
[root@oracle19c1/oracle19c2 ~]# rpm -e oracleasm-support-2.1.12-1.el8.x86_64
/*
warning: /etc/sysconfig/oracleasm saved as /etc/sysconfig/oracleasm.rpmsave
--Verify the packages and make sure that the latest version is available on the server.
*/
 
[root@oracle19c1/oracle19c2 ~]# rpm -qa | grep oracleasm
/*
oracleasmlib-2.0.17-1.el8.x86_64
oracleasm-support-2.1.12-1.el8.x86_64
kmod-redhat-oracleasm-2.0.8-18.0.1.el8.x86_64


[root@oracle19c1/oracle19c2 tmp]# wget https://download.oracle.com/otn_software/asmlib/oracleasmlib-2.0.17-1.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# wget https://public-yum.oracle.com/repo/OracleLinux/OL8/addons/x86_64/getPackage/oracleasm-support-2.1.12-1.el8.x86_64.rpm

[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./oracleasm-support-2.1.12-1.el8.x86_64.rpm
[root@oracle19c1/oracle19c2 tmp]# yum -y localinstall ./oracleasmlib-2.0.17-1.el8.x86_64.rpm

[root@oracle19c1/oracle19c2 ~]# systemctl enable oracleasm
[root@oracle19c1/oracle19c2 ~]#/usr/lib/systemd/systemd-sysv-install enable oracleasm
[root@oracle19c1/oracle19c2 ~]# systemctl start oracleasm
*/
--finally again issue oracleasm init  
[root@oracle19c1/oracle19c2 ~]# oracleasm init
/*
Loading module "oracleasm": oracleasm
Configuring "oracleasm" to use device physical block size
Mounting ASMlib driver filesystem: /dev/oracleasm
*/

-- Step 67 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm status
/*
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes
*/

-- Step 68 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 69 -->> On all Node
[root@oracle19c1/oracle19c2 ~]# oracleasm listdisks

[root@oracle19c1/oracle19c2 ~]# ls -ltr /etc/init.d/
/*
-rwxr-xr-x  1 root root  4954 Feb 29  2020 oracleasm
-rwx------  1 root root  1281 Feb 17  2021 oracle-database-preinstall-19c-firstboot
-rw-r--r--. 1 root root 18434 Aug 10  2022 functions
-rwxr-xr-x. 1 root root  8067 Apr 28  2023 network
-rw-r--r--. 1 root root  1161 May 23 15:28 README
*/

-- Step 70 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# ls -ll /dev/oracleasm/disks/
/*
total 0
*/
-- Step 71 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# rpm -qa | grep -i iscsi
/*
libvirt-daemon-driver-storage-iscsi-direct-8.0.0-23.0.1.module+el8.10.0+90308+7c659588.x86_64
udisks2-iscsi-2.9.0-16.el8.x86_64
libvirt-daemon-driver-storage-iscsi-8.0.0-23.0.1.module+el8.10.0+90308+7c659588.x86_64
qemu-kvm-block-iscsi-6.2.0-49.module+el8.10.0+90330+d0258130.x86_64
iscsi-initiator-utils-6.2.1.4-8.git095f59c.0.1.el8_8.x86_64
libiscsi-1.18.0-8.module+el8.9.0+90052+d3bf71d8.x86_64
iscsi-initiator-utils-iscsiuio-6.2.1.4-8.git095f59c.0.1.el8_8.x86_64
*/
[root@oracle19c1/oracle19c2 ~]# dnf install -y iscsi-initiator-utils
/*
Last metadata expiration check: 0:08:37 ago on Sun 02 Jun 2024 12:28:13 PM +0545.
Package iscsi-initiator-utils-6.2.1.4-8.git095f59c.0.1.el8_8.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
*/


[root@oracle19c1/oracle19c2 ~]# service iscsi start
/*
Redirecting to /bin/systemctl start iscsi.service
*/

[root@oracle19c1/oracle19c2 ~]# systemctl enable iscsi.service
[root@oracle19c1/oracle19c2 ~]# systemctl start iscsi.service


-- Step 72 -->> On all Nodes
[root@oracle19c1/oracle19c2 ~]# systemctl stop iscsi.service

-- Step 73 -->> On all Nodes
[root@oracle19c1/oracle19c2 ~]# systemctl status iscsi.service
/*
● iscsi.service - Login and scanning of iSCSI devices
   Loaded: loaded (/usr/lib/systemd/system/iscsi.service; enabled; vendor preset: disabled)
   Active: inactive (dead)
Condition: start condition failed at Sun 2024-06-02 12:41:33 +0545; 6min ago
           └─ ConditionDirectoryNotEmpty=/var/lib/iscsi/nodes was not met
     Docs: man:iscsiadm(8)
           man:iscsid(8)

Jun 02 11:22:30 oracle19c2.racdomain.com systemd[1]: iscsi.service: Unit cannot be reloaded because it is inactive.


*/
-- Step 74 -->> On all Nodes
[root@oracle19c1/oracle19c2 ~]# cd /etc/iscsi/
[root@oracle19c1/oracle19c2 iscsi]# ls
/*
initiatorname.iscsi  iscsid.conf
*/
-- Step 75 -->> On all Nodes
[root@oracle19c1 iscsi]# vi initiatorname.iscsi 
/*
InitiatorName=iqn.oracle19c1:oracle
*/

[root@oracle19c2 iscsi]# vi initiatorname.iscsi 
/*
InitiatorName=iqn.oracle19c2:oracle
*/

-- Step 76 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# systemctl start iscsi.service
[root@oracle19c1/oracle19c2 iscsi]# systemctl enable iscsi.service
[root@oracle19c1/oracle19c2 iscsi]# chkconfig iscsid on
/*
Note: Forwarding request to 'systemctl enable iscsid.service'.
Created symlink /etc/systemd/system/multi-user.target.wants/iscsid.service → /usr/lib/systemd/system/iscsid.service.
*/


-- Step 77 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[N:0:0:1]    disk    VMware Virtual NVMe Disk__1                /dev/nvme0n1
[N:0:0:2]    disk    VMware Virtual NVMe Disk__2                /dev/nvme0n2
 
*/

-- Step 78 -->> On all Nodes 
[root@oracle19c1/oracle19c2  iscsi]# iscsiadm -m discovery -t sendtargets -p sanstorage
/*
192.168.120.60:3260,1 iqn.openfiler:fra1
192.168.120.60:3260,1 iqn.openfiler:data1
192.168.120.60:3260,1 iqn.openfiler:ocr

*/
-- Step 79 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[N:0:0:1]    disk    VMware Virtual NVMe Disk__1                /dev/nvme0n1
[N:0:0:2]    disk    VMware Virtual NVMe Disk__2                /dev/nvme0n2 
*/

-- Step 80 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# ls /var/lib/iscsi/send_targets/
/*
sanstorage,3260
*/

-- Step 81 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# ls /var/lib/iscsi/nodes/
/*
iqn.openfiler:data1  iqn.openfiler:fra1  iqn.openfiler:ocr
*/

-- Step 82 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# systemctl restart iscsi.service


-- Step 83 -->> On all Nodes 


[root@oracle19c1/oracle19c2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[2:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sda
[3:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc
[N:0:0:1]    disk    VMware Virtual NVMe Disk__1                /dev/nvme0n1
[N:0:0:2]    disk    VMware Virtual NVMe Disk__2                /dev/nvme0n2

*/

-- Step 84 -->> On all Nodes 
[root@oracle19c1/oracle19c2 iscsi]# iscsiadm -m session
/*
tcp: [1] 192.168.120.60:3260,1 iqn.openfiler:data1 (non-flash)
tcp: [2] 192.168.120.60:3260,1 iqn.openfiler:ocr (non-flash)
tcp: [3] 192.168.120.60:3260,1 iqn.openfiler:fra1 (non-flash)

*/

-- Step 85 -->> On Node 1
[root@oracle19c1 iscsi]# iscsiadm -m node -T iqn.openfiler:ocr -p 192.168.120.60 --op update -n node.startup -v automatic
[root@oracle19c1 iscsi]# iscsiadm -m node -T iqn.openfiler:data1 -p 192.168.120.60 --op update -n node.startup -v automatic
[root@oracle19c1 iscsi]# iscsiadm -m node -T iqn.openfiler:fra1 -p 192.168.120.60 --op update -n node.startup -v automatic

-- Step 86 -->> On Node 1
[root@oracle19c1 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[2:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sda
[3:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc
[N:0:0:1]    disk    VMware Virtual NVMe Disk__1                /dev/nvme0n1
[N:0:0:2]    disk    VMware Virtual NVMe Disk__2                /dev/nvme0n2
*/

-- Step 87 -->> On Node 1
[root@oracle19c1 iscsi]# ls /dev/sd*
/*
/dev/sda  /dev/sdb  /dev/sdc
*/


-- Step 88 -->> On Node 1
[root@oracle19c1/oracle19c2 iscsi]# iscsiadm -m session -P 3 > scsi_drives.txt
[root@oracle19c1/oracle19c2 iscsi]# vi scsi_drives.txt 
[root@oracle19c1/oracle19c2 iscsi]# cat scsi_drives.txt 
/*

Target: iqn.openfiler:data1 (non-flash)
                        Attached scsi disk sda          State: running
Target: iqn.openfiler:ocr (non-flash)
                        Attached scsi disk sdb          State: running
Target: iqn.openfiler:fra1 (non-flash)
                        Attached scsi disk sdc          State: running
*/


-- Step 89 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# ls -ll /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Jun  2 15:49 /dev/sda
brw-rw---- 1 root disk 8, 16 Jun  2 15:49 /dev/sdb
brw-rw---- 1 root disk 8, 32 Jun  2 15:49 /dev/sdc
*/

--Step 89.1 -->> Both Node
[root@oracle19c1 ~]# lsblk
/*
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0   25G  0 disk
sdb           8:16   0   10G  0 disk
sdc           8:32   0 12.7G  0 disk
sr0          11:0    1 12.5G  0 rom
nvme0n1     259:0    0   90G  0 disk
├─nvme0n1p1 259:1    0    1G  0 part /boot
└─nvme0n1p2 259:2    0   89G  0 part
  ├─ol-root 253:0    0   22G  0 lvm  /
  ├─ol-swap 253:1    0    8G  0 lvm  [SWAP]
  ├─ol-usr  253:2    0   16G  0 lvm  /usr
  ├─ol-u01  253:3    0   27G  0 lvm  /u01
  ├─ol-tmp  253:4    0    8G  0 lvm  /tmp
  ├─ol-var  253:5    0    8G  0 lvm  /var
  └─ol-home 253:6    0    8G  0 lvm  /home
nvme0n2     259:3    0   10G  0 disk
└─nvme0n2p1 259:4    0   10G  0 part
  └─ol-usr  253:2    0   16G  0 lvm  /usr
*/

-- Step 90 -->> On Node 1
[root@oracle19c1 ~]# fdisk -ll | grep GiB
/*
Disk /dev/sdb: 10 GiB, 10737418240 bytes, 20971520 sectors    /ocr
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors    /fra
Disk /dev/sdc: 12.7 GiB, 13589544960 bytes, 26542080 sectors  /data
*/

-- Step 91 -->> On Node 1
[root@oracle19c1 ~]# fdisk /dev/sda
/*
Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x415674fe.

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x415674fe

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-52428799, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-52428799, default 52428799):

Created a new partition 1 of type 'Linux' and of size 25 GiB.

Command (m for help): p
Disk /dev/sda: 25 GiB, 26843545600 bytes, 52428800 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x415674fe

Device     Boot Start      End  Sectors Size Id Type
/dev/sda1        2048 52428799 52426752  25G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

*/

-- Step 92 -->> On Node 1
[root@oracle19c1 ~]# fdisk  /dev/sdb
/*
Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xf76185de.

Command (m for help): p
Disk /dev/sdb: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xf76185de

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-20971519, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519):

Created a new partition 1 of type 'Linux' and of size 10 GiB.

Command (m for help): p
Disk /dev/sdb: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xf76185de

Device     Boot Start      End  Sectors Size Id Type
/dev/sdb1        2048 20971519 20969472  10G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
*/

-- Step 93 -->> On Node 1
[root@oracle19c1 ~]# fdisk /dev/sdc
/*
Welcome to fdisk (util-linux 2.32.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xcb5f6251.

Command (m for help): p
Disk /dev/sdc: 12.7 GiB, 13589544960 bytes, 26542080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcb5f6251

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-26542079, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-26542079, default 26542079):

Created a new partition 1 of type 'Linux' and of size 12.7 GiB.

Command (m for help): p
Disk /dev/sdc: 12.7 GiB, 13589544960 bytes, 26542080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcb5f6251

Device     Boot Start      End  Sectors  Size Id Type
/dev/sdc1        2048 26542079 26540032 12.7G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

*/

-- Step 94 -->> On Node 1
[root@oracle19c1 ~]# ls -ll /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Jun  2 16:29 /dev/sda
brw-rw---- 1 root disk 8,  1 Jun  2 16:29 /dev/sda1
brw-rw---- 1 root disk 8, 16 Jun  2 16:32 /dev/sdb
brw-rw---- 1 root disk 8, 17 Jun  2 16:32 /dev/sdb1
brw-rw---- 1 root disk 8, 32 Jun  2 16:33 /dev/sdc
brw-rw---- 1 root disk 8, 33 Jun  2 16:33 /dev/sdc1

*/

-- Step 95 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# fdisk -ll | grep sd
/*
Disk /dev/sdb: 25 GiB, 26843545600 bytes, 52428800 sectors
/dev/sdb1        2048 52428799 52426752  25G 83 Linux
Disk /dev/sda: 12.7 GiB, 13589544960 bytes, 26542080 sectors
/dev/sda1        2048 26542079 26540032 12.7G 83 Linux
Disk /dev/sdc: 10 GiB, 10737418240 bytes, 20971520 sectors
/dev/sdc1        2048 20971519 20969472  10G 83 Linux


*/

-- Step 95.1 -->> On Both Node
[root@oracle19c1 ~]# lsblk
/*
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0   25G  0 disk
└─sda1        8:1    0   25G  0 part
sdb           8:16   0   10G  0 disk
└─sdb1        8:17   0   10G  0 part
sdc           8:32   0 12.7G  0 disk
└─sdc1        8:33   0 12.7G  0 part
sr0          11:0    1 12.5G  0 rom
nvme0n1     259:0    0   90G  0 disk
├─nvme0n1p1 259:1    0    1G  0 part /boot
└─nvme0n1p2 259:2    0   89G  0 part
  ├─ol-root 253:0    0   22G  0 lvm  /
  ├─ol-swap 253:1    0    8G  0 lvm  [SWAP]
  ├─ol-usr  253:2    0   16G  0 lvm  /usr
  ├─ol-u01  253:3    0   27G  0 lvm  /u01
  ├─ol-tmp  253:4    0    8G  0 lvm  /tmp
  ├─ol-var  253:5    0    8G  0 lvm  /var
  └─ol-home 253:6    0    8G  0 lvm  /home
nvme0n2     259:3    0   10G  0 disk
└─nvme0n2p1 259:4    0   10G  0 part
  └─ol-usr  253:2    0   16G  0 lvm  /usr
*/
-- Step 96 -->> On Node 1

[root@oracle19c1 ~]# mkfs.xfs /dev/sda1
[root@oracle19c1 ~]# mkfs.xfs /dev/sdb1
[root@oracle19c1 ~]# mkfs.xfs /dev/sdc1




-- Step 97 -->> On Node 1
[root@oracle19c1 ~]# oracleasm createdisk DATA /dev/sdb1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 98 -->> On Node 1
[root@oracle19c1 ~]# oracleasm createdisk FRA /dev/sda1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 99 -->> On Node 1
[root@oracle19c1 ~]# oracleasm createdisk OCR /dev/sdc1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 100 -->> On Node 1
[root@oracle19c1 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 101 -->> On Node 1
[root@oracle19c1 ~]# oracleasm listdisks
/*
DATA
FRA
OCR
*/

-- Step 102 -->> On Node 2
[root@oracle19c2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
Instantiating disk "OCR"
Instantiating disk "DATA"
Instantiating disk "FRA"
*/

-- Step 103 -->> On Node 2
[root@oracle19c2 ~]# oracleasm listdisks
/*
DATA
FRA
OCR
*/

-- Step 104 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# ls -ll /dev/oracleasm/disks/
/*
brw-rw---- 1 grid asmadmin 8,  1 Jun  2 16:42 DATA
brw-rw---- 1 grid asmadmin 8, 33 Jun  2 16:42 FRA
brw-rw---- 1 grid asmadmin 8, 17 Jun  2 16:42 OCR

*/

-- Step 105 -->> On Node 1
-- SSH Setup Between Nodes
[root@oracle19c1 ~]# su - grid
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/deinstall
[grid@oracle19c1 deinstall]$ ./sshUserSetup.sh -user grid -hosts "oracle19c1 oracle19c2" -noPromptPassphrase -confirm -advanced
/*
Password: grid
*/

-- Step 106 -->> On Node 1
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c1 date
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c2 date
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c1 date && ssh grid@oracle19c2 date
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c1.racdomain.com date
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c2.racdomain.com date
[grid@oracle19c1/oracle19c2 ~]$ ssh grid@oracle19c1.racdomain.com date && ssh grid@oracle19c2.racdomain.com date

[grid@oracle19c1 ~]# cd /u01/app/19c/grid/
[grid@oracle19c1 grid]$ ./runcluvfy.sh stage -pre crsinst -n oracle19c1,oracle19c2 -verbose
/*
Verifying /dev/shm mounted as temporary file system ...FAILED
oracle19c2: PRVE-0426 : The size of in-memory file system mounted as /dev/shm
            is "1843" megabytes which is less than the required size of "2048"
            megabytes on node "oracle19c2.racdomain.com"

oracle19c1: PRVE-0426 : The size of in-memory file system mounted as /dev/shm
            is "1843" megabytes which is less than the required size of "2048"
            megabytes on node "oracle19c1.racdomain.com"
			
			
Verifying Physical Memory ...FAILED
oracle19c2: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c2" [Required physical memory = 8GB (8388608.0KB)]

oracle19c1: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c1" [Required physical memory = 8GB (8388608.0KB)]

Verifying resolv.conf Integrity ...FAILED
oracle19c2: PRVG-2002 : Encountered error in copying file "/etc/resolv.conf"
            from node "oracle19c2" to node "oracle19c1"
            protocol error: filename does not match request

Verifying DNS/NIS name service ...FAILED
oracle19c2: PRVG-2002 : Encountered error in copying file "/etc/nsswitch.conf"
            from node "oracle19c2" to node "oracle19c1"
            protocol error: filename does not match request

*/

--resolve of PRVE-0426			
[root@oracle19c1 ~]# vi /etc/fstab
/*
tmpfs                  /dev/shm                 tmpfs   defaults,size=2G 0 0
*/

[root@oracle19c1/oracle19c2 ~]#  mount -o remount /dev/shm
/*
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
*/
	   
[root@oracle19c1/oracle19c2 ~]# systemctl daemon-reload
[root@oracle19c1/oracle19c2 ~]# df -h /dev/shm
/*
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           2.0G     0  2.0G   0% /dev/shm
*/




--Resolve of the PRVG-2002

-- Step 107 -->> On Node 1
[grid@oracle19c1 ~]$ vi /u01/app/19c/grid/cv/admin/cvu_config
/*

# Fallback to this distribution id
CV_ASSUME_DISTID=OEL8

*/

-- Step 108 -->> On Node 1
[grid@oracle19c1 ~]$ cat /u01/app/19c/grid/cv/admin/cvu_config | grep -E CV_ASSUME_DISTID
/*
CV_ASSUME_DISTID=OEL8
*/

-- To solve the Pre-check for rac Setup, from remote nodes PRVG-2002
--https://www.dbaplus.ca/2021/03/19c-runcluvfysh-faile-with-prvf-7596.html

[root@oracle19c1 ~]# ll /usr/bin/scp
/*
-rwxr-xr-x 1 root root 105352 May  7 22:26 /usr/bin/scp
*/
[root@oracle19c1 ~]# cp -p /usr/bin/scp /usr/bin/scp-original

[root@oracle19c1 ~]# ll /usr/bin/scp-original
/*
-rwxr-xr-x 1 root root 105352 May  7 22:26 /usr/bin/scp-original
*/
[root@oracle19c1 ~]# echo "/usr/bin/scp-original -T \$*" > /usr/bin/scp

[root@oracle19c1 ~]# cat /usr/bin/scp



--Pre-Checking Using CLUVFY (Use CLUVFY command to check for cluster installation readiness along with rectification in case of any issue. )
-- Step 108.1 -->> On Node 1
-- Pre-check for rac Setup
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/
[grid@oracle19c1 grid]$ export CV_ASSUME_DISTID=OEL8
[grid@oracle19c1 grid]$ ./runcluvfy.sh stage -pre crsinst -n oracle19c1,oracle19c2 -verbose
/*
Verifying Physical Memory ...FAILED
oracle19c2: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c2" [Required physical memory = 8GB (8388608.0KB)]

oracle19c1: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c1" [Required physical memory = 8GB (8388608.0KB)]

Verifying RPM Package Manager database ...INFORMATION
PRVG-11250 : The check "RPM Package Manager database" was not performed because
it needs 'root' user privileges.
--above the konwn issue because of I have allocated 4 GB RAM each node,oracle recommandation at least 8GB RAM ecch node,so I skipped this issued.

*/
[grid@oracle19c1 grid]$ export CV_ASSUME_DISTID=OEL8
[grid@oracle19c1 grid]$ ./runcluvfy.sh stage -pre crsinst -n oracle19c1,oracle19c2 -method root
/*
Verifying Physical Memory ...FAILED
oracle19c2: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c2" [Required physical memory = 8GB (8388608.0KB)]

oracle19c1: PRVF-7530 : Sufficient physical memory is not available on node
            "oracle19c1" [Required physical memory = 8GB (8388608.0KB)]
*/
--[grid@oracle19c1 grid]$ ./runcluvfy.sh stage -pre crsinst -n oracle19c1,oracle19c2 -fixup -verbose (If Required)

-- Step 109 -->> On Node 1
-- To Create a Response File to Install GID
[grid@oracle19c1 ~]$ cp /u01/app/19c/grid/install/response/gridsetup.rsp /home/grid/
[grid@oracle19c1 ~]$ cd /home/grid/
[grid@oracle19c1 ~]$ ls -ltr | grep gridsetup.rsp
/*
-rwxr-xr-x 1 grid oinstall 36221 Jun  6 15:22 gridsetup.rsp
*/

-- Step 109.1 -->> On Node 1
[root@oracle19c1 grid]# vi gridsetup.rsp
--Bug 30878668
--The sudo option for running root configuration scripts does not work during Oracle Database 19c 
--or Oracle Grid Infrastructure 19c installations on Oracle Linux 8 
--or Red Hat Enterprise Linux 8 systems.
/*
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v19.0.0
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en,en_GB
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/oracle
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=asmoper
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.scanType=LOCAL_SCAN
oracle.install.crs.config.gpnp.scanName=oracle19c-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.ClusterConfiguration=STANDALONE
oracle.install.crs.config.configureAsExtendedCluster=false
oracle.install.crs.config.clusterName=oracle19c-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=oracle19c1:oracle19c1-vip,oracle19c2:oracle19c2-vip
oracle.install.crs.config.networkInterfaceList=ens160:192.168.120.0:1,ens224:10.0.1.0:5
oracle.install.crs.configureGIMR=false
oracle.install.crs.config.storageOption=FLEX_ASM_STORAGE
oracle.install.crs.config.useIPMI=false
oracle.install.asm.SYSASMPassword=Adminrabin1
oracle.install.asm.diskGroup.name=OCR
oracle.install.asm.diskGroup.redundancy=EXTERNAL
oracle.install.asm.diskGroup.AUSize=4
oracle.install.asm.diskGroup.disks=/dev/oracleasm/disks/OCR
oracle.install.asm.diskGroup.diskDiscoveryString=/dev/oracleasm/disks/*
oracle.install.asm.monitorPassword=Adminrabin1
oracle.install.asm.configureAFD=false
oracle.install.crs.configureRHPS=false
oracle.install.crs.config.ignoreDownNodes=false
oracle.install.config.managementOption=NONE
oracle.install.config.omsPort=0
oracle.install.crs.rootconfig.executeRootScript=false
*/

-- Step 109.2 -->> On Node 1
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/
[grid@oracle19c1 grid]$ OPatch/opatch version
/*
OPatch Version: 12.2.0.1.42

OPatch succeeded.
*/

-- Step 110 -->> On Node 1
-- To Install Grid Software with Leteset Opatch
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/
[grid@oracle19c1 grid]$ export CV_ASSUME_DISTID=OEL8
[grid@oracle19c1 grid]$ ./gridSetup.sh -ignorePrereq -waitForCompletion -silent -applyRU /tmp/36031453/35940989 -responseFile /home/grid/gridsetup.rsp
/*
Preparing the home to patch...
Applying the patch /tmp/36031453/35940989...
Successfully applied the patch.
The log can be found at: /tmp/GridSetupActions2024-06-06_03-38-26PM/installerPatchActions_2024-06-06_03-38-26PM.log
Launching Oracle Grid Infrastructure Setup Wizard...

[WARNING] [INS-13014] Target environment does not meet some optional requirements.
   CAUSE: Some of the optional prerequisites are not met. See logs for details. gridSetupActions2024-06-06_03-38-26PM.log
   ACTION: Identify the list of failed prerequisite checks from the log: gridSetupActions2024-06-06_03-38-26PM.log. Then either from the log file or from installation manual find the appropriate configuration to meet the prerequisites and fix it manually.
The response file for this session can be found at:
 /u01/app/19c/grid/install/response/grid_2024-06-06_03-38-26PM.rsp

You can find the log of this install session at:
 /tmp/GridSetupActions2024-06-06_03-38-26PM/gridSetupActions2024-06-06_03-38-26PM.log

As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/19c/grid/root.sh

Execute /u01/app/oraInventory/orainstRoot.sh on the following nodes:
[oracle19c1, oracle19c2]
Execute /u01/app/19c/grid/root.sh on the following nodes:
[oracle19c1, oracle19c2]

Run the script on the local node first. After successful completion, you can start the script in parallel on all other nodes.

Successfully Setup Software with warning(s).
As install user, execute the following command to complete the configuration.
        /u01/app/19c/grid/gridSetup.sh -executeConfigTools -responseFile /home/grid/gridsetup.rsp [-silent]


Moved the install session logs to:
 /u01/app/oraInventory/logs/GridSetupActions2024-06-06_03-38-26PM

*/

-- Step 111 -->> On Node 1
[root@oracle19c1 ~]# /u01/app/oraInventory/orainstRoot.sh
/*
Changing permissions of /u01/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oraInventory to oinstall.
The execution of the script is complete.
*/

-- Step 112 -->> On Node 2
[root@oracle19c2 ~]# /u01/app/oraInventory/orainstRoot.sh
/*
Changing permissions of /u01/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /u01/app/oraInventory to oinstall.
The execution of the script is complete.
*/

-- Step 113 -->> On Node 1
[root@oracle19c1 ~]# /u01/app/19c/grid/root.sh
/*
Check /u01/app/19c/grid/install/root_oracle19c1.racdomain.com_2024-06-06_16-09-18-913235442.log for the output of root script
*/

-- Step 113.1 -->> On Node 1
[root@oracle19c1 ~]#   tail -f /u01/app/19c/grid/install/root_oracle19c1.racdomain.com_2024-06-06_16-09-18-913235442.log
/*
Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Relinking oracle with rac_on option
Using configuration parameter file: /u01/app/19c/grid/crs/install/crsconfig_params
The log of current session can be found at:
  /u01/app/oracle/crsdata/oracle19c1/crsconfig/rootcrs_oracle19c1_2024-06-06_04-09-47PM.log
2024/06/06 16:10:26 CLSRSC-594: Executing installation step 1 of 19: 'ValidateEnv'.
2024/06/06 16:10:26 CLSRSC-363: User ignored prerequisites during installation
2024/06/06 16:10:26 CLSRSC-594: Executing installation step 2 of 19: 'CheckFirstNode'.
2024/06/06 16:10:31 CLSRSC-594: Executing installation step 3 of 19: 'GenSiteGUIDs'.
2024/06/06 16:10:33 CLSRSC-594: Executing installation step 4 of 19: 'SetupOSD'.
Redirecting to /bin/systemctl restart rsyslog.service
2024/06/06 16:10:34 CLSRSC-594: Executing installation step 5 of 19: 'CheckCRSConfig'.
2024/06/06 16:10:35 CLSRSC-594: Executing installation step 6 of 19: 'SetupLocalGPNP'.
2024/06/06 16:10:50 CLSRSC-594: Executing installation step 7 of 19: 'CreateRootCert'.
2024/06/06 16:10:56 CLSRSC-594: Executing installation step 8 of 19: 'ConfigOLR'.
2024/06/06 16:11:11 CLSRSC-594: Executing installation step 9 of 19: 'ConfigCHMOS'.
2024/06/06 16:11:12 CLSRSC-594: Executing installation step 10 of 19: 'CreateOHASD'.
2024/06/06 16:11:19 CLSRSC-594: Executing installation step 11 of 19: 'ConfigOHASD'.
2024/06/06 16:11:20 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
2024/06/06 16:11:50 CLSRSC-594: Executing installation step 12 of 19: 'SetupTFA'.
2024/06/06 16:11:50 CLSRSC-594: Executing installation step 13 of 19: 'InstallAFD'.
2024/06/06 16:11:50 CLSRSC-594: Executing installation step 14 of 19: 'InstallACFS'.
2024/06/06 16:12:01 CLSRSC-594: Executing installation step 15 of 19: 'InstallKA'.
2024/06/06 16:12:17 CLSRSC-594: Executing installation step 16 of 19: 'InitConfig'.

ASM has been created and started successfully.

[DBT-30001] Disk groups created successfully. Check /u01/app/oracle/cfgtoollogs/asmca/asmca-240606PM041252.log for details.

2024/06/06 16:13:46 CLSRSC-482: Running command: '/u01/app/19c/grid/bin/ocrconfig -upgrade grid oinstall'
CRS-4256: Updating the profile
Successful addition of voting disk c1db0bf7ca024f73bf281628d17968a8.
Successfully replaced voting disk group with +OCR.
CRS-4256: Updating the profile
CRS-4266: Voting file(s) successfully replaced
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   c1db0bf7ca024f73bf281628d17968a8 (/dev/oracleasm/disks/OCR) [OCR]
Located 1 voting disk(s).
2024/06/06 16:16:39 CLSRSC-594: Executing installation step 17 of 19: 'StartCluster'.
2024/06/06 16:17:46 CLSRSC-343: Successfully started Oracle Clusterware stack
2024/06/06 16:17:46 CLSRSC-594: Executing installation step 18 of 19: 'ConfigNode'.
2024/06/06 16:19:12 CLSRSC-4002: Successfully installed Oracle Trace File Analyzer (TFA) Collector.
2024/06/06 16:19:57 CLSRSC-594: Executing installation step 19 of 19: 'PostConfig'.
2024/06/06 16:20:34 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded

*/

-- Step 114 -->> On Node 2
[root@oracle19c2 ~]# /u01/app/19c/grid/root.sh
/*
Check /u01/app/19c/grid/install/root_oracle19c2.racdomain.com_2024-06-06_16-22-08-306016166.log for the output of root script
*/

-- Step 114.1 -->> On Node 2 
[root@oracle19c2 ~]# tail -f /u01/app/19c/grid/install/root_oracle19c2.racdomain.com_2024-06-06_16-22-08-306016166.log
/*
Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Relinking oracle with rac_on option
Using configuration parameter file: /u01/app/19c/grid/crs/install/crsconfig_params
The log of current session can be found at:
  /u01/app/oracle/crsdata/oracle19c2/crsconfig/rootcrs_oracle19c2_2024-06-06_04-23-42PM.log
2024/06/06 16:23:49 CLSRSC-594: Executing installation step 1 of 19: 'ValidateEnv'.
2024/06/06 16:23:49 CLSRSC-363: User ignored prerequisites during installation
2024/06/06 16:23:50 CLSRSC-594: Executing installation step 2 of 19: 'CheckFirstNode'.
2024/06/06 16:23:52 CLSRSC-594: Executing installation step 3 of 19: 'GenSiteGUIDs'.
2024/06/06 16:23:53 CLSRSC-594: Executing installation step 4 of 19: 'SetupOSD'.
Redirecting to /bin/systemctl restart rsyslog.service
2024/06/06 16:23:54 CLSRSC-594: Executing installation step 5 of 19: 'CheckCRSConfig'.
2024/06/06 16:23:55 CLSRSC-594: Executing installation step 6 of 19: 'SetupLocalGPNP'.
2024/06/06 16:23:57 CLSRSC-594: Executing installation step 7 of 19: 'CreateRootCert'.
2024/06/06 16:23:57 CLSRSC-594: Executing installation step 8 of 19: 'ConfigOLR'.
2024/06/06 16:24:10 CLSRSC-594: Executing installation step 9 of 19: 'ConfigCHMOS'.
2024/06/06 16:24:11 CLSRSC-594: Executing installation step 10 of 19: 'CreateOHASD'.
2024/06/06 16:24:14 CLSRSC-594: Executing installation step 11 of 19: 'ConfigOHASD'.
2024/06/06 16:24:15 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
2024/06/06 16:24:52 CLSRSC-594: Executing installation step 12 of 19: 'SetupTFA'.
2024/06/06 16:24:52 CLSRSC-594: Executing installation step 13 of 19: 'InstallAFD'.
2024/06/06 16:24:52 CLSRSC-594: Executing installation step 14 of 19: 'InstallACFS'.
2024/06/06 16:24:56 CLSRSC-594: Executing installation step 15 of 19: 'InstallKA'.
2024/06/06 16:25:00 CLSRSC-594: Executing installation step 16 of 19: 'InitConfig'.
2024/06/06 16:25:33 CLSRSC-594: Executing installation step 17 of 19: 'StartCluster'.
2024/06/06 16:26:40 CLSRSC-343: Successfully started Oracle Clusterware stack
2024/06/06 16:26:41 CLSRSC-594: Executing installation step 18 of 19: 'ConfigNode'.
2024/06/06 16:27:46 CLSRSC-594: Executing installation step 19 of 19: 'PostConfig'.
2024/06/06 16:28:44 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded
*/

-- Step 115 -->> On Node 1
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/
[grid@oracle19c1 grid]$ export CV_ASSUME_DISTID=OEL7.6
[grid@oracle19c1 grid]$ /u01/app/19c/grid/gridSetup.sh -silent -executeConfigTools -responseFile /home/grid/gridsetup.rsp
/*
Launching Oracle Grid Infrastructure Setup Wizard...

You can find the logs of this session at:
/u01/app/oraInventory/logs/GridSetupActions2024-06-06_04-30-46PM

You can find the log of this install session at:
 /u01/app/oraInventory/logs/UpdateNodeList2024-06-06_04-30-46PM.log
Successfully Configured Software.
*/

-- Step 115.1 -->> On Node 1
[root@oracle19c1 ~]#  tail -f /u01/app/oraInventory/logs/UpdateNodeList2024-06-06_04-30-46PM.log

/*
INFO: New thread started for node : oracle19c2
INFO: Running command '/u01/app/19c/grid/oui/bin/runInstaller  -paramFile /u01/app/19c/grid/oui/clusterparam.ini  -silent -ignoreSysPrereqs -updateNodeList -setCustomNodelist -noClusterEnabled ORACLE_HOME=/u01/app/19c/grid "CLUSTER_NODES={oracle19c1,oracle19c2}" "NODES_TO_SET={oracle19c1,oracle19c2}" CRS=true  LOCAL_NODE=oracle19c2 -remoteInvocation -invokingNodeName oracle19c1 -logFilePath "/u01/app/oraInventory/logs" -timestamp 2024-06-06_04-30-46PM -doNotUpdateNodeList ' on the nodes 'oracle19c2'.
INFO: Invoking OUI on cluster nodes oracle19c2
INFO: /u01/app/19c/grid/oui/bin/runInstaller  -paramFile /u01/app/19c/grid/oui/clusterparam.ini  -silent -ignoreSysPrereqs -updateNodeList -setCustomNodelist -noClusterEnabled ORACLE_HOME=/u01/app/19c/grid "CLUSTER_NODES={oracle19c1,oracle19c2}" "NODES_TO_SET={oracle19c1,oracle19c2}" CRS=true  LOCAL_NODE=oracle19c2 -remoteInvocation -invokingNodeName oracle19c1 -logFilePath "/u01/app/oraInventory/logs" -timestamp 2024-06-06_04-30-46PM -doNotUpdateNodeList
INFO: Command execution completes for node : oracle19c2
INFO: Command execution sucess for node : oracle19c2
INFO: All threads completed its operations
INFO: Checkpoint:Index file written and updated
INFO: Done calling doOperation.
INFO: 'UpdateNodeList' was successful.
*/

-- Step 116 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin/
[root@oracle19c1/oracle19c2 bin]# ./crsctl check cluster
/*
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

*/


-- Step 117 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin/
[root@oracle19c1/oracle19c2 bin]# ./crsctl check cluster -all
/*
**************************************************************
oracle19c1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
oracle19c2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************

*/

-- Step 118 -->> On Node 1
[root@oracle19c1 ~]# cd /u01/app/19c/grid/bin/
[root@oracle19c1 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       oracle19c1               Started,STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.crf
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.crsd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.cssd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.ctssd
      1        ONLINE  ONLINE       oracle19c1               OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.gipcd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.gpnpd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.mdnsd
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.storage
      1        ONLINE  ONLINE       oracle19c1               STABLE
--------------------------------------------------------------------------------

*/


-- Step 119 -->> On Node 2
[root@oracle19c2 ~]# cd /u01/app/19c/grid/bin/
[root@oracle19c2 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.crf
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.crsd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.cssd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.ctssd
      1        ONLINE  ONLINE       oracle19c2               OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.gipcd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.gpnpd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.mdnsd
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.storage
      1        ONLINE  ONLINE       oracle19c2               STABLE
--------------------------------------------------------------------------------

*/

-- Step 120 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin/
[root@oracle19c1/oracle19c2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.chad
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.net1.network
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.ons
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               Started,STABLE
      2        ONLINE  ONLINE       oracle19c2               Started,STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.cvu
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.oracle19c1.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.oracle19c2.vip
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.qosmserver
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.scan3.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
--------------------------------------------------------------------------------

*/


-- Step 121 -->> On Both Nodes
[grid@oracle19c1/oracle19c2 ~]$ asmcmd -p
/*
ASMCMD [+] > lsdg
SState    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  4194304     10236     9896                0            9896              0             Y  OCR/

ASMCMD [+] > exit
*/

-- Step 122 -->> On Node 1
[grid@oracle19c1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 06-JUN-2024 16:45:18

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                06-JUN-2024 16:20:19
Uptime                    0 days 0 hr. 24 min. 59 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.61)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.63)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 122.1 -->> On Node 1
[grid@oracle19c1 ~]$ ps -ef | grep SCAN
/*
grid       43242       1  0 16:19 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN2 -no_crs_notify -inherit
grid       43260       1  0 16:19 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN3 -no_crs_notify -inherit
grid       99806   62906  0 16:47 pts/1    00:00:00 grep --color=auto SCAN

*/

-- Step 122.2 -->> On Node 1
[grid@oracle19c1 ~]$ lsnrctl status LISTENER_SCAN2
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 06-JUN-2024 16:48:14

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN2
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                06-JUN-2024 16:19:30
Uptime                    0 days 0 hr. 28 min. 44 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener_scan2/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN2)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.66)(PORT=1521)))
The listener supports no services
The command completed successfully

*/

[grid@oracle19c1 ~]$ lsnrctl  status LISTENER_SCAN3

/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 06-JUN-2024 16:49:04

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN3)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN3
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                06-JUN-2024 16:19:32
Uptime                    0 days 0 hr. 29 min. 31 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener_scan3/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN3)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.67)(PORT=1521)))
The listener supports no services
The command completed successfully
*/

-- Step 122.3 -->> On Node 2

[grid@oracle19c2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 06-JUN-2024 16:46:14

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                06-JUN-2024 16:28:17
Uptime                    0 days 0 hr. 17 min. 58 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.62)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.64)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- Step 122.4 -->> On Node 2
[grid@oracle19c2 ~]$ ps -ef | grep SCAN
/*
grid       32822       1  0 16:26 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN1 -no_crs_notify -inherit
grid       66147   60326  0 16:49 pts/1    00:00:00 grep --color=auto SCAN

*/

-- Step 122.5 -->> On Node 2
[grid@oracle19c2 ~]$ lsnrctl status LISTENER_SCAN1
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 06-JUN-2024 16:50:20

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN1
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                06-JUN-2024 16:26:43
Uptime                    0 days 0 hr. 23 min. 37 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c2/listener_scan1/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.65)(PORT=1521)))
The listener supports no services
The command completed successfully

*/

-- Step 123 -->> On Node 2
-- Bug 30286976: To Solve the Pre-check or any Oracle relavant Installation for rac Setup make compatible version CV_ASSUME_DISTID=OEL7.8
[grid@oracle19c2 ~]$ vi /u01/app/19c/grid/cv/admin/cvu_config
/*
# Configuration file for Cluster Verification Utility(CVU)
#
# Copyright (c) 2004, 2022, Oracle and/or its affiliates.
#
# Version: 011405
#
# NOTE:
# 1._ Any line without a '=' will be ignored
# 2._ Since the fallback option will look into the environment variables,
#     please have a component prefix(CV_) for each property to define a
#     namespace.
#


#Nodes for the cluster. If CRS home is not installed, this list will be
#picked up when -n all is mentioned in the commandline argument.
#CV_NODE_ALL=

#if enabled, cvuqdisk rpm is required on all nodes
CV_RAW_CHECK_ENABLED=TRUE

#Maximum number of reports (Text, Json) to retain in the CVU report directory.
CV_MAX_REPORT_COUNT=5

#Maximum number of baselines to retain in the CVU baseline directory.
CV_MAX_BASELINE_COUNT=10

#Minimum number of free inodes at /var/lib/oracle path
CV_MIN_FREE_INODES_REQ_VAR_PATH=100

#Minimum space required at the /var/lib/oracle path in Kilo Bytes
CV_MIN_FREE_SPACE_REQ_VAR_LIB_ORACLE_PATH=500

#Valid age in number of days for fresh software. If bits are found older than
#following number then CVU reports informational message suggesting update/upgrade
CV_MAX_DAYS_SOFTWARE_BITS_FRESH=180

#Minimum space required MB's in the CV_DESTLOC for CVU operations on the node
CV_DESTLOC_MIN_SPACE_MB=100

#Minimum space required MB's in the CVU TRACE LOC for CVU operations on the node
CV_TRACELOC_MIN_SPACE_MB=50

#Minimum space required MB's in the root filesystem
CV_ROOTFS_MIN_SPACE_MB=100

# Fallback to this distribution id.
CV_ASSUME_DISTID=OL7.6

#Complete file system path of sudo binary file, default is /usr/local/bin/sudo
CV_SUDO_BINARY_LOCATION=/usr/local/bin/sudo

#Complete file system path of pbrun binary file, default is /usr/local/bin/pbrun
CV_PBRUN_BINARY_LOCATION=/usr/local/bin/pbrun

# Whether X-Windows check should be performed for user equivalence with SSH
#CV_XCHK_FOR_SSH_ENABLED=TRUE

# To override SSH location
#ORACLE_SRVM_REMOTESHELL=/usr/bin/ssh

# To override SCP location
#ORACLE_SRVM_REMOTECOPY=/usr/bin/scp

# To override version used by command line parser
CV_ASSUME_CL_VERSION=19.1.0.0.0

# Location of the browser to be used to display HTML report
#CV_DEFAULT_BROWSER_LOCATION=/usr/bin/mozilla

# Maximum number of retries for discover DHCP server
#CV_MAX_RETRIES_DHCP_DISCOVERY=5

# Maximum CVU trace files size (in multiples of 100 MB)
#CV_TRACE_SIZE_MULTIPLIER=1

# ODA CVU profile json file location
#CV_ODA_PROFILE_JSON_FILE_PATH=/opt/oracle/cvu/oda_cvu_profile.json

# OEDA(Exadata) CVU profile json file location
#CV_OEDA_PROFILE_JSON_FILE_PATH=/opt/oracle/cvu/oeda_cvu_profile.json

# OCI(Cloud) CVU profile json file location
#CV_OCI_PROFILE_JSON_FILE_PATH=/opt/oracle/cvu/oci_cvu_profile.json

# Variable to represent which profile to use and load all the properties
# and data from the profile. The profiles will be used internally and
# updated for OCI,ODA and EXADATA environments and will not be exposed to
# the customers directly.
# Applicable values are OCI or ODA or EXADATA or OCI,EXADATA or OCI,ODA
#CV_PROFILE_TO_USE=OCI

# Variable to define the packet size to be used during multicast connectivity
#CV_MULTICAST_PACKET_SIZE=2016

# Variable to set the behavior of patch checks during rootscripts execution
CV_ROOTSCRIPTS_PATCHING_CHECKS=TRUE

# Number of Seconds to time out when checking node reachability from local node
# The maximum allowed time out is 6 seconds.
#CV_NETREACH_TIMEOUT=3

# Maximum time out in seconds required for the CVU stand alone execution.
# Used when alternative pluggable CVU home is in use to perform the checks
#CV_STAND_ALONE_MAX_TIMEOUT_SECONDS=600

*/

-- Step 123.1 -->> On Node 2
[grid@oracle19c2 ~]$ cat /u01/app/19c/grid/cv/admin/cvu_config | grep -E CV_ASSUME_DISTID
/*
CV_ASSUME_DISTID=OL8
*/

-- Step 124 -->> On Node 1
-- To Create ASM storage for Data and Archive 
[grid@oracle19c1 ~]$ cd /u01/app/19c/grid/bin
[grid@oracle19c1 bin]$ export CV_ASSUME_DISTID=OEL7.6

-- Step 1124.1 -->> On Node 1
[grid@oracle19c1 bin]$ ./asmca -silent -createDiskGroup -diskGroupName DATA -diskList /dev/oracleasm/disks/DATA -redundancy EXTERNAL

/*
[INFO] [DBT-30001] Disk groups created successfully. Check /u01/app/oracle/cfgtoollogs/asmca/asmca-240606PM045531.log for details
*/
-- Step 124.2 -->> On Node 1
[grid@oracle19c1 bin]$ ./asmca -silent -createDiskGroup -diskGroupName FRA -diskList /dev/oracleasm/disks/FRA -redundancy EXTERNAL
/*
[INFO] [DBT-30001] Disk groups created successfully. Check /u01/app/oracle/cfgtoollogs/asmca/asmca-240606PM050309.log for details.
*/

-- Step 125 -->> On Both Nodes
[grid@oracle19c1/oracle19c2 ~]$ sqlplus / as sysasm
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 13 11:39:15 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0

SQL> set lines 200;
SQL> COLUMN name FORMAT A30
SQL> SELECT inst_id,name,state,type,compatibility,database_compatibility,voting_files FROM gv$asm_diskgroup order by name;

   
   INST_ID NAME                           STATE       TYPE   COMPATIBILITY                                                DATABASE_COMPATIBILITY               V
---------- ------------------------------ ----------- ------ ------------------------------------------------------------ ------------------------------------------------------------ -
         2 DATA                           MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                           N
         1 DATA                           MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                           N
         2 FRA                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                           N
         1 FRA                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                           N
         1 OCR                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                           Y
         2 OCR                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0 

6 rows selected.

SQL> set lines 200;
SQL> col path format a40;
SQL> SELECT name,path, group_number group_#, disk_number disk_#, mount_status,header_status, state, total_mb, free_mb FROM v$asm_disk order by group_number;

NAME                           PATH                                        GROUP_#     DISK_# MOUNT_S HEADER_STATU STATE      TOTAL_MB    FREE_MB
------------------------------ ---------------------------------------- ---------- ---------- ------- ------------ -------- ---------- ----------
OCR_0000                       /dev/oracleasm/disks/OCR                          1          0 CACHED  MEMBER       NORMAL        10236       9896
DATA_0000                      /dev/oracleasm/disks/DATA                         2          0 CACHED  MEMBER       NORMAL        25599      25491
FRA_0000                       /dev/oracleasm/disks/FRA                          3          0 CACHED  MEMBER       NORMAL        12959      12851

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT inst_id,banner_full,banner_legacy,con_id FROM gv$version;

    INST_ID BANNER_FULL                                                                      BANNER_LEGACY                                                CON_ID
---------- -------------------------------------------------------------------------------- -------------------------------------------------------------------------------- ----------
         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                     0
           Version 19.22.0.0.0

         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                     0
           Version 19.22.0.0.0


SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0
*/

-- Step 126 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c1/oracle19c2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.chad
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.net1.network
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
ora.ons
               ONLINE  ONLINE       oracle19c1               STABLE
               ONLINE  ONLINE       oracle19c2               STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.FRA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               Started,STABLE
      2        ONLINE  ONLINE       oracle19c2               Started,STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1               STABLE
      2        ONLINE  ONLINE       oracle19c2               STABLE
ora.cvu
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.oracle19c1.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.oracle19c2.vip
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.qosmserver
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       oracle19c2               STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
ora.scan3.vip
      1        ONLINE  ONLINE       oracle19c1               STABLE
--------------------------------------------------------------------------------
*/


-- Step 127 -->> On Both Nodes
[grid@oracle19c1/oracle19c2 ~]$ asmcmd -p
/*
ASMCMD [+] > lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  1048576     25599    25491                0           25491              0             N  DATA/
MOUNTED  EXTERN  N         512             512   4096  1048576     12959    12851                0           12851              0             N  FRA/
MOUNTED  EXTERN  N         512             512   4096  4194304     10236     9896                0            9896              0             Y  OCR/

ASMCMD [+] > exit
*/

-- Step 128 -->> On Node 1
[root@oracle19c1 ~]# vi /etc/oratab
/*
+ASM1:/u01/app/19c/grid:N
*/

-- Step 129 -->> On Node 2
[root@oracle19c2 ~]# vi /etc/oratab
/*
+ASM2:/u01/app/19c/grid:N
*/

-- Step 130 -->> On Both Nodes
-- Creating the Oracle RDBMS Home Directory
[root@oracle19c1/oracle19c2 ~]# mkdir -p /u01/app/oracle/product/19c/db_1
[root@oracle19c1/oracle19c2 ~]# chown -R oracle:oinstall /u01/app/oracle/product/19c/db_1
[root@oracle19c1/oracle19c2 ~]# chmod -R 775 /u01/app/oracle/product/19c/db_1

-- Step 130.1 -->> On Node 1
-- To unzip the Oracle Binary and Letest Opatch
[root@oracle19c1 ~]# cd /u01/app/oracle/product/19c/db_1
[root@oracle19c1 db_1]# unzip -oq /root/Oracle_19C/19.3.0.0_DB_Binary/LINUX.X64_193000_db_home.zip
[root@oracle19c1 db_1]# unzip -oq /root/Oracle_19C/OPATCH_19c/p6880880_190000_Linux-x86-64.zip

-- Step 130.2 -->> On Node 1
[root@oracle19c1 ~]# chown -R oracle:oinstall /u01/app/oracle/product/19c/db_1/
[root@oracle19c1 ~]# chmod -R 775 /u01/app/oracle/product/19c/db_1/

-- Step 130.3 -->> On Node 1
[root@oracle19c1 ~]# su - oracle
[oracle@oracle19c1 ~]$  /u01/app/oracle/product/19c/db_1/OPatch/opatch version
/*
OPatch Version: 12.2.0.1.42

OPatch succeeded.
*/

-- Step 131 -->> On Node 1
-- To Setup the SSH Connectivity 
[root@oracle19c1 ~]# su - oracle
[oracle@oracle19c1 ~]$ cd /u01/app/oracle/product/19c/db_1/deinstall/
[oracle@oracle19c1 deinstall]$ ./sshUserSetup.sh -user oracle -hosts "oracle19c1 oracle19c2" -noPromptPassphrase -confirm -advanced
/*
Password: oracle
*/
-- Step 132 -->> On Both Nodes
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c1 date
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c2 date
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c1 date && ssh oracle@oracle19c2 date
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c1.racdomain.com date
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c2.racdomain.com date
[oracle@oracle19c1/oracle19c2 ~]$ ssh oracle@oracle19c1.racdomain.com date && ssh oracle@oracle19c2.racdomain.com date

-- Step 133 -->> On Node 1
-- To Create a responce file for Oracle Software Installation
[oracle@oracle19c1 ~]$ cp /u01/app/oracle/product/19c/db_1/install/response/db_install.rsp /home/oracle/
[oracle@oracle19c1 ~]$ cd /home/oracle/

-- Step 133.1 -->> On Node 1
[oracle@oracle19c1 ~]$ ls -ltr
/*
-rwxr-xr-x 1 oracle oinstall 19932 Jun  7 13:14 db_install.rsp
*/

-- Step 133.2 -->> On Node 1
[oracle@oracle19c1 ~]$ vi db_install.rsp
/*
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
ORACLE_HOME=/u01/app/oracle/product/19c/db_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
ORACLE_HOSTNAME=oracle19c1.racdomain.com
SELECTED_LANGUAGES=en
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=backupdba
oracle.install.db.OSDGDBA_GROUP=dgdba
oracle.install.db.OSKMDBA_GROUP=kmdba
oracle.install.db.OSRACDBA_GROUP=racdba
oracle.install.db.rootconfig.executeRootScript=false
oracle.install.db.CLUSTER_NODES=oracle19c1,oracle19c2
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.ConfigureAsContainerDB=false
*/

-- Step 134 -->> On Node 1
-- To install Oracle Software with Letest Opatch
[oracle@oracle19c1 ~]$ cd /u01/app/oracle/product/19c/db_1/
[oracle@oracle19c1 db_1]$ export CV_ASSUME_DISTID=OEL7.6
[oracle@oracle19c1 db_1]$ ./runInstaller -ignorePrereq -waitforcompletion -silent \
-applyRU /tmp/36031453/35940989                                             \
-responseFile /home/oracle/db_install.rsp                                   \
oracle.install.db.isRACOneInstall=false                                     \
oracle.install.db.rac.serverpoolCardinality=0                               \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                  \
DECLINE_SECURITY_UPDATES=true                                               


/*
Preparing the home to patch...
Applying the patch /tmp/36031453/35940989...
Successfully applied the patch.
The log can be found at: /u01/app/oraInventory/logs/InstallActions2024-06-07_10-15-48PM/installerPatchActions_2024-06-07_10-15-48PM.log
Launching Oracle Database Setup Wizard...

The response file for this session can be found at:
 /u01/app/oracle/product/19c/db_1/install/response/db_2024-06-07_10-15-48PM.rsp

You can find the log of this install session at:
 /u01/app/oraInventory/logs/InstallActions2024-06-07_10-15-48PM/installActions2024-06-07_10-15-48PM.log

As a root user, execute the following script(s):
        1. /u01/app/oracle/product/19c/db_1/root.sh

Execute /u01/app/oracle/product/19c/db_1/root.sh on the following nodes:
[oracle19c1, oracle19c2]


Successfully Setup Software.
*/

-- Step 135 -->> On Node 1
[root@oracle19c1 ~]# /u01/app/oracle/product/19c/db_1/root.sh
/*
Check /u01/app/oracle/product/19c/db_1/install/root_oracle19c1.racdomain.com_2024-06-07_22-40-24-669754291.log for the output of root script
*/

-- Step 136.1 -->> On Node 1
[root@oracle19c1 ~]# tail -f /u01/app/oracle/product/19c/db_1/install/root_oracle19c1.racdomain.com_2024-06-07_22-40-24-669754291.log
/*
    ORACLE_OWNER= oracle
    ORACLE_HOME=  /u01/app/oracle/product/19c/db_1
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.

*/

-- Step 137 -->> On Node 2
[root@oracle19c2 ~]# /u01/app/oracle/product/19c/db_1/root.sh
/*
Check /u01/app/oracle/product/19c/db_1/install/root_oracle19c2.racdomain.com_2024-06-07_22-42-33-687986408.log for the output of root script
*/

-- Step 137.1 -->> On Node 2
[root@oracle19c2 ~]# tail -f /u01/app/oracle/product/19c/db_1/install/root_oracle19c2.racdomain.com_2024-06-07_22-42-33-687986408.log
/* 
     ORACLE_OWNER= oracle
    ORACLE_HOME=  /u01/app/oracle/product/19c/db_1
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.

*/

-- Step 138 -->> On Node 1
-- To applying the Oracle PSU on Node 1
[root@oracle19c1 ~]# cd /tmp/
[root@oracle19c1 tmp]$ export CV_ASSUME_DISTID=OEL7.6
[root@oracle19c1 tmp]# export ORACLE_HOME=/u01/app/oracle/product/19c/db_1
[root@oracle19c1 tmp]# export PATH=${ORACLE_HOME}/bin:$PATH
[root@oracle19c1 tmp]# export PATH=${PATH}:${ORACLE_HOME}/OPatch

-- Step 139.1 -->> On Node 1
[root@oracle19c1 tmp]# which opatchauto
/*
/u01/app/oracle/product/19c/db_1/OPatch/opatchauto
*/

-- Step 140 -->> On Node 1
[root@oracle19c1 tmp]# opatchauto apply /tmp/36031453/35926646 -oh /u01/app/oracle/product/19c/db_1 --nonrolling
/*
OPatchauto session is initiated at Fri Jun  7 23:02:46 2024

System initialization log file is /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/systemconfig2024-06-07_11-02-52PM.log.

Session log file is /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2024-06-07_11-03-14PM.log
The id for this session is 8P65

Executing OPatch prereq operations to verify patch applicability on home /u01/app/oracle/product/19c/db_1
Patch applicability verified successfully on home /u01/app/oracle/product/19c/db_1


Executing patch validation checks on home /u01/app/oracle/product/19c/db_1
Patch validation checks successfully completed on home /u01/app/oracle/product/19c/db_1


Verifying SQL patch applicability on home /u01/app/oracle/product/19c/db_1
No sqlpatch prereq operations are required on the local node for this home
No step execution required.........


Preparing to bring down database service on home /u01/app/oracle/product/19c/db_1
No step execution required.........


Bringing down database service on home /u01/app/oracle/product/19c/db_1
Database service successfully brought down on home /u01/app/oracle/product/19c/db_1


Performing prepatch operation on home /u01/app/oracle/product/19c/db_1
Prepatch operation completed successfully on home /u01/app/oracle/product/19c/db_1


Start applying binary patch on home /u01/app/oracle/product/19c/db_1
Binary patch applied successfully on home /u01/app/oracle/product/19c/db_1


Running rootadd_rdbms.sh on home /u01/app/oracle/product/19c/db_1
Successfully executed rootadd_rdbms.sh on home /u01/app/oracle/product/19c/db_1


Performing postpatch operation on home /u01/app/oracle/product/19c/db_1
Postpatch operation completed successfully on home /u01/app/oracle/product/19c/db_1


Starting database service on home /u01/app/oracle/product/19c/db_1
Database service successfully started on home /u01/app/oracle/product/19c/db_1


Preparing home /u01/app/oracle/product/19c/db_1 after database service restarted
No step execution required.........


Trying to apply SQL patch on home /u01/app/oracle/product/19c/db_1
No SQL patch operations are required on local node for this home

OPatchAuto successful.

--------------------------------Summary--------------------------------

Patching is completed successfully. Please find the summary as follows:

Host:oracle19c1
RAC Home:/u01/app/oracle/product/19c/db_1
Version:19.0.0.0.0
Summary:

==Following patches were SUCCESSFULLY applied:

Patch: /tmp/36031453/35926646
Log: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2024-06-07_23-04-27PM_1.log



OPatchauto session completed at Fri Jun  7 23:07:03 2024
Time taken to complete the session 4 minutes, 17 seconds
*/

-- Step 140.1 -->> On Node 1
[root@oracle19c1 ~]# tail -f /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2024-06-07_11-03-14PM.log
/*
2024-06-07 23:07:03,387 INFO  [1] com.oracle.glcm.patch.auto.db.framework.core.oplan.IOUtils - Change the permission of the file /u01/app/oracle/product/19c/db_1/opatchautocfg/db/sessioninfo/patchingsummary.xmlto 775
2024-06-07 23:07:03,388 INFO  [1] com.oracle.glcm.patch.auto.db.product.executor.GISystemCall - System Call command is: [/bin/su, oracle, -m, -c, chmod 775 /u01/app/oracle/product/19c/db_1/opatchautocfg/db/sessioninfo/patchingsummary.xml]
2024-06-07 23:07:03,405 INFO  [1] com.oracle.glcm.patch.auto.db.product.executor.GISystemCall - Output message:
2024-06-07 23:07:03,405 INFO  [1] com.oracle.glcm.patch.auto.db.product.executor.GISystemCall - Return code: 0
*/

-- Step 141 -->> On Node 1
[root@oracle19c1 ~]# scp -r /tmp/36031453/ root@oracle19c2:/tmp/

-- Step 142 -->> On Node 2
[root@oracle19c2 ~]# cd /tmp/
[root@oracle19c2 tmp]# chown -R oracle:oinstall 36031453
[root@oracle19c2 tmp]# chmod -R 775 36031453

-- Step 142.1 -->> On Node 2
[root@oracle19c2 tmp]# ls -ltr | grep 36031453
/*
drwxrwxr-x 4 oracle oinstall    57 Jun  7 23:15 36031453
*/

-- Step 143 -->> On Node 2
-- To applying the Oracle PSU on Remote Node 2
[root@oracle19c2 ~]# cd /tmp/
[root@oracle19c1 tmp]$ export CV_ASSUME_DISTID=OEL7.6
[root@oracle19c2 tmp]# export ORACLE_HOME=/u01/app/oracle/product/19c/db_1
[root@oracle19c2 tmp]# export PATH=${ORACLE_HOME}/bin:$PATH
[root@oracle19c2 tmp]# export PATH=${PATH}:${ORACLE_HOME}/OPatch

-- Step 143.1 -->> On Node 2
[root@oracle19c2 tmp]# which opatchauto
/*
/u01/app/oracle/product/19c/db_1/OPatch/opatchauto
*/

-- Step 144 -->> On Node 2
[root@oracle19c2 tmp]# opatchauto apply /tmp/36031453/35926646 -oh /u01/app/oracle/product/19c/db_1 --nonrolling
/*
OPatchauto session is initiated at Fri Jun  7 23:18:14 2024

System initialization log file is /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/systemconfig2024-06-07_11-18-25PM.log.

Session log file is /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2024-06-07_11-18-40PM.log
The id for this session is HM2I

Executing OPatch prereq operations to verify patch applicability on home /u01/app/oracle/product/19c/db_1
Patch applicability verified successfully on home /u01/app/oracle/product/19c/db_1


Executing patch validation checks on home /u01/app/oracle/product/19c/db_1
Patch validation checks successfully completed on home /u01/app/oracle/product/19c/db_1


Verifying SQL patch applicability on home /u01/app/oracle/product/19c/db_1
No sqlpatch prereq operations are required on the local node for this home
No step execution required.........


Preparing to bring down database service on home /u01/app/oracle/product/19c/db_1
No step execution required.........


Bringing down database service on home /u01/app/oracle/product/19c/db_1
Database service successfully brought down on home /u01/app/oracle/product/19c/db_1


Performing prepatch operation on home /u01/app/oracle/product/19c/db_1
Prepatch operation completed successfully on home /u01/app/oracle/product/19c/db_1


Start applying binary patch on home /u01/app/oracle/product/19c/db_1
Binary patch applied successfully on home /u01/app/oracle/product/19c/db_1


Running rootadd_rdbms.sh on home /u01/app/oracle/product/19c/db_1
Successfully executed rootadd_rdbms.sh on home /u01/app/oracle/product/19c/db_1


Performing postpatch operation on home /u01/app/oracle/product/19c/db_1
Postpatch operation completed successfully on home /u01/app/oracle/product/19c/db_1


Starting database service on home /u01/app/oracle/product/19c/db_1
Database service successfully started on home /u01/app/oracle/product/19c/db_1


Preparing home /u01/app/oracle/product/19c/db_1 after database service restarted
No step execution required.........


Trying to apply SQL patch on home /u01/app/oracle/product/19c/db_1
No SQL patch operations are required on local node for this home

OPatchAuto successful.

--------------------------------Summary--------------------------------

Patching is completed successfully. Please find the summary as follows:

Host:oracle19c2
RAC Home:/u01/app/oracle/product/19c/db_1
Version:19.0.0.0.0
Summary:

==Following patches were SUCCESSFULLY applied:

Patch: /tmp/36031453/35926646
Log: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2024-06-07_23-19-41PM_1.log



OPatchauto session completed at Fri Jun  7 23:23:04 2024
Time taken to complete the session 4 minutes, 50 seconds
*/


-- Step 144.1 -->> On Node 2
[root@oracle19c2 ~]# tail -f /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2024-06-07_11-18-40PM.log
/*
[2024-06-07 23:23:04,264 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting empty directory: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/driver/2024-06-07-23-18-26/machine-readable
2024-06-07 23:23:04,264 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting empty directory: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/driver/2024-06-07-23-18-26/.tmp
2024-06-07 23:23:04,265 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting empty directory: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/machine-readable
2024-06-07 23:23:04,266 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting zero-byte file: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/.tmp/null.tmp
2024-06-07 23:23:04,266 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting empty directory: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/.tmp
2024-06-07 23:23:04,266 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting zero-byte file: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/log.txt.lck
2024-06-07 23:23:04,266 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting zero-byte file: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/log.txt
2024-06-07 23:23:04,267 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting zero-byte file: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41/ApplyInstructions.txt
2024-06-07 23:23:04,267 INFO  [1] com.oracle.glcm.patch.auto.utils.LoggedOutputStream - Deleting empty directory: /u01/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/2024-06-07-23-18-41
*/

-- Step 145 -->> On Both Nodes
-- To Create a Oracle Database
[root@oracle19c1/oracle19c2 ~]# mkdir -p /u01/app/oracle/admin/racdb/adump
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/oracle/admin/
[root@oracle19c1/oracle19c2 ~]# chown -R oracle:oinstall racdb/
[root@oracle19c1/oracle19c2 ~]# chmod -R 775 racdb/

-- Step 146 -->> On Node 1
-- To prepare the responce file
[root@oracle19c1 ~]# su - oracle

-- Step 147 -->> On Node 1
[oracle@oracle19c1 db_1]$ cd /u01/app/oracle/product/19c/db_1/assistants/dbca
[oracle@oracle19c1 dbca]$ export CV_ASSUME_DISTID=OEL7.6
[oracle@oracle19c1 dbca]$ dbca -silent -createDatabase \
-templateName General_Purpose.dbc             \
-gdbname racdb -responseFile NO_VALUE         \
-characterSet AL32UTF8                        \
-sysPassword Adminrabin1                      \
-systemPassword Adminrabin1                   \
-createAsContainerDatabase true               \
-numberOfPDBs 1                               \
-pdbName racpdb                               \
-pdbAdminPassword Adminrabin1                 \
-databaseType MULTIPURPOSE                    \
-automaticMemoryManagement false              \
-totalMemory 1704                            \
-redoLogFileSize 50                           \
-emConfiguration NONE                         \
-ignorePreReqs                                \
-nodelist oracle19c1,oracle19c2               \
-storageType ASM                              \
-diskGroupName +DATA/{DB_UNIQUE_NAME}/        \
-recoveryGroupName +FRA                       \
-useOMF true                                  \
-asmsnmpPassword Adminrabin1

/*
[WARNING] [DBT-11209] Current available memory is less than the required available memory (2,800MB) for creating the database.
   CAUSE: Following nodes do not have required available memory :
 Node:oracle19c1                Available memory:1.9129GB (2005788.0KB)
Node:oracle19c2         Available memory:2.3736GB (2488876.0KB)

Prepare for db operation
7% complete
Copying database files
27% complete
Creating and starting Oracle instance
28% complete
31% complete
35% complete
37% complete
40% complete
Creating cluster database views
41% complete
53% complete
Completing Database Creation
57% complete
59% complete
60% complete
Creating Pluggable Databases
64% complete
80% complete
Executing Post Configuration Actions
100% complete
Database creation complete. For details check the logfiles at:
 /u01/app/oracle/cfgtoollogs/dbca/racdb.
Database Information:
Global Database Name:racdb
System Identifier(SID) Prefix:racdb
Look at the log file "/u01/app/oracle/cfgtoollogs/dbca/racdb/racdb.log" for further details.
*/


-- Step 147.1 -->> On Node 1
[oracle@oracle19c1 ~]$  tail -f /u01/app/oracle/cfgtoollogs/dbca/racdb/racdb.log
/*
[ 2024-06-07 23:47:03.084 NPT ] [WARNING] [DBT-11209] Current available memory is less than the required available memory (2,800MB) for creating the database.
[ 2024-06-07 23:47:06.927 NPT ] Prepare for db operation
DBCA_PROGRESS : 7%
[ 2024-06-07 23:47:25.398 NPT ] Copying database files
DBCA_PROGRESS : 27%
[ 2024-06-07 23:49:42.050 NPT ] Creating and starting Oracle instance
DBCA_PROGRESS : 28%
DBCA_PROGRESS : 31%
DBCA_PROGRESS : 35%
DBCA_PROGRESS : 37%
DBCA_PROGRESS : 40%
[ 2024-06-08 00:19:12.625 NPT ] Creating cluster database views
DBCA_PROGRESS : 41%
DBCA_PROGRESS : 53%
[ 2024-06-08 00:20:12.418 NPT ] Completing Database Creation
DBCA_PROGRESS : 57%
DBCA_PROGRESS : 59%
DBCA_PROGRESS : 60%
[ 2024-06-08 00:33:45.298 NPT ] Creating Pluggable Databases
DBCA_PROGRESS : 64%
DBCA_PROGRESS : 80%
[ 2024-06-08 00:36:22.633 NPT ] Executing Post Configuration Actions
DBCA_PROGRESS : 100%
[ 2024-06-08 00:36:22.674 NPT ] Database creation complete. For details check the logfiles at:
 /u01/app/oracle/cfgtoollogs/dbca/racdb.
Database Information:
Global Database Name:racdb
System Identifier(SID) Prefix:racdb
*/

-- Step 148 -->> On Node 1  
[oracle@oracle19c1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 13 14:12:27 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0

SQL> show con_name

CON_NAME
------------------------------
CDB$ROOT

SQL> alter pluggable database racpdb open;
SQL> alter pluggable database all open;
SQL> alter pluggable database racpdb save state;

SQL> show pdbs

       CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 RACPDB                         READ WRITE NO


SQL> SELECT status ,instance_name FROM gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb1
OPEN         racdb2

SQL> SELECT a.inst_id,b.status,b.instance_name,a.database_role,a.open_mode FROM gv$database a,gv$instance b where a.inst_id=b.inst_id;

      INST_ID STATUS       INSTANCE_NAME    DATABASE_ROLE    OPEN_MODE
---------- ------------ ---------------- ---------------- --------------------
         1 OPEN         racdb1           PRIMARY          READ WRITE
         2 OPEN         racdb2           PRIMARY          READ WRITE


SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0
*/

-- Step 149 -->> On Both Nodes 
[oracle@oracle19c1/oracle19c2 ~]$ srvctl config database -d racdb
/*
Database unique name: racdb
Database name: racdb
Oracle home: /u01/app/oracle/product/19c/db_1
Oracle user: oracle
Spfile: +DATA/RACDB/PARAMETERFILE/spfile.278.1171199957
Password file: +DATA/RACDB/PASSWORD/pwdracdb.256.1171197683
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools:
Disk Groups: FRA,DATA
Mount point paths:
Services:
Type: RAC
Start concurrency:
Stop concurrency:
OSDBA group: dba
OSOPER group: oper
Database instances: racdb1,racdb2
Configured nodes: oracle19c1,oracle19c2
CSS critical: no
CPU count: 0
Memory target: 0
Maximum memory: 0
Default network number for database services:
Database is administrator managed

*/

-- Step 150 -->> On Both Nodes 
[oracle@oracle19c1/oracle19c2 ~]$ srvctl status database -d racdb -v
/*
Instance racdb1 is running on node oracle19c1. Instance status: Open.
Instance racdb2 is running on node oracle19c2. Instance status: Open.

*/

-- Step 151 -->> On Both Nodes 
[oracle@oracle19c1/oracle19c2 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): oracle19c1,oracle19c2
*/

-- Step 152 -->> On Node 1 
[oracle@oracle19c1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 09-JUN-2024 14:51:04

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                09-JUN-2024 11:54:07
Uptime                    0 days 2 hr. 56 min. 57 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.61)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.63)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=oracle19c1.racdomain.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/db_1/admin/racdb/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "1a7121a0bbd478e0e0633e78a8c06a1d" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racpdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 153 -->> On Node 2 
[oracle@oracle19c2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 09-JUN-2024 14:51:51

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                09-JUN-2024 11:48:23
Uptime                    0 days 3 hr. 3 min. 28 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.62)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.64)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=oracle19c2.racdomain.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/db_1/admin/racdb/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "1a7121a0bbd478e0e0633e78a8c06a1d" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racpdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- To Fix the ADRCI log if occured in remote nodes
-- Step Fix.1 -->> On Node 2
[oracle@oracle19c1 ~]$ adrci
/*


ADRCI: Release 19.0.0.0.0 - Production on Sun Jun 9 14:56:23 2024

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

ADR base = "/u01/app/oracle"
adrci>

*/

-- Step Fix.2 -->> On Node 2
[oracle@oracle19c1 ~]$ ls -ltr /u01/app/oracle/product/19c/db_1/log/diag/
/*
-rw-r----- 1 oracle asmadmin 16 Jun  9 13:21 adrci_dir.mif
*/

-- Step Fix.3 -->> On Node 2
[oracle@oracle19c2 ~]$ cd /u01/app/oracle/product/19c/db_1/
[oracle@oracle19c2 db_1]$ mkdir -p log/diag
[oracle@oracle19c2 db_1]$ mkdir -p log/oracle19c2/client
[oracle@oracle19c2 db_1]$ cd log
[oracle@oracle19c2 db_1]$ chown -R oracle:asmadmin diag
-- Step Fix.4 -->> On Node 2
[oracle@oracle19c1 ~]$ scp -r /u01/app/oracle/product/19c/db_1/log/diag/adrci_dir.mif oracle@oracle19c2:/u01/app/oracle/product/19c/db_1/log/diag/
/*
adrci_dir.mif                                                                                                          100%   16    16.6KB/s   00:00
*/
-- Step Fix.5 -->> On Node 2
[oracle@oracle19c2 ~]$ adrci
/*


ADRCI: Release 19.0.0.0.0 - Production on Sun Jun 9 15:08:21 2024

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

ADR base = "/u01/app/oracle"

adrci> exit
*/

-- Step 154 -->> On Node 1
[root@oracle19c1 ~]# vi /etc/oratab
/*
+ASM1:/u01/app/19c/grid:N
racdb:/u01/app/oracle/product/19c/db_1:N
racdb1:/u01/app/oracle/product/19c/db_1:N
*/

-- Step 155 -->> On Node 2
[root@oracle19c2 ~]# vi /etc/oratab 
/*
+ASM2:/u01/app/19c/grid:N
racdb:/u01/app/oracle/product/19c/db_1:N
racdb2:/u01/app/oracle/product/19c/db_1:N
*/

-- Step 156 -->> On Node 1
[root@oracle19c1 ~]# vi /u01/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /u01/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle19c-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.61)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle19c-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racpdb)
     )
  )

*/

-- Step 157 -->> On Node 2
[root@oracle19c2 ~]# vi /u01/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /u01/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle19c-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.62)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle19c-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racpdb)
     )
  )



*/

-- Step 158 -->> On Both Node (If Required)
-- To run the oracle tools (Till 11gR2 - If Required)
-- To Connect lower version tools
-- 1. Copy the contains of /etc/hosts
-- 2. Past on host file of relevant PC C:\Windows\System32\drivers\etc\hosts
[root@oracle19c1/oracle19c2 ~]# vi /u01/app/19c/grid/network/admin/sqlnet.ora
/*
# sqlnet.ora.oracle19c1/PDB-DC-N2 Network Configuration File: /u01/app/19c/grid/network/admin/sqlnet.ora
# Generated by Oracle configuration tools.

NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)

SQLNET.ALLOWED_LOGON_VERSION_SERVER=8
SQLNET.ALLOWED_LOGON_VERSION_CLIENT=8
*/

-- Step 158.1 -->> On Both Node
[root@oracle19c1/oracle19c2 ~]# vi /u01/app/oracle/product/19c/db_1/network/admin/sqlnet.ora
/*
# sqlnet.ora.oracle19c1 Network Configuration File: /u01/app/oracle/product/19c/db_1/network/admin/sqlnet.ora
# Generated by Oracle configuration tools.

NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)

SQLNET.ALLOWED_LOGON_VERSION_SERVER=8
SQLNET.ALLOWED_LOGON_VERSION_CLIENT=8
*/

-- Step 158.2 -->> On Both Node
[oracle@oracle19c1/oracle19c2 ~]$ srvctl stop listener
[oracle@oracle19c1/oracle19c2 ~]$ srvctl start listener
[oracle@oracle19c1/oracle19c2 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): oracle19c2,oracle19c1
*/
-- Step 159 -->> On Node 1
[oracle@oracle19c1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 13 17:24:12 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0

SQL> ALTER USER sys IDENTIFIED BY "Adminrabin1";

User altered.

SQL> ALTER USER sys IDENTIFIED BY "Adminrabin1" container=all;

User altered.

SQL> show con_name

CON_NAME
------------------------------
CDB$ROOT
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 RACPDB                         READ WRITE NO
SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0
*/

-- Step 159.1 -->> On Node 1
[oracle@oracle19c1 ~]$ sqlplus sys/Adminrbin1@racdb as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 13 17:25:56 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0

SQL> show con_name

CON_NAME
------------------------------
CDB$ROOT
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 RACPDB                         READ WRITE NO
SQL> connect sys/Adminrabin1@racdb as sysdba
Connected.
SQL> show con_name

CON_NAME
------------------------------
racdb
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 RACPDB                         READ WRITE NO
SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0
*/

-- Step 160 -->> On Node 1
[root@oracle19c1 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c1 ~]# ./crsctl stop cluster -all
[root@oracle19c1 ~]# ./crsctl start cluster -all

-- Step 161 -->> On Node 1
[root@oracle19c1 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c1 ~]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.crf
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.crsd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.cssd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       oracle19c1                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.storage
      1        ONLINE  ONLINE       oracle19c1                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 162 -->> On Node 2
[root@oracle19c2 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c2 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       oracle19c2                     Started,STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.crf
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.crsd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.cssd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       oracle19c2                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.storage
      1        ONLINE  ONLINE       oracle19c2                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 163 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c1/oracle19c2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       oracle19c1                     STABLE
               ONLINE  ONLINE       oracle19c2                     STABLE
ora.chad
               ONLINE  ONLINE       oracle19c1                     STABLE
               ONLINE  ONLINE       oracle19c2                     STABLE
ora.net1.network
               ONLINE  ONLINE       oracle19c1                     STABLE
               ONLINE  ONLINE       oracle19c2                     STABLE
ora.ons
               ONLINE  ONLINE       oracle19c1                     STABLE
               ONLINE  ONLINE       oracle19c2                     STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ARC.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     STABLE
      2        ONLINE  ONLINE       oracle19c2                     STABLE
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     STABLE
      2        ONLINE  ONLINE       oracle19c2                     STABLE
ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     STABLE
      2        ONLINE  ONLINE       oracle19c2                     STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     STABLE
      2        ONLINE  ONLINE       oracle19c2                     STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     Started,STABLE
      2        ONLINE  ONLINE       oracle19c2                     Started,STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       oracle19c1                     STABLE
      2        ONLINE  ONLINE       oracle19c2                     STABLE
ora.cvu
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.oracle19c1.vip
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.oracle19c2.vip
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.pdbdb.db
      1        ONLINE  ONLINE       oracle19c1                     Open,HOME=/u01/app/oracle/product/19c/db_1,STABLE
      2        ONLINE  ONLINE       oracle19c2                     Open,HOME=/u01/app/oracle/product/19c/db_1,STABLE
ora.qosmserver
      1        ONLINE  ONLINE       oracle19c2                     STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       oracle19c1                     STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       oracle19c2                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 164 -->> On Both Nodes
[root@oracle19c1/oracle19c2 ~]# cd /u01/app/19c/grid/bin
[root@oracle19c1/oracle19c2 bin]# ./crsctl check cluster -all
/*
**************************************************************
oracle19c1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
oracle19c2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

-- Step 165 -->> On Both Nodes
-- ASM Verification
[root@oracle19c1/oracle19c2 ~]# su - grid
[grid@oracle19c1/oracle19c2 ~]$ asmcmd -p
/*
ASMCMD [+] > lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  1048576     25599    18697                0           18697              0             N  DATA/
MOUNTED  EXTERN  N         512             512   4096  1048576     12959    11676                0           11676              0             N  FRA/
MOUNTED  EXTERN  N         512             512   4096  4194304     10236     9884                0            9884              0             Y  OCR/
ASMCMD [+] > exit

*/

-- Step 166 -->> On Node 1
[grid@oracle19c1 ~]$ lsnrctl status
/*

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 10-JUN-2024 15:33:34

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                10-JUN-2024 15:23:11
Uptime                    0 days 0 hr. 10 min. 22 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.61)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.63)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=oracle19c1.racdomain.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/db_1/admin/racdb/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "1a7121a0bbd478e0e0633e78a8c06a1d" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racpdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 167 -->> On Node 2
[grid@oracle19c2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 10-JUN-2024 15:34:12

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                10-JUN-2024 15:25:40
Uptime                    0 days 0 hr. 8 min. 32 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.62)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.64)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=oracle19c2.racdomain.com)(PORT=5500))(Security=(my_wallet_directory=/u01/app/oracle/product/19c/db_1/admin/racdb/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "1a7121a0bbd478e0e0633e78a8c06a1d" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racpdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 168 -->> On Node 1
[grid@oracle19c1 ~]$ ps -ef | grep SCAN
/*
grid       20636       1  0 15:23 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN2 -no_crs_notify -inherit
grid       20654       1  0 15:23 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN3 -no_crs_notify -inherit
grid       91094   90017  0 15:34 pts/2    00:00:00 grep --color=auto SCAN

*/

-- Step 168.1 -->> On Node 1
[grid@oracle19c1 ~]$ lsnrctl status LISTENER_SCAN1
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 13-MAY-2024 17:40:49

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN1
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                13-MAY-2024 17:34:33
Uptime                    0 days 0 hr. 6 min. 16 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c1/listener_scan1/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.6.25)(PORT=1521)))
Services Summary...
Service "18528463b26d763ce063150610acac23" has 2 instance(s).
  Instance "pdbdb1", status READY, has 1 handler(s) for this service...
  Instance "pdbdb2", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 2 instance(s).
  Instance "pdbdb1", status READY, has 1 handler(s) for this service...
  Instance "pdbdb2", status READY, has 1 handler(s) for this service...
Service "racdb" has 2 instance(s).
  Instance "pdbdb1", status READY, has 1 handler(s) for this service...
  Instance "pdbdb2", status READY, has 1 handler(s) for this service...
Service "pdbdb" has 2 instance(s).
  Instance "pdbdb1", status READY, has 1 handler(s) for this service...
  Instance "pdbdb2", status READY, has 1 handler(s) for this service...
Service "pdbdbXDB" has 2 instance(s).
  Instance "pdbdb1", status READY, has 1 handler(s) for this service...
  Instance "pdbdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- Step 169 -->> On Node 2
[grid@oracle19c2 ~]$ ps -ef | grep SCAN
/*
grid        7668       1  0 15:25 ?        00:00:00 /u01/app/19c/grid/bin/tnslsnr LISTENER_SCAN1 -no_crs_notify -inherit
grid       19113   15527  0 15:41 pts/1    00:00:00 grep --color=auto SCAN

*/

-- Step 169.1 -->> On Node 2
[grid@oracle19c2 ~]$ lsnrctl status LISTENER_SCAN2
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 10-JUN-2024 15:42:24

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN1
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                10-JUN-2024 15:25:41
Uptime                    0 days 0 hr. 16 min. 43 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/19c/grid/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle19c2/listener_scan1/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.65)(PORT=1521)))
Services Summary...
Service "1a7121a0bbd478e0e0633e78a8c06a1d" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdb" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racpdb" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 170 -->> On Both Nodes
[grid@oracle19c1/oracle19c2 ~]$ sqlplus / as sysasm
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 13 17:45:19 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT inst_id,banner_full,banner_legacy,con_id FROM gv$version;

   CON_ID
---------- -------------------------------------------------------------------------------- -------------------------------------------------------------------------------- ----------
         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                     0
           Version 19.22.0.0.0

         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                     0
           Version 19.22.0.0.0



SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.22.0.0.0
*/

-- Step 171 -->> On Both Nodes
-- DB Service Verification
[root@oracle19c1/oracle19c2 ~]# su - oracle
[oracle@oracle19c1/oracle19c2 ~]$ srvctl status database -d racdb -v
/*
Instance racdb1 is running on node oracle19c1. Instance status: Open.
Instance racdb2 is running on node oracle19c2. Instance status: Open.
*/

-- Step 172 -->> On Both Nodes
-- Listener Service Verification
[oracle@oracle19c1/oracle19c2 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): oracle19c2,oracle19c1
*/

-- Step 173 -->> On Both Nodes
[oracle@oracle19c1/oracle19c2 ~]$ rman target sys/Adminrabin1@racdb
--OR--
[oracle@oracle19c1/oracle19c2 ~]$ rman target /
/*

Recovery Manager: Release 19.0.0.0.0 - Production on Mon Jun 10 17:08:29 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (DBID=1168814713)


RMAN> show all;

using target database control file instead of recovery catalog
RMAN configuration parameters for database with db_unique_name RACDB are:
CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
CONFIGURE BACKUP OPTIMIZATION OFF; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE MAXSETSIZE TO UNLIMITED; # default
CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19c/db_1/dbs/snapcf_racdb1.f'; # default

--Node 1
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19c/db_1/dbs/snapcf_racdb1.f'; # default
--Node 2
CCONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19c/db_1/dbs/snapcf_racdb2.f'; # default

RMAN> exit

Recovery Manager complete.
*/

-- Step 174 -->> On Both Nodes
[oracle@oracle19c1 ~]$ rman target sys/Adminrabin1@racdb
/*
Recovery Manager: Release 19.0.0.0.0 - Production on Mon May 13 17:48:40 2024
Version 19.22.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: PDBDB:racdb (DBID=138440536)

RMAN> show all;

using target database control file instead of recovery catalog
RMAN configuration parameters for database with db_unique_name PDBDB are:
CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
CONFIGURE BACKUP u01IMIZATION OFF; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE MAXSETSIZE TO UNLIMITED; # default
CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' u01IMIZE FOR LOAD TRUE ; # default
CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
--Node 1
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19c/db_1/dbs/snapcf_pdbdb1.f'; # default
--Node 2
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19c/db_1/dbs/snapcf_pdbdb2.f'; # default

RMAN> exit

Recovery Manager complete.
*/
-- Step 175 -->> On Both Nodes
-- To connnect CDB$ROOT using TNS
[oracle@oracle19c1/oracle19c2 ~]$ sqlplus sys/Adminrabin1@racdb as sysdba

-- Step 176 -->> On Node 1
[oracle@oracle19c1 ~]$ sqlplus sys/Adminrabin1@racdb1 as sysdba

-- Step 177 -->> On Node 2
[oracle@oracle19c2 ~]$ sqlplus sys/Adminrabin1@racdb2 as sysdba

-- Step 178 -->> On Both Nodes
-- To connnect PDB using TNS
[oracle@oracle19c1/oracle19c2 ~]$ sqlplus sys/Adminrabin1@racpdb as sysdba