Clear-Host

########################################
#        Les Variables Globales        #
########################################

$nomou=Read-Host "Votre nom d'OU de BASE (Principale) ou faites entr�e si vous n'en avez pas"
$cheminbase=(Get-ADDomain).distinguishedname
$cheminou="OU="+$nomou+","+$cheminbase

$liste = Import-CSV -Path "./liste.csv" -Delimiter ";" -Encoding UTF8 #Ne pas utiliser de chemin absolut C:\... ; on choisit le délimiteur;on choisit l'encodage
$cheminutils ="OU=UTILISATEURS,"+$cheminou
$chemingroupes = "OU=GROUPES,"+$cheminou



########################################
#            Les Fonctions             #
########################################

function creation_ou()
{
$nomou=Read-Host "Votre nom d'OU svp"
New-ADOrganizationalUnit -Name $nomou -Path $cheminbase
}

function suppression_totale()
{
    $nomou=Read-Host "Quelle OU voulez-vpus supprimer ?"
    $nomoucomplet="OU="+"$nomou"+","+"$cheminbase"
    Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -Identity $nomoucomplet -Verbose
    Remove-ADOrganizationalUnit $nomoucomplet -Verbose -Confirm:$true -Recursive

    $chemin=(Get-DfsnRoot).path+"\*" #on récupère tout les chemin Dfs root"
    $chemin_service = (Get-DfsnFolder -Path $chemin).path+"\Services\*"
    $chemin_perso = (Get-DfsnFolder -Path $chemin).path+"\Perso\*"

    Remove-Item -Path $chemin_service -Recurse -Verbose
    Remove-Item -Path $chemin_service -Recurse -Verbose

}

function affichage_ou()
{
    clear-host
    Get-ADOrganizationalUnit -filter * -SearchScope OneLevel |Format-Table Name
    
}

function pause ($message="Appuyer sur 1 touche pour continuer")
{
    write-host -NoNewline $message
    $null=$host.UI.RawUI.ReadKey("Noecho,includeKeydown")
    write-host ""
}

function creation_ous()
{
    New-ADOrganizationalUnit -Name GROUPES -Path $cheminou -Verbose -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name IMPRIMANTES -Path $cheminou -Verbose -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name ORDINATEURS -Path $cheminou -Verbose -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name SERVEURS -Path $cheminou -Verbose -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name UTILISATEURS -Path $cheminou -Verbose -ProtectedFromAccidentalDeletion $false
  
   foreach ($ligne in $liste)
    {

        $service = $ligne.service.toUpper() #Va chercher dans la colonne service et stock dans $service; on convertit en majuscules
        try {
            New-ADOrganizationalUnit -Name $service -Path $cheminutils -verbose -ProtectedFromAccidentalDeletion $false
            }
            catch{}
     }
}

