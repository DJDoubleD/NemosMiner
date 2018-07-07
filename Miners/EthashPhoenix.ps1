. .\Include.ps1

$Path = ".\\Bin\\Ethash-Phoenix\\PhoenixMiner.exe"
$Uri = "http://mindminer.online/miners/nVidia/PhoenixMiner_3.0c.zip"

$Commands = [PSCustomObject]@{
    "ethash" = "" #Ethash(fastest)
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        Type = "NVIDIA"
        Path = $Path
		Arguments = "-pool $($Pools.Ethash.Protocol)://$($Pools.Ethash.Host):$($Pools.Ethash.Port) -wal $($Pools.Ethash.User) -pass $($Pools.Ethash.Pass) -wdog 0 -proto 1 -cdmport 3360 -nvidia -eres 1 -log 0 -gsi 15 $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Week * .9935} # substract 0.65% devfee
        API = "phoenix"
        Port = 3360 #3350
        Wrap = $false
        URI = $Uri
		User = $Pools.(Get-Algorithm($_)).User
    }
}