----------------------------------------------------------------
-------------Two Node rac Setup on VM Workstation---------------
----------------------------------------------------------------
 --Openfiler  Configuring

[root@openfiler ~]# df -h
/*
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2             7.5G  1.4G  5.8G  20% /
tmpfs                 491M  204K  490M   1% /dev/shm
/dev/sda1             289M   23M  252M   9% /boot
*/
---- Step 1 -->> Configure the network
[root@openfiler ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.30
#IPADDR=10.0.1.13
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/ 
-- Step 2 -->> configure host 
[root@openfiler ~]# vi /etc/hosts
/*
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               openfiler.mydomain openfiler localhost.localdomain localhost openfiler
::1             localhost6.localdomain6 localhost6
# Public
192.168.120.31   rac1.mydomain        rac1
192.168.120.32   rac2.mydomain        rac2

# Private
10.0.1.11        rac1-priv.mydomain   rac1-priv
10.0.1.12        rac2-priv.mydomain   rac2-priv

# Virtual
192.168.120.33   rac1-vip.mydomain    rac1-vip
192.168.120.34   rac2-vip.mydomain    rac2-vip

# Openfiler (SAN/NAS Storage)
192.168.120.30  openfiler.mydomain   openfiler

# SCAN
192.168.120.35   rac-scan.mydomain    rac-scan
192.168.120.36   rac-scan.mydomain    rac-scan
192.168.120.37   rac-scan.mydomain    rac-scan
*/
-- Step 3 -->> On Openfiler (SAN/NAS Storage)

[root@openfiler ~]# service network restart
/*
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:                                [  OK  ]

/*

-- Step 4 -->> On Openfiler (SAN/NAS Storage)
-- disabling the firewall.

[root@openfiler ~]# chkconfig --list iptables
/*
iptables  0:off    1:off    2:on    3:on    4:on    5:on    6:off
*/
[root@openfiler ~]# service iptables stop
/*
iptables: Setting chains to policy ACCEPT: nat mangle filte[  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@openfiler ~]# chkconfig iptables off
[root@openfiler ~]# iptables -F
[root@openfiler ~]# service iptables save
/*
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
*/
[root@openfiler ~]# /etc/init.d/iptables stop
/*
iptables: Setting chains to policy ACCEPT: filter          [  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@openfiler ~]# iptables -L
/*
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
*/

[root@openfiler ~]# chkconfig --list iptables
/*
iptables   0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/ 

-- Step 5 -->> On Openfiler (SAN/NAS Storage)
-- ntpd disable
[root@openfiler ~]# service ntpd stop
/*
Shutting down ntpd:                                        [FAILED]
*/

[root@openfiler ~]# service ntpd status
/*
ntpd is stopped
*/

[root@openfiler ~]# chkconfig ntpd off
[root@openfiler ~]# mv /etc/ntp.conf /etc/ntp.conf.backup
[root@openfiler ~]# rm -rf  /etc/ntp.conf
[root@openfiler ~]# rm -rf  /var/run/ntpd.pid

-- Step 6 -->> On Openfiler Restart Operfile host.
[root@openfiler ~]# init 6


-- 2 Node rac on VM -->> On both Node
[root@rac1/rac2 ~]# df -Th
/*
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             1.8G     0  1.8G   0% /dev
tmpfs                1.8G     0  1.8G   0% /dev/shm
tmpfs                1.8G  8.8M  1.8G   1% /run
tmpfs                1.8G     0  1.8G   0% /sys/fs/cgroup
/dev/mapper/ol-root   25G   83M   25G   1% /
/dev/mapper/ol-usr    10G  2.8G  7.3G  28% /usr
/dev/sda1           1014M  251M  764M  25% /boot
/dev/mapper/ol-home   10G   33M   10G   1% /home
/dev/mapper/ol-opt    30G   33M   30G   1% /opt
/dev/mapper/ol-tmp   6.0G   33M  6.0G   1% /tmp
/dev/mapper/ol-var    10G  986M  9.1G  10% /var
tmpfs                367M     0  367M   0% /run/user/0

*/

-- Step 1 -->> On both Node
[root@rac1/rac2 ~]# vi /etc/hosts
/*
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               openfiler.mydomain openfiler localhost.localdomain localhost openfiler
::1             localhost6.localdomain6 localhost6
# Public
192.168.120.31   rac1.mydomain        rac1
192.168.120.32   rac2.mydomain        rac2

# Private
10.0.1.11        rac1-priv.mydomain   rac1-priv
10.0.1.12        rac2-priv.mydomain   rac2-priv

# Virtual
192.168.120.33   rac1-vip.mydomain    rac1-vip
192.168.120.34   rac2-vip.mydomain    rac2-vip

# Openfiler (SAN/NAS Storage)
192.168.120.30  openfiler.mydomain   openfiler

# SCAN
192.168.120.35   rac-scan.mydomain    rac-scan
192.168.120.36   rac-scan.mydomain    rac-scan
192.168.120.37   rac-scan.mydomain    rac-scan
*/


-- Step 2 -->> On both Node
-- Disable secure linux by editing the "/etc/selinux/config" file, making sure the SELINUX flag is set as follows.
[root@rac1/rac2 ~]# vi /etc/selinux/config
/*
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
#SELINUX=enforcing
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
*/

-- Step 3 -->> On Node 1
[root@rac1 network-scripts ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=rac1.mydomain
*/

-- Step 4 -->> On Node 2
[root@rac2 network-scripts ~]# vi /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=rac2.mydomain
*/
-- Step 5 -->> On Node 1
[root@rac1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens33 
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=ens33
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.31
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 6 -->> On Node 1
[root@rac1 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens34
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=ens34
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.11
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 7 -->> On Node 2
[root@rac2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens33
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=ens33
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.32
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no

*/

-- Step 8 -->> On Node 2
[root@rac2 ~]# vi /etc/sysconfig/network-scripts/ifcfg-ens34
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=ens34
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=10.0.1.12
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
*/

-- Step 9 -->> On Both Node
[root@rac1/rac2 network-scripts]# service network restart
[root@rac1/rac2 network-scripts]# service NetworkManager stop
[root@rac1/rac2 network-scripts]# service network restart

-- Step 10 -->> On Node 1
[root@rac1 ~]# hostnamectl set-hostname rac1.mydomain
[root@rac1 ~]# hostnamectl
/*
   [root@rac1 ~]# hostnamectl set-hostname rac1.mydomain
[root@rac1 ~]# hostnamectl
   Static hostname: rac1.mydomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 53f14e69ebc34ccda18aaec15d069af2
           Boot ID: 11b1ba15db3144069379eaa27cde7980
    Virtualization: vmware
  Operating System: Oracle Linux Server 7.9
       CPE OS Name: cpe:/o:oracle:linux:7:9:server
            Kernel: Linux 4.14.35-2047.527.2.el7uek.x86_64
      Architecture: x86-64

*/
-- Step 11 -->> On Node 2
[root@rac2 ~]# hostnamectl set-hostname rac2.mydomain
[root@rac2 ~]# hostnamectl
/*
   
[root@rac1 ~]# hostnamectl
   Static hostname: rac2.mydomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 53f14e69ebc34ccda18aaec15d069af2
           Boot ID: 7c3eb2cffada4d91810a9a6999bd3b41
    Virtualization: vmware
  Operating System: Oracle Linux Server 7.9
       CPE OS Name: cpe:/o:oracle:linux:7:9:server
            Kernel: Linux 4.14.35-2047.527.2.el7uek.x86_64
      Architecture: x86-64

*/


-- Step 12  -->> On Both Node
[root@rac1/rac2 network-scripts]# systemctl stop firewalld
[root@rac1/rac2 network-scripts]# systemctl disable firewalld
/*
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
*/

-- Step 13 -->> On Both Node
[root@rac1/rac2 ~]# systemctl stop ntpd
[root@rac1/rac2 ~]# systemctl disable ntpd

[root@rac1/rac2 ~]# cd /etc/
[root@rac1/rac2 etc]# mv /etc/ntp.conf /etc/ntp.conf.backup
[root@rac1/rac2 etc]# ls | grep ntp

[root@rac1/rac2 ~]# rm -rf /etc/ntp.conf
[root@rac1/rac2 ~]# rm -rf /var/run/ntpd.pid

-- Step 14 -->> On Both Node
[root@rac1/rac2]# iptables -F
[root@rac1/rac2]# iptables -X
[root@rac1/rac2]# iptables -t nat -F
[root@rac1/rac2]# iptables -t nat -X
[root@rac1/rac2]# iptables -t mangle -F
[root@rac1/rac2]# iptables -t mangle -X
[root@rac1/rac2]# iptables -P INPUT ACCEPT
[root@rac1/rac2]# iptables -P FORWARD ACCEPT
[root@rac1/rac2]# iptables -P OUTPUT ACCEPT
[root@rac1/rac2]# iptables -L -nv
/*
Chain INPUT (policy ACCEPT 4 packets, 272 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 3 packets, 280 bytes)
 pkts bytes target     prot opt in     out     source               destination
*/
-- Step 15 -->> On Both Node
[root@rac1/rac2 ~ ]# systemctl stop named
[root@rac1/rac2 ~ ]# systemctl disable named

-- Step 16 -->> On Both Node
-- Enable chronyd service." `date`
[root@rac1/rac2 ~ ]# systemctl enable chronyd
[root@rac1/rac2 ~ ]# systemctl restart chronyd
[root@rac1/rac2 ~ ]# chronyc -a 'burst 4/4'
/*
200 OK
*/
[root@rac1/rac2 ~ ]# chronyc -a makestep
/*
200 OK
*/

[root@rac1 ~]# systemctl status chronyd
/*
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2023-07-15 03:30:57 EDT; 46s ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
  Process: 3186 ExecStartPost=/usr/libexec/chrony-helper update-daemon (code=exited, status=0/SUCCESS)
  Process: 3181 ExecStart=/usr/sbin/chronyd $OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 3184 (chronyd)
   CGroup: /system.slice/chronyd.service
           └─3184 /usr/sbin/chronyd

Jul 15 03:30:57 rac1.mydomain systemd[1]: Stopped NTP client/server.
Jul 15 03:30:57 rac1.mydomain systemd[1]: Starting NTP client/server...
Jul 15 03:30:57 rac1.mydomain chronyd[3184]: chronyd version 3.4 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +SECHASH +IPV6 +DEBUG)
Jul 15 03:30:57 rac1.mydomain chronyd[3184]: Frequency 0.277 +/- 0.546 ppm read from /var/lib/chrony/drift
Jul 15 03:30:57 rac1.mydomain systemd[1]: Started NTP client/server.
Jul 15 03:31:02 rac1.mydomain chronyd[3184]: Selected source 162.159.200.1
Jul 15 03:31:24 rac1.mydomain chronyd[3184]: System clock was stepped by 0.000077 seconds
*/


-- Step 17 -->> On Both Node
[root@rac1 run]# cat /proc/sys/dev/cdrom/info
/*
CD-ROM information, Id: cdrom.c 3.20 2003/12/17

drive name:             sr0
drive speed:            1
drive # of slots:       1
Can close tray:         1
Can open tray:          1
Can lock tray:          1
Can change speed:       1
Can select disk:        0
Can read multisession:  1
Can read MCN:           1
Reports media changed:  1
Can play audio:         1
Can write CD-R:         1
Can write CD-RW:        1
Can read DVD:           1
Can write DVD-R:        1
Can write DVD-RAM:      1
Can read MRW:           1
Can write MRW:          1
Can write RAM:          1
*/

[root@rac1/rac2 ~]# mkdir -p /media/cdrom
[root@rac1/rac2 ~]# mount /dev/sr0 /media/cdrom
/*
mount: /dev/sr0 is write-protected, mounting read-only
*/
[root@rac1/rac2 ~]# cd /media/cdrom/Packages
[root@rac1/rac2 Packages]# yum install -y bind
[root@rac1/rac2 Packages]# yum install -y dnsmasq
[root@rac1/rac2 ~]# systemctl enable dnsmasq
/*
Created symlink from /etc/systemd/system/multi-user.target.wants/dnsmasq.service to /usr/lib/systemd/system/dnsmasq.service.
*/

[root@rac1/rac2 ~]# systemctl restart dnsmasq
[root@rac1/rac2 ~]# vi /etc/dnsmasq.conf
/*
listen-address=::1,127.0.0.1

#Add the following Lines
except-interface=virbr0
bind-interfaces
*/

[root@rac1/rac2 ~]# systemctl restart dnsmasq
[root@rac1/rac2 ~]# systemctl restart network
[root@rac1/rac2 ~]# systemctl status dnsmasq
/*
● dnsmasq.service - DNS caching server.
   Loaded: loaded (/usr/lib/systemd/system/dnsmasq.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2023-07-15 03:49:34 EDT; 26s ago
 Main PID: 3316 (dnsmasq)
   CGroup: /system.slice/dnsmasq.service
           └─3316 /usr/sbin/dnsmasq -k

Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: listening on lo(#1): 127.0.0.1
Jul 15 03:49:34 rac1.mydomain systemd[1]: Started DNS caching server..
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: listening on lo(#1): ::1
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: started, version 2.76 cachesize 150
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: compile time options: IPv6 GNU-getopt DBus no-i18n IDN DHCP DHCPv6 no-Lua TFTP no-conntrack ipset auth nettlehash no-DNSSEC loop-detect inotify
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: reading /etc/resolv.conf
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: using nameserver 8.8.8.8#53
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: using nameserver 8.8.4.4#53
Jul 15 03:49:34 rac1.mydomain dnsmasq[3316]: read /etc/hosts - 12 addresses

*/

-- Step 18 -->> On Both Node
[root@rac1/rac2 ~]# init 6

-- Step 19 -->> On Both Node
[root@rac1/rac2 ~]# firewall-cmd --list-all
/*
FirewallD is not running
*/
[root@rac1/rac2 ~]# systemctl status firewalld
/*
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

*/

- Step 20 -->> On Both Node

[root@rac1 ~]# systemctl status chronyd
/*
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2023-07-15 03:55:05 EDT; 4min 37s ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
  Process: 1018 ExecStartPost=/usr/libexec/chrony-helper update-daemon (code=exited, status=0/SUCCESS)
  Process: 974 ExecStart=/usr/sbin/chronyd $OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 1013 (chronyd)
   CGroup: /system.slice/chronyd.service
           └─1013 /usr/sbin/chronyd

Jul 15 03:55:05 rac1.mydomain systemd[1]: Starting NTP client/server...
Jul 15 03:55:05 rac1.mydomain chronyd[1013]: chronyd version 3.4 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +SECHASH +IPV6 +DEBUG)
Jul 15 03:55:05 rac1.mydomain chronyd[1013]: Frequency 0.682 +/- 0.611 ppm read from /var/lib/chrony/drift
Jul 15 03:55:05 rac1.mydomain systemd[1]: Started NTP client/server.
Jul 15 03:55:10 rac1.mydomain chronyd[1013]: Selected source 162.159.200.123
/*
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
*/

--Step 21 -->> On Both Node
[root@rac2 ~]# systemctl status dnsmasq
/*
● dnsmasq.service - DNS caching server.
   Loaded: loaded (/usr/lib/systemd/system/dnsmasq.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2023-07-15 03:55:06 EDT; 7min ago
 Main PID: 1289 (dnsmasq)
   CGroup: /system.slice/dnsmasq.service
           └─1289 /usr/sbin/dnsmasq -k

Jul 15 03:55:06 rac1.mydomain systemd[1]: Started DNS caching server..
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: listening on lo(#1): 127.0.0.1
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: listening on lo(#1): ::1
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: started, version 2.76 cachesize 150
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: compile time options: IPv6 GNU-getopt DBus no-i18n IDN DHCP DHCPv6 no-Lua TFTP no-conntrack ipset auth nettlehash no-DNSSEC loop-detect inotify
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: reading /etc/resolv.conf
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: using nameserver 8.8.8.8#53
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: using nameserver 8.8.4.4#53
Jul 15 03:55:06 rac1.mydomain dnsmasq[1289]: read /etc/hosts - 12 addresses
*/


-- Step 22 -->> On Both Node
-- Perform either the Automatic Setup or the Manual Setup to complete the basic prerequisites. 

[root@rac1/rac2 ~]#  cd /media/cdrom/Packages/
/*
[root@rac1/rac2 Packages]# yum update

[root@rac1/rac2 Packages]# yum install -y yum-utils
[root@rac1/rac2 Packages]# yum install -y oracle-epel-release-el7
[root@rac1/rac2 Packages]# yum-config-manager --enable ol7_developer_EPEL
[root@rac1/rac2 Packages]# yum install -y sshpass zip unzip
[root@rac1/rac2 Packages]# yum install -y oracle-database-preinstall-19c

[root@rac1/rac2 Packages]# yum install -y bc    
[root@rac1/rac2 Packages]# yum install -y binutils
[root@rac1/rac2 Packages]# yum install -y compat-libcap1
[root@rac1/rac2 Packages]# yum install -y compat-libstdc++-33
[root@rac1/rac2 Packages]# yum install -y dtrace-utils
[root@rac1/rac2 Packages]# yum install -y elfutils-libelf
[root@rac1/rac2 Packages]# yum install -y elfutils-libelf-devel
[root@rac1/rac2 Packages]# yum install -y fontconfig-devel
[root@rac1/rac2 Packages]# yum install -y glibc
[root@rac1/rac2 Packages]# yum install -y glibc-devel
[root@rac1/rac2 Packages]# yum install -y ksh
[root@rac1/rac2 Packages]# yum install -y libaio
[root@rac1/rac2 Packages]# yum install -y libaio-devel
[root@rac1/rac2 Packages]# yum install -y libdtrace-ctf-devel
[root@rac1/rac2 Packages]# yum install -y libXrender
[root@rac1/rac2 Packages]# yum install -y libXrender-devel
[root@rac1/rac2 Packages]# yum install -y libX11
[root@rac1/rac2 Packages]# yum install -y libXau
[root@rac1/rac2 Packages]# yum install -y libXi
[root@rac1/rac2 Packages]# yum install -y libXtst
[root@rac1/rac2 Packages]# yum install -y libgcc
[root@rac1/rac2 Packages]# yum install -y librdmacm-devel
[root@rac1/rac2 Packages]# yum install -y libstdc++
[root@rac1/rac2 Packages]# yum install -y libstdc++-devel
[root@rac1/rac2 Packages]# yum install -y libxcb
[root@rac1/rac2 Packages]# yum install -y make
[root@rac1/rac2 Packages]# yum install -y net-tools
[root@rac1/rac2 Packages]# yum install -y nfs-utils
[root@rac1/rac2 Packages]# yum install -y python
[root@rac1/rac2 Packages]# yum install -y python-configshell
[root@rac1/rac2 Packages]# yum install -y python-rtslib
[root@rac1/rac2 Packages]# yum install -y python-six
[root@rac1/rac2 Packages]# yum install -y targetcli
[root@rac1/rac2 Packages]# yum install -y smartmontools
[root@rac1/rac2 Packages]# yum install -y sysstat
[root@rac1/rac2 Packages]# yum install -y unixODBC
[root@rac1/rac2 Packages]# yum install -y chrony
[root@rac1/rac2 Packages]# rpm -iUvh glibc-2*i686* nss-softokn-freebl-3*i686*
[root@rac1/rac2 Packages]# rpm -iUvh glibc-devel-2*i686*
[root@rac1/rac2 Packages]# rpm -iUvh libaio-0*i686*
[root@rac1/rac2 Packages]# rpm -iUvh libaio-devel-0*i686*
[root@rac1/rac2 Packages]# rpm -iUvh numactl-devel-2*x86_64*
[root@rac1/rac2 Packages]# rpm -iUvh libtool-ltdl*i686*
[root@rac1/rac2 Packages]# yum install -y oracleasm*
[root@rac1/rac2 Packages]# yum -y update
*/


-- Step 23 -->> On Both Node
--https://yum.oracle.com/repo/OracleLinux/OL7/8/base/x86_64/index.html
[root@rac1/rac2 ~]# cd /root/OracleLinux7_8_RPM/
[root@rac1/rac2 OracleLinux7_8_RPM]# rpm -iUvh compat-libcap1-1.10-7.el7.i686.rpm
[root@rac1/rac2 OracleLinux7_8_RPM]# rpm -iUvh glibc-utils-2.17-307.0.1.el7.1.x86_64.rpm
[root@rac1/rac2 OracleLinux7_8_RPM]# rpm -iUvh ncurses-devel-5.9-14.20130511.el7_4.x86_64.rpm
[root@rac1/rac2 OracleLinux7_8_RPM]# rpm -iUvh unixODBC-devel-2.3.1-14.0.1.el7.x86_64.rpm
[root@rac1/rac2 OracleLinux7_8_RPM]# rpm -iUvh oracleasmlib-2.0.12-1.el7.x86_64.rpm


-- Step 24 -->> On Both Node
[root@rac1/rac2 ~]# cd /media/cdrom/Packages/
[root@rac1/rac2 Packages]# yum install compat-libcap1 compat-libstdc++-33 bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libgcc libnsl librdmacm-devel libstdc++ libstdc++-devel libX11 libXau libxcb libXi libXrender libXrender-devel libXtst make net-tools nfs-utils python3 python3-configshell python3-rtslib python3-six smartmontools sysstat targetcli unzip
[root@rac1/rac2 Packages]# yum -y update

-- Step 25 -->> On Both Node
[root@rac1/rac2 Packages]# rpm -q binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static \
[root@rac1/rac2 Packages]# rpm -q gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers kernel-headers ksh libaio libaio-devel \
[root@rac1/rac2 Packages]# rpm -q libgcc libgomp libstdc++ libstdc++-devel make numactl-devel sysstat unixODBC unixODBC-devel \

-- Step 26 -->> On Both Node
-- Pre-Installation Steps for ASM
[root@rac1/rac2 ~ ]# cd /etc/yum.repos.d
[root@rac1/rac2 yum.repos.d]# uname -ras
/*
Linux rac1.mydomain 4.14.35-2047.527.2.el7uek.x86_64 #2 SMP Fri Jun 16 12:22:53 PDT 2023 x86_64 x86_64 x86_64 GNU/Linux
*/

[root@rac1 yum.repos.d]# cat /etc/os-release
/*
NAME="Oracle Linux Server"
VERSION="7.9"
ID="ol"
ID_LIKE="fedora"
VARIANT="Server"
VARIANT_ID="server"
VERSION_ID="7.9"
PRETTY_NAME="Oracle Linux Server 7.9"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:oracle:linux:7:9:server"
HOME_URL="https://linux.oracle.com/"
BUG_REPORT_URL="https://github.com/oracle/oracle-linux"

ORACLE_BUGZILLA_PRODUCT="Oracle Linux 7"
ORACLE_BUGZILLA_PRODUCT_VERSION=7.9
ORACLE_SUPPORT_PRODUCT="Oracle Linux"
ORACLE_SUPPORT_PRODUCT_VERSION=7.9
*/

[root@rac1/rac2 yum.repos.d]# yum install kmod-oracleasm
[root@rac1/rac2 yum.repos.d]# yum install oracleasm-support

[root@rac1/rac2 yum.repos.d]# rpm -qa | grep oracleasm
/*
oracleasm-support-2.1.11-2.el7.x86_64
kmod-oracleasm-2.0.8-28.0.1.el7.x86_64
oracleasmlib-2.0.12-1.el7.x86_64

*/


-- Step 20 -->> On Both Node
[root@rac1/rac2 yum.repos.d]# wget https://public-yum.oracle.com/public-yum-ol6.repo
/*
--2019-09-02 13:50:54--  https://public-yum.oracle.com/public-yum-ol6.repo
Resolving public-yum.oracle.com... 104.84.157.171
Connecting to public-yum.oracle.com|104.84.157.171|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 12045 (12K) [text/plain]
Saving to: “public-yum-ol6.repo.2”

100%[======================================>] 12,045      --.-K/s   in 0s      

2019-09-02 13:50:55 (95.3 MB/s) - “public-yum-ol6.repo” saved [12045/12045]
*/

-- Step 21 -->> On Both Node
[root@rac1/rac2 yum.repos.d]# yum install kmod-oracleasm
[root@rac1/rac2 yum.repos.d]# yum install oracleasm-support

-- Step 22 -->> On Both Node
[root@rac1/rac2 ~]# cd /mnt/hgfs/Oracle Linux/Oracle_Linux_6_Rpm/
[root@rac1/rac2 Oracle_Linux_6_Rpm]# rpm -iUvh oracleasmlib-2.0.4-1.el6.x86_64.rpm
[root@rac1/rac2 yum.repos.d]# rpm -qa | grep oracleasm
/*
oracleasm-support-2.1.11-2.el7.x86_64
kmod-oracleasm-2.0.8-28.0.1.el7.x86_64
oracleasmlib-2.0.12-1.el7.x86_64

*/

[root@rac1/rac2 ~]# cd /media/OL6.4\ x86_64\ Disc\ 1\ 20130225/Server/Packages/
[root@rac1/rac2 Packages]# yum update

-- Step 23 -->> On Both Node
-- Add the kernel parameters file "/etc/sysctl.conf" and add oracle recommended kernel parameters
[root@rac1/rac2 ~]# vi /etc/sysctl.conf
/*
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 65536
kernel.shmall = 4294967296
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

-- Run the following command to change the current kernel parameters.
[root@rac1/rac2 ~]# sysctl -p /etc/sysctl.conf
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
--or--
[root@rac1/rac2 ~]# /sbin/sysctl -p

-- Step 24 -->> On Both Node
-- Edit “/etc/security/limits.conf” file to limit user processes
[root@rac1/rac2 ~]# vi /etc/security/limits.conf
/*
oracle   soft   nofile  1024
oracle   hard   nofile  65536
oracle   soft   nproc   16384
oracle   hard   nproc   16384
oracle   soft   stack   10240
oracle   hard   stack   32768
oracle   hard   memlock 134217728
oracle   soft   memlock 134217728

grid    soft    nofile   1024
grid    hard    nofile   65536
grid    soft    nproc    16384
grid    hard    nproc    16384
grid    soft    stack    10240
grid    hard    stack    32768
grid    soft    memlock  134217728
grid    hard    memlock  134217728
*/

-- Step 25 -->> On Both Node
-- Add the following line to the "/etc/pam.d/login" file, if it does not already exist.
[root@rac1/rac2 ~]# vi /etc/pam.d/login
/*
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
-session    optional    pam_ck_connector.so
session    required     pam_limits.so
*/

-- Step 26 -->> On both Node
-- Create the new groups and users.
[root@rac1/rac2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:
*/
[root@rac1/rac2 ~]# cat /etc/group | grep -i dba
/*
dba:x:54322:
*/

[root@rac1/rac2 !]# cat /etc/group | grep -i asm

-- 1.Create OS groups using the command below. Enter these commands as the 'root' user:
[root@rac1/rac2 ~]# /usr/sbin/groupadd -g 503 oper
[root@rac1/rac2 ~]# /usr/sbin/groupadd -g 504 asmadmin
[root@rac1/rac2 ~]# /usr/sbin/groupadd -g 506 asmdba
[root@rac1/rac2 ~]# /usr/sbin/groupadd -g 507 asmoper
[root@rac1/rac2 ~]# /usr/sbin/groupadd -g 508 beoper

-- 2.Create the users that will own the Oracle software using the commands:
[root@rac1/rac2 ~]# /usr/sbin/useradd -g oinstall -G oinstall,dba,asmadmin,asmdba,asmoper,beoper grid	
[root@rac1/rac2 ~]# /usr/sbin/usermod -g oinstall -G oinstall,dba,oper,asmadmin,asmdba oracle

[root@rac1/rac2 ~]# cat /etc/group | grep -i oinstall
/*
oinstall:x:54321:grid,oracle
*/
[root@rac1/rac2 ~]# cat /etc/group | grep -i asm
/*
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
*/
[root@rac1/rac2 ~]# cat /etc/group | grep -i oracle
/*
oracle:x:500:
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
oper:x:503:oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
*/
[root@rac1/rac2 ~]# cat /etc/group | grep -i grid
/*
oinstall:x:54321:grid,oracle
dba:x:54322:grid,oracle
asmadmin:x:504:grid,oracle
asmdba:x:506:grid,oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

[root@rac1/rac2 ~]# cat /etc/group | grep -i oper
/*
oper:x:503:oracle
asmoper:x:507:grid
beoper:x:508:grid
*/

-- Step 27 -->> On both Node
[root@rac1/rac2 ~]# passwd oracle
/*
Changing password for user oracle.
New password: 
BAD PASSWORD: it is based on a dictionary word
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/

-- Step 28 -->> On both Node
[root@rac1/rac2 ~]# passwd grid
/*
Changing password for user grid.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
*/

-- Step 29 -->> On both Node
[root@rac1/rac2 ~]# su - oracle
[oracle@rac1/rac2 ~]$ su - grid
[grid@rac1/rac2 ~]$ su - root

-- Step 43 -->> On both Node
--Create the Oracle Inventory Director:
[root@rac1/rac2 ~]# mkdir -p /opt/app/oraInventory
[root@rac1/rac2 ~]# chown -R grid:oinstall /opt/app/oraInventory
[root@rac1/rac2 ~]# chmod -R 775 /opt/app/oraInventory

-- Step 44 -->> On both Node
--Creating the Oracle Grid Infrastructure Home Directory:
[root@rac1/rac2 ~]# mkdir -p /opt/app/19c/grid
[root@rac1/rac2 ~]# chown -R grid:oinstall /opt/app/19c/grid
[root@rac1/rac2 ~]# chmod -R 775 /opt/app/19c/grid

-- Step 45 -->> On both Node
--Creating the Oracle Base Directory
[root@rac1/rac2 ~]# mkdir -p /opt/app/oracle
[root@rac1/rac2 ~]# chmod -R 775 /opt/app/oracle
[root@rac1/rac2 ~]# cd /opt/app/
[root@rac1/rac2 ~]# chown -R oracle:oinstall /opt/app/oracle

-- Step 46 -->> On Node 1
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@rac1 ~]# su - oracle
[oracle@rac1 ~]$ vi .bash_profile
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

ORACLE_HOSTNAME=rac1.mydomain; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/19c/db_1; export ORACLE_HOME
ORACLE_SID=racdb1; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 47 -->> On Node 1
[oracle@rac1 ~]$ . .bash_profile

-- Step 48 -->> On Node 1
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@rac1 ~]# su - grid
[grid@rac1 ~]$ vi .bash_profile
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
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
GRID_HOME=/opt/app/19c/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 49 -->> On Node 1
[grid@rac1 ~]$ . .bash_profile

-- Step 50 -->> On Node 2
-- Login as the oracle user and add the following lines at the end of the ".bash_profile" file.
[root@rac2 ~]# su - oracle
[oracle@rac2 ~]$ vi .bash_profile
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

ORACLE_HOSTNAME=rac2.mydomain; export ORACLE_HOSTNAME
ORACLE_UNQNAME=racdb; export ORACLE_UNQNAME
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/19c/db_1; export ORACLE_HOME
ORACLE_SID=racdb2; export ORACLE_SID

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 51 -->> On Node 2
[oracle@rac2 ~]$ . .bash_profile

-- Step 52 -->> On Node 2
-- Login as the grid user and add the following lines at the end of the ".bash_profile" file.
[root@rac2 ~]# su - grid
[grid@rac2 ~]$ vi .bash_profile
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
ORACLE_BASE=/opt/app/oracle; export ORACLE_BASE
GRID_HOME=/opt/app/19c/grid; export GRID_HOME
ORACLE_HOME=$GRID_HOME; export ORACLE_HOME

PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
*/

-- Step 53 -->> On Node 2
[grid@rac2 ~]$ . .bash_profile

-- Step 54 -->> On Node 1
-- To Unzio The Oracle Grid Software and lateset Opatch
[root@rac1 ~]# cd /opt/app/19c/grid/
[root@rac1 grid]#  unzip -oq /root/ORACLE_SOFTWARE_19C/LINUX.X64_193000_grid_home.zip
[root@rac1 grid]# unzip -oq /root/ORACLE_SOFTWARE_19C/p6880880_190000_Linux-x86-64.zip

-- Step 55 -->> On Node 1
-- To Unzio The Oracle PSU
[root@rac1 ~]# cd /tmp/
[root@rac1 tmp]#  unzip -oq /root/ORACLE_SOFTWARE_19C/p35319490_190000_Linux-x86-64.zip
[root@rac1 tmp]# chown -R oracle:oinstall 35319490
[root@rac2 tmp]# chmod -R 775 35319490
[root@rac1 tmp]# ls -ltr | grep 35319490
/*
drwxrwxr-x 5 oracle oinstall      81 Apr  6 11:25 35319490
*/

-- Step 56 -->> On Node 1
-- Login as root user and issue the following command at rac1
[root@rac1 ~]# chown -R grid:oinstall /opt/app/19c/grid/
[root@rac1 ~]# chmod -R 775 /opt/app/19c/grid/

-- Step 57 -->> On Node 1
[root@rac1 ~]# scp -r /opt/app/19c/grid/cv/rpm/cvuqdisk-1.0.10-1.rpm root@rac2:/tmp/
/*
The authenticity of host 'rac2 (192.168.120.32)' can't be established.
ECDSA key fingerprint is SHA256:NcqmET25YXmLQNG+rUrY6o1IIfIgJl8vujxztOkorXo.
ECDSA key fingerprint is MD5:65:fe:1c:cb:00:a0:bf:80:dc:c4:96:a5:72:0b:86:92.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'rac2,192.168.120.32' (ECDSA) to the list of known hosts.
root@rac2's password:
cvuqdisk-1.0.10-1.rpm                                                             100%   11KB   6.1MB/s   00:00

*/

-- Step 58 -->> On Node 1
-- To install the cvuqdisk-1.0.10-1.rpm
-- Login from root user
[root@rac1 ~]# cd /opt/app/19c/grid/cv/rpm/
[root@rac1 rpm]# ls -ltr
/*
-rwxrwxr-x 1 grid oinstall 11412 Mar 13  2019 cvuqdisk-1.0.10-1.rpm
*/

[root@rac1 rpm]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
[root@rac1 rpm]# rpm -iUvh cvuqdisk-1.0.10-1.rpm 
/*
Preparing...                          ################################# [100%]
Updating / installing...
   1:cvuqdisk-1.0.10-1                ################################# [100%]
*/

-- Step 59 -->> On Node 2
[root@rac2 ~]# cd /tmp/
[root@rac2 tmp]# chown -R grid:oinstall cvuqdisk-1.0.10-1.rpm
[root@rac2 tmp]# chmod -R 775 cvuqdisk-1.0.10-1.rpm
[root@rac2 tmp]# ls -ltr | grep cvuqdisk-1.0.10-1.rpm
/*
-rwxrwxr-x 1 grid oinstall 11412 Sep  9 22:54 cvuqdisk-1.0.10-1.rpm
*/

-- Step 60 -->> On Node 2
-- To install the cvuqdisk-1.0.10-1.rpm
-- Login from root user
[root@rac2 ~]# cd /tmp/
[root@rac2 tmp]# CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
[root@rac2 tmp]# rpm -iUvh cvuqdisk-1.0.10-1.rpm 
/*
Preparing...                          ################################# [100%]
Updating / installing...
   1:cvuqdisk-1.0.10-1                ################################# [100%]
*/

-- Step 61 -->> On all Node
[root@rac1/rac2 ~]# which oracleasm
/*
/usr/sbin/oracleasm
*/

-- Step 62 -->> On all Node
[root@rac1/rac2 ~]# oracleasm configure
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
[root@rac1/rac2 ~]# oracleasm status
/*
Checking if ASM is loaded: no
Checking if /dev/oracleasm is mounted: no
*/

-- Step 64 -->> On all Node
[root@rac1/rac2 ~]# oracleasm configure -i
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
[root@rac1/rac2 ~]# oracleasm configure
/*
OracLEASM_ENABLED=true
OracLEASM_UID=grid
OracLEASM_GID=asmadmin
OracLEASM_SCANBOOT=true
OracLEASM_SCANORDER=""
OracLEASM_SCANEXCLUDE=""
OracLEASM_SCAN_DIRECTORIES=""
OracLEASM_USE_LOGICAL_BLOCK_SIZE="false"
*/

-- Step 66 -->> On all Node
[root@rac1/rac2 ~]# oracleasm init
/*
Creating /dev/oracleasm mount point: /dev/oracleasm
Loading module "oracleasm": oracleasm
Configuring "oracleasm" to use device physical block size
Mounting ASMlib driver filesystem: /dev/oracleasm
*/

-- Step 67 -->> On all Node
[root@rac1/rac2 ~]# oracleasm status
/*
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes
*/

-- Step 68 -->> On all Node
[root@rac1/rac2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 69 -->> On all Node
[root@rac1/rac2 ~]# oracleasm listdisks

[root@rac1/rac2 ~]# ls -ltr /etc/init.d/
/*
-rwxr-xr-x  1 root root  4954 Feb  3  2018 oracleasm
-rwxr-xr-x. 1 root root  2437 Feb  6  2018 rhnsd
-rwxr-xr-x. 1 root root  4569 May 22  2020 netconsole
-rw-r--r--. 1 root root 18281 May 22  2020 functions
-rwx------  1 root root  1281 Apr  1  2021 oracle-database-preinstall-19c-firstboot
-rwxr-xr-x. 1 root root  9198 Apr 26  2022 network
-rw-r--r--. 1 root root  1160 Dec  7  2022 README

*/

-- Step 70 -->> On Both Node
[root@rac1/rac2 ~]# ls -ltr /dev/oracleasm/disks/
/*
total 0
*/
--Step 71
[root@rac1/rac2 ~]# rpm -qa | grep -i iscsi
iscsi-initiator-utils-iscsiuio-6.2.0.874-22.0.1.el7_9.x86_64
iscsi-initiator-utils-6.2.0.874-22.0.1.el7_9.x86_64

[root@rac1/rac2 ~]#  yum install scsi-target-utils
[root@rac1/rac2 ~]#  yum install iscsi-initiator-utils

[root@rac1/rac2 ~]# service iscsi start
[root@rac1/rac2 ~]# chkconfig iscsi on

-- Step 72 -->> On all Nodes
[root@RAC1/RAC2 ~]# service iscsi stop
/*
Stopping iscsi:                                            [  OK  ]
*/

-- Step 73 -->> On all Nodes
[root@rac1/rac2 ~]# service iscsi status
/*
iscsi is stopped
*/

-- Step 74 -->> On all Nodes
[root@rac1/rac2 ~]# cd /etc/iscsi/
[root@rac1/rac2 iscsi]# ls
/*
initiatorname.iscsi  iscsid.conf
*/

-- Step 75 -->> On all Nodes
[root@rac1 iscsi]# vi initiatorname.iscsi 
/*
InitiatorName=iqn.rac1:oracle
*/

[root@rac2 iscsi]# vi initiatorname.iscsi 
/*
InitiatorName=iqn.rac2:oracle
*/

-- Step 76 -->> On all Nodes 
[root@rac1/rac2 iscsi]# service iscsi start
[root@rac1/rac2 iscsi]# systemctl enable iscsi.service
[root@rac1/rac2 iscsi]# chkconfig iscsid on
/*
Created symlink from /etc/systemd/system/multi-user.target.wants/iscsid.service to /usr/lib/systemd/system/iscsid.service.
*/

-- Step 78 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda
 
*/

-- Step 79 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# iscsiadm -m discovery -t sendtargets -p openfiler
/*
192.168.120.30:3260,1 iqn.openfiler:fra1
192.168.120.30:3260,1 iqn.openfiler:data1
192.168.120.30:3260,1 iqn.openfiler:ocr


*/

-- Step 80 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0 
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda 
*/

-- Step 81 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# ls /var/lib/iscsi/send_targets/
/*
openfiler,3260
*/

-- Step 82 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# ls /var/lib/iscsi/nodes/
/*
iqn.openfiler:data1  iqn.openfiler:fra1  iqn.openfiler:ocr
*/

-- Step 83 -->> On all Nodes 
[root@RAC1/RAC2 iscsi]# systemctl restart iscsi.service
/*
Stopping iscsi:                                            [  OK  ]
Starting iscsi:                                            [  OK  ]
*/

-- Step 84 -->> On all Nodes 


[root@rac1/rac2 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda
[3:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc
[5:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdd
 
*/

-- Step 85 -->> On all Nodes 
[root@rac1/rac2 iscsi]# iscsiadm -m session
/*
tcp: [1] 192.168.120.30:3260,1 iqn.openfiler:fra1 (non-flash)
tcp: [2] 192.168.120.30:3260,1 iqn.openfiler:data1 (non-flash)
tcp: [3] 192.168.120.30:3260,1 iqn.openfiler:ocr (non-flash)

*/

-- Step 86 -->> On Node 1
[root@rac1 iscsi]# iscsiadm -m node -T iqn.openfiler:ocr -p 192.168.120.30 --op update -n node.startup -v automatic
[root@rac1 iscsi]# iscsiadm -m node -T iqn.openfiler:data1 -p 192.168.120.30 --op update -n node.startup -v automatic
[root@rac1 iscsi]# iscsiadm -m node -T iqn.openfiler:fra1 -p 192.168.120.30 --op update -n node.startup -v automatic

-- Step 87 -->> On Node 1
[root@rac1 iscsi]# lsscsi
/*
[1:0:0:0]    cd/dvd  NECVMWar VMware IDE CDR10 1.00  /dev/sr0
[2:0:0:0]    disk    VMware,  VMware Virtual S 1.0   /dev/sda
[3:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdb
[4:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdc
[5:0:0:0]    disk    OPNFILER VIRTUAL-DISK     0     /dev/sdd

*/

-- Step 88 -->> On Node 1
[root@rac1 iscsi]# ls /dev/sd*
/*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb  /dev/sdc  /dev/sdd
*/

-- Step 89 -->> On Node 1
[root@rac1/rac2 iscsi]# iscsiadm -m session -P 3 > scsi_drives.txt
[root@rac1/rac2 iscsi]# vi scsi_drives.txt 
[root@rac1/rac2 iscsi]# cat scsi_drives.txt 
/*
# iscsiadm -m session -P 3

Target: iqn.openfiler:fra1 (non-flash)
                        Attached scsi disk sdb          State: running
Target: iqn.openfiler:data1 (non-flash)
                        Attached scsi disk sdc          State: running
Target: iqn.openfiler:ocr (non-flash)
                        Attached scsi disk sdd          State: running
*/

-- Step 90 -->> On Both Node
[root@rac1/rac2 ~]# ls -ltr /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Sep 28 01:12 /dev/sda
brw-rw---- 1 root disk 8,  1 Sep 28 01:12 /dev/sda1
brw-rw---- 1 root disk 8,  2 Sep 28 01:12 /dev/sda2
brw-rw---- 1 root disk 8, 32 Sep 28 02:03 /dev/sdc
brw-rw---- 1 root disk 8, 48 Sep 28 02:03 /dev/sdd
brw-rw---- 1 root disk 8, 16 Sep 28 02:03 /dev/sdb
*/

-- Step 91 -->> On Node 1
[root@rac1 ~]# fdisk -ll

/*
Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x00016903

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   8e  Linux LVM

Disk /dev/mapper/ol-root: 26.8 GB, 26843545600 bytes, 52428800 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-swap: 8589 MB, 8589934592 bytes, 16777216 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-usr: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-opt: 32.2 GB, 32212254720 bytes, 62914560 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-var: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-home: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-tmp: 6434 MB, 6434062336 bytes, 12566528 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 26.2 GB, 26239565824 bytes, 51249152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

*/

-- Step 92 -->> On Node 1
[root@rac1 ~]# fdisk /dev/sdb
/*
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x62e8780f.

Command (m for help): p

Disk /dev/sdb: 26.2 GB, 26239565824 bytes, 51249152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x62e8780f

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-51249151, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-51249151, default 51249151):
Using default value 51249151
Partition 1 of type Linux and of size 24.4 GiB is set

Command (m for help): p

Disk /dev/sdb: 26.2 GB, 26239565824 bytes, 51249152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x62e8780f

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    51249151    25623552   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

*/

-- Step 93 -->> On Node 1
[root@rac1 ~]# fdisk  /dev/sdc
/*
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x09efc1ab.

Command (m for help): p

Disk /dev/sdc: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x09efc1ab

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-83886079, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-83886079, default 83886079):
Using default value 83886079
Partition 1 of type Linux and of size 40 GiB is set

Command (m for help): p

Disk /dev/sdc: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x09efc1ab

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048    83886079    41942016   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

*/

-- Step 94 -->> On Node 1
[root@rac1 ~]# fdisk /dev/sdd
/*
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x1361a1ae.

Command (m for help): p

Disk /dev/sdd: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x1361a1ae

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039):
Using default value 41943039
Partition 1 of type Linux and of size 20 GiB is set

Command (m for help): p

Disk /dev/sdd: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x1361a1ae

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1            2048    41943039    20970496   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
*/

-- Step 95 -->> On Node 1
[root@rac1 ~]# ls -ltr /dev/sd*
/*
brw-rw---- 1 root disk 8,  0 Sep 28 01:12 /dev/sda
brw-rw---- 1 root disk 8,  1 Sep 28 01:12 /dev/sda1
brw-rw---- 1 root disk 8,  2 Sep 28 01:12 /dev/sda2
brw-rw---- 1 root disk 8, 16 Sep 28 03:32 /dev/sdb
brw-rw---- 1 root disk 8, 17 Sep 28 03:32 /dev/sdb1
brw-rw---- 1 root disk 8, 32 Sep 28 03:33 /dev/sdc
brw-rw---- 1 root disk 8, 33 Sep 28 03:33 /dev/sdc1
brw-rw---- 1 root disk 8, 48 Sep 28 03:35 /dev/sdd
brw-rw---- 1 root disk 8, 49 Sep 28 03:35 /dev/sdd1
*/

-- Step 96 -->> On Both Node
[root@rac1/rac2 ~]# fdisk -ll
/*

Disk /dev/sda: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x00016903

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   8e  Linux LVM

Disk /dev/mapper/ol-root: 26.8 GB, 26843545600 bytes, 52428800 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-swap: 8589 MB, 8589934592 bytes, 16777216 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-usr: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-opt: 32.2 GB, 32212254720 bytes, 62914560 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-var: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-home: 10.7 GB, 10737418240 bytes, 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ol-tmp: 6434 MB, 6434062336 bytes, 12566528 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 26.2 GB, 26239565824 bytes, 51249152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x62e8780f

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    51249151    25623552   83  Linux

Disk /dev/sdc: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x09efc1ab

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048    83886079    41942016   83  Linux

Disk /dev/sdd: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x1361a1ae

   Device Boot      Start         End      Blocks   Id  System
/dev/sdd1            2048    41943039    20970496   83  Linux

*/

-- Step 97 -->> On Node 1
[root@rac1 ~]# mkfs.xfs /dev/sdb1
[root@rac1 ~]# mkfs.xfs /dev/sdc1
[root@rac1 ~]# mkfs.xfs /dev/sdd1

or 

[root@rac1 ~]# mkfs.ext4 /dev/sdb1
[root@rac1 ~]# mkfs.ext4 /dev/sdc1
[root@rac1 ~]# mkfs.ext4 /dev/sdd1

-- Step 98 -->> On Node 1
[root@rac1 ~]# oracleasm createdisk OCR /dev/sdd1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 99 -->> On Node 1
[root@rac1 ~]# oracleasm createdisk DATA /dev/sdb1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 100 -->> On Node 1
[root@rac1 ~]# oracleasm createdisk FRA /dev/sdc1
/*
Writing disk header: done
Instantiating disk: done
*/

-- Step 101 -->> On Node 1
[root@rac1 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
*/

-- Step 102 -->> On Node 1
[root@rac1 ~]# oracleasm listdisks
/*
FRA
DATA
OCR
*/

-- Step 103 -->> On Node 2
[root@rac2 ~]# oracleasm scandisks
/*
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
Instantiating disk "OCR"
Instantiating disk "FRA"
Instantiating disk "DATA"
*/

-- Step 104 -->> On Node 2
[root@rac2 ~]# oracleasm listdisks
/*
ARC
DATA
OCR
*/

-- Step 105 -->> On Both Node
[root@rac1/rac2 ~]# ls -ltr /dev/oracleasm/disks/
/*
brw-rw---- 1 grid asmadmin 8, 49 Sep 28 03:51 OCR
brw-rw---- 1 grid asmadmin 8, 17 Sep 28 03:51 DATA
brw-rw---- 1 grid asmadmin 8, 33 Sep 28 03:52 FRA
*/

-- Step 106 -->> On Node 1
-- To setup SSH Pass
[root@rac1 ~]# su - grid
[grid@rac1 ~]$ cd /opt/app/19c/grid/deinstall
[grid@rac1 deinstall]$ ./sshUserSetup.sh -user grid -hosts "rac1 rac2" -noPromptPassphrase -confirm -advanced

-- Step 107 -->> On Node 1
[grid@rac1/rac2 ~]$ ssh grid@rac1 date
[grid@rac1/rac2 ~]$ ssh grid@rac2 date
[grid@rac1/rac2 ~]$ ssh grid@rac1 date && ssh grid@rac2 date
[grid@rac1/rac2 ~]$ ssh grid@rac1.mydomain date
[grid@rac1/rac2 ~]$ ssh grid@rac2.mydomain date
[grid@rac1/rac2 ~]$ ssh grid@rac1.mydomain date && ssh grid@rac2.mydomain date
tmpfs 12G 0 12G 0% /dev/shm
-- Step 107 -->> On Node 1
-- Pre-check for rac Setup
[grid@rac1 ~]$ cd /opt/app/19c/grid/
[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -verbose 
[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -method root
--[grid@rac1 grid]$ ./runcluvfy.sh stage -pre crsinst -n rac1,rac2 -fixup -verbose (If Required)

-- Step 108 -->> On Node 1
-- To Create a Response File to Install GID
[grid@rac1 ~]$ cp /opt/app/19c/grid/install/response/gridsetup.rsp /home/grid/
[grid@rac1 ~]$ cd /home/grid/
[grid@rac1 ~]$ ls -ltr | grep gridsetup.rsp
/*
-rwxr-xr-x 1 grid oinstall 36221 Sep 17 12:35 gridsetup.rsp
*/
[root@rac1 grid]# vim gridsetup.rsp
/*
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v19.0.0
INVENTORY_LOCATION=/opt/app/oraInventory
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/opt/app/oracle
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=asmoper
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.scanType=LOCAL_SCAN
oracle.install.crs.config.gpnp.scanName=rac-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.ClusterConfiguration=STANDALONE
oracle.install.crs.config.configureAsExtendedCluster=false
oracle.install.crs.config.clusterName=rac-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=rac1:rac1-vip,rac2:rac2-vip
oracle.install.crs.config.networkInterfaceList=ens33:192.168.120.0:1,ens34:10.0.1.0:5
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

-- Step 109 -->> On Node 1
-- To Install Grid Software with Leteset Opatch
[grid@rac1 ~]$ cd /opt/app/19c/grid/
[grid@rac1 grid]$ ./gridSetup.sh -ignorePrereq -waitForCompletion -silent -applyRU /tmp/35319490/35320081 -responseFile /home/grid/gridsetup.rsp
/*
[grid@rac1 grid]$ ./gridSetup.sh -ignorePrereq -waitForCompletion -silent -applyRU /tmp/35319490/35320081 -responseFile /home/grid/gridsetup.rsp
Preparing the home to patch...
Applying the patch /tmp/35319490/35320081...
Successfully applied the patch.
The log can be found at: /opt/app/oraInventory/logs/GridSetupActions2023-09-29_07-28-59AM/installerPatchActions_2023-09-29_07-28-59AM.log
Launching Oracle Grid Infrastructure Setup Wizard...

[WARNING] [INS-40109] The specified Oracle Base location is not empty on this server.
   ACTION: Specify an empty location for Oracle Base.
[WARNING] [INS-13013] Target environment does not meet some mandatory requirements.
   CAUSE: Some of the mandatory prerequisites are not met. See logs for details. /opt/app/oraInventory/logs/GridSetupActions2023-09-29_07-28-59AM/gridSetupActions2023-09-29_07-28-59AM.log
   ACTION: Identify the list of failed prerequisite checks from the log: /opt/app/oraInventory/logs/GridSetupActions2023-09-29_07-28-59AM/gridSetupActions2023-09-29_07-28-59AM.log. Then either from the log file or from installation manual find the appropriate configuration to meet the prerequisites and fix it manually.
The response file for this session can be found at:
 /opt/app/19c/grid/install/response/grid_2023-09-29_07-28-59AM.rsp

You can find the log of this install session at:
 /opt/app/oraInventory/logs/GridSetupActions2023-09-29_07-28-59AM/gridSetupActions2023-09-29_07-28-59AM.log

As a root user, execute the following script(s):
        1.  /opt/app/oraInventory/orainstRoot.sh
		2. /opt/app/19c/grid/root.sh

Execute /opt/app/19c/grid/root.sh on the following nodes:
[rac1, rac2]

Run the script on the local node first. After successful completion, you can start the script in parallel on all other nodes.

Successfully Setup Software with warning(s).
As install user, execute the following command to complete the configuration.
        /opt/app/19c/grid/gridSetup.sh -executeConfigTools -responseFile /home/grid/gridsetup.rsp [-silent]


*/

-- Step 110 -->> On Node 1
[root@rac1 ~]# /opt/app/oraInventory/orainstRoot.sh
/*
Changing permissions of /opt/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /opt/app/oraInventory to oinstall.
The execution of the script is complete.
*/

-- Step 111 -->> On Node 2
[root@rac2 ~]# /opt/app/oraInventory/orainstRoot.sh
/*
Changing permissions of /opt/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.

Changing groupname of /opt/app/oraInventory to oinstall.
The execution of the script is complete.
*/

-- Step 112 -->> On Node 1
[root@rac1 ~]# /opt/app/19c/grid/root.sh
/*
Check /opt/app/19c/grid/install/root_rac1.mydomain_2020-09-20_12-45-52-422635885.log for the output of root script
*/

[root@rac1 ~]# tail -f /opt/app/19c/grid/install/root_rac1.mydomain_2020-09-20_12-45-52-422635885.log
/*
[root@rac1 ~]# tail -f /opt/app/19c/grid/install/root_rac1.mydomain_2023-09-29_07-42-57-922043745.log
    ORACLE_HOME=  /opt/app/19c/grid
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Relinking oracle with rac_on option
Using configuration parameter file: /opt/app/19c/grid/crs/install/crsconfig_params
The log of current session can be found at:
  /opt/app/oracle/crsdata/rac1/crsconfig/rootcrs_rac1_2023-09-29_07-43-31AM.log
2023/09/29 07:43:52 CLSRSC-594: Executing installation step 1 of 19: 'SetupTFA'.
2023/09/29 07:43:52 CLSRSC-594: Executing installation step 2 of 19: 'ValidateEnv'.
2023/09/29 07:43:52 CLSRSC-363: User ignored prerequisites during installation
2023/09/29 07:43:52 CLSRSC-594: Executing installation step 3 of 19: 'CheckFirstNode'.
2023/09/29 07:43:54 CLSRSC-594: Executing installation step 4 of 19: 'GenSiteGUIDs'.
2023/09/29 07:43:54 CLSRSC-594: Executing installation step 5 of 19: 'SetupOSD'.
2023/09/29 07:43:54 CLSRSC-594: Executing installation step 6 of 19: 'CheckCRSConfig'.
2023/09/29 07:43:57 CLSRSC-594: Executing installation step 7 of 19: 'SetupLocalGPNP'.
2023/09/29 07:44:10 CLSRSC-594: Executing installation step 8 of 19: 'CreateRootCert'.
2023/09/29 07:44:28 CLSRSC-594: Executing installation step 9 of 19: 'ConfigOLR'.
2023/09/29 07:45:07 CLSRSC-594: Executing installation step 10 of 19: 'ConfigCHMOS'.
2023/09/29 07:45:08 CLSRSC-594: Executing installation step 11 of 19: 'CreateOHASD'.
2023/09/29 07:45:47 CLSRSC-594: Executing installation step 12 of 19: 'ConfigOHASD'.
2023/09/29 07:45:47 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
2023/09/29 07:46:13 CLSRSC-594: Executing installation step 13 of 19: 'InstallAFD'.
2023/09/29 07:46:15 CLSRSC-594: Executing installation step 14 of 19: 'InstallACFS'.
2023/09/29 07:46:18 CLSRSC-594: Executing installation step 15 of 19: 'InstallKA'.
2023/09/29 07:46:21 CLSRSC-594: Executing installation step 16 of 19: 'InitConfig'.

ASM has been created and started successfully.

[DBT-30001] Disk groups created successfully. Check /opt/app/oracle/cfgtoollogs/asmca/asmca-230929AM074655.log for details.

2023/09/29 07:47:56 CLSRSC-482: Running command: '/opt/app/19c/grid/bin/ocrconfig -upgrade grid oinstall'
CRS-4256: Updating the profile
Successful addition of voting disk 155f5e630f814f4ebf78ded3a46ba12c.
Successfully replaced voting disk group with +OCR.
CRS-4256: Updating the profile
CRS-4266: Voting file(s) successfully replaced
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   155f5e630f814f4ebf78ded3a46ba12c (/dev/oracleasm/disks/OCR) [OCR]
Located 1 voting disk(s).
2023/09/29 07:48:24 CLSRSC-4002: Successfully installed Oracle Trace File Analyzer (TFA) Collector.
2023/09/29 07:48:55 CLSRSC-594: Executing installation step 17 of 19: 'StartCluster'.
2023/09/29 07:49:54 CLSRSC-343: Successfully started Oracle Clusterware stack
2023/09/29 07:49:54 CLSRSC-594: Executing installation step 18 of 19: 'ConfigNode'.
2023/09/29 07:51:08 CLSRSC-594: Executing installation step 19 of 19: 'PostConfig'.
2023/09/29 07:51:35 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded
*/

-- Step 113 -->> On Node 2
[root@rac2 ~]# /opt/app/19c/grid/root.sh
/*
Check /opt/app/19c/grid/install/root_rac2.mydomain_2023-09-29_07-52-28-233110609.log for the output of root script
*/

[root@rac2 ~]# tail -f /opt/app/19c/grid/install/root_rac2.mydomain_2023-09-29_07-52-28-233110609.log
/*
Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Relinking oracle with rac_on option
Using configuration parameter file: /opt/app/19c/grid/crs/install/crsconfig_params
The log of current session can be found at:
  /opt/app/oracle/crsdata/rac2/crsconfig/rootcrs_rac2_2023-09-29_07-54-01AM.log
2023/09/29 07:54:45 CLSRSC-594: Executing installation step 1 of 19: 'SetupTFA'.
2023/09/29 07:54:45 CLSRSC-594: Executing installation step 2 of 19: 'ValidateEnv'.
2023/09/29 07:54:45 CLSRSC-363: User ignored prerequisites during installation
2023/09/29 07:54:45 CLSRSC-594: Executing installation step 3 of 19: 'CheckFirstNode'.
2023/09/29 07:54:46 CLSRSC-594: Executing installation step 4 of 19: 'GenSiteGUIDs'.
2023/09/29 07:54:46 CLSRSC-594: Executing installation step 5 of 19: 'SetupOSD'.
2023/09/29 07:54:46 CLSRSC-594: Executing installation step 6 of 19: 'CheckCRSConfig'.
2023/09/29 07:54:49 CLSRSC-594: Executing installation step 7 of 19: 'SetupLocalGPNP'.
2023/09/29 07:54:50 CLSRSC-594: Executing installation step 8 of 19: 'CreateRootCert'.
2023/09/29 07:54:50 CLSRSC-594: Executing installation step 9 of 19: 'ConfigOLR'.
2023/09/29 07:55:36 CLSRSC-594: Executing installation step 10 of 19: 'ConfigCHMOS'.
2023/09/29 07:55:36 CLSRSC-594: Executing installation step 11 of 19: 'CreateOHASD'.
2023/09/29 07:55:40 CLSRSC-594: Executing installation step 12 of 19: 'ConfigOHASD'.
2023/09/29 07:55:41 CLSRSC-330: Adding Clusterware entries to file 'oracle-ohasd.service'
2023/09/29 07:56:32 CLSRSC-594: Executing installation step 13 of 19: 'InstallAFD'.
2023/09/29 07:56:34 CLSRSC-594: Executing installation step 14 of 19: 'InstallACFS'.
2023/09/29 07:56:36 CLSRSC-594: Executing installation step 15 of 19: 'InstallKA'.
2023/09/29 07:56:38 CLSRSC-594: Executing installation step 16 of 19: 'InitConfig'.
2023/09/29 07:56:56 CLSRSC-594: Executing installation step 17 of 19: 'StartCluster'.
2023/09/29 07:57:46 CLSRSC-343: Successfully started Oracle Clusterware stack
2023/09/29 07:57:46 CLSRSC-594: Executing installation step 18 of 19: 'ConfigNode'.
2023/09/29 07:58:48 CLSRSC-594: Executing installation step 19 of 19: 'PostConfig'.
2023/09/29 07:59:19 CLSRSC-325: Configure Oracle Grid Infrastructure for a Cluster ... succeeded
2023/09/29 07:59:33 CLSRSC-4002: Successfully installed Oracle Trace File Analyzer (TFA) Collector.
*/

-- Step 114 -->> On Node 1
[grid@rac1 ~]$ cd /opt/app/19c/grid/
[grid@rac1 grid]$ /opt/app/19c/grid/gridSetup.sh -silent -executeConfigTools -responseFile /home/grid/gridsetup.rsp
/*
Launching Oracle Grid Infrastructure Setup Wizard...

You can find the logs of this session at:
/opt/app/oraInventory/logs/GridSetupActions2023-09-29_08-02-55AM

You can find the log of this install session at:
 /opt/app/oraInventory/logs/UpdateNodeList2023-09-29_08-02-55AM.log

Successfully Configured Software.
*/

[root@rac1 ~]# tail -f  /opt/app/oraInventory/logs/UpdateNodeList2023-09-29_08-02-55AM.log
/*
INFO: All threads completed its operations
INFO: Checkpoint:Index file written and updated
INFO: Done calling doOperation.
INFO: 'UpdateNodeList' was successful.
*/

-- Step 115 -->> On Both Nodes
[root@rac1/rac2 ~]# cd /opt/app/19c/grid/bin/
[root@rac1/rac2 bin]# ./crsctl check cluster
/*
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
*/


-- Step 116 -->> On Both Nodes
[root@rac1 bin]# ./crsctl check cluster -all
/*
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

-- Step 117 -->> On Node 1
[root@rac1 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac1                     Started,STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.crf
      1        ONLINE  ONLINE       rac1                     STABLE
ora.crsd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.cssd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       rac1                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       rac1                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.storage
      1        ONLINE  ONLINE       rac1                     STABLE
--------------------------------------------------------------------------------
*/


-- Step 118 -->> On Node 2
[root@rac2 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.crf
      1        ONLINE  ONLINE       rac2                     STABLE
ora.crsd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cssd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       rac2                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       rac2                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.evmd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.storage
      1        ONLINE  ONLINE       rac2                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 119 -->> On Both Nodes
[root@rac1/rac2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.chad
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.net1.network
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.ons
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        ONLINE  OFFLINE                               STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2                     STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       rac1                     STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     Started,STABLE
      2        ONLINE  ONLINE       rac2                     Started,STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.cvu
      1        ONLINE  ONLINE       rac1                     STABLE
ora.qosmserver
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac1.vip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac2.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       rac1                     STABLE
--------------------------------------------------------------------------------
*/


-- Step 120 -->> On Both Nodes
[grid@rac1/rac2 ~]$ asmcmd
/*
ASMCMD> lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  4194304     20476    20136                0           20136              0             Y  OCR/
ASMCMD> exit
*/

-- Step 121 -->> On Both Nodes
[grid@rac1/rac2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 29-SEP-2023 08:10:08

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                29-SEP-2023 07:51:26
Uptime                    0 days 0 hr. 18 min. 41 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/19c/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/rac1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.31)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.33)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1/+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1/+ASM2", status READY, has 1 handler(s) for this service...
The command completed successfully

*/


-- Step 122 -->> On Node 1
-- To Create ASM storage for Data and Archive
[grid@rac1 ~]$ cd /opt/app/19c/grid/bin
[grid@rac1 bin]$ ./asmca -silent -createDiskGroup -diskGroupName DATA -diskList /dev/oracleasm/disks/DATA -redundancy EXTERNAL
[grid@rac1 bin]$ ./asmca -silent -createDiskGroup -diskGroupName FRA -diskList /dev/oracleasm/disks/FRA -redundancy EXTERNAL

-- Step 123 -->> On Both Nodes
[grid@rac1/rac2 ~]$ sqlplus / as sysasm
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Fri Sep 29 08:14:27 2023
Version 19.20.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0

SQL> set lines 200;
SQL> COLUMN name FORMAT A30;
SQL> SELECT inst_id,name,state,type,compatibility,database_compatibility,voting_files from gv$asm_diskgroup order by name;

   INST_ID NAME                           STATE       TYPE   COMPATIBILITY                                                DATABASE_COMPATIBILITY                                       V
---------- ------------------------------ ----------- ------ ------------------------------------------------------------ ------------------------------------------------------------ -
         2 DATA                           MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   N
         1 DATA                           MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   N
         2 FRA                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   N
         1 FRA                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   N
         1 OCR                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   Y
         2 OCR                            MOUNTED     EXTERN 19.0.0.0.0                                                   10.1.0.0.0                                                   Y

6 rows selected.


SQL> set lines 200;
SQL> col path format a40;
SQL> select name,path, group_number group_#, disk_number disk_#, mount_status,header_status, state, total_mb, free_mb from v$asm_disk order by group_number;

NAME     NAME                           PATH                                        GROUP_#     DISK_# MOUNT_S HEADER_STATU STATE      TOTAL_MB    FREE_MB
------------------------------ ---------------------------------------- ---------- ---------- ------- ------------ -------- ---------- ----------
OCR_0000                       /dev/oracleasm/disks/OCR                          1          0 CACHED  MEMBER       NORMAL        20476      20136
DATA_0000                      /dev/oracleasm/disks/DATA                         2          0 CACHED  MEMBER       NORMAL        25023      24915
FRA_0000                       /dev/oracleasm/disks/FRA                          3          0 CACHED  MEMBER       NORMAL        40959      40851

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT INST_ID,BANNER_FULL,BANNER_LEGACY,CON_ID FROM gv$version;

   INST_ID BANNER_FULL                                                                      BANNER_LEGACY                                                                        CON_ID
---------- -------------------------------------------------------------------------------- -------------------------------------------------------------------------------- ----------
         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                    0
           Version 19.20.0.0.0

         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production           Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                    0
           Version 19.20.0.0.0
     

SQL> EXIT
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0
*/

-- Or --

[grid@rac1 ~]$ sqlplus / as sysasm
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Sun Sep 20 13:15:19 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> set lines 200;
SQL> COLUMN name FORMAT A30
SQL> SELECT inst_id,name,state,type,compatibility,database_compatibility,voting_files from gv$asm_diskgroup order by name;

   INST_ID NAME STATE   TYPE   COMPATIBILITY DATABASE_COMPATIBILITY V
---------- ---- ------- ------ ------------- ---------------------- -
         2 OCR  MOUNTED EXTERN 19.0.0.0.0    10.1.0.0.0             Y
         1 OCR  MOUNTED EXTERN 19.0.0.0.0    10.1.0.0.0             Y

SQL> CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK '/dev/oracleasm/disks/DATA' ATTRIBUTE 'compatible.asm'='19.0','compatible.rdbms'='19.0';

Diskgroup created.

SQL> CREATE DISKGROUP ARC EXTERNAL REDUNDANCY DISK '/dev/oracleasm/disks/ARC' ATTRIBUTE 'compatible.asm'='19.0','compatible.rdbms'='19.0';

Diskgroup created.

SQL> set lines 200;
SQL> COLUMN name FORMAT A30
SQL> SELECT inst_id,name,state,type,compatibility,database_compatibility,voting_files from gv$asm_diskgroup order by name;

   INST_ID NAME STATE   TYPE   COMPATIBILITY DATABASE_COMPATIBILITY V
---------- ---- ------- ------ ------------- ---------------------- -
         1 ARC  MOUNTED EXTERN 19.0.0.0.0    19.0.0.0.0             N
         2 ARC  MOUNTED EXTERN 19.0.0.0.0    19.0.0.0.0             N
         2 DATA MOUNTED EXTERN 19.0.0.0.0    19.0.0.0.0             N
         1 DATA MOUNTED EXTERN 19.0.0.0.0    19.0.0.0.0             N
         2 OCR  MOUNTED EXTERN 19.0.0.0.0    10.1.0.0.0             Y
         1 OCR  MOUNTED EXTERN 19.0.0.0.0    10.1.0.0.0             Y

SQL> set lines 200;
SQL> col path format a40;
SQL> select name,path, group_number group_#, disk_number disk_#, mount_status,header_status, state, total_mb, free_mb from v$asm_disk order by group_number;

NAME      PATH                         GROUP_#     DISK_# MOUNT_S HEADER_STATU STATE      TOTAL_MB    FREE_MB
--------- ------------------------- ---------- ---------- ------- ------------ -------- ---------- ----------
OCR_0000  /dev/oracleasm/disks/OCR           1          0 CACHED  MEMBER       NORMAL        20476      20140
DATA_0000 /dev/oracleasm/disks/DATA          2          0 CACHED  MEMBER       NORMAL        81919      81815
ARC_0000  /dev/oracleasm/disks/ARC           3          0 CACHED  MEMBER       NORMAL        51199      51095

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT inst_id,banner_full,banner_legacy,con_id FROM gv$version;

   INST_ID BANNER_FULL                                                  BANNER_LEGACY                                                          CON_ID
---------- ------------------------------------------------------------ ---------------------------------------------------------------------- ------
         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 -  Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production      0
           Production                                                                                                                          
           Version 19.7.0.0.0                                                                                                                  
																																			   
         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 -  Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production      0
           Production                                                                                                                         
           Version 19.7.0.0.0                                                                                                                 
																																			  
SQL> exit                                                                                                                                     
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production                                                      
Version 19.7.0.0.0 
*/

-- Step 124 -->> On Both Nodes
[root@rac1/rac2 ~]# cd /opt/app/19c/grid/bin
[root@rac1/rac2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.chad
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.net1.network
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.ons
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        ONLINE  OFFLINE                               STABLE
ora.FRA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        ONLINE  OFFLINE                               STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2                     STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       rac1                     STABLE
ora.LISTENER_SCAN3.lsnr
      1        ONLINE  ONLINE       rac1                     STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     Started,STABLE
      2        ONLINE  ONLINE       rac2                     Started,STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.cvu
      1        ONLINE  ONLINE       rac1                     STABLE
ora.qosmserver
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac1.vip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac2.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.scan3.vip
      1        ONLINE  ONLINE       rac1                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 125 -->> On Both Nodes
[grid@rac1/rac2 ~]$ asmcmd
/*
ASMCMD> lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  1048576     25023    24915                0           24915              0             N  DATA/
MOUNTED  EXTERN  N         512             512   4096  1048576     40959    40851                0           40851              0             N  FRA/
MOUNTED  EXTERN  N         512             512   4096  4194304     20476    20136                0           20136              0             Y  OCR/

*/

-- Step 126 -->> On Node 1
[root@rac1 ~]# vi /etc/oratab
/*
+ASM1:/opt/app/19c/grid:N
*/

-- Step 127 -->> On Node 2
[root@rac2 ~]# vi /etc/oratab
/*
+ASM2:/opt/app/19c/grid:N
*/

-- Step 128 -->> On Both Nodes
-- Creating the Oracle RDBMS Home Directory
[root@rac1/rac2 ~]# mkdir -p /opt/app/oracle/product/19c/db_1
[root@rac1/rac2 ~]# chown -R oracle:oinstall /opt/app/oracle/product/19c/db_1
[root@rac1/rac2 ~]# chmod -R 775 /opt/app/oracle/product/19c/db_1

-- Step 129 -->> On Node 1
-- To unzip the Oracle Binary and Letest Opatch
[root@rac1 ~]# cd /opt/app/oracle/product/19c/db_1
[root@rac1 db_1]# unzip -oq /root/ORACLE_SOFTWARE_19C/LINUX.X64_193000_db_home.zip
[root@rac1 db_1]# unzip -oq /root/ORACLE_SOFTWARE_19C/p6880880_190000_Linux-x86-64.zip 

[root@rac1 ~]# chown -R oracle:oinstall /opt/app/oracle/product/19c/db_1/
[root@rac1 ~]# chmod -R 775 /opt/app/oracle/product/19c/db_1/

-- Step 130 -->> On Node 1
-- To Setup the SSH Connectivity 
[root@rac1 ~]# su - oracle
[oracle@rac1 ~]$ cd /opt/app/oracle/product/19c/db_1/deinstall/
[oracle@rac1 deinstall]$ ./sshUserSetup.sh -user oracle -hosts "rac1 rac2" -noPromptPassphrase -confirm -advanced

-- Step 131 -->> On Both Nodes
[oracle@rac1/rac2 ~]$ ssh oracle@rac1 date
[oracle@rac1/rac2 ~]$ ssh oracle@rac2 date
[oracle@rac1/rac2 ~]$ ssh oracle@rac1 date && ssh oracle@rac2 date
[oracle@rac1/rac2 ~]$ ssh oracle@rac1.mydomain date
[oracle@rac1/rac2 ~]$ ssh oracle@rac2.mydomain date
[oracle@rac1/rac2 ~]$ ssh oracle@rac1.mydomain date && ssh oracle@rac2.mydomain date

-- Step 132 -->> On Node 1
-- To Create a responce file for Oracle Software Installation
[oracle@rac1 ~]$ cp /opt/app/oracle/product/19c/db_1/install/response/db_install.rsp /home/oracle/
[oracle@rac1 ~]$ cd /home/oracle/
[oracle@rac1 ~]$ ls -ltr
/*
-rwxr-xr-x 1 oracle oinstall 19932 Sep 30 02:10 db_install.rsp
*/
[oracle@rac1 ~]$  vim db_install.rsp
/*
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/opt/app/oraInventory
ORACLE_HOME=/opt/app/oracle/product/19c/db_1
ORACLE_BASE=/opt/app/oracle
ORACLE_HOSTNAME=rac1.mydomain
SELECTED_LANGUAGES=en
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=backupdba
oracle.install.db.OSDGDBA_GROUP=dgdba
oracle.install.db.OSKMDBA_GROUP=kmdba
oracle.install.db.OSRACDBA_GROUP=racdba
oracle.install.db.rootconfig.executeRootScript=false
oracle.install.db.CLUSTER_NODES=rac1,rac2
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.ConfigureAsContainerDB=false
*/

-- Step 133 -->> On Node 1
-- To install Oracle Software with Letest Opatch
[oracle@rac1 ~]$ cd /opt/app/oracle/product/19c/db_1/
[oracle@rac1 db_1]$ ./runInstaller -ignorePrereq -waitforcompletion -silent \
-applyRU /tmp/35319490/35320081                                             \
-responseFile /home/oracle/db_install.rsp                                   \
oracle.install.db.isRACOneInstall=false                                     \
oracle.install.db.rac.serverpoolCardinality=0                               \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                  \
DECLINE_SECURITY_UPDATES=true

/*
Preparing the home to patch...
Applying the patch /tmp/35319490/35320081...
Successfully applied the patch.
The log can be found at: /opt/app/oraInventory/logs/InstallActions2023-09-30_02-25-16AM/installerPatchActions_2023-09-30_02-25-16AM.log
Launching Oracle Database Setup Wizard...

[WARNING] [INS-13013] Target environment does not meet some mandatory requirements.
   CAUSE: Some of the mandatory prerequisites are not met. See logs for details. /opt/app/oraInventory/logs/InstallActions2023-09-30_02-25-16AM/installActions2023-09-30_02-25-16AM.log
   ACTION: Identify the list of failed prerequisite checks from the log: /opt/app/oraInventory/logs/InstallActions2023-09-30_02-25-16AM/installActions2023-09-30_02-25-16AM.log. Then either from the log file or from installation manual find the appropriate configuration to meet the prerequisites and fix it manually.
The response file for this session can be found at:
 /opt/app/oracle/product/19c/db_1/install/response/db_2023-09-30_02-25-16AM.rsp

You can find the log of this install session at:
 /opt/app/oraInventory/logs/InstallActions2023-09-30_02-25-16AM/installActions2023-09-30_02-25-16AM.log


As a root user, execute the following script(s):
        1. /opt/app/oracle/product/19c/db_1/root.sh

Execute /opt/app/oracle/product/19c/db_1/root.sh on the following nodes:
[rac1, rac2]


Successfully Setup Software with warning(s).
*/

-- Step 124 -->> On Node 1
[root@rac1 ~]# /opt/app/oracle/product/19c/db_1/root.sh
/*
Check /opt/app/oracle/product/19c/db_1/install/root_rac1.mydomain_2023-09-30_03-15-05-398863198.log for the output of root script
*/

[root@rac1 ~]# tail -f /opt/app/oracle/product/19c/db_1/install/root_rac1.mydomain_2023-09-30_03-15-05-398863198.log
/*
   ORACLE_OWNER= oracle
   ORACLE_HOME=  /opt/app/oracle/product/19c/db_1
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
*/

-- Step 135 -->> On Node 2
[root@rac2 ~]# /opt/app/oracle/product/19c/db_1/root.sh
/*
Check /opt/app/oracle/product/19c/db_1/install/root_rac2.mydomain_2023-09-30_03-16-04-658809801.log for the output of root script
*/

[root@rac2 ~]# tail -f /opt/app/oracle/product/19c/db_1/install/root_rac2.mydomain_2023-09-30_03-16-04-658809801.log
/* 
 ORACLE_OWNER= oracle
    ORACLE_HOME=  /opt/app/oracle/product/19c/db_1
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...

Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
*/

-- Step 136 -->> On Node 1
-- To applying the Oracle PSU on Node 1
[root@rac1 ~]# export ORACLE_HOME=/opt/app/oracle/product/19c/db_1
[root@rac1 ~]# export PATH=${ORACLE_HOME}/bin:$PATH
[root@rac1 ~]# export PATH=${PATH}:${ORACLE_HOME}/OPatch
[root@rac1 ~]# which opatchauto
/*
/opt/app/oracle/product/19c/db_1/OPatch/opatchauto
*/

-- Step 137 -->> On Node 1
[root@rac1 ~]# opatchauto apply /tmp/35319490/35320149 -oh /opt/app/oracle/product/19c/db_1 --nonrolling
/*
OPatchauto session is initiated at Sat Sep 30 03:28:30 2023

System initialization log file is /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/systemconfig2023-09-30_03-28-48AM.log.

Session log file is /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2023-09-30_03-29-14AM.log
The id for this session is 5AXU

Executing OPatch prereq operations to verify patch applicability on home /opt/app/oracle/product/19c/db_1
Patch applicability verified successfully on home /opt/app/oracle/product/19c/db_1


Executing patch validation checks on home /opt/app/oracle/product/19c/db_1
Patch validation checks successfully completed on home /opt/app/oracle/product/19c/db_1


Verifying SQL patch applicability on home /opt/app/oracle/product/19c/db_1
No sqlpatch prereq operations are required on the local node for this home
No step execution required.........


Preparing to bring down database service on home /opt/app/oracle/product/19c/db_1
No step execution required.........


Bringing down database service on home /opt/app/oracle/product/19c/db_1
Database service successfully brought down on home /opt/app/oracle/product/19c/db_1


Performing prepatch operation on home /opt/app/oracle/product/19c/db_1
Prepatch operation completed successfully on home /opt/app/oracle/product/19c/db_1


Start applying binary patch on home /opt/app/oracle/product/19c/db_1
Binary patch applied successfully on home /opt/app/oracle/product/19c/db_1


Performing postpatch operation on home /opt/app/oracle/product/19c/db_1
Postpatch operation completed successfully on home /opt/app/oracle/product/19c/db_1


Starting database service on home /opt/app/oracle/product/19c/db_1
Database service successfully started on home /opt/app/oracle/product/19c/db_1


Preparing home /opt/app/oracle/product/19c/db_1 after database service restarted
No step execution required.........


Trying to apply SQL patch on home /opt/app/oracle/product/19c/db_1
No SQL patch operations are required on local node for this home

OPatchAuto successful.

--------------------------------Summary--------------------------------

Patching is completed successfully. Please find the summary as follows:

Host:rac1
RAC Home:/opt/app/oracle/product/19c/db_1
Version:19.0.0.0.0
Summary:

==Following patches were SUCCESSFULLY applied:

Patch: /tmp/35319490/35320149
Log: /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2023-09-30_03-29-43AM_1.log



OPatchauto session completed at Sat Sep 30 03:31:08 2023
Time taken to complete the session 2 minutes, 38 seconds


*/

[root@rac1 ~]# tail -f /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2020-09-20_16-08-11PM_1.log
/*
[Sep 30, 2023 3:31:01 AM] [INFO]    Deleted the file "/opt/app/oracle/product/19c/db_1/.patch_storage/35320149_Jul_2_2023_22_44_47/rac/make_cmds.txt"
[Sep 30, 2023 3:31:01 AM] [INFO]    [OPSR-TIME] Backup area for restore has been cleaned up. For a complete list of files/directories
                                    deleted, Please refer log file.
[Sep 30, 2023 3:31:01 AM] [INFO]    Patch 35320149 successfully applied.
[Sep 30, 2023 3:31:01 AM] [INFO]    Sub-set patch [29585399] has become inactive due to the application of a super-set patch [35320149].
                                    Please refer to Doc ID 2161861.1 for any possible further required actions.
[Sep 30, 2023 3:31:01 AM] [INFO]    UtilSession: N-Apply done.
[Sep 30, 2023 3:31:01 AM] [INFO]    Finishing UtilSession at Sat Sep 30 03:31:01 EDT 2023
[Sep 30, 2023 3:31:01 AM] [INFO]    Log file location: /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2023-09-30_03-29-43AM_1.log
[Sep 30, 2023 3:31:02 AM] [INFO]    EXITING METHOD: NApply(patches,options)
*/

-- Step 138 -->> On Node 1
[root@rac1 ~]# scp -r /tmp/35319490/ root@rac2:/tmp/

-- Step 139 -->> On Node 2
[root@rac2 ~]# cd /tmp/
[root@rac2 tmp]# chown -R oracle:oinstall 35319490
[root@rac2 tmp]# chmod -R 775 35319490
[root@rac2 tmp]# ls -ltr | grep 35319490
/*
drwxrwxr-x  4 oracle oinstall   4096 Sep 20 16:15 30783556
*/

-- Step 140 -->> On Node 2
-- To applying the Oracle PSU on Remote Node 2
[root@rac2 ~]# export ORACLE_HOME=/opt/app/oracle/product/19c/db_1
[root@rac2 ~]# export PATH=${ORACLE_HOME}/bin:$PATH
[root@rac2 ~]# export PATH=${PATH}:${ORACLE_HOME}/OPatch
[root@rac2 ~]# which opatchauto
/*
/opt/app/oracle/product/19c/db_1/OPatch/opatchauto
*/

-- Step 141 -->> On Node 2
[root@rac2 ~]# opatchauto apply /tmp/35319490/35320149 -oh /opt/app/oracle/product/19c/db_1 --nonrolling
/*
OPatchauto session is initiated at Sat Sep 30 03:49:30 2023

System initialization log file is /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchautodb/systemconfig2023-09-30_03-50-08AM.log.

Session log file is /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/opatchauto2023-09-30_03-50-21AM.log
The id for this session is 443L

Executing OPatch prereq operations to verify patch applicability on home /opt/app/oracle/product/19c/db_1
Patch applicability verified successfully on home /opt/app/oracle/product/19c/db_1


Executing patch validation checks on home /opt/app/oracle/product/19c/db_1
Patch validation checks successfully completed on home /opt/app/oracle/product/19c/db_1


Verifying SQL patch applicability on home /opt/app/oracle/product/19c/db_1
No sqlpatch prereq operations are required on the local node for this home
No step execution required.........


Preparing to bring down database service on home /opt/app/oracle/product/19c/db_1
No step execution required.........


Bringing down database service on home /opt/app/oracle/product/19c/db_1
Database service successfully brought down on home /opt/app/oracle/product/19c/db_1


Performing prepatch operation on home /opt/app/oracle/product/19c/db_1
Prepatch operation completed successfully on home /opt/app/oracle/product/19c/db_1


Start applying binary patch on home /opt/app/oracle/product/19c/db_1
Binary patch applied successfully on home /opt/app/oracle/product/19c/db_1


Performing postpatch operation on home /opt/app/oracle/product/19c/db_1
Postpatch operation completed successfully on home /opt/app/oracle/product/19c/db_1


Starting database service on home /opt/app/oracle/product/19c/db_1
Database service successfully started on home /opt/app/oracle/product/19c/db_1


Preparing home /opt/app/oracle/product/19c/db_1 after database service restarted
No step execution required.........


Trying to apply SQL patch on home /opt/app/oracle/product/19c/db_1
No SQL patch operations are required on local node for this home

OPatchAuto successful.

--------------------------------Summary--------------------------------

Patching is completed successfully. Please find the summary as follows:

Host:rac2
RAC Home:/opt/app/oracle/product/19c/db_1
Version:19.0.0.0.0
Summary:

==Following patches were SUCCESSFULLY applied:

Patch: /tmp/35319490/35320149
Log: /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2023-09-30_03-52-08AM_1.log



OPatchauto session completed at Sat Sep 30 03:53:42 2023
Time taken to complete the session 4 minutes, 13 seconds

*/


[root@rac2 ~]# tail -f  /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2023-09-30_03-52-08AM_1.log
/*
[Sep 30, 2023 3:53:37 AM] [INFO]    Deleted the file "/opt/app/oracle/product/19c/db_1/.patch_storage/35320149_Jul_2_2023_22_44_47/rac/make_cmds.txt"
[Sep 30, 2023 3:53:37 AM] [INFO]    [OPSR-TIME] Backup area for restore has been cleaned up. For a complete list of files/directories
                                    deleted, Please refer log file.
[Sep 30, 2023 3:53:37 AM] [INFO]    Patch 35320149 successfully applied.
[Sep 30, 2023 3:53:37 AM] [INFO]    Sub-set patch [29585399] has become inactive due to the application of a super-set patch [35320149].
                                    Please refer to Doc ID 2161861.1 for any possible further required actions.
[Sep 30, 2023 3:53:37 AM] [INFO]    UtilSession: N-Apply done.
[Sep 30, 2023 3:53:37 AM] [INFO]    Finishing UtilSession at Sat Sep 30 03:53:37 EDT 2023
[Sep 30, 2023 3:53:37 AM] [INFO]    Log file location: /opt/app/oracle/product/19c/db_1/cfgtoollogs/opatchauto/core/opatch/opatch2023-09-30_03-52-08AM_1.log
[Sep 30, 2023 3:53:37 AM] [INFO]    EXITING METHOD: NApply(patches,options)

*/

-- Step 142 -->> On Both Nodes
-- To Create a Oracle Database
[root@rac1/rac2 ~]# mkdir -p /opt/app/oracle/admin/racdb/adump
[root@rac1/rac2 ~]# cd /opt/app/oracle/admin/
[root@rac1/rac2 ~]# chown -R oracle:oinstall racdb/
[root@rac1/rac2 ~]# chmod -R 775 racdb/

-- Step 125 -->> On Node 1
-- To prepare the responce file
[root@rac1 ~]# su - oracle
[oracle@rac1 ~]$ cp /opt/app/oracle/product/19c/db_1/assistants/dbca/dbca.rsp /home/oracle/
[oracle@rac1 ~]$ cd /home/oracle/
[oracle@rac1 ~]$ chmod -R 755 dbca.rsp
[oracle@rac1 ~]$ ls -ltr | grep dbca
/*
-rwxr-xr-x 1 oracle oinstall 25502 Sep 30 03:59 dbca.rsp
*/
 
-- Step 143 -->> On Node 1
[oracle@rac1 ~]$ vi dbca.rsp
/*
responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v19.0.0
gdbname=racdb
sid=racdb
databaseConfigType=RAC
force=FALSE
createAsContainerDatabase=true
numberOfPDBs=1
pdbName=racpdb
pdbAdminPassword=Adminrabin1
nodelist=rac1,rac2
templateName=/opt/app/oracle/product/19c/db_1/assistants/dbca/templates/General_Purpose.dbc
sysPassword=Adminrabin1
systemPassword=Adminrabin1
emConfiguration=NONE
datafileDestination=+DATA
recoveryAreaDestination=+DATA
storageType=ASM
diskGroupName=+DATA/{DB_UNIQUE_NAME}/
asmsnmpPassword=Adminrabin1
recoveryGroupName=+FRA
characterSet=AL32UTF8
listeners=LISTENER
sampleSchema=fasle
databaseType=MULTIPURPOSE
automaticMemoryManagement=fasle 
totalMemory=2048
*/

-- OR --
[oracle@rac1 ~]$ cd /opt/app/oracle/product/19c/db_1/bin/
[oracle@rac1 bin]$ dbca -silent -createDatabase \
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
  -totalMemory 1845                             \
  -redoLogFileSize 50                           \
  -emConfiguration NONE                         \
  -ignorePreReqs                                \
  -nodelist rac1,rac2                           \
  -storageType ASM                              \
  -diskGroupName +DATA/{DB_UNIQUE_NAME}/        \
  -recoveryGroupName +FRA                       \
  -useOMF true                                  \
  -asmsnmpPassword Adminrabin1

/*
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
 /opt/app/oracle/cfgtoollogs/dbca/racdb.
Database Information:
Global Database Name:racdb
System Identifier(SID) Prefix:racdb
Look at the log file "/opt/app/oracle/cfgtoollogs/dbca/racdb/racdb.log" for further details.
*/  

[oracle@rac1 ~]$ tail -f /opt/app/oracle/cfgtoollogs/dbca/racdb/racdb.log
/*
[ 2020-09-20 16:51:14.438 NPT ] Prepare for db operation
DBCA_PROGRESS : 7%
[ 2020-09-20 16:51:41.631 NPT ] Copying database files
DBCA_PROGRESS : 27%
[ 2020-09-20 16:53:18.738 NPT ] Creating and starting Oracle instance
DBCA_PROGRESS : 28%
DBCA_PROGRESS : 31%
DBCA_PROGRESS : 35%
DBCA_PROGRESS : 37%
DBCA_PROGRESS : 40%
[ 2020-09-20 17:19:41.868 NPT ] Creating cluster database views
DBCA_PROGRESS : 41%
DBCA_PROGRESS : 53%
[ 2020-09-20 17:21:17.705 NPT ] Completing Database Creation
DBCA_PROGRESS : 57%
DBCA_PROGRESS : 59%
DBCA_PROGRESS : 60%
[ 2020-09-20 17:33:07.570 NPT ] Creating Pluggable Databases
DBCA_PROGRESS : 64%
DBCA_PROGRESS : 80%
[ 2020-09-20 17:33:43.013 NPT ] Executing Post Configuration Actions
DBCA_PROGRESS : 100%
[ 2020-09-20 17:33:43.016 NPT ] Database creation complete. For details check the logfiles at:
 /opt/app/oracle/cfgtoollogs/dbca/racdb.
Database Information:
Global Database Name:racdb
System Identifier(SID) Prefix:racdb
*/

-- Step 144 -->> On Node 1  
[oracle@rac1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Sun Sep 20 17:42:39 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> ALTER PLUGGABLE DATABASE racpdb SAVE STATE;

Pluggable database altered.

SQL> SELECT status ,instance_name FROM gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb2
OPEN         racdb1

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0
*/

-- Step 145 -->> On Both Nodes 
[oracle@rac1/rac2 ~]$ srvctl config database -d racdb
/*
Database unique name: racdb
Database name: racdb
Oracle home: /opt/app/oracle/product/19c/db_1
Oracle user: oracle
Spfile: +DATA/RACDB/PARAMETERFILE/spfile.272.1051637423
Password file: +DATA/RACDB/PASSWORD/pwdracdb.256.1051635105
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools:
Disk Groups: ARC,DATA
Mount point paths:
Services:
Type: RAC
Start concurrency:
Stop concurrency:
OSDBA group: dba
OSOPER group: oper
Database instances: racdb1,racdb2
Configured nodes: rac1,rac2
CSS critical: no
CPU count: 0
Memory target: 0
Maximum memory: 0
Default network number for database services:
Database is administrator managed
*/

-- Step 146 -->> On Both Nodes 
[oracle@rac1/rac2 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

-- Step 147 -->> On Both Nodes 
[oracle@rac1 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac1,rac2
*/

-- Step 148 -->> On Node 1 
[oracle@rac1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 30-SEP-2023 12:43:04

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                30-SEP-2023 11:40:09
Uptime                    0 days 1 hr. 2 min. 54 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/19c/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/rac1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.31)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.33)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 149 -->> On Node 2 
[oracle@rac2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 30-SEP-2023 12:44:51

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                30-SEP-2023 11:40:41
Uptime                    0 days 1 hr. 4 min. 10 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/19c/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/rac2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.32)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.34)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM2", status READY, has 1 handler(s) for this service...
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

-- To Fix the if occured in remote nodes
[oracle@rac2 ~]$ adrci
/*
ADRCI: Release 19.0.0.0.0 - Production on Mon Sep 21 12:38:51 2020

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

No ADR base is set
adrci> exit
*/

[oracle@rac1 ~]$ ls -ltr /opt/app/oracle/product/19c/db_1/log/diag/
/*
-rw-r----- 1 oracle asmadmin 16 Sep 30 13:57 adrci_dir.mif
*/

[oracle@rac2 ~]$ cd /opt/app/oracle/product/19c/db_1/
[oracle@rac2 db_1]$ mkdir -p log/diag
[oracle@rac2 db_1]$ mkdir -p log/rac1/client
[oracle@rac2 db_1]$ cd log
[oracle@rac2 log]$ chown -R oracle:asmadmin diag
[oracle@rac1 ~]$ scp -r /opt/app/oracle/product/19c/db_1/log/diag/adrci_dir.mif oracle@rac2:/opt/app/oracle/product/19c/db_1/log/diag/


-- Step 150 -->> On Node 1
[root@rac1 ~]# vi /etc/oratab
/*
+ASM1:/opt/app/19c/grid:N
racdb:/opt/app/oracle/product/19c/db_1:N
racdb1:/opt/app/oracle/product/19c/db_1:N
*/

-- Step 151 -->> On Node 2
[root@rac2 ~]# vi /etc/oratab 
/*
+ASM2:/opt/app/19c/grid:N
racdb:/opt/app/oracle/product/19c/db_1:N
racdb2:/opt/app/oracle/product/19c/db_1:N
*/

-- Step 152 -->> On Node 1
[root@rac1 ~]# vi /opt/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /opt/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.31)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACPDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racpdb)
    )
  )

*/

-- Step 153 -->> On Node 2
[root@rac2 ~]# vi /opt/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /opt/app/oracle/product/19c/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB2 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.32)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACPDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = rac-scan)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racpdb)
    )
  )

*/

-- To run the oracle tools (Till 11gR2 - If Required)
[root@rac1/rac2 ~]# vi /opt/app/19c/grid/network/admin/sqlnet.ora
/*
# sqlnet.ora.rac1/rac2 Network Configuration File: /opt/app/19c/grid/network/admin/sqlnet.ora
# Generated by Oracle configuration tools.

NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)

SQLNET.ALLOWED_LOGON_VERSION_SERVER=11
SQLNET.ALLOWED_LOGON_VERSION_CLIENT=11
*/

[root@rac1/rac2 ~]# vi /opt/app/oracle/product/19c/db_1/network/admin/sqlnet.ora
/*
# sqlnet.ora.rac1/rac2 Network Configuration File: /opt/app/oracle/product/19c/db_1/network/admin/sqlnet.ora
# Generated by Oracle configuration tools.

NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)

SQLNET.ALLOWED_LOGON_VERSION_SERVER=11
SQLNET.ALLOWED_LOGON_VERSION_CLIENT=11
*/

[oracle@rac1/rac2 ~]$ srvctl stop listener
[oracle@rac1/rac2 ~]$ srvctl start listener
[oracle@rac1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Sat Sep 30 13:52:18 2023
Version 19.20.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0

SQL> ALTER USER sys IDENTIFIED BY "Adminrabin1";

User altered.

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0
*/

-- Step 155 -->> On Both Nodes
[root@rac1/rac2 ~]# cd /opt/app/19c/grid/bin
[root@rac1/rac2 ~]# ./crsctl stop crs
[root@rac1/rac2 ~]# ./crsctl start crs

-- Step 156 -->> On Node 1
[root@rac1 ~]# cd /opt/app/19c/grid/bin
[root@rac1 ~]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac1                     Started,STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.crf
      1        ONLINE  ONLINE       rac1                     STABLE
ora.crsd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.cssd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       rac1                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       rac1                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.drivers.acfs
      1        ONLINE  ONLINE       rac1                     STABLE
ora.evmd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       rac1                     STABLE
ora.storage
      1        ONLINE  ONLINE       rac1                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 157 -->> On Node 2
[root@rac2 ~]# cd /opt/app/19c/grid/bin
[root@rac2 bin]# ./crsctl stat res -t -init
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.asm
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cluster_interconnect.haip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.crf
      1        ONLINE  ONLINE       rac2                     STABLE
ora.crsd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cssd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.cssdmonitor
      1        ONLINE  ONLINE       rac2                     STABLE
ora.ctssd
      1        ONLINE  ONLINE       rac2                     OBSERVER,STABLE
ora.diskmon
      1        OFFLINE OFFLINE                               STABLE
ora.drivers.acfs
      1        ONLINE  ONLINE       rac2                     STABLE
ora.evmd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.gipcd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.gpnpd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.mdnsd
      1        ONLINE  ONLINE       rac2                     STABLE
ora.storage
      1        ONLINE  ONLINE       rac2                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 158 -->> On Both Nodes
[root@rac1/rac2 ~]# cd /opt/app/19c/grid/bin
[root@rac1/rac2 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
Name           Target  State        Server                   State details
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.LISTENER.lsnr
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.chad
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.net1.network
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.ons
               ONLINE  ONLINE       rac1                     STABLE
               ONLINE  ONLINE       rac2                     STABLE
ora.proxy_advm
               OFFLINE OFFLINE      rac1                     STABLE
               OFFLINE OFFLINE      rac2                     STABLE
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.ARC.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.ASMNET1LSNR_ASM.lsnr(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        ONLINE  OFFLINE                               STABLE
ora.DATA.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       rac2                     STABLE
ora.LISTENER_SCAN2.lsnr
      1        ONLINE  ONLINE       rac1                     STABLE
ora.OCR.dg(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asm(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     Started,STABLE
      2        ONLINE  ONLINE       rac2                     Started,STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.asmnet1.asmnetwork(ora.asmgroup)
      1        ONLINE  ONLINE       rac1                     STABLE
      2        ONLINE  ONLINE       rac2                     STABLE
      3        OFFLINE OFFLINE                               STABLE
ora.cvu
      1        ONLINE  ONLINE       rac1                     STABLE
ora.qosmserver
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac1.vip
      1        ONLINE  ONLINE       rac1                     STABLE
ora.rac2.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.racdb.db
      1        ONLINE  ONLINE       rac1                     Open,HOME=/opt/app/oracle/product/19c/db_1,STABLE
      2        ONLINE  ONLINE       rac2                     Open,HOME=/opt/app/oracle/product/19c/db_1,STABLE
ora.scan1.vip
      1        ONLINE  ONLINE       rac2                     STABLE
ora.scan2.vip
      1        ONLINE  ONLINE       rac1                     STABLE
--------------------------------------------------------------------------------
*/

-- Step 159 -->> On Both Nodes
[root@rac1/rac2 ~]# cd /opt/app/19c/grid/bin
[root@rac1/rac2 bin]# ./crsctl check cluster -all
/*
**************************************************************
rac1:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
rac2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
*/

-- Step 160 -->> On Both Nodes
-- ASM Verification
[root@rac1/rac2 ~]# su - grid
[grid@rac1/rac2 ~]$ asmcmd
ASMCMD> lsdg
/*
ASMCMD> lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512             512   4096  1048576     25023    18266                0           18266              0             N  DATA/
MOUNTED  EXTERN  N         512             512   4096  1048576     40959    36259                0           36259              0             N  FRA/
MOUNTED  EXTERN  N         512             512   4096  4194304     20476    20124                0           20124              0             Y  OCR/
ASMCMD> exit
*/

-- Step 161 -->> On Both Nodes
[grid@rac1/rac2 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 30-SEP-2023 14:38:47

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                30-SEP-2023 14:24:36
Uptime                    0 days 0 hr. 14 min. 12 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/19c/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/rac1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.31)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.33)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "+ASM_OCR" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "0697793beee221c0e0631f78a8c0506d" has 1 instance(s).
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

-- Step 162 -->> On Both Nodes
[grid@rac1/rac2 ~]$ sqlplus / as sysasm
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Mon Sep 21 13:24:02 2020
Version 19.7.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT inst_id,banner_full,banner_legacy,con_id FROM gv$version;

 INST_ID                                                                                   BANNER_FULL                                                             BANNER_LEGACY    CON_ID
__________ _____________________________________________________________________________________________ _________________________________________________________________________ _________
         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production            0
         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production            0

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0		   
*/		   

-- Step 163 -->> On Both Nodes
-- DB Service Verification
[root@rac1/rac2 ~]# su - oracle
[oracle@rac1/rac2 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

-- Step 164 -->> On Both Nodes
-- Listener Service Verification
[oracle@rac1/rac2 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac1,rac2
*/

-- Step 165 -->> On Node 1
-- Enable Archive
[oracle@rac1 ~]$ srvctl stop database -d racdb
[oracle@rac1 ~]$ srvctl start database -d racdb -o mount
[oracle@rac1 ~]$ sqlplus sys/Sys605014 as sysdba
/*
SQL*Plus: Release 19.0.0.0.0 - Production on Sat Sep 30 13:30:20 2023
Version 19.20.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.0.0


SQL> select status, instance_name from gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
MOUNTED      racdb1
MOUNTED      racdb2

SQL> SELECT inst_id,name,log_mode,open_mode,protection_mode FROM gv$database;

INST_ID NAME  LOG_MODE     OPEN_MODE PROTECTION_MODE
------- ----- ------------ --------- --------------------
      1 RACDB NOARCHIVELOG MOUNTED   MAXIMUM PERFORMANCE
      2 RACDB NOARCHIVELOG MOUNTED   MAXIMUM PERFORMANCE

SQL> ALTER DATABASE ARCHIVELOG;
SQL> ALTER SYSTEM SET log_archive_dest_1='LOCATION=+ARC/racdb' scope=both sid='*';
SQL> ALTER SYSTEM SET log_archive_format='racdb_%t_%s_%r.arc' SCOPE=both sid='*';


SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            +ARC/racdb
Oldest online log sequence     5
Next log sequence to archive   6
Current log sequence           6

SQL> SELECT inst_id,name,log_mode,open_mode,protection_mode FROM gv$database;

INST_ID NAME  LOG_MODE   OPEN_MODE PROTECTION_MODE
------- ----- ---------- --------- --------------------
      1 racDB ARCHIVELOG MOUNTED   MAXIMUM PERFORMANCE
      2 racDB ARCHIVELOG MOUNTED   MAXIMUM PERFORMANCE

SQL> set lines 200;
SQL> col BANNER_FULL format a80;
SQL> col BANNER_LEGACY format a80;
SQL> SELECT inst_id,banner_full,banner_legacy,con_id FROM gv$version;

   INST_ID BANNER_FULL                                                  BANNER_LEGACY                                                          CON_ID
---------- ------------------------------------------------------------ ---------------------------------------------------------------------- ------
         1 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 -  Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production      0
           Production                                                                                                                          
           Version 19.7.0.0.0                                                                                                                  
																																			   
         2 Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 -  Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production      0
           Production                                                                                                                         
           Version 19.7.0.0.0  

SQL> exit
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.7.0.0.0	
*/

-- Step 166 -->> On Node 1
[oracle@rac1 ~]$ srvctl stop database -d racdb
[oracle@rac1 ~]$ srvctl start database -d racdb

-- Step 167 -->> On Both Nodes
[oracle@rac1/rac2 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

-- Step 169 -->> On Both Nodes
[oracle@rac1/rac2 ~]$ rman target /
/*
Recovery Manager: Release 19.0.0.0.0 - Production on Sat Sep 30 13:17:12 2023
Version 19.20.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (DBID=1146503852)

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
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/opt/app/oracle/product/19c/db_1/dbs/snapcf_racdb1.f'; # default
-- Node 1
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/opt/app/oracle/product/19c/db_1/dbs/snapcf_racdb1.f'; # default
-- Node 2
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/opt/app/oracle/product/19c/db_1/dbs/snapcf_racdb2.f'; # default

RMAN> exit

Recovery Manager complete.
*/

-- Step 170 -->> On Both Nodes
-- To connnect CDB$ROOT using TNS
[oracle@rac1/rac2 ~]$ sqlplus sys/Adminrabin1@racdb as sysdba

-- Step 171 -->> On Node 1
[oracle@rac1 ~]$ sqlplus sys/Adminrabin1@racdb1 as sysdba

-- Step 172 -->> On Node 2
[oracle@rac2 ~]$ sqlplus sys/Adminrabin1@racdb2 as sysdba

-- Step 173 -->> On Both Nodes
-- To connnect PDB using TNS
[oracle@rac1/rac2 ~]$ sqlplus sys/Adminrabin1@racpdb as sysdba

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- To Delete All The DataBase (If required)
[oracle@rac1 ~]$ cd /opt/app/oracle/product/19c/db_1/bin/
[oracle@rac1 bin]$ dbca -silent -deleteDatabase -sourceDB racdb -sysDBAUserName sys -sysDBAPassword Adminrabin1
/*
[WARNING] [DBT-19202] The Database Configuration Assistant will delete the Oracle instances and datafiles for your database. All information in the database will be destroyed.
Prepare for db operation
32% complete
Connecting to database
39% complete
42% complete
45% complete
48% complete
52% complete
55% complete
58% complete
65% complete
Updating network configuration files
68% complete
Deleting instances and datafiles
77% complete
87% complete
97% complete
100% complete
Database deletion completed.
Look at the log file "/opt/app/oracle/cfgtoollogs/dbca/racdb/racdb0.log" for further details.