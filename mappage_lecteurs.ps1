########## Commun T ##########

$chemincommun = "\\"+$env:USERDNSDOMAIN+"\dfs\piscine\commun"
New-PSDrive -Name T -PSProvider FileSystem -Root $chemincommun -Description COMMUNTOUS -Persist -Scope global #persist == si le lecteur se deco , à la réouverture de la session il revient

########## Commun S ##########

$cheminservice = "\\"+$env:USERDNSDOMAIN+"\dfs\piscine\services"
New-PSDrive -Name S -PSProvider FileSystem -Root $cheminservices -Description COMMUNSERVICES -Persist -Scope global

########## Commun P ##########

$perso = $env:USERNAME
$cheminperso = "\\"+$env:USERDNSDOMAIN+"\dfs\piscine\perso\"+$perso
New-PSDrive -Name P -PSProvider FileSystem -Root $cheminperso -Description COMMUNPERSO -Persist -Scope global