.data
	laby: .space 400000
	nomFichier: .space 256
	bufferConversion: .space 12
	bufferEcriture: .space 12
	retourChariot: .asciiz "\n"  # chaine de caract�re pour le retour chariot
	chaineVide: .asciiz "" # juste une chaine vide
	espace: .asciiz " "   # juste un espace
	
	texteErreurParam : .asciiz "Nombre d'arguments incorrect"
	
	extension1 : .asciiz ".txt"
	extension2 : .asciiz ".txt.resolu"
	
	texteMenu : "Menu :\n1 - Generation du labyrinthe\n2 - Resolution du labyrinthe\n"
	texteMode : .asciiz "Choisissez un mode : "
	texteModeError : .asciiz "Choix du mode invalide."
	
	texteDemandeNomFichier : .asciiz "Veuillez rentrer le nom du fichier : "
	texteDemandeNomFichierError : .asciiz "Fichier introuvable."
	
	texteDemandeTaille : .asciiz "Veuillez rentrer la taille du labyrinthe : "
	texteDemandeTailleError : .asciiz "Valeur de la taille invalide.\n"

	texteFichierGenere1 : .asciiz "Le fichier "
	texteFichierGenere2 : .asciiz " a bien ete genere !"
	texteFichierGenereError : .asciiz "Une erreur s'est produite lors de la generation du fichier."
.text
.globl _main

# Point d'entrée du programme
_main:         
	beqz $a0 startSansParam # Cas où des arguments ne sont pas rentr�s en ligne de commande
	bnez $a0 startAvecParam # Cas où des arguments sont rentr�s en ligne de commande

startSansParam:
	jal choixFichier1	# Appel de la fonction choixFichier1
	jal choixMode1		# Appel de la fonction choixMode1
	la $s0 ($v0)		# Place dans $s0 le mode d'exécution
	addi $s0 $s0 -1
	bnez $s0 suiteMain	# Passe directement à la suite si c'est le mode 2
	jal choixTaille1	# Appel de la fonction choixTaille1
	la $s1 ($v0)		# Place dans $s1 la taille du labyrinthe
	j suiteMain			# Continue l'exécution principale

startAvecParam:
	bne $a0 3  erreurParam
		
	jal choixFichier2	# Appel de la fonction choixFichier2
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
	# Point de sortie du programme
	li $v0 10
	syscall
	
	
# BLOC DES FONCTIONS UTILITAIRES

# Affiche la chaine de caract�res dans $a0 puis fait un retour chariot
printfString:
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
printfInt:
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

