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
	
	.align 2 				  # Pour etre sur d'aligner les emplacement mémoire
	buffer:  .space 1024      # Buffer qui sert lors de l'ouverture du fichier texte

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

	# Textes pour les différents retours à l'utilisateur
    TexteFichier:
        .asciiz "\n\tLe fichier '"
    TexteResolution:
        .asciiz "', resolvant le labyrithe a été crée\n"


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
printfString:
	# Prologue
	addi $sp $sp -8
	sw $a0 4($sp)
	sw $ra 0($sp)
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	# Corps
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
	
	beqz $s0, modeGeneration
	j modeResolution


modeGeneration:
	
	### Code Germain
	
	j exit

modeResolution:

    jal CreerTableauFichier

    # On ajoute l'extension '.txt.resolu'
    la $a0, nomFichier
    la $a1, extension2
    jal concat


    move $a0, $v0                # $a0 -> taille du côté du labyrinthe
    move $a1, $v1                # 1er élément tu tableau

    jal ResolutionLaby
    jal SaveTableau      		 # Ecriture du tableau dans le fichier de sortie (=*.txt.resolu)

    
    # Appels systeme pour afficher des string
    li $v0, 4                            
    la $a0, TexteFichier         # "Le fichier"   
    syscall                              
    la $a0, nomFichier           # "*.txt.resolu"              
    syscall                              
    la $a0, TexteResolution      # "resolvant le labyrithe a été crée\n"       
    syscall                             

    j Exit


# Cette fonction résout le labyrinthe 
# Elle prend en entrée la taille du côté du labyrinthe ($a0) et l'addresse du premier élément du tableau ($a1)
ResolutionLaby:

    # Prologue
    subu $sp, $sp, 16
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $s0, 4($sp)
    sw $ra, 0($sp)

    move $t0, $a0
    move $a0, $a1                # 1er élément du tableau
    move $a1, $t0                # Taille du coté du labyrinthe

    jal GetCaseFin
    move $s4, $v0                # Indice de la case de fin -> $s4

    jal GetCaseDepart
    move $a2, $a1                # Côté du labyrinthe
    move $a1, $v0                # Indice de la case de départ
    jal MarquerPassage           # Marque la case courante comme visitée

    li $s3, 0

    # Parcours du labyrinthe
    DeplaceLaby:
	    jal VoisinResolution
	    move $a1, $v0
	    jal MarquerPassage            # Marque la case courante comme visitée
	    beq $a1, -1, MarcheArriereR   # Dépilage si coinçage
	    beq $a1, $s4, CheminTrouve    # Si on tombe sur la case de fin, fin de la boucle, c'est gagné
	    subu $sp, $sp, 4              # Reservation de l'espace mémoire pour la case
	    sw $a1, 0($sp)                # On stocke l'indice en mémoire
	    addi $s3, $s3, 4              # On incrémente le compteur de 4 (taille d'un mot-mémoire)
	    j DeplaceLaby

    # On recule si on est bloqué
    MarcheArriereR:
	    addu $sp, $sp, 4              # On dépile la case bloquée
	    subi $s2, $s2, 4              # On décrémente le compteur
	    beq $a1, $s4, CheminTrouve    # Si on tombe sur la case de fin, fin de la boucle, c'est gagné
	    lw $a1, 0($sp)                # Sinon on retourne sur la case précédente
	    j DeplaceLaby                 # Retour dans la boucle

    # On marque ici le chemin trouvé comme chemin solution
    CheminTrouve:
	    beqz $s2, ResolutionTerminee  # Compteur à 0 = résolution terminée
	    lw $t6, 0($sp)                # Indice de la case courante
	    addu $t6, $a0, $t6            # Adresse de la case courante
	    lb $t7, 0($t6)                # On récupère la valeur de la case
	    addi $t7, $t7, 64             # On marque la case comme étant sur le chemin "solution"
	    sb $t7, 0($t6)                # MAJ de la valeur de la case
	    subi $s2, $s2, 4              # On décrémente le compteur
	    addu $sp, $sp, 4              # On libère la mémoire sur la pile
	    j CheminTrouve

    ResolutionTerminee:
	    mul $a1, $a2, $a2             # $a1 = taille tu tableau (=côté * côté)
	    jal EnleveMarquage

	    # Epilogue
	    lw $a0, 12($sp)
	    lw $a1, 8($sp)
	    lw $s0, 4($sp)
	    lw $ra, 0($sp)
	    addu $sp, $sp, 16

	    jr $ra


