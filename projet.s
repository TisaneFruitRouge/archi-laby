.data
	laby : .space 400000
	nomFichier: .space 256
	retourChariot : .asciiz "\n"  # chaine de caract�re pour le retour chariot
	chaineVide : .asciiz "" # juste une chaine vide
	espace : .asciiz " "   # juste un espace
	
	texteErreurParam : .asciiz "Nombre d'arguments incorrect"
	
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

# Point d'entr�e du programme
_main:         
	beqz $a0 startSansParam # Cas o� des arguments ne sont pas rentr�s en ligne de commande
	bnez $a0 startAvecParam # Cas o� des arguments sont rentr�s en ligne de commande

startSansParam:
	jal choixFichier1		# Appel de la fonction choixFichier1
	jal choixMode1		# Appel de la fonction choixMode1
	la $s0 ($v0)		# Place dans $s0 le mode d'ex�cution
	addi $s0 $s0 -1
	bnez $s0 suiteMain	# Passe directement � la suite si c'est le mode 2
	jal choixTaille1		# Appel de la fonction choixTaille1
	la $s1 ($v0)		# Place dans $s1 la taille du labyrinthe
	j suiteMain			# Continue l'ex�cution principale

startAvecParam:
	bne $a0 3  erreurParam
		
	jal choixFichier2		# Appel de la fonction choixFichier2
	jal choixMode2		# Appel de la fonction choixMode2
	la $s0 ($v0) 		# Place dans $s0 le mode d'ex�cution
	addi $s0 $s0 -1
	bnez $s0 suiteMain	# Passe directement � la suite si c'est le mode 2
	jal choixTaille2		# Appel de la fonction choixTaille2
	la $s1 ($v0)		# Place dans $s1 la taille du labyrinthe
	j suiteMain			# Continue l'ex�cution principale
	
	erreurParam:
	la $a0 texteErreurParam
	jal printfString
	j exit

suiteMain:
	beqz $s0 modeGeneration
	j modeResolution
exit:
	li $v0 10
	syscall
	
# BLOC DES FONCTIONS UTILITAIRES

# Affiche la chaine de caract�res dans $a0 puis fait un retour chariot
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

# Cette fonction caste la chaine de caract�re contenu dans $a0 en entier
# Retourne dans $v0 l'entier
CastStringInt:
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t0 ($a0) 			# La chaine de caract�res � caster
	li $t1 0				# It�rateur
	li $t7 0				# Valeur finale
	deb_CastStringInt:
	add $t2 $t0 $t1			# Place dans $t2 l'adresse du caract�re 
	lbu $t3 ($t2)			# Charge dans $t3 le byte du caract�re
	beq $t3 '\0' fin_CastStringInt # V�rifie si ce n'est pas la sentinelle
	addi $t4 $t3 -48			# Convertit le caract�re en Int
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

# Cette fonction concat�ne deux chaines de caract�res dans les adresses de debuts sont dans $a0 et $a1
# Ajoute � la fin la chaine point�e par $a0 la chaine point�e par $a1
concat:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	deb_premiereChaine:			# Parcours de la premiere chaine
	lb $t0 ($a0)					# Prends le caract�re � l'adresse $a0
	beq $t0 '\n' deb_secondeChaine	# Si c'est le retourChariot alors aller � la seconde chaine
	addi $a0 $a0 1 				# Sinon prendre le caract�re suivant
	j deb_premiereChaine			# R�p�ter l'it�ration
	
	deb_secondeChaine:			#Parcours de la seconde chaine
	lb $t1 ($a1)					# Prends le caract�re � l'adresse $a1
	beq $t1 '\0' fin_concat			# Si c'est la sentinelle alors sortir de la fonction
	sb $t1 ($a0)				# Sinon ajouter � la fin de la premiere chaine
	addi $a0 $a0 1				# Passer � la prochaine adresse dans la premiere chaine
	addi $a1 $a1 1				# Passer au caract�re suivant dans la seconde chaine
	j deb_secondeChaine 			# R�p�ter l'it�ration
	
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
	syscall					# Appel systeme pour demander � l'utilsateur
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
	syscall					# Lecture de l'entier repr�sentant la taille
	bgt $v0 1 fin_choixTaille1		# Teste si la taille est sup�rieure stricte � 1
	la $a0 texteDemandeTailleError	# Cas d'une erreur
	jal printfString				# Affichage du message d'erreur
	j deb_choixTaille1			# Redemande � l'utilisateur d'entrer une valeur
	
	# Epilogue
	fin_choixTaille1:
	lw $a0 ($sp)
	lw $ra ($sp)
	addi $sp $sp 8
	jr $ra
	

