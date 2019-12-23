param(
	[parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
	[UInt32]$Critical = 11,

	[parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
	[UInt32]$Warning = 16)

$Severidade = 0
$i=0
$DHCPServers = Get-DhcpServerInDC
foreach($DHCPServer in $DHCPServers){
    Try{
        $DHCPScopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer.dnsname -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Active"}
        foreach($DHCPScope in $DHCPScopes){
            $FreeIPs = (Get-DhcpServerv4ScopeStatistics -ComputerName $DHCPServer.dnsname -ScopeId $DHCPScope.scopeid.IPAddressToString).Free
            if($FreeIPs -lt $Critical){
               $Severidade = 2
               $output += "Mensagem: Escopo DHCP " + $DHCPScope.scopeid.IPAddressToString + " possui apenas " + $FreeIPs + " IPs livres no servidor " + $DHCPServer.dnsname + "`n"
               $output += "Serveridade: " + $Severidade + "`n`n"
               #$i++
            }
            elseif($FreeIPs -lt $Warning){
               $Severidade = 1
               $output += "Mensagem: Escopo DHCP " + $DHCPScope.scopeid.IPAddressToString + " possui apenas " + $FreeIPs + " IPs livres no servidor " + $DHCPServer.dnsname + "`n"
               $output += "Serveridade: " + $Severidade + "`n`n"
               #$i++
            }
        }
    }Catch{
        #Write-Host "Cannot connect to server: " $DHCPServer.dnsname
    }
}
$output
