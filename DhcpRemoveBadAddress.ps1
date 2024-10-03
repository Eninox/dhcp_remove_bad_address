
# selection des adresses IP cible
$DHCPBadReservations = Get-DhcpServerv4Scope -ComputerName serverX | Get-DhcpServerv4Lease -ComputerName serverX | Where-Object -FilterScript {$_.HostName -eq 'BAD_ADDRESS'} | Sort-Object IPAddress

# definition variables
$DateStart = Get-Date
$DateFormat = $DateStart.ToString('yyyyMMdd_HHmm')
$Count = 0
$LogFile = "chemin\du\fichier\log\"+$DateFormat+"_DhcpRemoveBadAddress.log"
Set-Content -Path $LogFile -Value "Suppression des BAD_ADDRESS des étendues DHCP : $DateStart `n"

# boucle d'iteration sur les adresses avec test ping, suppression ou maintien et log des actions et des temps de traitement (verbose)
foreach ($BadIp in $DHCPBadReservations) {
    $TestPing = Test-NetConnection $BadIp.IpAddress -InformationLevel Quiet -WarningAction SilentlyContinue
    $Count += 1
    If ($TestPing) {
        $Result = $BadIp.Hostname + "`t" + $BadIp.IPAddress + "`t`t" + $BadIp.LeaseExpiryTime + "`t" + $Count + "/" + $DHCPBadReservations.Count + "`t`t" + "Ping OK -> maintien IP"
    } else {
        $Result = $BadIp.Hostname + "`t" + $BadIp.IPAddress + "`t`t" + $BadIp.LeaseExpiryTime + "`t" + $Count + "/" + $DHCPBadReservations.Count + "`t`t" + "Ping TimedOut -> suppression IP"
        Remove-DhcpServerv4Lease -IPAddress $BadIp.IPAddress
    }
    Write-Host $Result
    Add-Content $LogFile -Value $Result
}

# definition variables de fin et calcul de temps de traitement
$DateEnd = Get-Date
$ProcessDuration = ([Math]::Round(($DateEnd - $DateStart).TotalMinutes, 2))
Add-Content $LogFile -Value "`n Fin du traitement en $ProcessDuration minutes"

# epuration logs + 1 mois pour optimisation espace
$LogDirectory = "chemin\du\fichier\log\"
$DateLimit = (Get-Date).AddMonths(-1)
$LogFiles = Get-ChildItem -Path $LogDirectory -File

foreach ($File in $LogFiles) {
    if ($File.LastWriteTime -lt $DateLimit) {
        Remove-Item -Path $File.FullName -Force
    }
}

Exit