. .\Include.ps1

try {
    $nlpool_Request = Invoke-WebRequest "http://www.nlpool.nl/api/status" -UseBasicParsing -Headers @{"Cache-Control" = "no-cache"} | ConvertFrom-Json 
}
catch { return }

if (-not $nlpool_Request) {return}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Location = "Europe"

$nlpool_Request | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | foreach {
	$nlpool_Host = "mine.nlpool.nl"
	$nlpool_Port = $nlpool_Request.$_.port
	$nlpool_Algorithm = Get-Algorithm $nlpool_Request.$_.name
	$nlpool_Coin = ""

	$Divisor = 1000000 * [Double]$nlpool_Request.$_.mbtc_mh_factor

	if ((Get-Stat -Name "$($Name)_$($nlpool_Algorithm)_Profit") -eq $null) {$Stat = Set-Stat -Name "$($Name)_$($nlpool_Algorithm)_Profit" -Value ([Double]$nlpool_Request.$_.actual_last24h / $Divisor)}
	else {$Stat = Set-Stat -Name "$($Name)_$($nlpool_Algorithm)_Profit" -Value ([Double]$nlpool_Request.$_.actual_last24h / $Divisor * (1 - ($nlpool_Request.$_.fees / 100)))}

	$ConfName = if ($Config.PoolsConfig.$Name -ne $Null) {$Name}else {"default"}
	$PwdCurr = if ($Config.PoolsConfig.$ConfName.PwdCurrency) {$Config.PoolsConfig.$ConfName.PwdCurrency}else {$Config.Passwordcurrency}

	if ($Config.PoolsConfig.default.Wallet) {
		[PSCustomObject]@{
			Algorithm     = $nlpool_Algorithm
			Info          = $nlpool
			Price         = $Stat.Live * $Config.PoolsConfig.$ConfName.PricePenaltyFactor
			StablePrice   = $Stat.Week
			MarginOfError = $Stat.Fluctuation
			Protocol      = "stratum+tcp"
			Host          = $nlpool_Host
			Port          = $nlpool_Port
			User          = $Config.PoolsConfig.$ConfName.Wallet
			Pass          = "$($Config.PoolsConfig.$ConfName.WorkerName),c=$($PwdCurr)"
			Location      = $Location
			SSL           = $false
		}
	}
}