function creation_groupes()
{
    #### Création des groupes globaux généraux ###

    new-adgroup -GroupCategory Security -GroupScope Global -Name GG_TOUS -Path $chemingroupes -Verbose
    new-adgroup -GroupCategory Security -GroupScope Global -Name GG_PERMANENT -Path $chemingroupes -Verbose
    new-adgroup -GroupCategory Security -GroupScope Global -Name GG_TEMPORAIRE -Path $chemingroupes -Verbose

    #### Création des groupes de domaines locaux généraux ###

     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_TOUS_R -Path $chemingroupes -Verbose
     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_TOUS_RW -Path $chemingroupes -Verbose
     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_TOUS_M -Path $chemingroupes -Verbose

     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_TEMPORAIRE_R -Path $chemingroupes -Verbose
     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_TEMPORAIRE_RW -Path $chemingroupes -Verbose

     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_PERMANENT_R -Path $chemingroupes -Verbose
     new-adgroup -GroupCategory Security -GroupScope DomainLocal -Name GDL_PERMANENT_RW -Path $chemingroupes -Verbose

     #### Création des groupes par service depuis le CSV ###

       foreach ($ligne in $liste)
    {
        $service=$ligne.service.toupper()
        $GG="GG_"+$service
        $GU="GU_"+$service
        $GDL_R="GDL_"+$service+"_R"     #Lecture
        $GDL_RW="GDL_"+$service+"_RW"   #Lecture & Ecriture
        $GDL_M="GDL_"+$service+"_M"     #Modification
        $GDL_F="GDL_"+$service+"_F"     #Full

        try {
            new-adgroup -GroupCategory Security -GroupScope Global -Name $GG -Path $chemingroupes -Verbose
        } catch {}

         try {
            new-adgroup -GroupCategory Security -GroupScope Universal -Name $GU -Path $chemingroupes -Verbose
        } catch {}

         try {
            new-adgroup -GroupCategory Security -GroupScop DomainLocal -Name $GDL_R -Path $chemingroupes -Verbose
        } catch {}

        try {
            new-adgroup -GroupCategory Security -GroupScop DomainLocal -Name $GDL_RW -Path $chemingroupes -Verbose
        } catch {}

        try {
            new-adgroup -GroupCategory Security -GroupScop DomainLocal -Name $GDL_M -Path $chemingroupes -Verbose
        } catch {}

        try {
            new-adgroup -GroupCategory Security -GroupScop DomainLocal -Name $GDL_F -Path $chemingroupes -Verbose
        } catch {}

        Add-ADGroupMember $GU -Members $GG -Verbose #Le groupe universsel sont membre de groupe global
        Add-ADGroupMember $GDL_R -Members $GU -Verbose
        Add-ADGroupMember $GDL_RW -Members $GU -Verbose
        Add-ADGroupMember $GDL_M -Members $GU -Verbose
        Add-ADGroupMember $GDL_F -Members $GU -Verbose

        Add-ADGroupMember GG_TOUS -Members $GG -Verbose
        #Add-ADGroupMember GG_PERMANENT -Members $GG -Verbose
        #Add-ADGroupMember GG_TEMPORAIRE -Members $GG -Verbose
    }

     Add-ADGroupMember GDL_TOUS_R -Members GG_TOUS -Verbose
     Add-ADGroupMember GDL_TOUS_RW -Members GG_TOUS -Verbose
     Add-ADGroupMember GDL_TOUS_M -Members GG_TOUS -Verbose

     Add-ADGroupMember GDL_PERMANENT_R -Members GG_PERMANENT -Verbose
     Add-ADGroupMember GDL_PERMANENT_RW -Members GG_PERMANENT -Verbose

     Add-ADGroupMember GDL_TEMPORAIRE_R -Members GG_TEMPORAIRE -Verbose
     Add-ADGroupMember GDL_TEMPORAIRE_RW -Members GG_TEMPORAIRE -Verbose

     Add-ADGroupMember GG_TOUS -Members GG_PERMANENT -Verbose
     Add-ADGroupMember GG_TOUS -Members GG_TEMPORAIRE -Verbose
}

function affichage_groupes()
{
    #Liste des groupes globaux
    Write-Host "Liste des groupe globaux"
    Get-ADGroup -Filter * -SearchBase $chemingroupes |where {$_.groupscope -eq "Global" } | ft name

    #Liste des groupes Domain local
    Write-Host "Liste des groupe Domain Locaux"
    Get-ADGroup -Filter * -SearchBase $chemingroupes |where {$_.groupscope -eq "Domainlocal" } | ft name
    $nomgroupe = Read-Host "Le groupe que vous souhaitez détailler ?"
    Get-ADGroupMember $nomgroupe | ft name #Format Table
}

function permissions()
{
    $chemin=(Get-DfsnRoot).path+"\*"
    $chemin_service = (Get-DfsnFolder -Path $chemin).path+"\Services\"
    $chemin_perso = (Get-DfsnFolder -Path $chemin).path+"\Perso\"

    $listedossierservices = Get-ChildItem -Path $chemin_service -Directory
    $listedossierperso = Get-ChildItem -Path $chemin_perso -Directory

    ############## Dossier Service #################

    foreach($dossier in $listedossierservices)
    {
        $chemin = $dossier.fullname #chemin du dossier == chemin absolut
        $acl = (Get-Item $chemin).GetAccessControl('Access')
        $gdl = "GDL_"+$dossier.name+"_RW"
        $ar = New-Object security.accesscontrol.filesystemaccessrule($gdl,'ReadAndExecute,Write','ContainerInherit,ObjectInherit','none','Allow') #Access rule
        $acl.SetAccessRule($ar)
        Set-Acl -Path $chemin -AclObject $acl -Verbose    
     }

     
     ############## Dossier Perso #################

         foreach($dossier in $listedossierperso)
    {
        $chemin = $dossier.fullname #chemin du dossier == chemin absolut
        $acl = (Get-Item $chemin).GetAccessControl('Access')
        $nomuser = $dossier.name
        $ar = New-Object security.accesscontrol.filesystemaccessrule($nomuser,'Modify','ContainerInherit,ObjectInherit','none','Allow') #Access rule
        $acl.SetAccessRule($ar)
        Set-Acl -Path $chemin -AclObject $acl -Verbose    
     }
}