# Cette fonction caste un entier en chaine de caractères (de 00 - 99)
# $a0 l'entier
# Retourne dans $v0 la chaine
castIntString:
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)

	# Corps de la fonction
	div $t0 $a0 10			# $t0 contient le chiffre des dizaines
	mfhi $t1 				# $t1 contient le Chiffre des unités
	
	addi $t0 $t0 48			# Convertit en caractère
	addi $t1 $t1 48			# Convertit en caractère
	
	la $t2 bufferConversion	
	sb $t0 ($t2)
	sb $t1 1($t2)
	sb $zero 2($t2)

	move $v0 $t2

	# Epilogue
	lw $a0 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 8
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
	addi $sp $sp 12
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
# Retourne dans $v1 la position de la case d'arrivée
choixDepartArrivee:
	# Prologue
	addi $sp $sp -32
	sw $a0 28($sp)
	sw $a1 24($sp)
	sw $a2 20($sp)
	sw $s0 16($sp)
	sw $s1 12($sp)
	sw $s2 8($sp)
	sw $s3 4($sp)
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
	
	bnez $t1 secondCote		# Test du choix du cot� : haut/bas - gauche/droite
	premierCote:			# Cas du premier c�t� : haut ou gauche
	li $t5 0				# $t5 coordonn�e de la case de d�part
	la $t6 ($s1)			# $t6 coordonn�e de la case de d'arriv�e
	addi $t6 $t6 -1
	bnez $t0 suite_choixH	# Test de l'orientation : horizontale/verticale
	j suite_choixV
	secondCote:				# Cas du second c�t� : bas ou droite
	li $t6 	0				# $t6 coordonn�e de la case de d'arriv�e
	la $t5 ($s1)			# $t5 coordonn�e de la case de d�part
	addi $t5 $t5 -1
	bnez $t0 suite_choixH	# Test de l'orientation : horizontale/verticale
	j suite_choixV
	
	suite_choixV:			# Cas de l'orientation verticale
	la $a0 ($t5)			# $a0 contient la coordonn�e en i de la case de d�part
	la $a1 ($t3)			# $a1 contient la coordonn�e en j de la case de d�part
	la $a2 ($s1)			# $a2 contient la taille du labyrinthe
	jal coordToPos
	move $s2 $v0
	li $a0 4			 	# $a3 contient le bit � modifier pour marquer comme case de d�part
	lw $a1 ($s2)		 	# $a0 contient la position de la case
	jal changeBitN		 	# Appel de la fonction pour placer la case de d�part
	sw $v0 ($s2)
	move $s0 $s2			# $s0 contient la postion de la case de d�part

	la $a0 ($t6)			# $a0 contient la coordonn�e en i de la case d'arriv�e
	la $a1 ($t4)			# $a1 contient la coordonn�e en j de la case d'arriv�e
	la $a2 ($s1)			# $a2 contient la taille du labyrinthe
	jal coordToPos
	move $s2 $v0
	li $a0 5				# $a3 contient le bit � modifier pour marquer comme case d'arriv�e
	lw $a1 ($s2)			# $a0 contient la position de la case
	jal changeBitN			# Appel de la fonction pour placer la case d'arriv�e
	sw $v0 ($s2)
	move $s3 $s2
	j fin_choixDepartArrivee
	
	suite_choixH:			# Cas de l'orientation horizontale
	la $a0 ($t3)			# $a0 contient la coordonn�e en i de la case de d�part
	la $a1 ($t5)			# $a1 contient la coordonn�e en j de la case de d�part
	la $a2 ($s1)			# $a2 contient la taille du labyrinthe
	jal coordToPos
	move $s2 $v0
	li $a0 4				# $a3 contient le bit � modifier pour marquer comme case de d�part
	lw $a1 ($s2)			# $a0 contient la position de la case
	jal changeBitN			# Appel de la fonction pour placer la case de d�part
	sw $v0 ($s2)
	move $s0 $s2			# $s0 contient la postion de la case de d�part

	la $a0 ($t4)			# $a0 contient la coordonn�e en i de la case d'arriv�e
	la $a1 ($t6)			# $a1 contient la coordonn�e en j de la case d'arriv�e
	la $a2 ($s1)			# $a2 contient la taille du labyrinthe
	jal coordToPos
	move $s2 $v0
	li $a0 5				# $a3 contient le bit � modifier pour marquer comme case d'arriv�e
	lw $a1 ($s2)			# $a0 contient la position de la case
	jal changeBitN			# Appel de la fonction pour placer la case d'arriv�e
	sw $v0 ($s2)
	move $s3 $s2
	j fin_choixDepartArrivee	
	
	# Epilogue
	fin_choixDepartArrivee:
	la $v0 ($s0)		# Place dans $v0 la position de la case d�part.
	la $v1 ($s3)
	lw $a0 28($sp)
	lw $a1 24($sp)
	lw $a2 20($sp)
	lw $s0 16($sp)
	lw $s1 12($sp)
	lw $s2 8($sp)
	lw $s3 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 32
	jr $ra

