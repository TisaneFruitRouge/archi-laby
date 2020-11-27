####################- INFOS GENERALES -##############
# - On ne demande pas la taille en entrée si on est dans le mode de résolution
# - nomFichier == NOM DU FICHIER
# - $s0 == MODE //1==création laby ; 2==résolution
# - $s1 == TAILLE DU FICHER
#####################################################

###########- MODIFS POUR PLUS TARD -#################
# - Faire en sorte que si mode==2, pas besoin de 3 arguments (mais que de deux)
#####################################################

.data
	retourChariot : .asciiz "\n"  # chaine de caractère pour le retour chariot
	chaineVide : .asciiz "" # juste une chaine vide
	
	texteErreurParam : .asciiz "Nombre d'arguments incorrect"
	
	.align 2 				  #Pour etre sur d'aligner les emplacement mémoire
	buffer: .space 1024       # Buffer qui sert lors de l'ouverture du fichier texte

	nomFichier: .space 256
	extension1 : .asciiz ".txt"
	extension2 : .asciiz ".txt.resolu"
	
	texteMenu : "Menu :\n1 - Generation du labyrinthe\n2 - Resolution du labyrinthe\n"
	texteMode : .asciiz "Choisissez un mode : "
	texteModeError : .asciiz "Choix du mode invalide.\n"
	
	texteDemandeNomFichier : .asciiz "Veuillez rentrer le nom du fichier : "
	texteDemandeNomFichierError : .asciiz "Fichier introuvable."
	
	texteDemandeTaille : .asciiz "Veuillez rentrer la taille du labyrinthe : "
	texteDemandeTailleError : .asciiz "Valeur de la taille invalide.\n"
.text
.globl _main

# Point d'entrée du programme
_main:         
	beqz $a0 startSansParam # Cas où des arguments ne sont pas rentrés en ligne de commande
	bnez $a0 startAvecParam # Cas où des arguments sont rentrés en ligne de commande

startSansParam:
	jal choixFichier1	# Appel de la fonction choixFichier1

	jal choixMode1	# Appel de la fonction choixMode1
	la $s0 ($v0)	# Place dans $s0 le mode d'exécution
	addi $s0 $s0 -1	# On addition -1 à $s0 (comme ça on peut beqz) (donc $s0==0 ou $s0==1)

	bnez $s0 finParam     # On ne demande pas la taille si on est dans le mode résolution
		jal choixTaille1  # Appel de la fonction choixTaille1
		la $s1 ($v0)	  # Place dans $s1 la taille du labyrinthe

	finParam:
		j suiteMain		# Continue l'exécution principale

startAvecParam:
	bne $a0 3  erreurParam	
	jal choixFichier2	# Appel de la fonction choixFichier2
	jal choixTaille2	# Appel de la fonction choixTaille2
	la $s1 ($v0)	# Place dans $s1 la taille du labyrinthe
	jal choixMode2	# Appel de la fonction choixMode2
	la $s0 ($v0) 	# Place dans $s0 le mode d'exécution
	la $a0 ($s0)
	jal printfInt
	j suiteMain		# Continue l'exécution principale
	erreurParam:
	la $a0 texteErreurParam
	jal printfString
	j exit

#Fonction pour quitter le programme
exit:
	li $v0 10
	syscall
	
# BLOC DES FONCTIONS UTILITAIRES

# Affiche la chaine de caractères dans $a0 puis fait un retour chariot
printfString :
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	li $v0 4
	syscall 
	la $a0 retourChariot
	li $v0 4
	syscall
	
	# Epilogue
	lw $a0 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 8
	jr $ra

# Affiche l'entier dans $a0 puis fait un retour chariot	
printfInt :
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	li $v0 1
	syscall 
	la $a0 retourChariot
	li $v0 4
	syscall
	
	# Epilogue
	lw $a0 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 8
	jr $ra

# Cette fonction caste la chaine de caractère contenu dans $a0 en entier
# Retourne dans $v0 l'entier
CastStringInt:
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t0 ($a0) 			# La chaine de caractères à caster
	li $t1 0				# Itérateur
	li $t7 0				# Valeur finale
	deb_CastStringInt:
	add $t2 $t0 $t1			# Place dans $t2 l'adresse du caractère 
	lbu $t3 ($t2)			# Charge dans $t3 le byte du caractère
	beq $t3 '\0' fin_CastStringInt # Vérifie si ce n'est pas la sentinelle
	addi $t4 $t3 -48			# Convertit le caractère en Int
	mul $t7 $t7 10 
	add $t7 $t7 $t4
	addi $t1 $t1 1
	j deb_CastStringInt
	
	# Epilogue
	fin_CastStringInt:
	lw $a0 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 8
	la $v0 ($t7)
	jr $ra

