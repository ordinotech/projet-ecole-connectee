root@DbSrv:~# systemctl status mariadb.s
Unit mariadb.s.service could not be found.
root@DbSrv:~# systemctl status mariadb  
* mariadb.service - MariaDB 10.6.23 database server
     Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2026-07-19 02:11:49 UTC; 1h 14min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 166 ExecStartPre=/usr/bin/install -m 755 -o mysql -g root -d /var/run/mysqld (code=exited, status=0/SUCCESS)
    Process: 171 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 173 ExecStartPre=/bin/sh -c [ ! -e /usr/bin/galera_recovery ] && VAR= ||   VAR=`/usr/bin/galera_recovery`; [ $?>
    Process: 222 ExecStartPost=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 224 ExecStartPost=/etc/mysql/debian-start (code=exited, status=0/SUCCESS)
   Main PID: 202 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 10 (limit: 61261)
     Memory: 93.8M
        CPU: 709ms
     CGroup: /system.slice/mariadb.service
             `-202 /usr/sbin/mariadbd
Jul 19 03:04:43 DbSrv mariadbd[202]: 2026-07-19  3:04:43 32 [Warning] IP address '10.0.1.2' could not be resolved: Temporary>
Jul 19 03:04:43 DbSrv mariadbd[202]: 2026-07-19  3:04:43 32 [Warning] Aborted connection 32 to db: 'unconnected' user: 'unau>
Jul 19 03:10:44 DbSrv mariadbd[202]: 2026-07-19  3:10:44 33 [Warning] IP address '10.0.1.2' could not be resolved: Temporary>
Jul 19 03:10:54 DbSrv mariadbd[202]: 2026-07-19  3:10:54 33 [Warning] Aborted connection 33 to db: 'unconnected' user: 'unau>
Jul 19 03:21:12 DbSrv mariadbd[202]: 2026-07-19  3:21:12 34 [Warning] IP address '10.0.1.2' could not be resolved: Temporary>
Jul 19 03:21:15 DbSrv mariadbd[202]: 2026-07-19  3:21:15 35 [Warning] IP address '10.0.1.2' could not be resolved: Temporary>
Jul 19 03:21:17 DbSrv mariadbd[202]: 2026-07-19  3:21:17 34 [Warning] Aborted connection 34 to db: 'unconnected' user: 'unau>
Jul 19 03:21:17 DbSrv mariadbd[202]: 2026-07-19  3:21:17 35 [Warning] Aborted connection 35 to db: 'unconnected' user: 'unau>
Jul 19 03:21:23 DbSrv mariadbd[202]: 2026-07-19  3:21:23 36 [Warning] IP address '10.0.1.2' could not be resolved: Temporary>
Jul 19 03:21:33 DbSrv mariadbd[202]: 2026-07-19  3:21:33 36 [Warning] Aborted connection 36 to db: 'unconnected' user: 'unau>
lines 1-28/28 (END)
root@DbSrv:~# 
