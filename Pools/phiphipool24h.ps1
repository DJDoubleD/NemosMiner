. .\Include.ps1

try { 
    $phiphipool_Request = Invoke-RestMethod "http://www.phi-phi-pool.com/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
} 
catch { return }
 
if (-not $phiphipool_Request) {return}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Locations = "US", "Europe"

$Locations | ForEach {
    $Location = $_

    $phiphipool_Request | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | foreach {
        $phiphipool_Host = "pool1.phi-phi-pool.com"
        $phiphipool_Port = $phiphipool_Request.$_.port
        $phiphipool_Algorithm = Get-Algorithm $phiphipool_Request.$_.name
        $phiphipool_Coin = ""

        $Divisor = 1000000 * [Double]$phiphipool_Request.$_.mbtc_mh_factor

        if ((Get-Stat -Name "$($Name)_$($phiphipool_Algorithm)_Profit") -eq $null) {$Stat = Set-Stat -Name "$($Name)_$($phiphipool_Algorithm)_Profit" -Value ([Double]$phiphipool_Request.$_.actual_last24h / $Divisor)}
        else {$Stat = Set-Stat -Name "$($Name)_$($phiphipool_Algorithm)_Profit" -Value ([Double]$phiphipool_Request.$_.actual_last24h / $Divisor * (1 - ($phiphipool_Request.$_.fees / 100)))}

        $ConfName = if ($Config.PoolsConfig.$Name -ne $Null) {$Name}else {"default"}
		$PwdCurr = if ($Config.PoolsConfig.$ConfName.PwdCurrency) {$Config.PoolsConfig.$ConfName.PwdCurrency}else {$Config.Passwordcurrency}
	
        if ($Config.PoolsConfig.default.Wallet) {
            [PSCustomObject]@{
                Algorithm     = $phiphipool_Algorithm
                Info          = $phiphipool
                Price         = $Stat.Live * $Config.PoolsConfig.$ConfName.PricePenaltyFactor
                StablePrice   = $Stat.Week
                MarginOfError = $Stat.Fluctuation
                Protocol      = "stratum+tcp"
                Host          = $phiphipool_Host
                Port          = $phiphipool_Port
                User          = $Config.PoolsConfig.$ConfName.Wallet
                Pass          = "$($Config.PoolsConfig.$ConfName.WorkerName),c=$($PwdCurr)"
                Location      = $Location
                SSL           = $false
            }
        }
    }
}