# Cette fonction permet de choisir le mode d'ex�cution dans le cas du lancement du programme sans arguments
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
	syscall				# Affichage du message de choix
	li $v0 5				# Lecture de l'entier representant le choix
	syscall
	beq $v0 1 fin_choixMode1	# V�rifie si la valeur est �gale � 1 ou 2 
	beq $v0 2 fin_choixMode1
	la $a0 texteModeError		# Cas d'une valeur invalide
	#li $a1 2				# On met une boite de dialogue pour les erreurs ?
	#li $v0 55
	#syscall
	jal printfString			# Affichage du message d'erreur
	j deb_choixMode1			# Redemande � l'utilisateur de faire un choix
	
	# Epilogue
	fin_choixMode1:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

	
# Cette fonction r�cup�re le nom du fichier pass�e en ligne de commande
# Place dans nomFichier le nom du fichier	
choixFichier2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t0 nomFichier			# Charge dans $t0 l'adresse du nom du fichier
	lw $t1 8($a1)			# Charge dans $t1 le troisieme argument entr� en ligne de commande
	deb_choixFichier2:
	lb $t2 ($t1)				# Prend le premier caract�re � l'adresse $t1
	beq $t2 '\0' fin_choixFichier2	# Si c'est la sentinelle alors aller � la fin de la fonction
	sb $t2 ($t0)				# Sinon mettre dans � la fin de NomFichier
	addi $t0 $t0 1			# Passer � l'adresse suivante pour nomFichier
	addi $t1 $t1 1			# Prendre le caract�re suivant
	j deb_choixFichier2		# R�p�ter l'it�ration
												
	# Epilogue
	fin_choixFichier2:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

# Cette fonction r�cup�re la taille du labyrinthe pass�e en ligne de commande
# Retourne dans $v0 la taille 
choixTaille2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	lw $a0 4($a1)				# Charge dans $a0 le deuxieme argument entr� en ligne de commande
	jal CastStringInt				# Caste en entier la chaine de caract�re
	bgt $v0 1 fin_choixTaille1		# Teste si la taille est sup�rieure stricte � 1
	la $a0 texteDemandeTailleError	# Cas d'une erreur
	jal printfString				# Affichage du message d'erreur
	j exit						# Sortie du programme
	
	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra
	
# Cette fonction r�cup�re le mode d'ex�cution pass� en ligne de commande
# Retourne dans $v0 le mode
choixMode2:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	lw $a0 ($a1)			# Charge dans $a0 le premier argument entr� en ligne de commande
	jal CastStringInt			# Caste en entier la chaine de caract�re
	beq $v0 1 fin_choixMode2	# V�rifie si le mode est 1 ou 2
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

# Cette fonction initialise un tableau d'entier NxN avec une valeur
# $a0 : contient la taille du tableau
# $a1 : contient l'adresse du premier element du tableau
# $a2 : contient la valeur utilis�e pour initialiser
initialiseLabyrinthe:
	# Prologue
	addi $sp $sp -16
	sw $a0 12($sp)
	sw $a1 8($sp)
	sw $a2 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	li $t0 0 					# it�rateur de la ligne 
	deb_parcoursLigneI:
	beq $t0 $a0 fin_initialiseLabyrinthe # for (i = 0, i < $a0, i++)
	li $t1 0 					# it�rateur de la colonne 
	deb_parcoursColonneI:
	beq $t1 $a0 fin_parcoursColonneI 	# for (j = 0, j < $a0, j++)
	mul $t3 $t0 $a0				# ((i*TailleColonne
	add $t3 $t3 $t1				#			  + j)
	mul $t3 $t3 4				#			      *sizeOf(Int))
	add $t3 $t3 $a1				#                                             + addrDebut == tab[i][j]
	sw $a2 ($t3)				# tab[i][j] = $a2
	addi $t1 $t1 1				# Incr�mente j
	j deb_parcoursColonneI			# Passe au d�but de la boucle j
	fin_parcoursColonneI:
	addi $t0 $t0 1				# Incr�ment i
	j deb_parcoursLigneI			# Passe au d�but de la boucle i
	
	# Epilogue
	fin_initialiseLabyrinthe:
	lw $a0 12($sp)
	lw $a1 8($sp)
	lw $a2 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 16
	jr $ra

