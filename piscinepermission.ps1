$cheminelement=read-host "Merci d'ecrire le chemin de l'element dont vous souhaitez modifier les permissions"




function retiredroit {
   $nomutilisateur=read-host "De quel utilisateur souhaitez vous modifier les droits?"
   $listedossiertest= Get-Item -Path $cheminelement  -Verbose
 
   foreach ($dossier in $listedossiertest)
   {
    $chemin= $dossier.fullname
    $useracl = "$nomutilisateur"

    Get-Item $chemin | Disable-NTFSAccessInheritance

    Remove-NTFSAccess –Path $chemin  –Account "$nomutilisateur" -AccessRights ReadAndExecute, Synchronize, CreateDirectories, CreateFiles

    $acl = Get-Acl $chemin -Verbose
    $usersid = New-Object System.Security.Principal.Ntaccount ($useracl) -Verbose
    $acl.PurgeAccessRules($usersid)
    $acl | Set-Acl -Verbose

   }
   }
function fullcontrol {
    $nomutilisateur=read-host "De quel utilisateur souhaitez vous modifier les droits?"

    Add-NTFSAccess –Path $cheminelement  –Account $nomutilisateur –AccessRights FullControl -verbose
   }
   function READ {
    $nomutilisateur=read-host "De quel utilisateur souhaitez vous modifier les droits?"

    Add-NTFSAccess –Path $cheminelement  –Account $nomutilisateur –AccessRights Read -verbose
   }
   function READANDWRITE {
    $nomutilisateur=read-host "De quel utilisateur souhaitez vous modifier les droits?"

    Add-NTFSAccess –Path $cheminelement  –Account $nomutilisateur –AccessRights ReadAndExecute, Write -verbose
   }
   function MODIFY {
    $nomutilisateur=read-host "De quel utilisateur souhaitez vous modifier les droits?"

    Add-NTFSAccess –Path $cheminelement  –Account $nomutilisateur –AccessRights Modify -verbose
   }
function ajoutmodule {

    Install-Module NTFSSecurity -ErrorAction SilentlyContinue -Force -Verbose

   }
function partage {
    $admin="ADMINISTRATEUR"
    $namedir=read-host "Comment souhaitez vous nommer votre partage?"
    New-SmbShare -Path $cheminelement -Name $namedir -FullAccess $admin -ChangeAccess 'Tout le monde' -FolderEnumerationMode AccessBased -Verbose

}

function menu {

    write-host = "Merci de selectionner votre choix"
    write-host = "1 : Retirer les droits d'un utilisateur"
    write-host = "2 : Ajouter les droits à un utilisateur"
    write-host = "3 : Partager un fichier"
    write-host = "4 : Permiere utilisation du script, installer le module NTFSSecurity"
    write-host = "Q : Quitter"
    $choix=Read-Host "Votre choix?"

switch ($choix)
{
   1{retiredroit;menu}
   2{menuajoutdroit;menu}
   3{partage;menu}
   4{ajoutmodule;menu}
   Q{Exit}
   default {menu} 
}
}
function menuajoutdroit {

    write-host = "Merci de selectionner votre choix"
    write-host = "1 : FULL ACCESS"
    write-host = "2 : READ"
    write-host = "3 : READ AND WRITE"
    write-host = "4 : MODIFY"
    write-host = "Q : Quitter"
    $choix=Read-Host "Votre choix?"

switch ($choix)
{
   1{fullaccess;menu}
   2{READ;menu}
   3{READANDWRITE;menu}
   4{MODIFY;menu}
   Q{Exit}
   default {menu} 
}
}
menu