# Cette fonction enlève le marquage laisser par les visites sur les cases
# Elle prend en entrée la taille du côté du labyrinthe ($a0) et l'addresse du premier élément du tableau ($a1)
EnleveMarquage:

    # Prologue
    subu $sp, $sp, 8
    sw $a0, 4($sp)
    sw $ra, 0($sp)

    # Corps
    li $t0, -1                       # Compteur (initialisé à -1, car on incrément dés la 1ere instruction de la boucle)
    li $t5, 128                      # Valeur à ajouter aux cases du labyrinthe

    BoucleEnleveMarquage:
	    addu $t0, $t0, 1                      # Incrémentation du compteur
	    beq $t0, $a1, FinBoucleEnleveMarquage # Si compteur=taille alors on a parcouru tout le tableau
	    addu $t1, $a0, $t0                    # Sinon ajout du compteur à l'adresse
	    lb $t2, 0($t1)                        # On récupère la valeur de la case
	    bge $t2, $0, BoucleEnleveMarquage     # Si cette case a une valeur >0, on passe à la case suivante
	    add $t2, $t2, $t5                     # Sinon on lui ajoute 128

	    sb $t2, 0($t1)                    # On remplace la case courante du tableau par la nouvelle valeur
	    j BoucleEnleveMarquage            

    # Epilogue
    FinBoucleEnleveMarquage:
	    lw $a0, 4($sp)
	    lw $ra, 0($sp)
	    addu $sp, $sp, 8

	    jr $ra


# Cette fonction permet de modifier la valeur d'une case du tableau
# Elle prend en entrée la taille du côté ($a0), l'indice du 1er élément ($a1), et la valeur de remplacement  
ModifierTableau:

    # Prologue
    subu $sp, $sp, 8
    sw $s0, 4($sp)
    sw $ra, 0($sp)

    # Corps
    add $s0, $a0, $a1     # On calcule l'adresse de la case à modifier
    sb $a2, 0($s0)        # On change la valeur

    # Epilogue
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 8,

    jr $ra


