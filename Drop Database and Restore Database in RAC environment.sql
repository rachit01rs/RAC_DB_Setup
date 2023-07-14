WITH tbs_auto AS
(
 SELECT DISTINCT
      tablespace_name,
      autoextensible
 FROM dba_data_files
 WHERE autoextensible = 'YES'
),
files AS
(
 SELECT
       tablespace_name,
       COUNT(*)              tbs_files,
       SUM(BYTES/1024/1024)  total_tbs_mb
 FROM dba_data_files
 GROUP BY tablespace_name
),
fragments AS
(
 SELECT
      tablespace_name,
      COUNT(*)               tbs_fragments,
      SUM(bytes)/1024/1024   total_tbs_free_mb,
      MAX(bytes)/1024/1024   max_free_chunk_mb
 FROM dba_free_space
 GROUP BY tablespace_name
),
autoextend AS
(
 SELECT
      tablespace_name,
      SUM(size_to_grow) total_growth_tbs
 FROM (
       SELECT
            tablespace_name,
            SUM(maxbytes)/1024/1024  size_to_grow
       FROM dba_data_files
       WHERE autoextensible = 'YES'
       GROUP BY tablespace_name
       UNION
       SELECT
            tablespace_name,
            SUM(bytes)/1024/1024  size_to_grow
       FROM dba_data_files
       WHERE autoextensible = 'NO'
       GROUP BY tablespace_name
     )
 GROUP BY tablespace_name
)
SELECT
     --c.instance_name,
     a.tablespace_name tablespace,
     CASE tbs_auto.autoextensible
          WHEN 'YES' THEN 'YES'
     ELSE 'NO'
     END AS autoextensible,
     files.tbs_files                                                                               files_in_tablespace_count,
     Round(files.total_tbs_mb/(1024),1)                                                            total_tablespace_space_gb,
     Round((files.total_tbs_mb - fragments.total_tbs_free_mb)/(1024),1)                            total_used_space_gb,
     Round(fragments.total_tbs_free_mb/(1024),1)                                                   total_tablespace_free_space_gb
     --round((((files.total_tbs_mb - fragments.total_tbs_free_mb)/files.total_tbs_mb)*100),1)        total_used_pct_mb,
     --round(((fragments.total_tbs_free_mb/files.total_tbs_mb)*100),1)                               total_free_pct_mb
FROM
    dba_tablespaces a,
    --v$instance c,
    files,
    fragments,
    autoextend,
    tbs_auto
WHERE
    a.tablespace_name = files.tablespace_name
