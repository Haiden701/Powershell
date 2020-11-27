$test=(Get-ADDomain).distinguishedName
$chemin="OU=UMBRELLA,$test"
$chemin2="OU=UTILISATEURS,$chemin"
$gpowall=New-GPO -name pagedacceuil
$gpowall | Set-GPPrefRegistryValue -context User  -key HKEY_CURRENT_USER\SOFTWARE\Microsoft"Internet Explorer"\Main -ValueName "Start Page" -value http://www.google.fr/ -type string  -Action Create
New-GPLink -Name pagedacceuil -Target "OU=Commerciaux,OU=UTILISATEURS,OU=UMBRELLA,$test";
New-GPLink -Name pagedacceuil -Target "OU=Comptabilité,OU=UTILISATEURS,OU=UMBRELLA,$test";
New-GPLink -Name pagedacceuil -Target "OU=Documentation,OU=UTILISATEURS,OU=UMBRELLA,$test";
New-GPLink -Name pagedacceuil -Target "OU=IT,OU=UTILISATEURS,OU=UMBRELLA,$test";
New-GPLink -Name pagedacceuil -Target "OU=Stagiaires,OU=UTILISATEURS,OU=UMBRELLA,$test"