# Cette fonction permet de sauvegarder un tableau dans un fichier 
# Elle prend en entrée le côté du labyrinthe ($a0) et l'addresse du 1er élément du tableau ($a1)
SaveTableau:

    # Prologue
    subu $sp, $sp, 24
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $ra, 0($sp)

    # Ouverture du fichier
    la $a0, nomFichier       # Nom du fichier
    li $a1, 1                # On ouvre le fichier en écriture (=1)
    li $a2, 0                # Mode ignoré
    li $v0, 13               # syscall pour ouvrir un fichier
    syscall

    move $a3, $v0            # Sauvegarde du file descriptor

    # On récupère les valeurs des args du syscall
    lw $a0, 12($sp)
    lw $a1, 8($sp)
    lw $a2, 4($sp)

    move $s0, $a0             # $s0 : taille du côté du labyrinthe
    mul $t0, $a0, $a0         # $t0 : nombre total de cases
    move $t1, $s0             # $t1 : ième colonne (initialisé à la taille du côté du labyrinthe, dans le but de commencer par un saut de ligne)
    li $t2, 0                 # $t2 : décalage de la case courante du tableau

    jal ConversionEnCaractere
    li $a0, 2                # Nombre d'arguments (soit 1, soit 2), ici 2, car on souhaite écrire les 2 chiffes
    move $a1, $v0            # Premier chiffre
    move $a2, $v1            # Deuxième chiffre
    jal EcritureFichier

    BoucleSaveTableau:
	    beq $t2, $t0 FinBoucleSaveTableau # Fin de la boucle si tout la tableau a été parcouru

	    # Cas du saut de ligne
	    blt $t1, $s0 ApresSautDeLigne   # Si on est pas à la fin de la ligne, on ne saute pas
	    li $t1, 0                		# On se replace à la première colonne
	    li $a0, 1                		# Nombre d'arguments, ici 1, car on souhaite uniquement écrire '\n'
	    li $a1, 0x0A             		# Code ASCII pour '\n'
	    jal EcritureFichier

    # Cas des espaces (entre les nombres)
    ApresSautDeLigne:
	    beq $t1, 0 ApresEspace   # Si on est au début de la ligne, on n'insère pas d'espace
	    li $a0, 1                # Nombre d'arguments (soit 1, soit 2), ici 1, car on souhaite écrire uniquement un espace
	    li $a1, 0x20             # Caractère 'espace' en ASCII 
	    jal EcritureFichier

	    ApresEspace:
	    lw $a1, 8($sp)            # On récupère la valeur initiale de $a1
	    addu $t3, $a1, $t2        # $t3 : adresse de la case courante

	    # Ecrit Nombre
	    lb $a0, 0($t3)           # $a0 contient désormais la valeur de la case courante
	    jal ConversionEnCaractere
	    li $a0, 2                # Nombre d'arguments (ici, 2)
	    move $a1, $v0            # Premier chiffre
	    move $a2, $v1            # Deuxième chiffre
	    jal EcritureFichier

	    addu $t2, $t2, 1          # On incrémente $t2 (on avance d'une case du tableau, le décalage augmente donc de 1)
	    addu $t1, $t1, 1          # On incrémente $t1 (on avance d'une colonne)

	    j BoucleSaveTableau

    # fermeture fichier
    FinBoucleSaveTableau:
	    move $a0, $a3            # file descriptor à fermer
	    li $v0, 16               # syscall pour fermer un fichier
	    syscall,

	    # Epilogue
	    lw $s0, 20($sp)
	    lw $s1, 16($sp)
	    lw $a0, 12($sp)
	    lw $a1, 8($sp)
	    lw $a2, 4($sp)
	    lw $ra, 0($sp)
	    addu $sp, $sp, 24

	    jr $ra


# Cette fonction renvoie un nombre entier converti en caractère
# Elle prend en entrée le nombre à convertir ($a0)
# Elle renvoie les deux chiffres qui composent le nombre sous forme de caractère (dizaine:$v0, unité:$v1)
ConversionEnCaractere:
    li $v0, 0                			  # Par défaut le premier digit vaut 0
    move $v1, $a0            			  # On met par défaut v1 à la valeur de a0
    blt $a0, 10 FinConversionEnCaractere # Si $a0 <= 10, alors on a fini

    # Si le nombre est supérieur ou égal à 10, ont doit changer les valeurs de sortie
    div $v0, $a0, 10          # Le chiffre des dizaines est donc $a0 // 10
    mfhi $v1                  # Le chiffre des unités est $a0 % 10
                             

    FinConversionEnCaractere:
	    # On convertit les chiffres en caractères, on ajoute 30 en héxadécimal, soit 48 en décimal
	    addiu $v0, $v0, 0x30      # Conversion 1er chiffre (dizaines)
	    addiu $v1, $v1, 0x30      # Conversion 2eme chiffre (unités)

	    jr $ra