# Cette fonction v�rifie si une case a des voisins non visit�s
# $a0 position de la case
# $a1 taille du labyrinthe
# Retourne dans $v0 -1 si la case n'a pas de voisins non visit�s sinon la position d'un des voisins
voisinNonVisite:
	# Prologue
	addi $sp $sp -40
	sw $a0 36($sp)
	sw $a1 32($sp)
	sw $s0 28($sp)
	sw $s1 24($sp)
	sw $s2 20($sp)
	sw $s3 16($sp)
	sw $s4 12($sp)
	sw $s5 8($sp)
	sw $s6 4($sp)
	sw $ra 0($sp)
	
	# Corps de la fonction
	jal posToCoord
	move $s5 $v0
	move $s6 $v1

	addi $s0 $a0 4			# $s0 : voisin de droite
	addi $s1 $a0 -4			# $s1 : voisin de gauche
	mul $t0 $a1 -4
	add $s2 $a0 $t0			# $s2 : voisin du haut
	mul $t0 $a1 4
	add $s3 $a0 $t0			# $s3 : voisin du bas

	la $a0 ($s0)			# Charge dans $a0 la position 
	jal posToCoord			# Trouve les coordonnées i,j de la case et met dans $v0,$v1
	add $t0 $s5 0			# coordonnée supposée en i du voisin
	add $t1 $s6 1			# coordonnée supposée en j du voisin
	bge $t0 $a1 noDroite	# teste si i est dans le laby
	bge $t1 $a1 noDroite	# teste si j est dans le laby
	bltz $t0 noDroite		# teste si i est dans le laby
	bltz $t1 noDroite		# teste si j est dans le laby
	bne $v0 $t0 noDroite	# teste si le i du voisin correspond à la supposition
	bne $v1 $t1 noDroite	# teste si le i du voisin correspond à la supposition
	j forGauche				# continuer
	noDroite:
		li $s0 -1
	
	forGauche:
	la $a0 ($s1)
	jal posToCoord
	add $t0 $s5 0
	add $t1 $s6 -1
	bge $t0 $a1 noGauche
	bge $t1 $a1 noGauche
	bltz $t0 noGauche
	bltz $t1 noGauche
	bne $v0 $t0 noGauche
	bne $v1 $t1 noGauche
	j forHaut
	noGauche:
		li $s1 -1

	forHaut:
	la $a0 ($s2)
	jal posToCoord
	add $t0 $s5 -1
	add $t1 $s6 0
	bge $t0 $a1 noHaut
	bge $t1 $a1 noHaut
	bltz $t0 noHaut
	bltz $t1 noHaut
	bne $v0 $t0 noHaut
	bne $v1 $t1 noHaut
	j forBas
	noHaut:
		li $s2 -1

	forBas:
	la $a0 ($s3)
	jal posToCoord
	add $t0 $s5 1
	add $t1 $s6 0
	bge $t0 $a1 noBas
	bge $t1 $a1 noBas
	bltz $t0 noBas
	bltz $t1 noBas
	bne $v0 $t0 noBas
	bne $v1 $t1 noBas
	j forSuite
	noBas:
		li $s3 -1
	
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
	li $a0 7	
	lw $a1 ($s1)
	jal checkValeurBitN
	beq $v0 1 apresVG
	addi $s4 $s4 1
	addi $sp $sp -4			# Allouer de l'espace dans la pile
	sw $s1 ($sp)			# Placer la case en haut de pile

	apresVG:
	beq $s2 -1 apresVH
	li $a0 7	
	lw $a1 ($s2)
	jal checkValeurBitN
	beq $v0 1 apresVH
	addi $s4 $s4 1
	addi $sp $sp -4			# Allouer de l'espace dans la pile
	sw $s2 ($sp)			# Placer la case en haut de pile

	apresVH:
	beq $s3 -1 apresVB
	li $a0 7	
	lw $a1 ($s3)
	jal checkValeurBitN
	beq $v0 1 apresVB
	addi $s4 $s4 1 
	addi $sp $sp -4			# Allouer de l'espace dans la pile
	sw $s3 ($sp)			# Placer la case en haut de pile

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
	lw $a0 36($sp)
	lw $a1 32($sp)
	lw $s0 28($sp)
	lw $s1 24($sp)
	lw $s2 20($sp)
	lw $s3 16($sp)
	lw $s4 12($sp)
	lw $s5 8($sp)
	lw $s6 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 40
	jr $ra


