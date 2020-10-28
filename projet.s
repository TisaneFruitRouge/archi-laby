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
	
# BLOC GENERATION
modeGeneration:
	la $a0 ($s1) 		# Place dans $a0 la taille du labyrinthe
 	la $a1 laby			# Place dans $a1 l'adresse du d�but du labyrinthe
 	li $a2 15			# initialise le labyrinthe avec la valeur 15  :  00001111
 	jal initialiseLabyrinthe   # initialisation du labyrinthe
 	jal afficheLabyrinthe
	j exit
	
# BLOC RESOLUTION
modeResolution:
	j exit