# Cette fonction permet d'écrire des caractères dans un fichier
# Elle prend en entrée le nombre de caractères (1 ou 2) ($a0), stockés dans $a1 et $a2 et le file descriptor ($a3)
EcritureFichier:

    # Prologue
    subu $sp, $sp, 24
    sw $a0, 20($sp)
    sw $a1, 16($sp)
    sw $a2, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $ra, 0($sp)

    # Corps
    move $a0, $a3            # file descriptor
    la $a1, buffer           # Adresse du buffer
    lw $s1, 16($sp)          # Premier caractère
    sb $s1, 0($a1)           # On met le caractère dans le buffer
    li $a2, 1                # La taille du buffer est de 1 car on écrit caractère par caractère
    li $v0, 15               # syscall pour écrire dans un fichier
    syscall

    lw $s1, 20($sp)                # On met $s1 à la valeur originale de $a0
    bne $s1, 2 FinEcritureFichier  # Si il n'y a qu'un caractère, on fini
    lw $s1, 12($sp)                # Ecriture du deuxieme caractère (même procédé)
    sb $s1, 0($a1)                 
    li $v0, 15                     
    syscall

    # Epilogue
    FinEcritureFichier:
	    lw $a0, 20($sp)
	    lw $a1, 16($sp)
	    lw $a2, 12($sp)
	    lw $s0,, 8($sp)
	    lw $s1, 4($sp)
	    lw $ra, 0($sp)
	    addu $sp, $sp, 24

	    jr $ra


# Cette fonction permet de détruire un mur
# Elle prend en entrée l'addresse du 1er élément du tableau ($a0), l'indice de l'ancienne case ($a1), 
# l'indice de la nouvelle case ($a2) et la direction dans laquelle on se dirige ($a3)
DetruireMurs:

    # Prologue
    subu $sp, $sp, 32
    sw $a1, 28($sp)
    sw $a2, 24($sp)
    sw $a3, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $ra, 0($sp)

    # Corps
    add $s0, $a0, $a1             # adresse de l'ancienne case --> $s0
    add $s1, $a0, $a2             # adresse de la nouvelle case --> $s1
    lb $s0, 0($s0)                # valeur de l'ancienne case --> $s0 
    lb $s1, 0($s1)                # valeur de la nouvelle case --> $s1 

    move $s2, $a1                 #On sauvegarde les arguments dans des registres
    move $s3, $a2                 

    beq $a3, 0, DirectionHaut         # On se deplace en fonction de la direction (stockée dans $a3)
    beq $a3, 1, DirectionDroite       # (0: haut, 1:droite, 2:bas, 3:gauche)
    beq $a3, 2, DirectionBas          
    beq $a3, 3, DirectionGauche       

    DirectionHaut:
    move $a1, $s2
    subi $a2, $s0, 1               # On décrémente la valeur de la case précédente
    jal ModifierTableau            # On détruit donc le mur (0 en B0 = pas de mur en haut)
    move $a1, $s3
    subi $a2, $s1 4                # On enlève 4 (100 en binaire) à la nouvelle case
    jal ModifierTableau            # On détruit donc le mur (0 en B2 = pas de mur en base)
    j FinDestructionMurs

    DirectionDroite:
    move $a1, $s2
    subi $a2, $s0, 2               # On enlève 2 (10 en binaire) à la case précédente
    jal ModifierTableau            # On détruit donc le mur (0 en B1 = pas de mur à droite)
    move $a1, $s3
    subi $a2, $s1, 8               # On enlève 8 (1000 en binaire) à la nouvelle case
    jal ModifierTableau            # On détruit donc le mur (0 en B3 = pas de mur à gauche)
    j FinDestructionMurs

    DirectionGauche:
    move $a1, $s2
    subi $a2, $s0, 8               # On enlève 8 (1000 en binaire) à la case précédente
    jal ModifierTableau            # On détruit donc le mur (0 en B0 = pas de mur en haut)
    move $a1, $s3
    subi $a2, $s1, 2               # On enlève 2 (10 en binaire) à la nouvelle case
    jal ModifierTableau            # On détruit donc le mur (0 en B0 = pas de mur en haut)
    j FinDestructionMurs

    DirectionBas:
    move $a1, $s2
    subi $a2, $s0, 4               # On enlève 4 (100 en binaire) à la case précédente
    jal ModifierTableau            # On détruit donc le mur (0 en B0 = pas de mur en haut)
    move $a1, $s3
    subi $a2, $s1, 1               # On décrémente la valeur de la nouvelle case
    jal ModifierTableau            # On détruit donc le mur (0 en B0 = pas de mur en haut)
    j FinDestructionMurs

    # Epilogue
    FinDestructionMurs:
    lw $a1, 28($sp)
    lw $a2, 24($sp)
    lw $a3, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 32

    jr $ra