# Cette fonction affiche le labyrinthe
# $a0 : contient la taille du tableau
# $a1 : contient l'adresse du premier element du tableau
afficheLabyrinthe:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t0 ($a0)
	li $t1 0 					# it�rateur de la ligne 
	deb_parcoursLigneA:
	beq $t1 $t0 fin_afficheLabyrinthe 	# for (i = 0, i < $a0, i++)
	li $t2 0 					# it�rateur de la colonne 
	deb_parcoursColonneA:
	beq $t2 $t0 fin_parcoursColonneA	# for (j = 0, j < $a0, j++)
	mul $t4 $t1 $t0				# ((i*TailleColonne
	add $t4 $t4 $t2				#			  + j)
	mul $t4 $t4 4				#			      *sizeOf(Int))
	add $t4 $t4 $a1				#                                             + addrDebut == tab[i][j]
	lw $a0 ($t4)				# $a0 = tab[i][j]
	li $v0 1					
	syscall					# Affiche l'entier tab[i][j]
	la $a0 espace				# Charge un espace
	li $v0 4
	syscall					# Affiche un espace
	addi $t2 $t2 1				# Incr�mente j
	j deb_parcoursColonneA		# Passe au d�but de la boucle j
	fin_parcoursColonneA:
	la $a0 retourChariot			# Charge '\n'
	li $v0 4
	syscall					# Fait un retour chariot
	addi $t1 $t1 1				# Incremente i
	j deb_parcoursLigneA			# Passe au d�but de la boucle i
	
	# Epilogue
	fin_afficheLabyrinthe:
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra


# Cette fonction change le Nieme bit de $a1
# $a0 : position du bit � changer
# $a1 : valeur � changer
# Retourne dans $v0 la valeur modifi�e
changeBitN:
	# Prologue 
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	li $t1 1
	sllv $t0 $t1 $a0 		# Masque pour le nombre 1 << N
	xor $v0 $t0 $a1			# Place dans $v0 la nouvelle valeur
	
	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

# Cette fonction retourne la valeur du bit à la position N
# $a0 contient la position du bit
# $a1 contient la valeur à checker
# La fonction retourne dans $v0 la valeur du bit N
checkValeurBitN:
	#Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)

	#Corps de la fonction
	li $t0 1
	sllv $t1 $t0 $a0		# Masque pour le nombre 1 << N
	and $t2 $t1 $a1			# $a0 & (1 << N)
	seq $v0 $t2 $t1			# Place dans $v0 le bit à la position N

	#Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

	
# Cette fonction transforme les coordonn�es i,j en position dans le tableau
# $a0 contient la coordonn�e en i de la case
# $a1 contient la coordonn�e en j de la case
# $a2 contient la taille du tableau
# Retourne dans $v0 la position
coordToPos:
	# Prologue
	addi $sp $sp -16
	sw $a0 12($sp)
	sw $a1 8($sp)
	sw $a2 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	la $t1 laby
	mul $t0 $a0 $a2 	# ((i*TailleColonne
	add $t0 $t0 $a1	#			  + j)
	mul $t0 $t0 4	#			      *sizeOf(Int))
	add $t0 $t0 $t1	#                                             + addrDebut == tab[i][j]

	# Epilogue
	la $v0 ($t0)
	lw $a0 12($sp)
	lw $a1 8($sp)
	lw $a2 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 16
	jr $ra
	
# Cette fonction transforme la position dans le tableau en coordonnées i,j
# $a0 contient la position de la case
# $a1 contient la taille du tableau
# Retourne dans $v0 la coordonnée en i et $v1 la coordonnée en j
posToCoord:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)

	# Corps de la fonction
	la $t0 laby 		# adresse du début du laby
	sub $t1 $a0 $t0  	# ((pos - adrDebut)
	div $t1 $t1 4		#                 // sizeof(Int))
	div $v0 $t1 $a1 	# i = res//tailleColonne
	mfhi $v1			# j = res%tailleColonne

	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp -12
	jr $ra


