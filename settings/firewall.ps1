<#
.SYNOPSIS
    Брандмауер: блокування протоколів Inbound/Outbound, захист від зовнішніх загроз,
    TOR/ChatGPT/Wifi Pineapple, захист від Lateral Movement, жорстке налаштування правил.
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1.
    Джерела: PSHardening (GitHub), CIS Benchmarks, ACSC Network Hardening Guide.
    ⚠ УВАГА: Деякі правила (Whitelist-Only Outbound, SMBv2) можуть порушити роботу мережі —
    перевіряйте на тестовому середовищі.
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── БЛОКУВАННЯ ЗАСТАРІЛИХ / НЕБЕЗПЕЧНИХ ПРОТОКОЛІВ INBOUND ───────────────
# Відповідає: Block Protocols Inbound.ps1 (PSHardening) 🔴 Критично
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Блокування протоколів Inbound — Legacy/Obsolete"
    Name  = "Заблокувати застарілі небезпечні протоколи Inbound (Telnet, FTP, rsh, finger, chargen, echo…)"
    Desc  = @"
Блокує вхідний трафік застарілих та небезпечних мережевих протоколів:
• Telnet (23/TCP) — передає дані відкритим текстом, замінений SSH
• FTP (20-21/TCP) — автентифікація відкритим текстом, замінений SFTP/FTPS
• TFTP (69/UDP) — без автентифікації, використовується для атак
• Gopher (70/TCP) — застарілий протокол
• Finger (79/TCP) — розкриває інформацію про користувачів
• rsh/rlogin/rexec (512-514/TCP) — застарілі UNIX сервіси без шифрування
• Chargen (19/TCP+UDP), Echo (7/TCP+UDP), Daytime (13/TCP), Systat (11/TCP),
  Qotd (17/TCP+UDP), Discard (9/TCP+UDP) — потенційні вектори DoS-атак