# Cette fonction permet de marquer le passage sur une case
# Elle prend en entrée l'adresse du 1er élément du tableau ($a0) et l'indice de la case passée ($a1)
MarquerPassage:

    # Prologue
    subu $sp, $sp, 12
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $ra, 0($sp)

    # Corps
    add $a1, $a0, $a1         # On calcule l'addresse de la case à modifier
    lb $a2, 0($a1)            # Récupération de la valeur actuelle de la case
    lw $a1, 8($sp)            # Récupération de la valeur originale de $a1
    addiu $a2, $a2, 128
    jal ModifierTableau

    # Epilogue
    lw $a2, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 12

    jr $ra


# Cette fonction test si une case a été visitée
# Elle prend en entrée l'addresse du 1er élément du tableau ($a1) et l'indice de la case à tester
# Elle renvoie, dans $v0, 1 si elle a été visitée, 0 si elle ne l'a pas été
TesteVisite:

    # Prologue
    subu $sp, $sp, 12
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $ra, 0($sp)

    # Corps
    add $a1, $a0, $a1             # Calcule de l'addresse de la case à tester
    lb $a0, 0($a1)                # Valeur de la case à tester
    li $v0, 0                     # Par défaut, on suppose que la case n'a pas été visitée
    bge $a0, $0, FinTesteVisite   # Si la case est positive, alors on a effectivement fini, elle n'a pas été visitée
    li $v0, 1                     # Sinon la case a été visitée et on change la valeur de $v0

    # Epilogue
    FinTesteVisite:
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 12

    jr $ra


# Cette fonction test si il y a un mur aux alentours d'une case
# Elle prend en entrée l'adresse du 1er élément du tableau ($a0), l'indice de la case ($a1) à tester et la directions ($a2)
# Elle renvoie, dans $v0, 1 si il y a un mur, et 0 s'il n'y en a pas
TestMur:

    # Prologue
    subu $sp, $sp, 8
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    # Corps
    add $s0, $a0, $a1             # Calcul de l'adresse de la case à tester
    lb $s1, 0($s0)                # valeur de la case --> $s1
    and $v0, $a2, $s1             # On vérifie si le bit de Mur est sur 1 ou sur 0
    beqz $v0, FinTestMur          # $v0=0 si pas de mur
    li $v0, 1                     # $v0=1 sinon

    # Epilogue
    FinTestMur:
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addu $sp, $sp, 8

    jr $ra


