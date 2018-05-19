. .\Include.ps1

$Path = ".\Bin\NVIDIA-Alexis78\ccminer.exe"
$Uri = "https://github.com/nemosminer/ccminerAlexis78/releases/download/Alexis78-v1.2/ccminerAlexis78v1.2x32.7z"

$Commands = [PSCustomObject]@{
    "hsr" = " -d $SelGPUCC --api-remote" #Hsr
	"poly" = " -d $SelGPUCC" #polytimos(fastest)
    #"bitcore" = "" #Bitcore
    "blake2s" = " -d $SelGPUCC --api-remote" #Blake2s
    #"blakecoin" = " -d $SelGPUCC --api-remote" #Blakecoin
    #"vanilla" = "" #BlakeVanilla
    #"cryptonight" = "" #Cryptonight
    "veltor" = " -i 23 -d $SelGPUCC --api-remote" #Veltor
    #"decred" = "" #Decred
    #"equihash" = "" #Equihash
    #"ethash" = "" #Ethash
    #"groestl" = "" #Groestl
    #"hmq1725" = "" #hmq1725
    "keccak" = " -m 2 -i 29 -d $SelGPUCC" #Keccak
	"keccakc" = " -i 29 -d $SelGPUCC" #Keccakc(fastest)
    "lbry" = " -d $SelGPUCC --api-remote" #Lbry
    "lyra2v2" = " -d $SelGPUCC -N 1 --api-remote" #Lyra2RE2
    #"lyra2z" = "" #Lyra2z
    "myr-gr" = " -d $SelGPUCC -N 1" #MyriadGroestl
    #"neoscrypt" = " -i 15 -d $SelGPUCC" #NeoScrypt
    "nist5" = " -i 25.7 -d $SelGPUCC --api-remote" #Nist5
    #"pascal" = "" #Pascal
    #"qubit" = "" #Qubit
    #"scrypt" = "" #Scrypt
    #"sia" = "" #Sia
    #"sib" = " -i 21 -d $SelGPUCC --api-remote" #Sib
    "skein" = " -i 29 -d $SelGPUCC --api-remote" #Skein
    #"timetravel" = "" #Timetravel
    "c11" = " -i 21 -d $SelGPUCC --api-remote" #C11
    "x11evo" = " -N 1 -i 21 -d $SelGPUCC " #X11evo(fastest)
    "x11gost" = " -i 21 -d $SelGPUCC --api-remote" #X11gost
    "x17" = " -i 21.5 -d $SelGPUCC --api-remote" #X17
    #"yescrypt" = "" #Yescrypt
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
    [PSCustomObject]@{
        Type = "NVIDIA"
        Path = $Path
        Arguments = "-b $($Variables.MinerAPITCPPort) -a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = $Variables.MinerAPITCPPort #4068
        Wrap = $false
        URI = $Uri
		User = $Pools.(Get-Algorithm($_)).User
    }
}