# Cette fonction permet de casser le mur entre deux cases voisines
# $a0 contient la position premiere case (courante)
# $a1 contient la position de la seconde case (la voisine)
# $a2 contient la taille 
# Agit par effet de bord sur le labyrinthe
casseMur:
	# Prologue
	addi $sp $sp -28
	sw $a0 24($sp)
	sw $a1 20($sp)
	sw $a2 16($sp)
	sw $s0 12($sp)
	sw $s1 8($sp)
	sw $s2 4($sp)
	sw $ra 0($sp)

	# Corps de la fonction
	la $s0 ($a0)			# Charge dans $s0 la position de la case courante
	la $s1 ($a1)			# Charge dans $s1 la position de la case voisine

	sub $t2 $s0 $s1			# Cherche le sens entre courante-voisine
	div $t2 $t2 4			# Stocke dans $t2 le sens
	beq $t2 -1 sDroit		# si c'est -1 le voisin est à droite
	beq $t2 1 sGauche		# si c'est 1 le voisin est à gauche
	beq $t2 $a2 sHaut		# si c'est N le voisin est en haut, sinon le voisin est en bas
	li $t2 2				# $t2 contient le bit à modifier pour la case courante
	li $s2 0				# $s2 contient le bit à modifier pour le voisin
	j suite_sens	
	sHaut:
	li $t2 0
	li $s2 2
	j suite_sens
	sGauche:
	li $t2 3
	li $s2 1
	j suite_sens
	sDroit:
	li $t2 1
	li $s2 3

	suite_sens:
	la $a0 ($t2)			# Charge dans $a0 le bit à modifier
	lw $a1 ($s0)			# Charge dans $a1 la valeur actuelle de la courante
	jal changeBitN			# modifie le bit à la position $t2
	sw $v0 ($s0)			# Stocke la nouvelle valeur dans le laby

	la $a0 ($s2)			# Charge dans $a0 le bit à modifier
	lw $a1 ($s1)			# Charge dans $a1 la valeur actuelle du voisin
	jal changeBitN			# modifie le bit à la position $s2
	sw $v0 ($s1)			# Stocke la nouvelle valeur dans le laby

	# Epilogue
	lw $a0 24($sp)
	lw $a1 20($sp)
	lw $a2 16($sp)
	lw $s0 12($sp)
	lw $s1 8($sp)
	lw $s2 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 28
	jr $ra

# Cette fonction ramène à 0 le bit numéro 7 de toutes les cases du labyrinthe
# $a0 contient la taille du labyrinthe
nettoieBit7:
	# Prologue
	addi $sp $sp -24
	sw $a0 20($sp)
	sw $s0 16($sp)
	sw $s1 12($sp)
	sw $s2 8($sp)
	sw $s3 4($sp)
	sw $ra 0($sp)

	# Corps de la fonction
	la $s0 ($a0)
	li $s1 0 					# it�rateur de la ligne 
	deb_parcoursLigneN:
	beq $s1 $s0 fin_nettoieBit7 # for (i = 0, i < $s0, i++)
	li $s2 0 					# it�rateur de la colonne 
	deb_parcoursColonneN:
	beq $s2 $s0 fin_parcoursColonneN	# for (j = 0, j < $s0, j++)
	mul $t3 $s1 $s0				# ((i*TailleColonne
	add $t3 $t3 $s2			    #			       + j)
	mul $t3 $t3 4				#			      *sizeOf(Int))
	la $t2 laby
	add $s3 $t3 $t2			    #                             + addrDebut == tab[i][j]
	li $a0 7
	lw $a1 ($s3)				# $a1 = tab[i][j]  
	jal checkValeurBitN			# verifie la valeur du bit 7
	beqz $v0 dejaZero			# si c'est déjà égal à zero, passer à la suite
	jal changeBitN				# sinon changer le bit 7
	sw $v0 ($s3)				# stocker la nouvelle valeur
	dejaZero:
	addi $s2 $s2 1				# Incr�mente j
	j deb_parcoursColonneN		# Passe au d�but de la boucle j
	fin_parcoursColonneN:
	addi $s1 $s1 1				# Incr�ment i
	j deb_parcoursLigneN		# passe au début de la boucle i

	# Epilogue
	fin_nettoieBit7:
	lw $a0 20($sp)
	lw $s0 16($sp)
	lw $s1 12($sp)
	lw $s2 8($sp)
	lw $s3 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 24
	jr $ra

