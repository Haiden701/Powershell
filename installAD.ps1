#install-windowsfeature AD-Domain-Services
install-ADDSForest `
-ForestMode "7" `
-DomainMode "7" `
-DomainName "morgane.lan" `
-DomainNetbiosName "MORGANE" `
-installDns:$true `
-CreateDnsDelegation:$fals e`
-DatabasePath "B:\BDD" ` #Cérer un dossier BDD dans B:
-LogPath "L:\LOGS" ` # Idem que BDD mais pour logs
-sysvolpath "S:\sysvol" `
-norebootoncompletion:$false`#Fait un reboot
-force:$true #Force l'application