# Cette fonction renvoie l'indice d'un voisin, choisis aléatoirement, d'une case
# Elle prend en entrée l'addresse du 1er élément du tableau ($a0), l'indice de la case courante (noté CC) ($a1)
# et la valeur de la taille du côté du labyrinthe (notée N) ($a2)
# Elle renvoie, dans $v0, l'indice du voisin choisi (-1 si aucun)
VoisinResolution:

    # Prologue
    subu $sp, $sp, 32
    sw $a0, 28($sp)
    sw $a1, 24($sp)
    sw $a2, 20($sp)
    sw $a3, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $ra, 0($sp)

    # Corps
    li $s0, 0                        # Compteur du nombre de voisins
    move $t0, $a1                    # CC
    move $t1, $a2                    # N
    div $t2, $t0, $t1
    mfhi $t2                         # CC%N

    # Valeurs pour les tests
    subi $t3, $t1, 1                  # $t3=N-1
    mul $t4, $t1, $t3                 # $t4=N*(N-1)


    # On cherche, parmi les voisins, ceux qui sont disponibles

    TestVoisinGaucheR:
	    									
	    beq $t2, 0, TestVoisinDroiteR      # Si CC%N = 0 alors il n'y a pas de voisin à gauche donc on passe à celui de droite
	    subi $a1, $t0, 1                   # Autrement, l'indice vaut CC-1
	    jal TesteVisite                    # On vérifie si la case à déjà été visitée
	    beq $v0, 1, TestVoisinDroiteR      # Si oui, le voisin ne sera pas compté (on est déjà passé dessus)


	    # On vérifie que le voisin n'est pas un mur (sinon o ne pourra évidement pas aller dessus)

	    li $a2, 2
	    jal TestMur
	    bnez $v0, TestVoisinDroiteR

	    addi $s0, $s0, 4                  # On augmente le compteur de 4
	    subu $sp, $sp, 4                  # On alloue de la mémoire sur la pile pour le voisin
	    sw $a1, 0($sp)                    # On empile l'indice du voisin
    

    TestVoisinDroiteR:

	    beq $t3, $t2, TestVoisinHautR     # Si CC%N = N-1 alors pas de voisin à droite
	    addi $a1, $t0, 1                  # Sinon l'indice vaut CC+1
	    jal TesteVisite                   # On vérifie si la case a déjà été visitée
	    beq $v0, 1, TestVoisinHautR       # Si c'est le cas, ce voisin n'est plus disponible

	    # Vérification présence d'un mur
	    li $a2, 8
	    jal TestMur
	    bnez $v0, TestVoisinHautR

	    addi $s0, $s0, 4                  # Idem que précedement
	    subu $sp, $sp, 4                  # 
	    sw $a1, 0($sp)                    # 
    

    TestVoisinHautR:

	    blt $t0, $t1, TestVoisinBasR      # Il n'y a pas de voisin en haut si CC<N
	    sub $a1, $t0, $t1                 # Si il y a un voisin, son indice vaut l'indice vaut CC-N
	    jal TesteVisite                   # Idem (vérification visite)
	    beq $v0, 1, TestVoisinBasR        # 

	    # Vérification présence d'un mur
	    li $a2, 4
	    jal TestMur
	    bnez $v0, TestVoisinBasR

	    addi $s0, $s0, 4                  # Idem que précedement
	    subu $sp, $sp, 4                  # 
	    sw $a1, 0($sp)                    # 
    

    TestVoisinBasR:

	    bge $t0, $t4, FinVoisinR          # Si CC >= N*(N-1) alors il n'y a pas de voisin en bas
	    add $a1, $t0, $t1                 # Autrement l'indice vaut CC+N
	    jal TesteVisite                   # Idem (vérification visite)
	    beq $v0, 1, FinVoisinR            # 

	    # Vérification présence d'un mur
	    li $a2, 1
	    jal TestMur
	    bnez $v0, FinVoisinR

	    addi $s0, $s0, 4                  # Idem que précedement
	    subu $sp, $sp, 4                  # 
	    sw $a1, 0($sp)                    # 
    

    FinVoisinR:

	    li $v0, -1                        # On considère par défaut qu'il n'y a pas de voisins disponibles

	    div $s1, $s0, 4                   # Récupération du nombre de voisin sur la pile
	    beq $s1, $0, Epilogue             # S'il n'y a aucun voisin, on passe à l'épilogue

	    li $a0, 0
	    move $a1, $s1                     # Borne supérieur ($a0) = $s1
	    li $v0, 42                        # On génère un nombre aléatoire r tq 0 <= $a0 < $a1
	    syscall
	    move $s2, $a0
	    mul $s2, $s2, 4                   # On calcule le décalage pour avoir le bon voisin
	    addu $s2, $sp, $s2                # On récupère l'adresse sur la pile
	    lw $v0, 0($s2)                    # $v0 contient l'indice d'un voisin désigné

	    addu $sp, $sp, $s0                # On libère la mémoire allouée sur la pile

    # Epilogue
    Epilogue:
	    lw $a0, 28($sp)
	    lw $a1, 24($sp)
	    lw $a2, 20($sp)
	    lw $a3, 16($sp)
	    lw $s0, 12($sp)
	    lw $s1, 8($sp)
	    lw $s2, 4($sp)
	    lw $ra, 0($sp)
	    addu $sp, $sp, 32

	    jr $ra