#Cette fonction crée un fichier contenant le labyrinthe
# $a0 contient la taille
genereFichier:
	# Prologue
	addi $sp $sp -24
	sw $a0 20($sp)
	sw $s0 16($sp)
	sw $s1 12($sp)
	sw $s2 8($sp)
	sw $s3 4($sp)
	sw $ra 0($sp)
	

	# Corps de la fonction
	move $s0 $a0			# Place dans $s0 la taille du labyrinthe

	## Ouverture du fichier
	li $v0 13 				# commande système pour ouvrir le fichier
	la $a0 nomFichier		# place dans $a0 le nom du fichier
	li $a1 1        		# place dans $a1 l'option : écriture
	li $a2 0        		# mode ignoré
	syscall            		# ouvre le fichier
	bltz $v0 erreur_ecriture
	move $s3, $v0      		# stocke dans $s3 le descripteur du fichier

	## Ecriture de la taille dans le fichier
	move $a0 $s0			# Place la taille dans $a0
	jal castIntString		# Convertit la taille en string
	move $t0 $v0			# Place dans $t0 la taille en string
	li $v0 15       		# commande système d'écriture
	move $a0 $s3     		# place dans $a0 le descripteur
	la $a1 ($t0)   			# place dans $a1 la taille en string
	li $a2 2       			# place dans $a2 taille du buffer à écrire
	syscall            		# Ecrit dans le fichier
	bltz $v0 erreur_ecriture

	li $v0 15				
	move $a0 $s3
	la $a1 retourChariot	# $a1 contient le caractère de retour à la ligne
	li $a2 1 
	syscall
	bltz $v0 erreur_ecriture

	deb_ecriture:
		li $s1 0 					# itérateur de la ligne 
		deb_parcoursLigneE:
		beq $s1 $s0 fin_ecriture 	# for (i = 0, i < $s0, i++)
		li $s2 0 					# itérateur de la colonne 
		deb_parcoursColonneE:
		beq $s2 $s0 fin_parcoursColonneE	# for (j = 0, j < $s0, j++)
		mul $t3 $s1 $s0						# ((i*TailleColonne
		add $t3 $t3 $s2			    		#			       + j)
		mul $t3 $t3 4						#			      *sizeOf(Int))
		la $t2 laby
		add $t3 $t3 $t2			    		#                             + addrDebut == tab[i][j]
		
		lw $a0 ($t3)						# $a0 = tab[i][j]  
		jal castIntString					# convertit en string le nombre à la position tab[i][j]
		move $t2 $v0
		li $v0 15
		move $a0 $s3
		la $a1 ($t2)						
		li $a2 2
		syscall								# Ecrit dans le fichier le nombre.
		bltz $v0 erreur_ecriture

		li $v0 15
		move $a0 $s3
		la $a1 espace						# Puis écriture d'un espace
		li $a2 1 
		syscall
		bltz $v0 erreur_ecriture
		
		addi $s2 $s2 1						# Incrémente j
		j deb_parcoursColonneE				# Passe au début de la boucle j
		fin_parcoursColonneE:
		addi $s1 $s1 1						# Incrément i
		li $v0 15
		move $a0 $s3
		la $a1 retourChariot				# En fin de ligne, on fait un retour à la ligne
		li $a2 1 
		syscall
		bltz $v0 erreur_ecriture
		j deb_parcoursLigneE				# passe au début de la boucle i

	erreur_ecriture:
		li $v0 -1
		j fin_genereFichier
	fin_ecriture:
	# Fermeture du fichier
	li   $v0, 16       # commande système pour la fermeture
	move $a0, $s3      # 
	syscall            # fichier fermé
	li $v0 0

	# Epilogue
	fin_genereFichier:
	lw $a0 20($sp)
	lw $s0 16($sp)
	lw $s1 12($sp)
	lw $s2 8($sp)
	lw $s3 4($sp)
	lw $ra 0($sp)
	addi $sp $sp 24
	jr $ra


