<#
.SYNOPSIS
    DNS-over-HTTPS та ARP Spoofing Mitigation — hardening-модуль
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
    Джерела: SaneRelapse/PSHardening, troennes/private-secure-windows
    Покриття: DoH системний, DoH Edge GPO, ARP захист
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 1: DNS OVER HTTPS (DoH) — SYSTEM ─────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "DNS-over-HTTPS"
    Name  = "Force DNS over HTTPS — примусовий DoH (Cloudflare/Google)"
    Desc  = @"
Вмикає DNS over HTTPS (DoH) на рівні Windows 11 для захисту DNS-запитів:
  - EnableAutoDoh=2: примусовий DoH для всіх інтерфейсів
  - netsh dns add encryption: реєструє DoH-шаблони для Cloudflare (1.1.1.1,
    1.0.0.1) та Google (8.8.8.8, 8.8.4.4) з відповідними DoH URL
  - DoH шифрує DNS-трафік (порт 443/HTTPS), запобігаючи перехопленню
    та підміні DNS-відповідей (DNS Spoofing / MITM)
  - Після застосування перезапускається DNS Client для набуття змін чинності
"@
    Apply = {
        # Увімкнути примусовий DoH (Windows 11 21H2+)
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" "EnableAutoDoh" 2

        # Зареєструвати DoH-шаблони Cloudflare
        netsh dns add encryption server=1.1.1.1    dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no 2>$null
        netsh dns add encryption server=1.0.0.1    dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no 2>$null
        # Cloudflare IPv6
        netsh dns add encryption server=2606:4700:4700::1111 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no 2>$null
        netsh dns add encryption server=2606:4700:4700::1001 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no 2>$null

        # Зареєструвати DoH-шаблони Google
        netsh dns add encryption server=8.8.8.8    dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no 2>$null
        netsh dns add encryption server=8.8.4.4    dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no 2>$null

        # Встановити Cloudflare як основний DoH-сервер на всіх активних інтерфейсах
        Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
            Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex `
                -ServerAddresses @('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue
        }

        # Перезапустити DNS-клієнт
        Restart-Service Dnscache -Force -ErrorAction SilentlyContinue
        Clear-DnsClientCache -ErrorAction SilentlyContinue

        Write-AppLog -Level 'INFO' -Message "DoH увімкнено: EnableAutoDoh=2, Cloudflare+Google DoH templates зареєстровано."
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" "EnableAutoDoh" 0

        netsh dns delete encryption server=1.1.1.1 2>$null
        netsh dns delete encryption server=1.0.0.1 2>$null
        netsh dns delete encryption server=8.8.8.8 2>$null
        netsh dns delete encryption server=8.8.4.4 2>$null

        Restart-Service Dnscache -Force -ErrorAction SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "DoH вимкнено, шаблони видалено."
    }
    Check = {
        (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" "EnableAutoDoh" 0) -eq 2
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 2: DNS OVER HTTPS — EDGE GPO ──────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "DNS-over-HTTPS"
    Name  = "DoH Edge GPO — примусовий DNS-over-HTTPS для Microsoft Edge"
    Desc  = @"
Примусово вмикає DNS-over-HTTPS у Microsoft Edge через Group Policy:
  - DnsOverHttpsMode=force: Edge завжди використовує DoH
  - DnsOverHttpsTemplates=Cloudflare DoH URL
Це забезпечує шифрування DNS навіть якщо системний DoH не налаштовано.
Працює незалежно від системного DoH — Edge буде використовувати свій DoH-канал.
"@
    Apply = {
        $edge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
        Set-Reg $edge "DnsOverHttpsMode"      "force"                                    "String"
        Set-Reg $edge "DnsOverHttpsTemplates"  "https://cloudflare-dns.com/dns-query{?dns}" "String"
        Write-AppLog -Level 'INFO' -Message "Edge DoH GPO: DnsOverHttpsMode=force, Cloudflare template встановлено."
    }
    Revert = {
        $edge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
        Remove-RegValue $edge "DnsOverHttpsMode"
        Remove-RegValue $edge "DnsOverHttpsTemplates"
        Write-AppLog -Level 'INFO' -Message "Edge DoH GPO скасовано."
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "DnsOverHttpsMode" "") -eq "force"
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 3: ARP SPOOFING MITIGATION ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "DNS-over-HTTPS"
    Name  = "ARP Spoofing Mitigation — статичні ARP-записи для шлюзу"
    Desc  = @"
Захист від ARP Spoofing (підміни ARP) шляхом встановлення статичних
ARP-записів для мережевого шлюзу та DNS-серверів:
  - Визначає IP шлюзу та його MAC-адресу автоматично
  - Додає статичний ARP-запис: arp -s <gateway_ip> <gateway_mac>
  - Статичні записи не оновлюються через ARP-відповіді — захист від
    ARP Poisoning, Man-in-the-Middle, DHCP Snooping атак
  - Також вмикає обмеження відповіді на ARP-запити (ArpRetryCount=1)
УВАГА: якщо MAC-адреса шлюзу зміниться (новий роутер) — потрібен Revert
та повторне Apply після підключення до нової мережі.
"@
    Apply = {
        # Знайти активні адаптери та їх шлюзи
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        $added = @()

        foreach ($adapter in $adapters) {
            $gw = (Get-NetRoute -InterfaceIndex $adapter.InterfaceIndex -DestinationPrefix '0.0.0.0/0' `
                -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1).NextHop
            if (-not $gw -or $gw -eq '0.0.0.0') { continue }

            # Отримати MAC шлюзу через ARP
            $arpOut = arp -a $gw 2>$null | Out-String
            $macMatch = [regex]::Match($arpOut, '([0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2})', 'IgnoreCase')
            if (-not $macMatch.Success) {
                # Пінг для заповнення ARP-кешу, потім повторна спроба
                ping -n 1 -w 1000 $gw 2>$null | Out-Null
                $arpOut   = arp -a $gw 2>$null | Out-String
                $macMatch = [regex]::Match($arpOut, '([0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2}[-:][0-9a-f]{2})', 'IgnoreCase')
            }

            if ($macMatch.Success) {
                $mac = $macMatch.Value -replace '-','-'
                # Додати статичний ARP-запис
                arp -s $gw $mac 2>$null
                $added += [PSCustomObject]@{ Interface = $adapter.Name; Gateway = $gw; MAC = $mac }
                Write-AppLog -Level 'INFO' -Message "Статичний ARP: $gw -> $mac (інтерфейс: $($adapter.Name))"
            } else {
                Write-AppLog -Level 'WARN' -Message "Не вдалося визначити MAC для шлюзу $gw на $($adapter.Name)"
            }
        }

        # Зменшити кількість ARP-повторень (захід від ARP flood)
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "ArpRetryCount" 1

        if ($added.Count -eq 0) {
            Write-AppLog -Level 'WARN' -Message "Статичних ARP-записів не додано — шлюз не знайдено."
        }
    }
    Revert = {
        # Видалити всі статичні ARP-записи
        $gateways = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty NextHop | Where-Object { $_ -ne '0.0.0.0' }
        foreach ($gw in $gateways) {
            arp -d $gw 2>$null
            Write-AppLog -Level 'INFO' -Message "ARP-запис видалено: $gw"
        }
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "ArpRetryCount"
        Write-AppLog -Level 'INFO' -Message "ARP Spoofing Mitigation скасовано."
    }
    Check = {
        # Перевірити чи є статичні ARP-записи
        $arpOut = arp -a 2>$null | Out-String
        $arpOut -match 'static'
    }
}

)