# Cette fonction créer un tableau à partir d'un fichier
# Elle renvoie $v0, la taille N du côté du labyrinthe et $v1, l'adresse du premier élément du tableau
CreerTableauFichier:

    # Prologue
    subu $sp, $sp, 28
    sw $a0, 24($sp)
    sw $a1, 20($sp)
    sw $a2, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    # Ouverture du fichier
    la $a0, nomFichier      # Nom du fichier --> $a0
    li $a1, 0               # Mode (ici, lecture) --> $a1
    li $a2, 0               # Cet argument est ignoré
    li $v0, 13              # syscall pour ouvrir le fichier
    syscall
    blt $v0, $0, ErreurFichierNonTrouve  # Si le fichier n'existe pas, on gère l'erreur
    move $s0, $v0        				 # Sauvegarde du file descriptor dans $s0


    # Lecture du fichier
    move $a0, $s0        # file descriptor --> $a0
    la $a1, buffer       # Adresse du buffer dans lequel écrire
    li $a2, 1            # Taille du buffer = 1
    li $v0, 14           # syscall pour lire un fichier
    syscall

    lb $s1, 0($a1)        # Premier chiffre (dans le buffer)
    subiu $s1, $s1, 0x30  # Conversion en entier décimal
    mul $s1, $s1, 10      # Multiplication par 1à, car c'est l'entier des dizaines

    li $v0, 14            # syscall pour lire un fichier
    syscall

    lb $s2, 0($a1)        # Deuxième chiffre
    subiu $s2, $s2, 0x30  # Conversion en entier

    addu $t2, $s1, $s2    # $t2 contient la valeur de N

    mul $a0, $t2, $t2     # Taille du tableau à créer en octets (N*N)
    li $v0, 9             # On réserve de la mémoire pour le tableau
    syscall               # $v0 contiendra l'adresse du 1er élément du tableau

    move $v1, $v0         # Adresse du premier élément du tableau --> $v1
    move $t0, $v1         # $v1 --> $t0
    addu $t1, $t0, $a0    # On calcule l'adresse du fin de tableau


    # On parcourt chaque caractère du fichier
    BoucleRemplissageTableau:

	    beq $t0, $t1 FinBoucleRemplissageTableau # Fin si adresse courante == adresse de fin de tableau 

	    move $a0, $s0        # Même procedure que précedement pour lire un caractère
	    la $a1, buffer       # 
	    li $a2, 1            # 
	    li $v0 ,14           # 
	    syscall

	    lb $s1, 0($a1)       # Caractère courant (=CC)

	    # On vérifie que '0' <= CC <= '9', en ASCII

	    blt $s1, 48, BoucleRemplissageTableau
	    bgt $s1, 57, BoucleRemplissageTableau


	    subiu $s1, $s1, 0x30  # Conversion en entier décimal
	    mul $s1, $s1, 10      # Multiplication par 10 car chiffre des dizaines

	    li $v0, 14            # syscall pour lire un fichier
	    syscall

	    lb $s2, 0($a1)        # Deuxième chiffre
	    subiu $s1, $s1, 0x30  # Conversion en entier

	    addu $s3, $s1, $s2    # $s3 = $s2+$s1 (chiffre des unités + chiffre des dizaines)
	    sb $s3, 0($t0)        # On sauvegarde dans le tableau

	    addiu $t0, $t0, 1     # On incrémente $t0 (adresse à laquelle écrire dans le tableau)
	    j BoucleRemplissageTableau

    # fermeture du fichier et épilogue
    FinBoucleRemplissageTableau:
	    move $a0, $s0        # file descriptor à fermer
	    li $v0, 16           # syscall pour fermer un fichier
	    syscall

	    move $v0, $t2        # $v0 = N

	    # Epilogue
	    lw $a0, 24($sp)
	    lw $a1, 20($sp)
	    lw $a2, 16($sp)
	    lw $s0, 12($sp)
	    lw $s1, 8($sp)
	    lw $s2, 4($sp)
	    lw $s3, 0($sp)
	    addu $sp, $sp, 28

	    jr $ra


