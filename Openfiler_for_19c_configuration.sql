----------------------------------------------------------------
-------------Two Node rac Setup on VM Workstation---------------
----------------------------------------------------------------
 --Openfiler  Configuring

[root@sanstorage ~]# df -h
/*
Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/sda2     ext3    7.5G  1.4G  5.8G  20% /
tmpfs        tmpfs    491M  188K  490M   1% /dev/shm
/dev/sda1     ext3    289M   23M  252M   9% /boot

*/
---- Step 1 -->> Configure the network
[root@sanstorage ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0
/*
# Intel Corporation 82545EM Gigabit Ethernet Controller (Copper)
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.120.60
NETMASK=255.255.255.0
GATEWAY=192.168.120.254
DNS=192.168.120.100
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT
*/ 
-- Step 2 -->> configure host 
[root@sanstorage ~]# vi /etc/hosts
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
-- Step 3 -->> On Openfiler (SAN/NAS Storage)

[root@sanstorage ~]# service network restart
/*
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:                                [  OK  ]

/*

-- Step 4 -->> On Openfiler (SAN/NAS Storage)
-- disabling the firewall.

[root@sanstorage ~]# chkconfig --list iptables
/*
iptables        0:off   1:off   2:off   3:off   4:off   5:off   6:off
*/
[root@sanstorage ~]# service iptables stop
/*
iptables: Setting chains to policy ACCEPT: nat mangle filte[  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@sanstorage ~]# chkconfig iptables off
[root@sanstorage ~]# iptables -F
[root@sanstorage ~]# service iptables save
/*
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
*/
[root@sanstorage ~]# /etc/init.d/iptables stop
/*
iptables: Setting chains to policy ACCEPT: filter          [  OK  ]
iptables: Flushing firewall rules:                         [  OK  ]
iptables: Unloading modules:                               [  OK  ]
*/
[root@sanstorage ~]# iptables -L
/*
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
*/

[root@sanstorage ~]# chkconfig --list iptables
/*
iptables   0:off    1:off    2:off    3:off    4:off    5:off    6:off
*/ 

-- Step 5 -->> On Openfiler (SAN/NAS Storage)
-- ntpd disable
[root@sanstorage ~]# service ntpd stop
/*
Shutting down ntpd:                                        [FAILED]
*/

[root@sanstorage ~]# service ntpd status
/*
ntpd is stopped
*/

[root@sanstorage ~]# chkconfig ntpd off
[root@sanstorage ~]# mv /etc/ntp.conf /etc/ntp.conf.backup
[root@sanstorage ~]# rm -rf  /etc/ntp.conf
[root@sanstorage ~]# rm -rf  /var/run/ntpd.pid
[root@sanstorage ~]# cat /etc/sysconfig/network
/*
NETWORKING=yes
HOSTNAME=sanstorage.racdomain.com
GATEWAY=192.168.120.254
*/


-- Step 6 -->> On Openfiler Restart Operfile host.
[root@sanstorage ~]# init 6
--if the not access wb administration GUI : https://192.168.120.60:446/
--step 1 : press Windows key + R >> type inetcpl.cpl, and press Enter >> Switch to the Advanced tab and check the boxes for Use TLS 1.0, Use TLS 1.1, and Use TLS 1.2

