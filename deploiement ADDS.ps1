Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-Credential (Get-Credential) `
-CriticalReplicationOnly:$false `
-DatabasePath "B:\Base" `
-DomainName "piscine.lan" `
-InstallDns:$true `
-LogPath "J:\Journaux" `
-NoRebootOnCompletion:$false `
-ReplicationSourceDC "DC1.piscine.lan" `
-SiteName "Default-First-Site-Name" `
-SysvolPath "S:\Sysvols" `
-Force:$true