# Cette fonction modifie le labyrinthe
# $a0 contient la position de la case
# $a1 contient le bit qui se modifier pour le nombre en i,j
# effet de bord sur laby 
updateLabyrinthe:
	# Prologue
	addi $sp $sp -12
	sw $a0 8($sp)
	sw $a1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	lw $t0 ($a0)
	la $s0 ($a0)
	la $t1 ($a1)
	la $a0 ($t1)
	la $a1 ($t0)
	jal changeBitN
	sw $v0 ($s0)

	# Epilogue
	lw $a0 8($sp)
	lw $a1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 12
	jr $ra

# Cette fonction permet de placer le depart et l'arriv�e
# $a0 contient la taille du labyrinthe
# Retourne dans $v0 la position de la case de d�part
choixDepartArrivee:
	# Prologue
	addi $sp $sp -24
	sw $a0 20($sp)
	sw $a1 16($sp)
	sw $a2 12($sp)
	sw $s0 8($sp)
	sw $s1 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	
	# Travaille sur la position de la case de d�part. La case d'arriv�e est plac�e en fonction de celle de d�part
	# Choix de horizontal / Vertical
	# Choisit  al�atoirement un entier entre 0 et 1. 
	# 0 : la case sera � la verticale
	# 1 : la case sera � l'horizontale
	la $s1 ($a0)
	li $a0 0
	li $a1 2 
	li $v0 42
	syscall 
	move $t0 $a0
	
	# Choix du c�t�
	# Choisit  al�atoirement un entier entre 0 et 1. 
	# Si c'est l'orientation verticale : 
	## 0 : la case sera en haut
	## 1 : la case sera en bas
	# Si c'est l'orientation horizontale :
	## 0 : la case sera � gauche
	## 1 : la case sera � droite
	li $a0 0
	li $a1 2
	li $v0 42
	syscall 
	move $t1 $a0
	
	# Choix position de d�part
	# Choisit  al�atoirement un entier entre 0 et taille - 1 
	li $a0 0
	la $a1 ($s1)
	li $v0 42
	syscall 
	move $t3 $a0
	
	# Choix position d'arriv�e
	# Choisit  al�atoirement un entier entre 0 et taille - 1 
	li $a0 0
	la $a1 ($s1)
	li $v0 42
	syscall 
	move $t4 $a0
	
	bnez $t1 secondCote	# Test du choix du cot� : haut/bas - gauche/droite
	premierCote:		# Cas du premier c�t� : haut ou gauche
	li $t5 0			# $t5 coordonn�e de la case de d�part
	la $t6 ($s1)			# $t6 coordonn�e de la case de d'arriv�e
	addi $t6 $t6 -1
	bnez $t0 suite_choixH	# Test de l'orientation : horizontale/verticale
	j suite_choixV
	secondCote:		# Cas du second c�t� : bas ou droite
	li $t6 	0			# $t6 coordonn�e de la case de d'arriv�e
	la $t5 ($s1)			# $t5 coordonn�e de la case de d�part
	addi $t5 $t5 -1
	bnez $t0 suite_choixH	# Test de l'orientation : horizontale/verticale
	j suite_choixV
	
	suite_choixV:		# Cas de l'orientation verticale
	la $a0 ($t5)			# $a0 contient la coordonn�e en i de la case de d�part
	la $a1 ($t3)			# $a1 contient la coordonn�e en j de la case de d�part
	la $a2 ($s1)		# $a2 contient la taille du labyrinthe
	jal coordToPos
	la $a0 ($v0)		# $a0 contient la position de la case
	li $a1 4			# $a3 contient le bit � modifier pour marquer comme case de d�part
	jal updateLabyrinthe	# Appel de la fonction pour placer la case de d�part
	la $s0 ($a0)		# $s0 contient la postion de la case de d�part
	la $a0 ($t6)			# $a0 contient la coordonn�e en i de la case d'arriv�e
	la $a1 ($t4)			# $a1 contient la coordonn�e en j de la case d'arriv�e
	la $a2 ($s1)		# $a2 contient la taille du labyrinthe
	jal coordToPos
	la $a0 ($v0)		# $a0 contient la position de la case
	li $a1 5			# $a3 contient le bit � modifier pour marquer comme case d'arriv�e
	jal updateLabyrinthe	# Appel de la fonction pour placer la case d'arriv�e
	j fin_choixDepartArrivee
	
	suite_choixH:		# Cas de l'orientation horizontale
	la $a0 ($t3)			# $a0 contient la coordonn�e en i de la case de d�part
	la $a1 ($t5)			# $a1 contient la coordonn�e en j de la case de d�part
	la $a2 ($s1)		# $a2 contient la taille du labyrinthe
	jal coordToPos
	la $a0 ($v0)		# $a0 contient la position de la case
	li $a1 4			# $a3 contient le bit � modifier pour marquer comme case de d�part
	jal updateLabyrinthe	# Appel de la fonction pour placer la case de d�part
	la $s0 ($v0)		# $s0 contient la postion de la case de d�part
	la $a0 ($t4)			# $a0 contient la coordonn�e en i de la case d'arriv�e
	la $a1 ($t6)			# $a1 contient la coordonn�e en j de la case d'arriv�e
	la $a2 ($s1)		# $a2 contient la taille du labyrinthe
	jal coordToPos
	la $a0 ($v0)		# $a0 contient la position de la case
	li $a1 5			# $a3 contient le bit � modifier pour marquer comme case d'arriv�e
	jal updateLabyrinthe	# Appel de la fonction pour placer la case d'arriv�e
	j fin_choixDepartArrivee	
	
	# Epilogue
	fin_choixDepartArrivee:
	la $v0 ($s0)		# Place dans $v0 la position de la case d�part.
	lw $a0 20($sp)
	lw $a1 16($sp)
	lw $a2 12($sp)
	lw $s0 8($sp)
	lw $s1 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 24
	jr $ra