function creation_dossiers
()
{
    $chemin=(Get-DfsnRoot).path+"\*"
    $chemin_service = (Get-DfsnFolder -Path $chemin).path+"\Services\"
    $chemin_perso = (Get-DfsnFolder -Path $chemin).path+"\Perso\"

    $chemin_test = $chemin_service+$service
    $existe = test-path -Path $chemin_test

    if (!$existe)
    {
        New-Item -ItemType Directory -Name $service -Path $chemin_service
    }

    New-Item -ItemType Directory -Name $sam -Path $chemin_perso
}

function creation_users ()
{
      $pass = ConvertTo-SecureString("Merignac1") -AsPlainText -Force

      foreach ($ligne in $liste)
    {
        $prenom = $ligne.prenom.substring(0,1).toUpper()+$ligne.prenom.substring(1).toLower() #substring 0,1 me 0 corresspond au départ et le 1 le nombre de caratère
        $nom = $ligne.nom.toUpper()
        $nomcomplet = $prenom+" "+$nom
        $sam = $prenom.tolower()+"."+$nom.tolower()
        $upn = $sam+"@"+$env:USERDNSDOMAIN.tolower() #variable d'environement pour récupérer le nom de domaine elle sont natif au système
        $fonction = $ligne.fonction.substring(0,1).toUpper()+$ligne.fonction.substring(1).toLower()
        $service = $ligne.service.toupper()
        $description = $ligne.despcrition
        $mail = $upn
        $cheminsuer = "OU="+$service+","+$cheminutils
        $groupe = "GG_"+$service

        New-ADUser  -GivenName $prenom -SurName $nom -Name $nomcomplet -DisplayName $nomcomplet -SamAccountName $sam -UserPrincipalName $upn -Title $fonction -Department $service -Description $description -EmailAddress $mail -Path $cheminsuer  -AccountPassword $pass -ChangePasswordAtLogon $True -Enabled $true -Verbose
        creation_dossiers($service,$sam)
        Add-ADGroupMember $groupe -Members $sam -Verbose

    }
}

function modification_adresse_ip ()
{
    Get-NetIPInterface
    Get-NetIPAddress
    $inter=Read-Host "Entrer 1 n° index interface"

    ### Interface / IP /Version / Mask CIDR / Gateway / DNS1 /DNS2 ###
    Remove-NetIPAddress -InterfaceIndex $inter -Confirm:$true
    Set-DnsClientServerAddress -InterfaceIndex $inter -ResetServerAddresses

    $version="IPV4"
    $IP=Read-Host "Entrer 1 adresse IP"
    $mask=Read-Host "Entrer 1 masque"
    $gateway=Read-Host "Entrer 1 Gateway"
    $dns1=Read-Host "Entrer 1 DNS primaire"
    $dns2=Read-Host "Entrer 1 DNS secondaire"


    New-NetIPAddress -AddressFamily $Version -InterfaceIndex $inter -IPAddress $IP -PrefixLength $mask -DefaultGateway $gateway | Set-DnsClientServerAddress $dns1,$dns2

    ipconfig
}

 ########################################
 #         La Fonction Principale       #
 ########################################

function menu()
{
    Clear-Host
    Write-Host "**** Projet TSSR ****"
    Write-Host "1 Cr�ation d'une OU ?"
    Write-Host "2 Affichage de la liste des OU ?"
    Write-Host "3 Suppression d'une OU ?"
    Write-Host "4 Ajout d'OU en lot (fichier CSV)"
    Write-Host "5 Cr�ation des Groupes (GG GU GDL)"
    Write-Host "6 Affiche les membres d'un groupe"
    Write-Host "7 Cr�ation d'utilisateurs en lot"
    Write-Host "8 Modifer votre adresse IP"
    Write-Host "9 Modifier les permissions"
    Write-Host "Q Quitter ?"

    $choix=Read-Host "Votre choix ?"
    
    switch ($choix)
    {
        1 {creation_ou;pause;menu}
        2 {affichage_ou;pause;menu}
        3 {suppression_totale;pause;menu}
        4 {creation_ous;pause;menu}
        5 {creation_groupes;pause;menu}
        6 {affichage_groupes;pause;menu}
        7 {creation_users;pause;menu}
        8 {modification_adresse_ip;pause;menu}
        9 {permissions;pause;menu}
        Q {exit}
        default {menu}
     }
}
menu