"@
    Apply = {
        $rules = @(
            @{ N='Block Telnet Inbound';      P='TCP'; L='23' },
            @{ N='Block FTP Data Inbound';    P='TCP'; L='20' },
            @{ N='Block FTP Control Inbound'; P='TCP'; L='21' },
            @{ N='Block TFTP Inbound';        P='UDP'; L='69' },
            @{ N='Block Gopher Inbound';      P='TCP'; L='70' },
            @{ N='Block Finger Inbound';      P='TCP'; L='79' },
            @{ N='Block rexec Inbound';       P='TCP'; L='512' },
            @{ N='Block rlogin Inbound';      P='TCP'; L='513' },
            @{ N='Block rsh Inbound';         P='TCP'; L='514' },
            @{ N='Block Chargen TCP Inbound'; P='TCP'; L='19' },
            @{ N='Block Chargen UDP Inbound'; P='UDP'; L='19' },
            @{ N='Block Echo TCP Inbound';    P='TCP'; L='7' },
            @{ N='Block Echo UDP Inbound';    P='UDP'; L='7' },
            @{ N='Block Daytime Inbound';     P='TCP'; L='13' },
            @{ N='Block Systat Inbound';      P='TCP'; L='11' },
            @{ N='Block Qotd TCP Inbound';    P='TCP'; L='17' },
            @{ N='Block Qotd UDP Inbound';    P='UDP'; L='17' },
            @{ N='Block Discard TCP Inbound'; P='TCP'; L='9' },
            @{ N='Block Discard UDP Inbound'; P='UDP'; L='9' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Block Telnet Inbound','Block FTP Data Inbound','Block FTP Control Inbound',
          'Block TFTP Inbound','Block Gopher Inbound','Block Finger Inbound',
          'Block rexec Inbound','Block rlogin Inbound','Block rsh Inbound',
          'Block Chargen TCP Inbound','Block Chargen UDP Inbound',
          'Block Echo TCP Inbound','Block Echo UDP Inbound','Block Daytime Inbound',
          'Block Systat Inbound','Block Qotd TCP Inbound','Block Qotd UDP Inbound',
          'Block Discard TCP Inbound','Block Discard UDP Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block Telnet Inbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Блокування протоколів Inbound — Admin/Management"
    Name  = "Заблокувати адміністративні протоколи Inbound (RDP, WinRM, RPC, NetBIOS, WMI, Kerberos)"
    Desc  = @"
Блокує вхідний трафік протоколів дистанційного адміністрування та аутентифікації:
• RDP (3389/TCP+UDP) — Remote Desktop Protocol, частий вектор атак
• WinRM HTTP (5985/TCP) — PowerShell Remoting нешифровано
• WinRM HTTPS (5986/TCP) — PowerShell Remoting шифровано
• MS-RPC Endpoint Mapper (135/TCP+UDP) — точка входу DCOM/WMI
• NetBIOS Name Service (137/UDP), Datagram (138/UDP), Session (139/TCP)
• Kerberos (88/TCP+UDP) — протокол автентифікації Active Directory
• LDAP (389/TCP+UDP), LDAPS (636/TCP+UDP) — служба каталогів
⚠ Увага: у доменному середовищі ці правила можуть блокувати легітимний трафік.
"@
    Apply = {
        $rules = @(
            @{ N='Block RDP TCP Inbound';      P='TCP'; L='3389' },
            @{ N='Block RDP UDP Inbound';      P='UDP'; L='3389' },
            @{ N='Block WinRM HTTP Inbound';   P='TCP'; L='5985' },
            @{ N='Block WinRM HTTPS Inbound';  P='TCP'; L='5986' },
            @{ N='Block RPC Mapper TCP Inbound'; P='TCP'; L='135' },
            @{ N='Block RPC Mapper UDP Inbound'; P='UDP'; L='135' },
            @{ N='Block NetBIOS-NS Inbound';   P='UDP'; L='137' },
            @{ N='Block NetBIOS-DGM Inbound';  P='UDP'; L='138' },
            @{ N='Block NetBIOS-SSN Inbound';  P='TCP'; L='139' },
            @{ N='Block Kerberos TCP Inbound'; P='TCP'; L='88' },
            @{ N='Block Kerberos UDP Inbound'; P='UDP'; L='88' },
            @{ N='Block LDAP TCP Inbound';     P='TCP'; L='389' },
            @{ N='Block LDAP UDP Inbound';     P='UDP'; L='389' },
            @{ N='Block LDAPS Inbound';        P='TCP'; L='636' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Block RDP TCP Inbound','Block RDP UDP Inbound',
          'Block WinRM HTTP Inbound','Block WinRM HTTPS Inbound',
          'Block RPC Mapper TCP Inbound','Block RPC Mapper UDP Inbound',
          'Block NetBIOS-NS Inbound','Block NetBIOS-DGM Inbound','Block NetBIOS-SSN Inbound',
          'Block Kerberos TCP Inbound','Block Kerberos UDP Inbound',
          'Block LDAP TCP Inbound','Block LDAP UDP Inbound','Block LDAPS Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block RDP TCP Inbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Блокування протоколів Inbound — Databases/DevOps"
    Name  = "Заблокувати порти баз даних та DevOps Inbound (MSSQL, MySQL, PostgreSQL, MongoDB, Redis, Docker, K8s…)"
    Desc  = @"
Блокує вхідний трафік до портів баз даних та хмарних/DevOps сервісів:
• MSSQL (1433-1434/TCP+UDP) — Microsoft SQL Server
• MySQL/MariaDB (3306/TCP), PostgreSQL (5432/TCP)
• MongoDB (27017-27019/TCP), CouchDB (5984/TCP), Redis (6379/TCP)
• Memcached (11211/TCP+UDP), Elasticsearch (9200/TCP, 9300/TCP)
• Cassandra (9042/TCP, 7000-7001/TCP), Neo4j (7474/TCP, 7687/TCP)
• RabbitMQ (5672/TCP, 15672/TCP), Apache Kafka (9092/TCP)
• Docker API (2375-2377/TCP), Kubernetes API (6443/TCP), etcd (2379-2380/TCP)
• Consul (8300-8301/TCP+UDP, 8500/TCP, 8600/TCP+UDP)
• MinIO (9000/TCP), Prometheus (9090/TCP), Grafana (3000/TCP)
"@
    Apply = {
        $rules = @(
            @{ N='Block MSSQL TCP Inbound';         P='TCP'; L='1433' },
            @{ N='Block MSSQL Browser Inbound';     P='UDP'; L='1434' },
            @{ N='Block MySQL Inbound';             P='TCP'; L='3306' },
            @{ N='Block PostgreSQL Inbound';        P='TCP'; L='5432' },
            @{ N='Block MongoDB Inbound';           P='TCP'; L='27017' },
            @{ N='Block MongoDB 27018 Inbound';     P='TCP'; L='27018' },
            @{ N='Block MongoDB 27019 Inbound';     P='TCP'; L='27019' },
            @{ N='Block CouchDB Inbound';           P='TCP'; L='5984' },
            @{ N='Block Redis Inbound';             P='TCP'; L='6379' },
            @{ N='Block Memcached TCP Inbound';     P='TCP'; L='11211' },
            @{ N='Block Memcached UDP Inbound';     P='UDP'; L='11211' },
            @{ N='Block Elasticsearch HTTP Inbound'; P='TCP'; L='9200' },
            @{ N='Block Elasticsearch Trans Inbound'; P='TCP'; L='9300' },
            @{ N='Block Cassandra CQL Inbound';     P='TCP'; L='9042' },
            @{ N='Block Cassandra Internal Inbound'; P='TCP'; L='7000' },
            @{ N='Block Cassandra TLS Inbound';     P='TCP'; L='7001' },
            @{ N='Block Neo4j HTTP Inbound';        P='TCP'; L='7474' },
            @{ N='Block Neo4j Bolt Inbound';        P='TCP'; L='7687' },
            @{ N='Block RabbitMQ AMQP Inbound';     P='TCP'; L='5672' },
            @{ N='Block RabbitMQ Mgmt Inbound';     P='TCP'; L='15672' },
            @{ N='Block Kafka Inbound';             P='TCP'; L='9092' },
            @{ N='Block Docker API Inbound';        P='TCP'; L='2375' },
            @{ N='Block Docker TLS Inbound';        P='TCP'; L='2376' },
            @{ N='Block Docker Swarm Inbound';      P='TCP'; L='2377' },
            @{ N='Block K8s API Inbound';           P='TCP'; L='6443' },
            @{ N='Block K8s Kubelet Inbound';       P='TCP'; L='10250' },
            @{ N='Block etcd Client Inbound';       P='TCP'; L='2379' },
            @{ N='Block etcd Peer Inbound';         P='TCP'; L='2380' },
            @{ N='Block Consul RPC Inbound';        P='TCP'; L='8300' },
            @{ N='Block Consul LAN TCP Inbound';    P='TCP'; L='8301' },
            @{ N='Block Consul LAN UDP Inbound';    P='UDP'; L='8301' },
            @{ N='Block Consul HTTP Inbound';       P='TCP'; L='8500' },
            @{ N='Block MinIO Inbound';             P='TCP'; L='9000' },
            @{ N='Block Prometheus Inbound';        P='TCP'; L='9090' },
            @{ N='Block Grafana Inbound';           P='TCP'; L='3000' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Block MSSQL TCP Inbound','Block MSSQL Browser Inbound','Block MySQL Inbound',
          'Block PostgreSQL Inbound','Block MongoDB Inbound','Block MongoDB 27018 Inbound',
          'Block MongoDB 27019 Inbound','Block CouchDB Inbound','Block Redis Inbound',
          'Block Memcached TCP Inbound','Block Memcached UDP Inbound',
          'Block Elasticsearch HTTP Inbound','Block Elasticsearch Trans Inbound',
          'Block Cassandra CQL Inbound','Block Cassandra Internal Inbound','Block Cassandra TLS Inbound',
          'Block Neo4j HTTP Inbound','Block Neo4j Bolt Inbound',
          'Block RabbitMQ AMQP Inbound','Block RabbitMQ Mgmt Inbound','Block Kafka Inbound',
          'Block Docker API Inbound','Block Docker TLS Inbound','Block Docker Swarm Inbound',
          'Block K8s API Inbound','Block K8s Kubelet Inbound',
          'Block etcd Client Inbound','Block etcd Peer Inbound',
          'Block Consul RPC Inbound','Block Consul LAN TCP Inbound','Block Consul LAN UDP Inbound',
          'Block Consul HTTP Inbound','Block MinIO Inbound','Block Prometheus Inbound','Block Grafana Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block Redis Inbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Блокування протоколів Inbound — UNIX/Remote Display"
    Name  = "Заблокувати UNIX-сервіси та Remote Display Inbound (NFS, rpcbind, X11, VNC, XDMCP)"
    Desc  = @"
Блокує вхідний трафік до мережевих UNIX-сервісів та протоколів відображення:
• NFS (2049/TCP+UDP) — Network File System, доступ до файлів без аутентифікації
• rpcbind/portmapper (111/TCP+UDP) — брокер RPC-сервісів UNIX
• X11 (6000-6063/TCP) — X Window System, передає дані без шифрування
• VNC (5900/TCP+UDP, 5800/TCP) — Virtual Network Computing
• XDMCP (177/UDP) — X Display Manager Control Protocol
"@
    Apply = {
        $rules = @(
            @{ N='Block NFS TCP Inbound';      P='TCP'; L='2049' },
            @{ N='Block NFS UDP Inbound';      P='UDP'; L='2049' },
            @{ N='Block rpcbind TCP Inbound';  P='TCP'; L='111' },
            @{ N='Block rpcbind UDP Inbound';  P='UDP'; L='111' },
            @{ N='Block X11 Inbound';          P='TCP'; L='6000-6063' },
            @{ N='Block VNC TCP Inbound';      P='TCP'; L='5900' },
            @{ N='Block VNC UDP Inbound';      P='UDP'; L='5900' },
            @{ N='Block VNC Web Inbound';      P='TCP'; L='5800' },
            @{ N='Block XDMCP Inbound';        P='UDP'; L='177' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Block NFS TCP Inbound','Block NFS UDP Inbound',
          'Block rpcbind TCP Inbound','Block rpcbind UDP Inbound',
          'Block X11 Inbound','Block VNC TCP Inbound','Block VNC UDP Inbound',
          'Block VNC Web Inbound','Block XDMCP Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block X11 Inbound' -ErrorAction SilentlyContinue) }
},

# ════════════════════════════════════════════════════════════════════════
# ── БЛОКУВАННЯ НЕБЕЗПЕЧНИХ ПРОТОКОЛІВ OUTBOUND ───────────────────────────
# Відповідає: Block Protocols Outbound.ps1 (PSHardening) 🔴 Критично
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Блокування протоколів Outbound — Небезпечні"
    Name  = "Заблокувати застарілі небезпечні протоколи Outbound (Telnet, FTP, rsh, TFTP, IRC, SNMP…)"
    Desc  = @"
Блокує вихідний трафік небезпечних та застарілих мережевих протоколів:
• Telnet (23/TCP), FTP (20-21/TCP) — передають автентифікаційні дані відкритим текстом
• rsh/rlogin/rexec (512-514/TCP) — застарілі UNIX сервіси
• TFTP (69/UDP) — без аутентифікації, використовується малварем
• IRC (6660-6669, 6697, 7000/TCP) — часто використовується для C2 (Command & Control)
• SNMP (161-162/UDP) — може витікати інформацію про мережу
• rpcbind (111/TCP+UDP) — брокер UNIX RPC-сервісів
• Echo (7), Chargen (19), Daytime (13) — застарілі сервіси
"@
    Apply = {
        $rules = @(
            @{ N='Block Telnet Outbound';       P='TCP'; R='23' },
            @{ N='Block FTP Data Outbound';     P='TCP'; R='20' },
            @{ N='Block FTP Control Outbound';  P='TCP'; R='21' },
            @{ N='Block rexec Outbound';        P='TCP'; R='512' },
            @{ N='Block rlogin Outbound';       P='TCP'; R='513' },
            @{ N='Block rsh Outbound';          P='TCP'; R='514' },
            @{ N='Block TFTP Outbound';         P='UDP'; R='69' },
            @{ N='Block IRC Outbound 6660-6669'; P='TCP'; R='6660-6669' },
            @{ N='Block IRC SSL Outbound';      P='TCP'; R='6697' },
            @{ N='Block IRC 7000 Outbound';     P='TCP'; R='7000' },
            @{ N='Block SNMP UDP Outbound 161'; P='UDP'; R='161' },
            @{ N='Block SNMP UDP Outbound 162'; P='UDP'; R='162' },
            @{ N='Block rpcbind TCP Outbound';  P='TCP'; R='111' },
            @{ N='Block rpcbind UDP Outbound';  P='UDP'; R='111' },
            @{ N='Block Echo Outbound';         P='TCP'; R='7' },
            @{ N='Block Chargen Outbound';      P='TCP'; R='19' },
            @{ N='Block Daytime Outbound';      P='TCP'; R='13' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Outbound -Protocol $r.P `
                -RemotePort $r.R -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Block Telnet Outbound','Block FTP Data Outbound','Block FTP Control Outbound',
          'Block rexec Outbound','Block rlogin Outbound','Block rsh Outbound',
          'Block TFTP Outbound','Block IRC Outbound 6660-6669','Block IRC SSL Outbound',
          'Block IRC 7000 Outbound','Block SNMP UDP Outbound 161','Block SNMP UDP Outbound 162',
          'Block rpcbind TCP Outbound','Block rpcbind UDP Outbound',
          'Block Echo Outbound','Block Chargen Outbound','Block Daytime Outbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block Telnet Outbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Блокування протоколів Outbound — Небезпечні"
    Name  = "Whitelist Outbound — дозволити лише HTTP/HTTPS/DNS/NTP, блокувати всі інші вихідні"
    Desc  = @"
⚠ УВАГА: Жорстке правило — може порушити роботу деяких застосунків!
Блокує весь вихідний TCP/UDP трафік ОКРІМ дозволених портів:
• 80/TCP (HTTP), 443/TCP (HTTPS) — веб-трафік
• 53/TCP+UDP (DNS) — служба доменних імен
• 123/UDP (NTP) — синхронізація часу
• 67-68/UDP (DHCP) — отримання IP-адреси
Рекомендується для максимально ізольованих станцій.
Використовуйте з обережністю у виробничих середовищах.
"@
    Apply = {
        # Дозволити необхідний трафік явно
        $allows = @(
            @{ N='Allow HTTP Outbound';   D='Outbound'; P='TCP'; R='80';  A='Allow' },
            @{ N='Allow HTTPS Outbound';  D='Outbound'; P='TCP'; R='443'; A='Allow' },
            @{ N='Allow DNS TCP Outbound'; D='Outbound'; P='TCP'; R='53'; A='Allow' },
            @{ N='Allow DNS UDP Outbound'; D='Outbound'; P='UDP'; R='53'; A='Allow' },
            @{ N='Allow NTP Outbound';    D='Outbound'; P='UDP'; R='123'; A='Allow' },
            @{ N='Allow DHCP Outbound';   D='Outbound'; P='UDP'; R='67-68'; A='Allow' }
        )
        foreach ($r in $allows) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction $r.D -Protocol $r.P `
                -RemotePort $r.R -Action $r.A -Profile Any -Enabled True | Out-Null
        }
        # Заблокувати всі інші вихідні TCP/UDP
        Remove-NetFirewallRule -DisplayName 'Block All Other TCP Outbound (Whitelist)' -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block All Other UDP Outbound (Whitelist)' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block All Other TCP Outbound (Whitelist)' -Direction Outbound `
            -Protocol TCP -Action Block -Profile Any -Enabled True | Out-Null
        New-NetFirewallRule -DisplayName 'Block All Other UDP Outbound (Whitelist)' -Direction Outbound `
            -Protocol UDP -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        @('Allow HTTP Outbound','Allow HTTPS Outbound',
          'Allow DNS TCP Outbound','Allow DNS UDP Outbound',
          'Allow NTP Outbound','Allow DHCP Outbound',
          'Block All Other TCP Outbound (Whitelist)',
          'Block All Other UDP Outbound (Whitelist)') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block All Other TCP Outbound (Whitelist)' -ErrorAction SilentlyContinue) }
},

# ════════════════════════════════════════════════════════════════════════
# ── ЖОРСТКЕ НАЛАШТУВАННЯ OUTBOUND БРАНДМАУЕРА (Domain/Private) ──────────
# Відповідає: Outbound Firewall Hardening Command.ps1 (PSHardening) 🟠 Важливо
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Жорстке налаштування брандмауера"
    Name  = "Outbound Firewall Hardening — блокувати вихідні за замовчуванням для Domain/Private профілів"
    Desc  = @"
Встановлює DefaultOutboundAction=Block для профілів Domain та Private:
• У Domain та Private профілях вихідний трафік блокується за замовчуванням
• Public профіль залишається з Allow outbound (стандартне налаштування для Public)
• Весь дозволений вихідний трафік має бути явно вказаний у правилах
Важливо: переконайтеся, що базові правила (DNS, HTTP, HTTPS) налаштовані до застосування.
"@
    Apply = {
        Set-NetFirewallProfile -Profile Domain,Private -DefaultOutboundAction Block -ErrorAction SilentlyContinue
        # Дозволити базовий вихідний трафік для Domain/Private
        $allows = @(
            @{ N='FW Allow DNS Out Domain';   P='UDP'; R='53' },
            @{ N='FW Allow HTTPS Out Domain'; P='TCP'; R='443' },
            @{ N='FW Allow HTTP Out Domain';  P='TCP'; R='80' },
            @{ N='FW Allow NTP Out Domain';   P='UDP'; R='123' }
        )
        foreach ($r in $allows) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Outbound -Protocol $r.P `
                -RemotePort $r.R -Action Allow -Profile Domain,Private -Enabled True | Out-Null
        }
    }
    Revert = {
        Set-NetFirewallProfile -Profile Domain,Private -DefaultOutboundAction Allow -ErrorAction SilentlyContinue
        @('FW Allow DNS Out Domain','FW Allow HTTPS Out Domain','FW Allow HTTP Out Domain','FW Allow NTP Out Domain') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = {
        $p = Get-NetFirewallProfile -Profile Domain -ErrorAction SilentlyContinue
        $p -and $p.DefaultOutboundAction -eq 'Block'
    }
},

[PSCustomObject]@{
    Group = "Жорстке налаштування брандмауера"
    Name  = "Block Domain Profile — блокувати весь трафік Domain профілю"
    Desc  = @"
Відповідає: Block Domain Profile traffic.ps1 (PSHardening) 🟠 Важливо
Блокує вхідні та вихідні з'єднання у Domain мережевому профілі:
• Застосовується, коли станція підключена до корпоративної мережі
• DefaultInboundAction=Block, DefaultOutboundAction=Block для Domain
⚠ Важливо для home/standalone машин — у домені може порушити роботу.
"@
    Apply = {
        Set-NetFirewallProfile -Profile Domain -Enabled True `
            -DefaultInboundAction Block -DefaultOutboundAction Block -ErrorAction SilentlyContinue
    }
    Revert = {
        Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block `
            -DefaultOutboundAction Allow -ErrorAction SilentlyContinue
    }
    Check = {
        $p = Get-NetFirewallProfile -Profile Domain -ErrorAction SilentlyContinue
        $p -and $p.DefaultInboundAction -eq 'Block' -and $p.DefaultOutboundAction -eq 'Block'
    }
},

[PSCustomObject]@{
    Group = "Жорстке налаштування брандмауера"
    Name  = "Налаштування Remote Access Inbound/Outbound — заборонити за замовчуванням"
    Desc  = @"
Відповідає: Properly Configure Inbound/Outbound Remote access.ps1 (PSHardening) 🟠 Важливо
Налаштовує правила Remote Access у брандмауері:
• Забороняє RDP інбаунд (3389/TCP+UDP) якщо він не потрібен
• Забороняє WinRM інбаунд (5985-5986/TCP)
• Забороняє Remote Assistance (445/TCP + відповідні)
• Вимикає вхідні правила Remote Desktop Services у брандмауері
"@
    Apply = {
        # Вимкнути стандартні правила Remote Desktop у брандмауері
        @('Remote Desktop - User Mode (TCP-In)', 'Remote Desktop - User Mode (UDP-In)',
          'Remote Desktop - Shadow (TCP-In)', 'Remote Assistance (TCP-In)') |
            ForEach-Object {
                Get-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue |
                    Set-NetFirewallRule -Enabled False -ErrorAction SilentlyContinue
            }
        # Явно заблокувати Remote access порти
        $rules = @(
            @{ N='Block Remote Access RDP TCP'; P='TCP'; L='3389' },
            @{ N='Block Remote Access RDP UDP'; P='UDP'; L='3389' },
            @{ N='Block Remote Access WinRM';   P='TCP'; L='5985-5986' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        @('Remote Desktop - User Mode (TCP-In)', 'Remote Desktop - User Mode (UDP-In)') |
            ForEach-Object {
                Get-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue |
                    Set-NetFirewallRule -Enabled True -ErrorAction SilentlyContinue
            }
        @('Block Remote Access RDP TCP','Block Remote Access RDP UDP','Block Remote Access WinRM') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = {
        $r = Get-NetFirewallRule -DisplayName 'Block Remote Access RDP TCP' -ErrorAction SilentlyContinue
        $null -ne $r -and $r.Enabled
    }
},

[PSCustomObject]@{
    Group = "Жорстке налаштування брандмауера"
    Name  = "File/Printer Sharing — повністю заблокувати через брандмауер"
    Desc  = @"
Відповідає: Properly Configure and Block-FilePrinterSharingFirewallRules.ps1 (PSHardening) 🟠 Важливо
Вимикає всі правила брандмауера 'File and Printer Sharing':
• Відключає вхідні/вихідні правила FPS у брандмауері Windows
• Додатково блокує SMB (445), NetBIOS (137-139) на рівні правил
"@
    Apply = {
        # Вимкнути всі вбудовані правила File and Printer Sharing
        Get-NetFirewallRule -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like '*File and Printer Sharing*' } |
            Set-NetFirewallRule -Enabled False -ErrorAction SilentlyContinue
        # Явно заблокувати File/Printer Sharing порти (Inbound)
        Remove-NetFirewallRule -DisplayName 'Block FPS SMB Inbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block FPS SMB Inbound' -Direction Inbound `
            -Protocol TCP -LocalPort 445 -Action Block -Profile Any -Enabled True | Out-Null
        Remove-NetFirewallRule -DisplayName 'Block FPS NetBIOS Inbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block FPS NetBIOS Inbound' -Direction Inbound `
            -Protocol TCP -LocalPort '137-139' -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        Get-NetFirewallRule -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like '*File and Printer Sharing*' } |
            Set-NetFirewallRule -Enabled True -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block FPS SMB Inbound'     -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block FPS NetBIOS Inbound' -ErrorAction SilentlyContinue
    }
    Check = {
        $fps = Get-NetFirewallRule -ErrorAction SilentlyContinue |
               Where-Object { $_.DisplayName -like '*File and Printer Sharing*' -and $_.Direction -eq 'Inbound' } |
               Select-Object -First 1
        $fps -and -not $fps.Enabled
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── LATERAL MOVEMENT / PIVOT PREVENTION ──────────────────────────────────
# Відповідає: Pivot Prevention Local-Private Network.ps1 (PSHardening) 🔴 Критично
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Lateral Movement / Pivot Prevention"
    Name  = "Pivot Prevention — блокувати Lateral Movement у локальній мережі"
    Desc  = @"
Відповідає: Pivot Prevention Local-Private Network.ps1 (PSHardening) 🔴 Критично
Захищає від горизонтального переміщення (Lateral Movement) у локальній мережі:
• Блокує вхідний SMB (445), WMI/RPC (135), WinRM (5985-5986) з Private/Domain мереж
• Блокує NetBIOS-based discovery (137-139) у локальній мережі
• Блокує адміністративні share підключення (\\machine\C$, \\machine\ADMIN$)
• Обмежує вхідний трафік до 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12 (RFC1918)
⚠ Застосовувати після налаштування дозволених правил для легітимного трафіку.
"@
    Apply = {
        $privateRanges = @('192.168.0.0/16','10.0.0.0/8','172.16.0.0/12','169.254.0.0/16')
        # Блокувати Lateral Movement порти для локальних мереж Inbound
        $lateralPorts = @(
            @{ N='Block Lateral SMB Private Inbound';    P='TCP'; L='445' },
            @{ N='Block Lateral WMI RPC Private Inbound'; P='TCP'; L='135' },
            @{ N='Block Lateral WinRM Private Inbound';  P='TCP'; L='5985-5986' },
            @{ N='Block Lateral NetBIOS-NS Private';     P='UDP'; L='137' },
            @{ N='Block Lateral NetBIOS-DGM Private';    P='UDP'; L='138' },
            @{ N='Block Lateral NetBIOS-SSN Private';    P='TCP'; L='139' }
        )
        foreach ($r in $lateralPorts) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            New-NetFirewallRule -DisplayName $r.N -Direction Inbound -Protocol $r.P `
                -LocalPort $r.L -RemoteAddress $privateRanges -Action Block -Profile Private,Domain -Enabled True | Out-Null
        }
        # Обмежити адміністративні shared ресурси
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AutoShareWks"    0
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AutoShareServer" 0
    }
    Revert = {
        @('Block Lateral SMB Private Inbound','Block Lateral WMI RPC Private Inbound',
          'Block Lateral WinRM Private Inbound','Block Lateral NetBIOS-NS Private',
          'Block Lateral NetBIOS-DGM Private','Block Lateral NetBIOS-SSN Private') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AutoShareWks"    1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AutoShareServer" 1
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block Lateral SMB Private Inbound' -ErrorAction SilentlyContinue) }
},

# ════════════════════════════════════════════════════════════════════════
# ── TOR / CHATGPT / WIFI PINEAPPLE / ЗОВНІШНІ ЗАГРОЗИ ───────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "TOR / ChatGPT / Wifi Pineapple / Зовнішні загрози"
    Name  = "Заблокувати відомі TOR exit node IP-адреси (статичний список)"
    Desc  = @"
Відповідає: Block TOR exit nodes.ps1 (PSHardening) 🟡 Бажано
Блокує вхідний та вихідний трафік до відомих TOR exit node IP-адрес.
⚠ Список частково статичний — TOR мережа постійно змінюється.
Для актуальних даних: https://check.torproject.org/torbulkexitlist
або https://dan.me.uk/torlist/
Включає широко відомі та стабільні exit node CIDR блоки.
"@
    Apply = {
        # Відомі та стабільні TOR-пов'язані IP/CIDR (частковий список)
        $torIPs = @(
            '176.10.104.0/24','176.10.107.0/24','185.220.101.0/24','185.220.102.0/24',
            '185.220.103.0/24','185.130.44.0/24','45.33.32.0/24','45.79.0.0/16',
            '193.189.100.0/22','104.244.72.0/21','51.15.0.0/16','163.172.0.0/16',
            '5.196.0.0/16','62.210.0.0/16','149.56.0.0/16','198.98.0.0/16',
            '23.129.64.0/18','107.189.0.0/21','209.141.0.0/16','204.8.96.0/20',
            '195.176.3.0/24','162.247.72.0/22','64.113.32.0/19'
        )
        Remove-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Inbound'  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Outbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Inbound' -Direction Inbound `
            -RemoteAddress $torIPs -Action Block -Profile Any -Enabled True | Out-Null
        New-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Outbound' -Direction Outbound `
            -RemoteAddress $torIPs -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Inbound'  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Outbound' -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block TOR Exit Nodes Outbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "TOR / ChatGPT / Wifi Pineapple / Зовнішні загрози"
    Name  = "Hardening AI — заблокувати ChatGPT/OpenAI та інші AI endpoint (hosts + firewall)"
    Desc  = @"
Відповідає: Hardening AI ChatGPT.ps1 (PSHardening) 🟡 Бажано
Блокує доступ до OpenAI, ChatGPT та суміжних AI-сервісів:
• Через hosts файл: chat.openai.com, api.openai.com, openai.com, oaiusercontent.com
• Через брандмауер: відомі AS блоки OpenAI
Корисно для корпоративних середовищ де заборонено використання AI-сервісів.
"@
    Apply = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $aiDomains = @(
            '# ── AI Services Block ────────────────────────────────────────────',
            '0.0.0.0 chat.openai.com',
            '0.0.0.0 api.openai.com',
            '0.0.0.0 openai.com',
            '0.0.0.0 www.openai.com',
            '0.0.0.0 oaiusercontent.com',
            '0.0.0.0 chatgpt.com',
            '0.0.0.0 auth.openai.com',
            '0.0.0.0 platform.openai.com',
            '0.0.0.0 cdn.openai.com'
        )
        $existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $newEntries = $aiDomains | Where-Object {
            $_ -notmatch '^#' -and ($existingContent -notcontains $_)
        }
        if ($newEntries.Count -gt 0) {
            Add-Content -Path $hostsPath -Value ($aiDomains -join "`n") -Encoding UTF8
        }
        # Брандмауер: відомі IP-блоки OpenAI
        $openAiIPs = @('104.18.0.0/16','172.64.0.0/13','104.21.0.0/16')
        Remove-NetFirewallRule -DisplayName 'Block AI OpenAI Outbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block AI OpenAI Outbound' -Direction Outbound `
            -RemoteAddress $openAiIPs -Action Block -Profile Any -Enabled True | Out-Null
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Revert = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $lines = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $filtered = $lines | Where-Object {
            $_ -notmatch 'openai\.com|chatgpt\.com|oaiusercontent|AI Services Block'
        }
        $filtered | Set-Content $hostsPath -Encoding UTF8
        Remove-NetFirewallRule -DisplayName 'Block AI OpenAI Outbound' -ErrorAction SilentlyContinue
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Check = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $content = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $content -contains '0.0.0.0 chat.openai.com'
    }
},

[PSCustomObject]@{
    Group = "TOR / ChatGPT / Wifi Pineapple / Зовнішні загрози"
    Name  = "Wifi Pineapple — правила брандмауера та виявлення (захист від MitM)"
    Desc  = @"
Відповідає: Block Wifi Pineapple.ps1 + Enumerate network for Wifi-Pineapple.ps1 🟡 Бажано
Wifi Pineapple — пристрій для атак MitM через Wi-Fi (управляється на 172.16.42.1:1471).
• Блокує підключення до типових управляючих адрес Wifi Pineapple
• Блокує характерні порти (1471, 9090 — Hak5 Pineapple management)
• Додає перевірку мережі на наявність підозрілих точок доступу
"@
    Apply = {
        $pineappleIPs = @('172.16.42.0/24','172.16.43.0/24')
        Remove-NetFirewallRule -DisplayName 'Block Wifi Pineapple Outbound' -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block Wifi Pineapple Inbound'  -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block Wifi Pineapple Outbound' -Direction Outbound `
            -RemoteAddress $pineappleIPs -Action Block -Profile Any -Enabled True | Out-Null
        New-NetFirewallRule -DisplayName 'Block Wifi Pineapple Inbound' -Direction Inbound `
            -RemoteAddress $pineappleIPs -Action Block -Profile Any -Enabled True | Out-Null
        # Заблокувати Pineapple management port
        Remove-NetFirewallRule -DisplayName 'Block Pineapple Mgmt Port' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block Pineapple Mgmt Port' -Direction Outbound `
            -Protocol TCP -RemotePort '1471' -Action Block -Profile Any -Enabled True | Out-Null
        # Перевірка мережі на підозрілі Hak5 SSID (логування)
        $suspiciousSSIDs = @('Pineapple_','HAK5','WIFI_PINEAPPLE','pineap_')
        $wifiProfiles = netsh wlan show profiles 2>$null
        foreach ($ssid in $suspiciousSSIDs) {
            if ($wifiProfiles -match $ssid) {
                Write-AppLog -Level 'WARN' -Message "Виявлено підозрілий SSID: $ssid — можливий Wifi Pineapple!"
            }
        }
    }
    Revert = {
        @('Block Wifi Pineapple Outbound','Block Wifi Pineapple Inbound','Block Pineapple Mgmt Port') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block Wifi Pineapple Outbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "TOR / ChatGPT / Wifi Pineapple / Зовнішні загрози"
    Name  = "HPING3 DoS — захист від DDoS/DoS атак через rate limiting та SYN Flood"
    Desc  = @"
Відповідає: Block HPING3 DDOS-DOS.ps1 (PSHardening) 🟡 Бажано
Протидія hping3 та аналогічним DoS-інструментам:
• Блокує Port 0 (вектор HPING3 DDoS) — TCP/UDP Inbound/Outbound
• Додаткові параметри TCP/IP стеку для протидії flood-атакам
• EnableDeadGWDetect, TcpMaxHalfOpen, TcpMaxSynRetransmissions
• Блокує ICMP flood через обмеження кількості пакетів
"@
    Apply = {
        # Блокувати Port 0 (HPING3 DDoS вектор) — вже може бути в network.ps1
        $rules = @(
            @{ N='Block HPING3 Port0 TCP In';  D='Inbound';  P='TCP'; L='0' },
            @{ N='Block HPING3 Port0 TCP Out'; D='Outbound'; P='TCP'; R='0' },
            @{ N='Block HPING3 Port0 UDP In';  D='Inbound';  P='UDP'; L='0' },
            @{ N='Block HPING3 Port0 UDP Out'; D='Outbound'; P='UDP'; R='0' }
        )
        foreach ($r in $rules) {
            Remove-NetFirewallRule -DisplayName $r.N -ErrorAction SilentlyContinue
            if ($r.D -eq 'Inbound') {
                New-NetFirewallRule -DisplayName $r.N -Direction $r.D -Protocol $r.P `
                    -LocalPort $r.L -Action Block -Profile Any -Enabled True | Out-Null
            } else {
                New-NetFirewallRule -DisplayName $r.N -Direction $r.D -Protocol $r.P `
                    -RemotePort $r.R -Action Block -Profile Any -Enabled True | Out-Null
            }
        }
        # TCP/IP захист від SYN Flood (HPING3)
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "SynAttackProtect"         2
        Set-Reg $tcp "TcpMaxHalfOpen"           25
        Set-Reg $tcp "TcpMaxHalfOpenRetried"    20
        Set-Reg $tcp "TcpMaxSynRetransmissions" 1
        Set-Reg $tcp "EnableDeadGWDetect"       0
        Set-Reg $tcp "DisableIPSourceRouting"   2
        # ICMP обмеження
        Remove-NetFirewallRule -DisplayName 'Block ICMP Flood Inbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block ICMP Flood Inbound' -Direction Inbound `
            -Protocol ICMPv4 -IcmpType 8 -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        @('Block HPING3 Port0 TCP In','Block HPING3 Port0 TCP Out',
          'Block HPING3 Port0 UDP In','Block HPING3 Port0 UDP Out',
          'Block ICMP Flood Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Remove-RegValue $tcp "SynAttackProtect"
        Remove-RegValue $tcp "TcpMaxHalfOpen"
        Remove-RegValue $tcp "TcpMaxHalfOpenRetried"
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block HPING3 Port0 TCP In' -ErrorAction SilentlyContinue) }
},

# ════════════════════════════════════════════════════════════════════════
# ── СПЕЦІАЛЬНІ СЕРВІСИ / ПРОТОКОЛИ ───────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "Microsoft Family Safety — заблокувати (брандмауер + реєстр)"
    Desc  = @"
Відповідає: Block Microsoft Family Safety.ps1 (PSHardening) 🟡 Бажано
Блокує Microsoft Family Safety / Microsoft Kids сервіс:
• Блокує підключення до familysafety.microsoft.com та суміжних доменів
• Вимикає заплановані завдання FamilySafety
• Реєстровий ключ: DisableFamilySafety
"@
    Apply = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $fsDomains = @(
            '0.0.0.0 familysafety.microsoft.com',
            '0.0.0.0 account.microsoft.com/family',
            '0.0.0.0 family.microsoft.com'
        )
        $existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $newEntries = $fsDomains | Where-Object { $existingContent -notcontains $_ }
        if ($newEntries.Count -gt 0) {
            $newEntries | Add-Content -Path $hostsPath -Encoding UTF8
        }
        # Вимкнути заплановані завдання Family Safety
        Disable-Task '\Microsoft\Windows\Shell\' 'FamilySafetyMonitor'
        Disable-Task '\Microsoft\Windows\Shell\' 'FamilySafetyRefreshTask'
        Disable-Task '\Microsoft\Windows\Family Safety\' 'FamilySafetyMonitor'
        Disable-Task '\Microsoft\Windows\Family Safety\' 'FamilySafetyRefreshTask'
        # Реєстр
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableFamilySafety" 1
    }
    Revert = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $lines = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $lines | Where-Object { $_ -notmatch 'familysafety\.microsoft\.com|family\.microsoft\.com' } |
            Set-Content $hostsPath -Encoding UTF8
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableFamilySafety"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableFamilySafety" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "RTP — заблокувати Real-Time Transport Protocol (Inbound/Outbound)"
    Desc  = @"
Відповідає: Block-RTP.ps1 (PSHardening) 🟡 Бажано
Блокує протокол RTP (Real-time Transport Protocol) — використовується для VoIP,
відеоконференцій, стрімінгу. Порти 5004-5005/UDP (RTSP) та 16384-32767/UDP (динамічні RTP).
⚠ Застосовуйте лише якщо RTP/VoIP не використовується в організації.
"@
    Apply = {
        Remove-NetFirewallRule -DisplayName 'Block RTP Inbound'  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'Block RTP Outbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block RTP Inbound' -Direction Inbound `
            -Protocol UDP -LocalPort '5004-5005,16384-32767' -Action Block -Profile Any -Enabled True | Out-Null
        New-NetFirewallRule -DisplayName 'Block RTP Outbound' -Direction Outbound `
            -Protocol UDP -RemotePort '5004-5005,16384-32767' -Action Block -Profile Any -Enabled True | Out-Null
        # RTSP port
        Remove-NetFirewallRule -DisplayName 'Block RTSP Inbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block RTSP Inbound' -Direction Inbound `
            -Protocol TCP -LocalPort '554,8554' -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        @('Block RTP Inbound','Block RTP Outbound','Block RTSP Inbound') |
            ForEach-Object { Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue }
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName 'Block RTP Outbound' -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "SMS / Phone Link / Your Phone — заблокувати синхронізацію SMS"
    Desc  = @"
Відповідає: Block SMS.ps1 (PSHardening) 🟡 Бажано
Блокує синхронізацію SMS через Phone Link / Your Phone:
• Вимикає сервіс PhoneExperienceHost та Phone Link застосунок
• Блокує реєстрові ключі Phone Link
• Зупиняє фоновий сервіс смс-синхронізації
"@
    Apply = {
        # Вимкнути Phone Link через реєстр
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableMmx"          0
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Mobility" "OptedIn"      0
        # Заблокувати застосунок Phone Link
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PhoneLink" "EnablePhoneLink"  0
        # Вимкнути сервіс PhoneSvc
        Set-ServiceDisabled "PhoneSvc"
        # Брандмауер: блокувати Your Phone / Link to Windows
        Remove-NetFirewallRule -DisplayName 'Block Your Phone Outbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block Your Phone Outbound' -Direction Outbound `
            -Program "$env:SystemDrive\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\*" `
            -Action Block -Profile Any -Enabled True -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PhoneLink" "EnablePhoneLink"
        Set-ServiceManual "PhoneSvc"
        Remove-NetFirewallRule -DisplayName 'Block Your Phone Outbound' -ErrorAction SilentlyContinue
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PhoneLink" "EnablePhoneLink" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "IE AppContainer — заблокувати мережевий доступ (Enhance Protected Mode)"
    Desc  = @"
Відповідає: Block-IE-AppContainer-NetworkAccess.ps1 (PSHardening) 🟡 Бажано
Блокує мережевий доступ для Internet Explorer AppContainer (Enhance Protected Mode):
• EnableEnhancedProtectedMode=1: ізоляція IE від системи через AppContainer
• EnableEnhancedProtectedMode64Bit=1: 64-бітна версія EPM
• ActiveX блокування та заборона інсталяції надбудов
"@
    Apply = {
        $ie = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
        Set-Reg $ie "EnableEnhancedProtectedMode"      1
        Set-Reg $ie "EnableEnhancedProtectedMode64Bit" 1
        Set-Reg $ie "Isolation"                        "PMEM" "String"
        Set-Reg $ie "Isolation64Bit"                   1
        # Заблокувати IE доступ до мережі через брандмауер
        Remove-NetFirewallRule -DisplayName 'Block IE AppContainer Network' -ErrorAction SilentlyContinue
        $iePath = "${env:ProgramFiles}\Internet Explorer\iexplore.exe"
        if (Test-Path $iePath) {
            New-NetFirewallRule -DisplayName 'Block IE AppContainer Network' -Direction Outbound `
                -Program $iePath -Action Block -Profile Any -Enabled True | Out-Null
        }
    }
    Revert = {
        $ie = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
        Remove-RegValue $ie "EnableEnhancedProtectedMode"
        Remove-RegValue $ie "EnableEnhancedProtectedMode64Bit"
        Remove-NetFirewallRule -DisplayName 'Block IE AppContainer Network' -ErrorAction SilentlyContinue
    }
    Check = { (Get-Reg "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "EnableEnhancedProtectedMode" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "Secure Notepad — обмежити мережевий доступ Notepad через брандмауер"
    Desc  = @"
Відповідає: Secure Notepad.ps1 (PSHardening) 🟡 Бажано
Блокує вихідний мережевий доступ для Notepad (у Windows 11 це Store-застосунок):
• Notepad.exe не повинен мати доступ до мережі
• Блокує outbound для notepad.exe та Windows Notepad AppX
"@
    Apply = {
        $notepadPaths = @(
            "$env:SystemRoot\System32\notepad.exe",
            "$env:SystemRoot\notepad.exe"
        )
        foreach ($np in $notepadPaths) {
            if (Test-Path $np) {
                $ruleName = "Block Notepad Network Access ($np)"
                Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
                New-NetFirewallRule -DisplayName $ruleName -Direction Outbound `
                    -Program $np -Action Block -Profile Any -Enabled True | Out-Null
            }
        }
    }
    Revert = {
        @("$env:SystemRoot\System32\notepad.exe","$env:SystemRoot\notepad.exe") | ForEach-Object {
            Remove-NetFirewallRule -DisplayName "Block Notepad Network Access ($_)" -ErrorAction SilentlyContinue
        }
    }
    Check = {
        $np = "$env:SystemRoot\System32\notepad.exe"
        $null -ne (Get-NetFirewallRule -DisplayName "Block Notepad Network Access ($np)" -ErrorAction SilentlyContinue)
    }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "Remote Assistance — видалити приховані scheduled tasks та заблокувати"
    Desc  = @"
Відповідає: Remove default remote assistance hidden tasks.ps1 (PSHardening) 🟠 Важливо
Видаляє/вимикає приховані завдання Remote Assistance та блокує сервіс:
• Вимикає задачі Remote Assistance у Task Scheduler
• Блокує RemoteAssistanceTask у брандмауері
• Відключає Remote Assistance через реєстр (fAllowToGetHelp=0)
"@
    Apply = {
        # Вимкнути заплановані задачі Remote Assistance
        Disable-Task '\Microsoft\Windows\RemoteAssistance\' 'RemoteAssistanceTask'
        # Блокувати Remote Assistance у реєстрі
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp"   0
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"       "fAllowToGetHelp"   0
        # Брандмауер
        Remove-NetFirewallRule -DisplayName 'Block Remote Assistance All' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block Remote Assistance All' -Direction Inbound `
            -Protocol TCP -LocalPort '3389,49152-65535' -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        Enable-Task '\Microsoft\Windows\RemoteAssistance\' 'RemoteAssistanceTask'
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" "fAllowToGetHelp" 1
        Remove-NetFirewallRule -DisplayName 'Block Remote Assistance All' -ErrorAction SilentlyContinue
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" "fAllowToGetHelp" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Спеціальні сервіси — блокування"
    Name  = "Internet Connection Sharing (ICS) — зупинити та заблокувати"
    Desc  = @"
Відповідає: Stop Shared Access.ps1 / Method #2 (PSHardening) 🟠 Важливо
Вимикає Internet Connection Sharing (ICS):
• Зупиняє та вимикає сервіс SharedAccess
• Реєстр: NC_ShowSharedAccessUI=0 — приховати інтерфейс ICS
• Брандмауер: блокує порти ICS (67-68 UDP — DHCP сервер для клієнтів)
"@
    Apply = {
        Set-ServiceDisabled "SharedAccess"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_AllowNetBridge_NLA"  0
        # Блокувати ICS DHCP Inbound (клієнти ICS не отримають адреси)
        Remove-NetFirewallRule -DisplayName 'Block ICS DHCP Server Inbound' -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName 'Block ICS DHCP Server Inbound' -Direction Inbound `
            -Protocol UDP -LocalPort '67' -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        Set-ServiceManual "SharedAccess"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI"
        Remove-NetFirewallRule -DisplayName 'Block ICS DHCP Server Inbound' -ErrorAction SilentlyContinue
    }
    Check = { $s = Get-Service "SharedAccess" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
}

)