# Cette fonction v�rifie si une case a des voisins non visit�s
# $a0 position de la case
# $a1 taille du labyrinthe
# la fonction retourne dans $v0 -1 si la case n'a pas de voisins non visit�s sinon la position d'un des voisins
voisinNonVisite:
	# Prologue
	addi $sp $sp -32
	sw $a0 28($sp)
	sw $a1 24($sp)
	sw $s0 20($sp)
	sw $s1 16($sp)
	sw $s2 12($sp)
	sw $s3 8($sp)
	sw $s4 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	addi $s0 $a0 4			# $s0 : voisin de droite
	addi $s1 $a0 -4			# $s1 : voisin de gauche
	mul $t0 $a1 4
	add $s2 $a0 $t0			# $s2 : voisin du haut
	mul $t0 $a1 -4
	add $s3 $a0 $t0			# $s3 : voisin du bas

	la $t0 laby				# position minimale
	mul $t1 $a1 $a1			# (N²
	sub $t1 $t1 $a1         #    - N)
	mul $t1 $t1 4 			#        *sizeof(Int)
	add $t1 $t1 $t0			#                     + adrDebut = position maximale

	## Le voisin est bien dans le laby ?
	blt $s0 $t0 noDroite	# Vérifie si le voisin de droite est dans le labyrinthe
	bgt $s0 $t1 noDroite
	j forGauche				# Passe au voisin de gauche
	noDroite:
		li $s0 -1			# Met -1 si le voisin n'est pas dans le labyrinthe
	forGauche:
	blt $s1 $t0 noGauche	# Vérifie si le voisin de gauche est dans le labyrinthe
	bgt $s1 $t1 noGauche
	j forHaut				# Passe au voisin du haut
	noGauche:
		li $s1 -1			# Met -1 si le voisin n'est pas dans le labyrinthe
	forHaut:
	blt $s2 $t0 noHaut		# Vérifie si le voisin du haut est dans le labyrinthe
	bgt $s2 $t1 noHaut
	j forBas				# Passe au voisin du bas
	noHaut:
		li $s2 -1			# Met -1 si le voisin n'est pas dans le labyrinthe
	forBas:
	blt $s3 $t0 noBas		# Vérifie si le voisin du bas est dans le labyrinthe
	bgt $s3 $t1 noBas
	j forSuite				# Continue la suite de l'algo
	noBas:
		li $s3 -1			# Met -1 si le voisin n'est pas dans le labyrinthe
	
	forSuite:
	li $s4 0 				# Compteur de voisins non visités
	## Check s'il est déja visité
	beq $s0 -1 apresVD		# Si le voisin est dans le labyrinthe, le mettre dans le stack, sinon passer au suivant
	li $a0 7				# Charge dans $a0 la valeur indiquant le bit 7
	lw $a1 ($s0)			# Charge dans $a1 la valeur du voisin 
	jal checkValeurBitN		# Vérifie s'il est déjà visité
	beq $v0 1 apresVD		# S'il est déja visité, passer au prochain voisin
	addi $s4 $s4 1			# Sinon, incrémenté le nombre de voisins non visités
	addi $sp $sp -4			# Allouer de l'espace dans la pile
	sw $s0 ($sp)			# Placer la case en haut de pile

	apresVD:
	beq $s1 -1 apresVG
	lw $a1 ($s1)
	jal checkValeurBitN
	beq $v0 1 apresVG
	addi $s4 $s4 1
	addi $sp $sp -4
	sw $s1 ($sp)

	apresVG:
	beq $s2 -1 apresVH
	lw $a1 ($s2)
	jal checkValeurBitN
	beq $v0 1 apresVH
	addi $s4 $s4 1
	addi $sp $sp -4
	sw $s2 ($sp)

	apresVH:
	beq $s3 -1 apresVB
	lw $a1 ($s3)
	jal checkValeurBitN
	beq $v0 1 apresVB
	addi $s4 $s4 1 
	addi $sp $sp -4
	sw $s3 ($sp)

	apresVB: 
