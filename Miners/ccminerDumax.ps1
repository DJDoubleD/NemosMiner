if (!(IsLoaded(".\Include.ps1"))) {. .\Include.ps1;RegisterLoaded(".\Include.ps1")}

$Path = ".\Bin\NVIDIA-ccminerDumax\ccminer.exe"
$Uri = "https://github.com/DumaxFr/ccminer/releases/download/dumax-0.9.3/ccminer-dumax-0.9.3-win64.zip"

$Commands = [PSCustomObject]@{
    #"phi2" = " -i 20.9 -d $($Config.SelGPUCC)" #Phi2testing)
    #"x17" = " -i 20.9 -d $($Config.SelGPUCC)" #X17(testing)
    "x16r" = " -i 20.9 -d $($Config.SelGPUCC)" #X16r(testing)
    #"x16s" = " -i 20.9 -d $($Config.SelGPUCC)" #X16s(testing)
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
    [PSCustomObject]@{
        Type = "NVIDIA"
        Path = $Path
        Arguments = "-b $($Variables.NVIDIAMinerAPITCPPort) -R 1 -a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = $Variables.NVIDIAMinerAPITCPPort
        Wrap = $false
        URI = $Uri
        User = $Pools.(Get-Algorithm($_)).User
    }
}