# Cette fonction concatène deux chaines de caractères dans les adresses de debuts sont dans $a0 et $a1
# Ajoute à la fin la chaine pointée par $a0 la chaine pointée par $a1
concat:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	deb_premiereChaine:			# Parcours de la premiere chaine
	lb $t0 ($a0)					# Prends le caractère à l'adresse $a0
	beq $t0 '\n' deb_secondeChaine	# Si c'est le retourChariot alors aller à la seconde chaine
	addi $a0 $a0 1 				# Sinon prendre le caractère suivant
	j deb_premiereChaine			# Répéter l'itération
	
	deb_secondeChaine:			#Parcours de la seconde chaine
	lb $t1 ($a1)					# Prends le caractère à l'adresse $a1
	beq $t1 '\0' fin_concat			# Si c'est la sentinelle alors sortir de la fonction
	sb $t1 ($a0)				# Sinon ajouter à la fin de la premiere chaine
	addi $a0 $a0 1				# Passer à la prochaine adresse dans la premiere chaine
	addi $a1 $a1 1				# Passer au caractère suivant dans la seconde chaine
	j deb_secondeChaine 			# Répéter l'itération
	
	# Epilogue
	fin_concat:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

	
# Cette fonction permet de choisir le nom du fichier dans le cas du lancement du programme sans arguments
# Place dans nomFichier le nom du fichier
choixFichier1:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $a0 texteDemandeNomFichier	# Chargement du message de demande du nom de fichier
	li $v0 4					
	syscall					# Affichage du message			
	la $a0 nomFichier				# Chargement de l'adresse de stockage
	li $a1 256					# Chargement de la taille max
	li $v0 8					
	syscall					# Appel systeme pour demander à l'utilsateur
	la $a0 nomFichier				# Chargement du premier argument de concat
	la $a1 extension1				# Chargement du second argument de concat
	jal concat					# Concatenation de $a0 et $a1
		
	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

# Cette fonction permet de choisir la taille du labyrinthe dans le cas du lancement du programme sans arguments
# Retourne dans $v0 le choix de l'utilisateur
choixTaille1:
	# Prologue
	addi $sp $sp -8
	sw $a0 ($sp)
	sw $ra ($sp)
	
	# Corps de la fonction
	deb_choixTaille1:
	la $a0 texteDemandeTaille		# Chargement du message de la demande
	li $v0 4
	syscall					# Affichage du message de la demande
	li $v0 5					
	syscall					# Lecture de l'entier représentant la taille
	bgt $v0 1 fin_choixTaille1		# Teste si la taille est supérieure stricte à 1
	la $a0 texteDemandeTailleError	# Cas d'une erreur
	jal printfString				# Affichage du message d'erreur
	j deb_choixTaille1			# Redemande à l'utilisateur d'entrer une valeur
	
	# Epilogue
	fin_choixTaille1:
	lw $a0 ($sp)
	lw $ra ($sp)
	addi $sp $sp 8
	jr $ra
	

# Cette fonction permet de choisir le mode d'exécution dans le cas du lancement du programme sans arguments
# Retourne dans $v0 le choix de l'utilisateur
choixMode1:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	deb_choixMode1:
	la $a0 texteMenu			# Chargement du message du menu
	jal printfString			# Affichage du menu
	la $a0 texteMode			# Chargement du message de choix
	li $v0 4				
	syscall				    # Affichage du message de choix
	li $v0 5				# Lecture de l'entier representant le choix
	syscall
	beq $v0 1 fin_choixMode1	# Vérifie si la valeur est égale à 1 ou 2 
	beq $v0 2 fin_choixMode1
	la $a0 texteModeError		# Cas d'une valeur invalide
	li $a1 2				    # On met une boite de dialogue pour les erreurs ?
	li $v0 55
	syscall
	jal printfString			# Affichage du message d'erreur
	j deb_choixMode1			# Redemande à l'utilisateur de faire un choix
	
	# Epilogue
	fin_choixMode1:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

	
# Cette fonction récupère le nom du fichier passée en ligne de commande
# Place dans nomFichier le nom du fichier	
choixFichier2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t0 nomFichier			# Charge dans $t0 l'adresse du nom du fichier
	lw $t1 8($a1)			# Charge dans $t1 le troisieme argument entré en ligne de commande
	deb_choixFichier2:
	lb $t2 ($t1)				# Prend le premier caractère à l'adresse $t1
	beq $t2 '\0' fin_choixFichier2	# Si c'est la sentinelle alors aller à la fin de la fonction
	sb $t2 ($t0)				# Sinon mettre dans à la fin de NomFichier
	addi $t0 $t0 1			# Passer à l'adresse suivante pour nomFichier
	addi $t1 $t1 1			# Prendre le caractère suivant
	j deb_choixFichier2		# Répéter l'itération
												
	# Epilogue
	fin_choixFichier2:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