## choix du voisin
	beqz $s4 tousVisite		# Vérifie s'il y'a des voisins non visités
	li $a0 0				# Choisir un nombre aléatoire pour choisir le voisin
	la $a1 ($s4)
	li $v0 42
	syscall 
	move $t1 $a0			# Mettre dans $t1 le numero choisi
	mul $t1 $t1 4			# Calculez l'adresse dans la pile d'un voisin en fonction du numéro choisi
	la $t2 ($sp)
	add $t2 $t2 $t1		
	lw $v0 ($t2)			# Place dans $v0 le voisin non visité choisit aléatoirement

	deb_retourNormal:		# Dépile les voisins mis dans la pile
	beqz $s4 fin_voisinNonVisite
	addi $sp $sp 4
	addi $s4 $s4 -1	
	j deb_retourNormal
	
	tousVisite:				# Cas où tous les voisins sont déjà visités
	li $v0 -1				# Place dans $v0 -1
	# Epilogue
	fin_voisinNonVisite:
	lw $a0 28($sp)
	lw $a1 24($sp)
	lw $s0 20($sp)
	lw $s1 16($sp)
	lw $s2 12($sp)
	lw $s3 8($sp)
	lw $s4 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 32
	jr $ra

# BLOC GENERATION
modeGeneration:
	## DONNEES
	la $a0 ($s1) 		# Place dans $a0 la taille du labyrinthe
 	la $a1 laby			# Place dans $a1 l'adresse du d�but du labyrinthe
 	li $a2 15			# initialise le labyrinthe avec la valeur 15  :  00001111
 	jal initialiseLabyrinthe   # initialisation du labyrinthe
 	#jal afficheLabyrinthe

 	## INITIALISATION
 	jal choixDepartArrivee
 	la $s3 ($v0)		# $s3 contient la case courante
 	
 	li $a0 7			# Bit � marquer pour d�finir comme visit�
 	lw $a1 ($s3)		# Valeur � changer
 	jal changeBitN		# Change le bit 
 	sw $v0 ($s3)		# Stocke la nouvelle valeur dans le tableau

	la $a0 ($s3)
	la $a1 ($s1)
	jal voisinNonVisite
	la $s3 ($v0)
 	 	
 	la $a0 ($s1) 		# Place dans $a0 la taille du labyrinthe
 	la $a1 laby			# Place dans $a1 l'adresse du d�but du labyrinthe	
 	jal afficheLabyrinthe
	j exit
 	
	
# BLOC RESOLUTION
modeResolution:
	j exit