# Cette fonction renvoie l'addresse de la case de départ
# Elle prend en entrée l'adresse du 1er élément du tableau ($a0) et la taille du côté du labyrinthe ($a1)
# Elle renvoie dans $v0 l'adresse de la case de départ
GetCaseDepart:

    # Prologue
    subu $sp, $sp, 12
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $ra, 0($sp)

    # Corps
    move $s2, $a0            # adresse du 1er élement du tableau --> $s2

    li $t0, 16               # Masque pour trouver le bit de départ   00010000 && (CASE) == Vrai si départ faux sinon 
    lb $s0, 0($a0)           # On récupère la valeur de la case dans $s0

    mul $s1, $a1, $a1
    add $s1, $a0, $s1        # l'adresse de la case de fin --> $s1

    CaseSuivante:
	    and $v0, $s0, $t0               # Test si il y a un 1 en B4
	    addi $a0, $a0, 1                # On incrémente $a0, qui contient l'adresse de la case courante
	    bnez $v0, FinCaseDepart         # Si $v0 != 0 alors on a trouvé la case départ
	    beq $a0, $s1, FinCaseDepart
	    lb $s0, 0($a0)                  # On charge la nouvelle valeur
	    j CaseSuivante                  # On continue
    
    FinCaseDepart:

	    subu $a0, $a0, $s2        # Adresse finale - adresse initiale
	    subi $a0, $a0 ,1          # On enlève 1, car on a commencé à traiter la première case avant
	    move $v0, $a0             # On met le bon indice sur la valeur de sortie, $v0

    # Epilogue
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 12

    jr $ra


# Cette fonction renvoie l'addresse de la case de fin
# Elle prend en entrée l'adresse du 1er élément du tableau ($a0) et la taille du côté du labyrinthe ($a1)
# Elle renvoie dans $v0 l'adresse de la case de fin
GetCaseFin:

    # Prologue
    subu $sp, $sp, 12
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $ra, 0($sp)

    # Corps
    move $s2, $a0            # adresse du 1er élement du tableau --> $s2

    li $t0, 32               # Masque pour trouver le bit de départ   00100000 && (CASE) == Vrai si départ faux sinon 
    lb $s0, 0($a0)           # On récupère la valeur de la case dans $s0

    mul $s1, $a1, $a1
    add $s1, $a0, $s1         # $s1 : l'adresse de la case de fin

    CaseSuivanteFin:
	    and $v0, $s0, $t0                # Idem que pour la fonction getCaseDépart mais en testant B5
	    addi $a0, $a0, 1
	    bnez $v0, FinCaseDepartFin       
	    beq $a0, $s1, FinCaseDepartFin
	    lb $s0, 0($a0)                   
	    j CaseSuivanteFin

    FinCaseDepartFin:

	    subu $a0, $a0, $s2      # Adresse finale - adresse initiale
	    subi $a0, $a0, 1        # On enlève 1, car on a commencé à traiter la première case avant
	    move $v0, $a0           # On met le bon indice sur la valeur de sortie, $v0

    # Epilogue
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addu $sp, $sp, 12

    jr $ra


# Erreur quand le fichier n'a pas été trouvé
ErreurFichierNonTrouve:

    li $v0, 4                            # On affiche les string 
    la $a0, TexteFichier                 # Correspondant au message
    syscall                              # Que le fichier n'a pas été
    la $a0, nomFichier                   # Trouvé
    syscall                              # C'est ballot
    la $a0, texteDemandeNomFichierError  # :/
    syscall                              

    j Exit  #Optionnel, en soi

# Fin du programme
Exit:
    li $v0, 10
    syscall