# Cette fonction récupère la taille du labyrinthe passée en ligne de commande
# Retourne dans $v0 la taille 
choixTaille2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	lw $a0 4($a1)				# Charge dans $a0 le deuxieme argument entré en ligne de commande
	jal CastStringInt				# Caste en entier la chaine de caractère
	bgt $v0 1 fin_choixTaille1		# Teste si la taille est supérieure stricte à 1
	la $a0 texteDemandeTailleError	# Cas d'une erreur
	jal printfString				# Affichage du message d'erreur
	j exit						# Sortie du programme
	
	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra
	
# Cette fonction récupère le mode d'exécution passé en ligne de commande
# Retourne dans $v0 le mode
choixMode2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	lw $a0 ($a1)			# Charge dans $a0 le premier argument entré en ligne de commande
	jal CastStringInt			# Caste en entier la chaine de caractère
	beq $v0 1 fin_choixMode2	# Vérifie si le mode est 1 ou 2
	beq $v0 2 fin_choixMode2
	la $a0 texteModeError		# Cas d'une erreur
	jal printfString			# Affichage du message d'erreur
	j exit					# Sortie du programme
		
	# Epilogue
	fin_choixMode2:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra
	
# BLOC DES FONCTIONS PRINCIPALES


suiteMain: 
	
	beqz $s0 modeGeneration
	j modeResolution


modeGeneration:
	
	### Code Germain
	
	j exit

modeResolution:
	
	# Ouvre le fichier pour lecture

	li   $v0, 13       		  # syscall pour ouvrir un fichier
	la   $a0, nomFichier      # nom du fichier
	li   $a1, 0               # mode d'ouverture (lecture, ecriture etc..)
	li   $a2, 0               # argument ignoré par Mars il me semble
	syscall                   
	move $s0, $v0             # sauvegarde du "file descriptor" dans $s0 

	CreerTableau:
		li   $v0, 14              # syscall pour lire un fichier
		move $a0, $s0             # file descriptor dans $a0
		la   $a1, buffer          # adress du buffer duquel lire
		li   $a2,  1              # taille du buffer (hardcoded)
		syscall  

		
		lb $s1, 0($a1)       # Premier chiffre
    	subiu $s1, $s1, 0x30  # Conversion en entier
    	mul $s1, $s1, 10      # Multiplication par 10 car chiffre des dizaines

    	
    	li $v0, 1           #Affiche pour voir si ça marche
    	move $a0, $s1
    	syscall

    	
    	li $v0 14           # Appel système pour lire un fichier
	    move $a0, $s0       # file descirpor dans $a0
	    syscall

	    lb $s2, 0($a1)       # Deuxième chiffre
	    subiu $s2, $s2, 0x30  # On le converti en entier

	    li $v0, 1           #Affiche pour voir si ça marche
    	move $a0, $s2
    	syscall

    	addu $t2, $s1, $s2  # $t2 contient la taille d'un coté du laby (N = $s1 + $s2)

 		
    	mul $a0, $t2, $t2    # $a0 contient la taille du tableau pour l'allocation mémoire
    	li  $v0, 9           # syscall 9 pour allouer de la mémoire
    	syscall


    	move $t0, $v0        # $t0 contient l'addresse du premier élément du tableau
    	addu $t1, $t0, $a0   # adresse de fin de tableau dans $t1 (cela nous servira à parcourir le tableau)


    RemplirTableau: 
	    beq $t0 $t1 FinRemplissage

	    li   $v0, 14              # syscall pour lire un fichier
		move $a0, $s0             # file descriptor dans $a0
		la   $a1, buffer          # adress du buffer duquel lire
		li   $a2,  1              # taille du buffer (hardcoded)
		syscall  


	    lb $s1 0($a1)       # Caractère courant


	    blt $s1, 48, RemplirTableau # Le caractère doit être un chiffre pour pouvoir être converti
	    bgt $s1, 57, RemplirTableau # 48 <= chiffres <= 57

	    subiu $s1, $s1, 0x30  # On converti le premier digit en entier
	    mul $s1, $s1, 10      # On le multiplie par 10, car c'est le chiffre des dizaine


	    li   $v0, 14         # syscall pour lire un fichier
		move $a0, $s0        # file descriptor dans $a0
		la   $a1, buffer     # adresse du buffer duquel lire
		li   $a2,  1         # taille du buffer (hardcoded)
		syscall  


	    lb $s2, 0($a1)        # Second chiffre
	    subiu $s1, $s1, 0x30  # Conversion en entier

	    addu $s3, $s1, $s2    # $s3 = entier correspondant à la case

	    sb $s3, 0($t0)       # On sauvegarde la valeur dans la bonne case du tableau


    	addiu $t0, $t0, 1     # On incrémente $t0

	    j RemplirTableau


	FinRemplissage:
    	move $a0 $s0        # On ferme le file descriptor
    	li $v0 16           # syscall pour ferme le fichier
    	syscall

	j exit
	