AND a.tablespace_name = fragments.tablespace_name
AND a.tablespace_name = autoextend.tablespace_name
AND a.tablespace_name = tbs_auto.tablespace_name(+)
--AND a.tablespace_name='BACKUP_TBS'
--AND (((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/ files.total_tbs_bytes))* 100 > 90
order by 5 desc;


--If you are using file system for Oracle Storage, then you can use it following script.e
CREATE TABLESPACE NEW_TBS_TEST
DATAFILE '/oracle/oradata/TEST/NEW_TBS_TEST01.dbf' SIZE 4G AUTOEXTEND ON NEXT 200M MAXSIZE UNLIMITED LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

--If you are using the Oracle ASM , then you can use it following script.
CREATE TABLESPACE NEW_TBS_TEST DATAFILE '+DATA' SIZE 2G AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;

/*
CREATE TABLESPACE NEW_TBS_TEST
DATAFILE
'+DATA' SIZE 4G AUTOEXTEND ON NEXT 200M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;
*/
create tablespace backup_tbs datafile '+DATA' size 100M AUTOEXTEND on;
select tablespace_name, file_name, bytes, autoextensible, maxbytes from dba_data_files order by 1,2;
/*
tablespace_name file_name                                             bytes autoextensible    maxbytes
BACKUP_TBS      +DATA/racdb/datafile/backup_tbs.269.1142093117    104857600 YES            34359721984
EXAMPLE         +DATA/racdb/datafile/example.264.1141979847       362414080 YES            34359721984
NEW_TBS_TEST    +DATA/racdb/datafile/new_tbs_test.270.1142092819 2147483648 YES            34359721984
SYSAUX          +DATA/racdb/datafile/sysaux.257.1141979775        587202560 YES            34359721984
SYSTEM          +DATA/racdb/datafile/system.256.1141979773        754974720 YES            34359721984
UNDOTBS1        +DATA/racdb/datafile/undotbs1.258.1141979775       62914560 YES            34359721984
UNDOTBS2        +DATA/racdb/datafile/undotbs2.265.1141979915       26214400 YES            34359721984
USERS           +DATA/racdb/datafile/users.259.1141979775           5242880 YES            34359721984


*/

--If you want to create temporary (temp) tablespace, you can create it as follows, if you use Oracle ASM.
CREATE TEMPORARY TABLESPACE TEMP1 TEMPFILE
'+DATA' SIZE 100M AUTOEXTEND ON NEXT 1024M MAXSIZE UNLIMITED;
DROP TABLESPACE BACKUP_TBS INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;

--Query to see Current Temp Datafiles State
select d.TABLESPACE_NAME, d.FILE_NAME, d.BYTES/1024/1024 SIZE_MB, d.AUTOEXTENSIBLE, d.MAXBYTES/1024/1024 MAXSIZE_MB, d.INCREMENT_BY*(v.BLOCK_SIZE/1024)/1024 INCREMENT_BY_MB
from dba_temp_files d,
 v$tempfile v
where d.FILE_ID = v.FILE#
order by d.TABLESPACE_NAME, d.FILE_NAME;
/*
tablespace_name file_name                                 size_mb autoextensible   maxsize_mb increment_by_mb
TEMP            +DATA/racdb/tempfile/temp.263.1141979843       20 YES            32767.984375            .625
TEMP1           +DATA/racdb/tempfile/temp1.271.1142094321     100 YES            32767.984375            1024

*/

--for more details https://ittutorial.org/what-is-the-tablespace-in-oracle/

select * from V$ASM_DISKGROUP;
/*
group_number name sector_size block_size allocation_unit_size state     type   total_mb free_mb hot_used_mb cold_used_mb required_mirror_free_mb usable_file_mb offline_disks compatibility database_compatibility voting_files
           1 DATA         512       4096              1048576 CONNECTED EXTERN    40959   36730           0         4229                       0          36730             0 11.2.0.0.0    10.1.0.0.0             N
           2 FRA          512       4096              1048576 CONNECTED EXTERN    20479   18247           0         2232                       0          18247             0 11.2.0.0.0    10.1.0.0.0             N
           3 OCR          512       4096              4194304 MOUNTED   EXTERN    25020   24588           0          432                       0          24588             0 11.2.0.0.0    10.1.0.0.0             Y
*/


----ASM Disk Space Usage Script (In Detail)

SELECT
NVL(a.name, '[CANDIDATE]') disk_group_name
, b.path disk_file_path
, b.name disk_file_name
, b.failgroup disk_file_fail_group
, b.total_mb total_mb
, (b.total_mb-b.free_mb) used_mb
, ROUND((1- (b.free_mb / b.total_mb))*100, 2) pct_used
FROM v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number) where b.header_status = 'MEMBER'
ORDER BY a.name;


/*
disk_group_name disk_file_path            disk_file_name disk_file_fail_group total_mb used_mb pct_used
DATA            /dev/oracleasm/disks/DATA DATA_0000      DATA_0000               40959    4229    10.32
FRA             /dev/oracleasm/disks/FRA  FRA_0000       FRA_0000                20479    2232     10.9
OCR             /dev/oracleasm/disks/OCR  OCR_0000       OCR_0000                25020     432     1.73
*/

----Datafiles of a particular TableSpace
select tablespace_name,file_name,bytes/1024/1024/1024 Size_GB,autoextensible,maxbytes/1024/1024/1024 MAXSIZE_GB
from dba_data_files where tablespace_name='&tablespace_name' order by 1,2;

/*
tablespace_name file_name                                        size_gb autoextensible          maxsize_gb
BACKUP_TBS      +DATA/racdb/datafile/backup_tbs.269.1142093117 .09765625 YES            31.9999847412109375
NEW_TBS_TEST    +DATA/racdb/datafile/new_tbs_test.270.1142092819       2 YES            31.9999847412109375

*/