# BLOC GENERATION
modeGeneration:
	## DONNEES
	la $a0 ($s1) 					# Place dans $a0 la taille du labyrinthe
 	la $a1 laby						# Place dans $a1 l'adresse du d�but du labyrinthe
 	li $a2 15						# initialise le labyrinthe avec la valeur 15  :  00001111
 	jal initialiseLabyrinthe   		# initialisation du labyrinthe

	jal choixDepartArrivee
	move $s0 $v0 					# Place dans $s0 la case de départ
	move $s2 $v1 					# Place dans $s2 la case d'arrivée

	move $s3 $s0 					# Faire de la case de départ la case courante
	li $a0 7						# Bit 7 pour marquer comme visité
	lw $a1 ($s3)					# Dans $s3 la valeur
	jal changeBitN					# Change le bit 7
	sw $v0 ($s3)					# Stocke la nouvelle valeur

	addi $sp $sp -4					# Empiler la case de départ
	sw $s3 ($sp)
	li $s4 0

	deb_principal:	
		move $a0 $s3				# Place dans $a0 la case courante
		move $a1 $s1				# Place dans $a1 la taille du labyrinthe
		jal voisinNonVisite			# Vérifier si la case a des voisins non visités
		beq $v0 -1 noVoisin			# S'il n'y a pas de voisins non visité remonter dans la pile
			move $a1 $v0			# Sinon mettre dans $a1 le voisin
			move $a2 $s1			# $a2 contient la taille du labyrinthe
			jal casseMur			# Détruire le mur entre la case courante et le voisin
			move $s3 $a1			# Faire du voisin la case courante
			li $a0 7		
			lw $a1 ($s3)		
			jal changeBitN			# Changer le bit 7 pour marquer la case comme visitée
			sw $v0 ($s3)			# Enregistre la nouvelle valeur
			addi $sp $sp -4			# Empile la case courante
			sw $s3 ($sp)
			addi $s4 $s4 1			# Ecrémenter le compteur
			j deb_principal			# Réitérer l'opération

		noVoisin:					# Cas où il n'y a plus de voisins disponibles
			addi $sp $sp 4			# Dépiler
			addi $s4 $s4 -1			# Décrémenter le compteur
			beqz $s4 fini			# Si c'est égal à 0 alors on est dans le cas voisin nul et case courante égale case départ
			lw $s3 ($sp)			# faire de la case précédente la case courante
			j deb_principal			# Réitérer l'opération

	fini:
		la $a0 ($s1)
		jal nettoieBit7						# Enlève tous les marqueurs au bit 7
		la $a0 ($s1) 						# Place dans $a0 la taille du labyrinthe
		la $a1 laby							# Place dans $a1 l'adresse du début du labyrinthe	
		jal genereFichier					# Génère le fichier contenant le labyrinthe généré
		
		# Affichage du message de fin après génération
		bnez $v0 erreurGenerationFichier
			la $a0 texteFichierGenere1
			li $v0 4
			syscall
			la $a0 nomFichier
			syscall
			la $a0 texteFichierGenere2
			jal printfString
			j exit

		erreurGenerationFichier:
			la $a0 texteFichierGenereError
			jal printfString
			j exit
 	
	
# BLOC RESOLUTION
modeResolution:
	j exit