select dbms_metadata.get_ddl('TABLESPACE','&TABLESPACE_NAME') FROM DUAL;
/*

  CREATE TABLESPACE "NEW_TBS_TEST" DATAFILE
  SIZE 2147483648
  AUTOEXTEND ON NEXT 20971520 MAXSIZE 32767M
  LOGGING ONLINE PERMANENT BLOCKSIZE 8192
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT
 NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO

*/
--user create with default tablespace ,temporary tablespaceand  quota
CREATE USER RABIN IDENTIFIED BY rabin123
DEFAULT TABLESPACE NEW_TBS_TEST
TEMPORARY TABLESPACE TEMP1
QUOTA UNLIMITED ON NEW_TBS_TEST;

SELECT * FROM dba_users WHERE username ='RABIN';
GRANT CONNECT,RESOURCE TO RABIN;

BEGIN
  FOR i IN (SELECT privilege FROM dba_sys_privs)
  LOOP
     BEGIN
         EXECUTE IMMEDIATE 'GRANT '||i.privilege||' TO RABIN';
         Dbms_Output.Put_Line('GRANT '||i.privilege||' TO RABIN');
     EXCEPTION WHEN OTHERS THEN
         NULL;
     END;
  END LOOP;
END;
/

SELECT privilege FROM dba_sys_privs;

SELECT Count(*) privilege FROM DBA_SYS_PRIVS WHERE GRANTEE='RABIN' AND ADMIN_OPTION ='NO';

BEGIN
  FOR i IN (SELECT * FROM dba_sys_privs WHERE ADMIN_OPTION = 'YES')
  LOOP
     BEGIN
         EXECUTE IMMEDIATE 'GRANT '||i.privilege||' TO RABIN WITH ADMIN OPTION';
         --Dbms_Output.Put_Line('GRANT '||i.privilege||' TO RABIN WITH ADMIN OPTION');
     EXCEPTION WHEN OTHERS THEN
         NULL;
     END;
  END LOOP;
END;
/


SELECT * FROM invoice_tbl;


create table test (snb number, real_exch varchar2(20));

insert into test (snb, real_exch)
      select 11001 + level - 1, 'GSMB'
      from dual
      connect by level <= 1000000;





  INSERT INTO test   SELECT * FROM test;

  COMMIT;
  
  SELECT Count(*) FROM test;

  /*
    "COUNT(*)"
    32000000
  */

SELECT Count(*) FROM INVOICE_TBL;

/*
  "COUNT(*)"
    399389
*/

---- drop database in RAC environment
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/

[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/

[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb1
/*
Remove instance from the database racdb? (y/[n]) y
*/

[oracle@RAC1 ~]$ srvctl remove instance -d racdb -i racdb2
/*
Remove instance from the database racdb? (y/[n]) y
*/

[oracle@RAC1 ~]$  srvctl status database -d racdb
/*
Database is not running.
*/

[oracle@RAC1 ~]$ srvctl remove database -d racdb
/*
Remove the database racdb? (y/[n]) y
*/

[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
PRCD-1120 : The resource for database racdb could not be found.
PRCR-1001 : Resource ora.racdb.db does not exist
*/
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jul 14 11:58:12 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> startup;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size             973082184 bytes
Database Buffers          570425344 bytes
Redo Buffers                7569408 bytes
Database mounted.
Database opened.
SQL> alter system set cluster_database=false scope=spfile;

System altered.

SQL> alter system set cluster_database_instances=1 scope=spfile;

System altered.

SQL> alter database disable thread 2;

Database altered.

SQL>  select thread#, group# from v$log;

   THREAD#     GROUP#
---------- ----------
         1          1
         1          2
         2          3
         2          4

SQL> alter database drop logfile group 3;

Database altered.

SQL> alter database drop logfile group 4;

Database altered.

SQL> select thread#, group# from v$log;

   THREAD#     GROUP#
---------- ----------
         1          1
         1          2

SQL> select tablespace_name from dba_data_files where tablespace_name like 'UNDOTBS%';

TABLESPACE_NAME
------------------------------
UNDOTBS1
UNDOTBS2

SQL> drop tablespace UNDOTBS2 including contents and datafiles;

Tablespace dropped.

SQL> select tablespace_name from dba_data_files where tablespace_name like 'UNDOTBS%';

TABLESPACE_NAME
------------------------------
UNDOTBS1


SQL>  create pfile='/home/oracle/backup/rmanbkp/old_db_config_files/initracdb.ora.bkp1'  from spfile;

File created.

SQL>  shut immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup mount restrict;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size             973082184 bytes
Database Buffers          570425344 bytes
Redo Buffers                7569408 bytes
Database mounted.
SQL> drop database;

Database dropped.

Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
SQL> exit
*/
[oracle@RAC1 ~]$ su - grid
Password:
[grid@RAC1 ~]$
[grid@RAC1 ~]$ asmcmd
/*
ASMCMD> ls
ARC/
ARCHIVELOG/
BACKUPSET/
ASMCMD> cd ARCHIVELOG/
ASMCMD> ls
2023_07_14/
ASMCMD> cd 2023_07_14
ASMCMD> ls
thread_1_seq_66.367.1142161271
thread_1_seq_67.365.1142161325
thread_1_seq_68.362.1142161331
thread_1_seq_69.357.1142162929
thread_1_seq_70.355.1142164411
thread_1_seq_71.278.1142164725
thread_2_seq_45.363.1142161327
thread_2_seq_46.360.1142161335
thread_2_seq_47.352.1142164719
thread_2_seq_48.350.1142164723
thread_2_seq_49.284.1142164723

ASMCMD> rm -rf thread*

ASMCMD> cd data
ASMCMD> ls
ASMCMD>

*/

[oracle@RAC1 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/dbs/
hc_racdb1.dat  init.ora  initracdb1.ora  orapwracdb1
[oracle@RAC1 dbs]$ cat initracdb1.ora
/*
SPFILE='+DATA/racdb/spfileracdb.ora'
*/

-- Required file from SOURCE_DB Server
[oracle@SOURCE_DB1 backup]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jul 14 11:02:53 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> create pfile='/home/oracle/backup/rmanbkp/old_db_config_files/spfileracdb.ora' from spfile;

File created.

SQL> exit;

[oracle@RAC1]$ cd /home/oracle/backup/rmanbkp/old_db_config_files
[oracle@RAC1 old_db_config_files]$ ls -lrt

-rwxrwxr-x 1 oracle oinstall   37 Jul 14 11:08 initracdb2.ora
-rwxrwxr-x 1 oracle oinstall 1536 Jul 14 11:08 orapwracdb2
-rwxrwxr-x 1 oracle asmadmin 1385 Jul 14 11:12 spfileracdb.ora
-rwxrwxr-x 1 oracle oinstall   37 Jul 14 11:26 initracdb1.ora
-rwxrwxr-x 1 oracle oinstall 1536 Jul 14 11:26 orapwracdb1
-rwxrwxr-x 1 oracle asmadmin 1489 Jul 14 12:04 initracdb.ora.bkp1
*/

[oracle@RAC1 old_db_config_files]$ vi spfileracdb.ora
/*
racdb1.__pga_aggregate_target=637534208
racdb2.__pga_aggregate_target=637534208
racdb1.__sga_target=922746880
racdb2.__sga_target=922746880
racdb1.__shared_io_pool_size=0
racdb2.__shared_io_pool_size=0
racdb1.__shared_pool_size=301989888
racdb2.__shared_pool_size=301989888
racdb1.__streams_pool_size=0
racdb2.__streams_pool_size=0
*.audit_file_dest='/opt/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.cluster_database=true
*.compatible='11.2.0.0.0'
*.control_files='+DATA/racdb/controlfile/current.260.1141979833','+FRA/racdb/controlfile/current.256.1141979833'
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_domain=''
*.db_name='racdb'
*.db_recovery_file_dest='+FRA'
*.db_recovery_file_dest_size=4558159872
*.diagnostic_dest='/opt/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
racdb1.instance_number=1
racdb2.instance_number=2
*.log_archive_dest_1='LOCATION=+FRA/RACDB/ARC/'
*.log_archive_format='racdb_%t_%s_%r.arc'
*.memory_target=1547698176
*.open_cursors=300
*.processes=150
*.remote_listener='RAC-scan:1521'
*.remote_login_passwordfile='exclusive'
racdb2.thread=2
racdb1.thread=1
racdb1.undo_tablespace='UNDOTBS1'
racdb2.undo_tablespace='UNDOTBS2'

*/
[root@DB-RAC1 adump]# cd /opt/app/oracle/admin/racdb/adump
[root@DB-RAC1 adump]# rm -rf *.aud

[root@DB-RAC1 adump]# cd /opt/app/11.2.0.3.0/grid/rdbms/audit
[root@RAC1 audit]#  rm -rf *.aud

[root@RAC1 audit]# cd /opt/app/oracle/product/11.2.0.3.0/db_1/rdbms/audit/
[root@RAC1 audit]# rm -rf *.aud

[root@RAC1 ]#cd /opt/app/oracle/diag/rdbms/racdb/racdb1/trace
[root@RAC1  trace]# rm -rf *


[root@RAC2 adump]# cd /opt/app/oracle/admin/racdb/adump
[root@RAC2 adump]# rm -rf *.aud
[root@RAC2 adump]#
[root@RAC2 adump]# cd /opt/app/11.2.0.3.0/grid/rdbms/audit
[root@RAC2 audit]# rm -rf *.aud
[root@RAC2 audit]#
[root@RAC2 audit]# cd /opt/app/oracle/product/11.2.0.3.0/db_1/rdbms/audit/
[root@RAC2 audit]# rm -rf *.aud

[root@RAC2 audit]# cd /opt/app/oracle/diag/rdbms/racdb/racdb2/trace/
[root@RAC2 trace]# rm -rf *
[root@RAC2 trace]#

[root@RAC1 ~]# cd /opt/app/11.2.0.3.0/grid/bin/
/*
[root@RAC1/RAC2 bin]# ./crsctl check cluster -all
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

[oracle@RAC1/RAC2 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac2,rac1

*/

[oracle@RAC1 ~]$ cd backup/rmanbkp/old_db_config_files/
[oracle@RAC1 old_db_config_files]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jul 14 13:01:54 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> !ls
initracdb1.ora  initracdb2.ora  initracdb.ora.bkp1  orapwracdb1  orapwracdb2  spfileracdb.ora
SQL> startup nomount pfile='spfileracdb.ora';
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size             973082184 bytes
Database Buffers          570425344 bytes
Redo Buffers                7569408 bytes

SQL>  create SPFILE='+DATA/racdb/spfileracdb.ora' from pfile='/home/oracle/backup/rmanbkp/old_db_config_files/spfileracdb.ora';

File created.
SQL> shut immediate;
ORA-01507: database not mounted


ORACLE instance shut down.
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 1553305600 bytes
Fixed Size                  2228664 bytes
Variable Size             973082184 bytes
Database Buffers          570425344 bytes
Redo Buffers                7569408 bytes

SQL> sho parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +DATA/racdb/spfileracdb.ora


SQL> !ps -ef | grep pmon;
grid      4730     1  0 12:57 ?        00:00:00 asm_pmon_+ASM1
oracle   10480     1  0 14:01 ?        00:00:00 ora_pmon_racdb1
oracle   10688 10095  0 14:02 pts/0    00:00:00 /bin/bash -c ps -ef | grep pmon
oracle   10690 10688  0 14:02 pts/0    00:00:00 grep pmon

*/

[oracle@RAC1 ~]$ rman target /
/*

Recovery Manager: Release 11.2.0.3.0 - Production on Fri Jul 14 14:04:01 2023

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RACDB (not mounted)

RMAN> restore controlfile from '/home/oracle/backup/rmanbkp/Control_RACDB_4b217vtv_139';

Starting restore at 14-JUL-23
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=140 instance=racdb1 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:04
output file name=+DATA/racdb/controlfile/current.268.1142172733
output file name=+FRA/racdb/controlfile/current.278.1142172733
Finished restore at 14-JUL-23

RMAN> sql 'alter database mount';

sql statement: alter database mount
released channel: ORA_DISK_1
RMAN> catalog start with '/home/oracle/backup/rmanbkp/';

Starting implicit crosscheck backup at 14-JUL-23
allocated channel: ORA_DISK_1
allocated channel: ORA_DISK_2
allocated channel: ORA_DISK_3
allocated channel: ORA_DISK_4
Crosschecked 98 objects
Crosschecked 33 objects
Finished implicit crosscheck backup at 14-JUL-23

Starting implicit crosscheck copy at 14-JUL-23
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4
Finished implicit crosscheck copy at 14-JUL-23

searching for all files in the recovery area
cataloging files...
no files cataloged

searching for all files that match the pattern /home/oracle/backup/rmanbkp/
List of Files Unknown to the Database
=====================================
File Name: /home/oracle/backup/rmanbkp/Control_RACDB_4b217vtv_139
File Name: /home/oracle/backup/rmanbkp/fullbkp.sh
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/orapwracdb1
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/spfileracdb.ora
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/orapwracdb2
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/initracdb1.ora
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/initracdb2.ora
File Name: /home/oracle/backup/rmanbkp/old_db_config_files/initracdb.ora.bkp1
File Name: /home/oracle/backup/rmanbkp/logs/racdb_full_bkp_2023_07_14.log

Do you really want to catalog the above files (enter YES or NO)? y
cataloging files...
cataloging done

List of Cataloged Files
=======================
File Name: /home/oracle/backup/rmanbkp/Control_RACDB_4b217vtv_139
RMAN> restore database;

Starting restore at 14-JUL-23
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4

channel ORA_DISK_1: starting datafile backup set restore
channel ORA_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_DISK_1: restoring datafile 00004 to +DATA/racdb/datafile/users.259.1141979775
channel ORA_DISK_1: restoring datafile 00008 to +DATA/racdb/datafile/new_tbs_test.270.1142092819
channel ORA_DISK_1: reading from backup piece /home/oracle/backup/rmanbkp/database_RACDB_41217vrp_129
channel ORA_DISK_2: starting datafile backup set restore
channel ORA_DISK_2: specifying datafile(s) to restore from backup set
channel ORA_DISK_2: restoring datafile 00001 to +DATA/racdb/datafile/system.256.1141979773
channel ORA_DISK_2: restoring datafile 00006 to +DATA/racdb/datafile/undotbs2.265.1141979915
channel ORA_DISK_2: reading from backup piece /home/oracle/backup/rmanbkp/database_RACDB_42217vrp_130
channel ORA_DISK_3: starting datafile backup set restore
channel ORA_DISK_3: specifying datafile(s) to restore from backup set
channel ORA_DISK_3: restoring datafile 00002 to +DATA/racdb/datafile/sysaux.257.1141979775
channel ORA_DISK_3: restoring datafile 00003 to +DATA/racdb/datafile/undotbs1.258.1141979775
channel ORA_DISK_3: reading from backup piece /home/oracle/backup/rmanbkp/database_RACDB_43217vrq_131
channel ORA_DISK_4: starting datafile backup set restore
channel ORA_DISK_4: specifying datafile(s) to restore from backup set
channel ORA_DISK_4: restoring datafile 00005 to +DATA/racdb/datafile/example.264.1141979847
channel ORA_DISK_4: restoring datafile 00007 to +DATA/racdb/datafile/backup_tbs.269.1142093117
channel ORA_DISK_4: reading from backup piece /home/oracle/backup/rmanbkp/database_RACDB_44217vs5_132
channel ORA_DISK_2: piece handle=/home/oracle/backup/rmanbkp/database_RACDB_42217vrp_130 tag=FULLBKP
channel ORA_DISK_2: restored backup piece 1
channel ORA_DISK_2: restore complete, elapsed time: 00:00:25
channel ORA_DISK_3: piece handle=/home/oracle/backup/rmanbkp/database_RACDB_43217vrq_131 tag=FULLBKP
channel ORA_DISK_3: restored backup piece 1
channel ORA_DISK_3: restore complete, elapsed time: 00:00:25
channel ORA_DISK_4: piece handle=/home/oracle/backup/rmanbkp/database_RACDB_44217vs5_132 tag=FULLBKP
channel ORA_DISK_4: restored backup piece 1
channel ORA_DISK_4: restore complete, elapsed time: 00:00:25
channel ORA_DISK_1: piece handle=/home/oracle/backup/rmanbkp/database_RACDB_41217vrp_129 tag=FULLBKP
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:35
Finished restore at 14-JUL-23

RMAN> recover database;

Starting recover at 14-JUL-23
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4

starting media recovery

channel ORA_DISK_1: starting archived log restore to default destination
channel ORA_DISK_1: restoring archived log
archived log thread=2 sequence=45
channel ORA_DISK_1: reading from backup piece /home/oracle/backup/rmanbkp/arch_RACDB_47217vts_135
channel ORA_DISK_2: starting archived log restore to default destination
channel ORA_DISK_2: restoring archived log
archived log thread=1 sequence=67
channel ORA_DISK_2: restoring archived log
archived log thread=1 sequence=68
channel ORA_DISK_2: reading from backup piece /home/oracle/backup/rmanbkp/arch_RACDB_49217vts_137
channel ORA_DISK_3: starting archived log restore to default destination
channel ORA_DISK_3: restoring archived log
archived log thread=2 sequence=46
channel ORA_DISK_3: reading from backup piece /home/oracle/backup/rmanbkp/arch_RACDB_4a217vts_138
channel ORA_DISK_1: piece handle=/home/oracle/backup/rmanbkp/arch_RACDB_47217vts_135 tag=ARCHBKP
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
channel ORA_DISK_2: piece handle=/home/oracle/backup/rmanbkp/arch_RACDB_49217vts_137 tag=ARCHBKP
channel ORA_DISK_2: restored backup piece 1
channel ORA_DISK_2: restore complete, elapsed time: 00:00:01
archived log file name=+FRA/racdb/arc/racdb_1_67_1141979836.arc thread=1 sequence=67
archived log file name=+FRA/racdb/arc/racdb_2_45_1141979836.arc thread=2 sequence=45
archived log file name=+FRA/racdb/arc/racdb_1_68_1141979836.arc thread=1 sequence=68
channel ORA_DISK_3: piece handle=/home/oracle/backup/rmanbkp/arch_RACDB_4a217vts_138 tag=ARCHBKP
channel ORA_DISK_3: restored backup piece 1
channel ORA_DISK_3: restore complete, elapsed time: 00:00:01
archived log file name=+FRA/racdb/arc/racdb_2_46_1141979836.arc thread=2 sequence=46
unable to find archived log
archived log thread=1 sequence=69
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 07/14/2023 14:15:54
RMAN-06054: media recovery requesting unknown archived log for thread 1 with sequence 69 and starting SCN of 1515889

RMAN> alter database open resetlogs;

database opened
SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
*/

[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jul 14 14:33:05 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options
SQL> select status, instance_name from gv$instance;

STATUS       INSTANCE_NAME
------------ ----------------
OPEN         racdb1

SQL> select name, open_mode, dbid from v$database;

NAME      OPEN_MODE                  DBID
--------- -------------------- ----------
RACDB     READ WRITE           1139596601

SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

*/

[oracle@RAC1 ~]$  which srvctl
/*
/opt/app/oracle/product/11.2.0.3.0/db_1/bin/srvctl
*/

[oracle@RAC1 ~]$ srvctl add database -d racdb -o /opt/app/oracle/product/11.2.0.3.0/db_1
[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances:
Disk Groups:
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl add instance -d racdb -i racdb1 -n RAC1
[oracle@RAC1 ~]$ srvctl add instance -d racdb -i racdb2 -n RAC2

[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups:
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl status database -d racdb
/*
Instance racdb1 is not running on node rac1
Instance racdb2 is not running on node rac2
*/
[oracle@RAC1 ~]$ srvctl start database -d  racdb
[oracle@RAC1 ~]$ srvctl status database -d  racdb
/*
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
*/
[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: DATA,FRA
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl stop database -d racdb
[oracle@RAC1 ~]$ srvctl start database -d  racdb
[oracle@RAC1 ~]$ srvctl status database -d racdb
Instance racdb1 is running on node rac1
Instance racdb2 is running on node rac2
[oracle@RAC1 ~]$ srvctl config database -d racdb -a
/*
Database unique name: racdb
Database name:
Oracle home: /opt/app/oracle/product/11.2.0.3.0/db_1
Oracle user: oracle
Spfile:
Domain:
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: racdb
Database instances: racdb1,racdb2
Disk Groups: DATA,FRA
Mount point paths:
Services:
Type: RAC
Database is enabled
Database is administrator managed
*/

[oracle@RAC1 ~]$ srvctl status listener -l listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac2,rac1
*/
[oracle@RAC1 ~]$ lsnrctl status
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 14-JUL-2023 14:49:16

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                14-JUL-2023 12:57:51
Uptime                    0 days 1 hr. 51 min. 25 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.11)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.13)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM1", status READY, has 1 handler(s) for this service...
Service "racdb" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 1 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

[oracle@RAC1 ~]$  cd /opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/
[oracle@RAC1 admin]$ cat tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.11)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )
*/
[oracle@RAC2 ~]$ cd /opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/
[oracle@RAC2 admin]$ ls
samples  shrept.lst  tnsnames.ora
[oracle@RAC2 admin]$ cat tnsnames.ora
/*
# tnsnames.ora Network Configuration File: /opt/app/oracle/product/11.2.0.3.0/db_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

RACDB2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.120.12)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )
*/

[oracle@RAC1 admin]$ tnsping racdb
/*
TNS Ping Utility for Linux: Version 11.2.0.3.0 - Production on 14-JUL-2023 14:52:27

Copyright (c) 1997, 2011, Oracle.  All rights reserved.

Used parameter files:


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = RAC-scan)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = racdb)))
OK (0 msec)
*/


--after restored database verify the tables and it's RECORD
[oracle@RAC1 ~]$ sqlplus / as sysdba
/*
SQL*Plus: Release 11.2.0.3.0 Production on Fri Jul 14 14:55:54 2023

Copyright (c) 1982, 2011, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
Data Mining and Real Application Testing options

SQL> conn rabin/rabin123
Connected.
select tablespace_name, file_name, bytes, autoextensible, maxbytes from dba_data_files order by 1,2;

tablespace_name file_name                                             bytes autoextensible    maxbytes
BACKUP_TBS      +DATA/racdb/datafile/backup_tbs.270.1142172843    104857600 YES            34359721984
EXAMPLE         +DATA/racdb/datafile/example.261.1142172841       362414080 YES            34359721984
NEW_TBS_TEST    +DATA/racdb/datafile/new_tbs_test.271.1142172841 2147483648 YES            34359721984
SYSAUX          +DATA/racdb/datafile/sysaux.262.1142172841        597688320 YES            34359721984
SYSTEM          +DATA/racdb/datafile/system.263.1142172841        754974720 YES            34359721984
UNDOTBS1        +DATA/racdb/datafile/undotbs1.269.1142172843       94371840 YES            34359721984
UNDOTBS2        +DATA/racdb/datafile/undotbs2.264.1142172843       26214400 YES            34359721984
USERS           +DATA/racdb/datafile/users.259.1142172843           5242880 YES            34359721984

SELECT * FROM user_tables;

table_name  tablespace_name  status pct_free pct_used ini_trans max_trans initial_extent next_extent min_extents max_extents pct_increase freelists freelist_groups logging
INVOICE_TBL NEW_TBS_TEST     VALID        10                  1       255          65536     1048576           1  2147483645                                        YES    
TEST        NEW_TBS_TEST     VALID        10                  1       255          65536     1048576           1  2147483645                                        YES    

SELECT Count(*) FROM test;

  /*
    "COUNT(*)"
    32000000
  */
  
  
  
 SELECT Count(*) FROM INVOICE_TBL;

/*
  "COUNT(*)"
    399389
*/

*/


