# ============================================================
# PARTIE 6 -  génération du labyrinthe 
# ============================================================

.data                              # Section des donnees
largeur_img: .word 64           # Largeur de l'image
hauteur_img: .word 64           # Hauteur de l'image
adresse_image: .word 0          # Adresse de l'image utilisee pour dessiner
msgVide: .asciz "Erreur : la pile est vide\n" # Message pour une pile vide
msgPleine: .asciz "Erreur : la pile est pleine\n" # Message pour une pile pleine
espace: .asciz " "                # Dependence de printIntEsp

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    jal ra, I_creer          # Allouer la memoire pour l'image
    la t0, adresse_image     # Charger l'adresse de la variable image
    sw a0, 0(t0)             # Enregistrer l'adresse de base de l'image

    jal ra, L_creer          # Creer un labyrinthe initialement ferme
    mv s0, a0                # Conserver l'adresse du labyrinthe

    li a0, 0                 # Indice de la premiere cellule
    mv a1, s0                # Adresse du labyrinthe
    jal ra, L_generer        # Generer les passages aleatoires

    li a0, 0                 # Indice de la cellule de depart
    mv a1, s0                # Adresse du labyrinthe
    jal ra, L_defDepart      # Marquer la cellule de depart

    lw t0, 0(s0)             # Lire le nombre de colonnes
    lw t1, 4(s0)             # Lire le nombre de lignes
    mul s1, t0, t1           # Calculer le nombre total de cellules
    addi s1, s1, -1          # Indice de la derniere cellule
    mv a0, s1                # Choisir cette cellule comme arrivee
    mv a1, s0                # Adresse du labyrinthe
    jal ra, L_defArrivee     # Marquer la cellule d'arrivee

    mv a0, s0                # Adresse du labyrinthe
    jal ra, L_afficher       # Dessiner les murs noirs et passages blancs

    li a0, 0                 # Indice de depart
    li a1, 0x0000FF00        # Couleur verte
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_afficherCellule # Dessiner le depart en vert

    mv a0, s1                # Indice d'arrivee
    li a1, 0x00FF0000        # Couleur rouge
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_afficherCellule # Dessiner l'arrivee en rouge

    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION L_voisinsNonVisitees
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Retourne nombre dans a0, directions par octets dans a1
# ============================================================

L_voisinsNonVisitees:
    addi sp, sp, -48                  # Ajouter -48 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw s6, 28(sp)                     # Sauvegarder s6 dans 28(sp)
    sw s7, 32(sp)                     # Sauvegarder s7 dans 32(sp)
    sw s8, 36(sp)                     # Sauvegarder s8 dans 36(sp)
    sw a2, 40(sp)                     # Sauvegarder a2 dans 40(sp)

    mv s0, a0                         # indice de C
    mv s1, a1                         # adresse du labyrinthe

    # (x, y) de C ; a0 et a1 contiennent deja les bons arguments
    jal ra, L_indiceToCoords          # Appeler L_indiceToCoords et memoriser le retour dans ra
    mv s2, a0                         # x de C
    mv s3, a1                         # y de C

    li s4, 0                          # direction courante (0..3)
    li s5, 0                          # nombre de voisines non visitees
    li s6, 0                          # directions regroupees (un octet chacune)

L_voisinsNonVisitees_boucle:
    li t0, 4                          # Placer 4 dans t0
    bge s4, t0, L_voisinsNonVisitees_fin # Si s4 est superieur ou egal a t0, aller a L_voisinsNonVisitees_fin

    # (x, y) du voisin dans la direction s4
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s3                         # Copier s3 dans a1
    mv a2, s4                         # Copier s4 dans a2
    jal ra, L_voisinDir               # Appeler L_voisinDir et memoriser le retour dans ra
    mv s7, a0                         # x du voisin
    mv s8, a1                         # y du voisin (a1 sera ecrase par les appels)

    # Le voisin est-il dans le labyrinthe ?
    mv a0, s7                         # Copier s7 dans a0
    mv a1, s8                         # Copier s8 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_estDedans               # Appeler L_estDedans et memoriser le retour dans ra
    beqz a0, L_voisinsNonVisitees_suite # Si egal a zero, aller a L_voisinsNonVisitees_suite

    # Indice du voisin
    mv a0, s7                         # Copier s7 dans a0
    mv a1, s8                         # Copier s8 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_coordsToIndice          # Appeler L_coordsToIndice et memoriser le retour dans ra

    # Le voisin a-t-il deja ete visite ?
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_estVisitee              # Appeler L_estVisitee et memoriser le retour dans ra
    bnez a0, L_voisinsNonVisitees_suite # Si different de zero, aller a L_voisinsNonVisitees_suite

    # Ranger la direction s4 dans l'octet numero s5
    mv a0, s6                         # Copier s6 dans a0
    mv a1, s5                         # Copier s5 dans a1
    mv a2, s4                         # Copier s4 dans a2
    jal ra, B_setByte                 # Appeler B_setByte et memoriser le retour dans ra
    mv s6, a0                         # Copier a0 dans s6
    addi s5, s5, 1                    # une voisine de plus

L_voisinsNonVisitees_suite:
    addi s4, s4, 1                    # direction suivante
    j L_voisinsNonVisitees_boucle     # Aller a L_voisinsNonVisitees_boucle

L_voisinsNonVisitees_fin:
    mv a0, s5                         # nombre de voisines
    mv a1, s6                         # directions

    lw a2, 40(sp)                     # Charger dans a2 la valeur situee a 40(sp)
    lw s8, 36(sp)                     # Charger dans s8 la valeur situee a 36(sp)
    lw s7, 32(sp)                     # Charger dans s7 la valeur situee a 32(sp)
    lw s6, 28(sp)                     # Charger dans s6 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 48                   # Ajouter 48 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

#           a1 = directions, une par octet (n octets de poids faible)

# ============================================================
# FONCTION L_directionAleatoire
# Entree(s) : a0 = nombre, a1 = directions
# Objectif : Retourne une direction choisie au hasard
# ============================================================

L_directionAleatoire:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)

    mv s0, a1                         # sauvegarder les directions
    addi a0, a0, -1                   # auHasard est inclusif : tirage dans [0, n-1]
    jal ra, auHasard                  # a0 = numero d'octet au hasard

    mv a1, a0                         # a1 = numero d'octet
    mv a0, s0                         # a0 = directions regroupees
    jal ra, B_getByte                 # a0 = la direction choisie

    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# Murs : noirs ; passages : blancs

# ============================================================
# FONCTION L_afficher
# Entree(s) : a0 = labyrinthe
# Objectif : Dessine murs noirs et passages blancs
# ============================================================

L_afficher:
    addi sp, sp, -32                  # Ajouter -32 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw a0, 16(sp)                     # Sauvegarder a0 dans 16(sp)
    sw a1, 20(sp)                     # Sauvegarder a1 dans 20(sp)
    sw a2, 24(sp)                     # Sauvegarder a2 dans 24(sp)

    mv s0, a0                         # Adresse du labyrinthe

    # Nombre total de cellules = colonnes * lignes
    lw t0, 0(s0)                      # Charger dans t0 la valeur situee a 0(s0)
    lw t1, 4(s0)                      # Charger dans t1 la valeur situee a 4(s0)
    mul s1, t0, t1                    # Multiplier t0 et t1 ; resultat dans s1

    # Nombre de points de l'image
    lw t0, largeur_img                # Charger dans t0 la valeur situee a largeur_img
    lw t1, hauteur_img                # Charger dans t1 la valeur situee a hauteur_img
    mul t2, t0, t1                    # Multiplier t0 et t1 ; resultat dans t2

    # Adresse du premier point
    lw t3, adresse_image              # Charger dans t3 la valeur situee a adresse_image

L_afficher_effacer:
    beqz t2, L_afficher_debut         # Si egal a zero, aller a L_afficher_debut

    # Mettre le point en noir
    sw zero, 0(t3)                    # Sauvegarder zero dans 0(t3)

    addi t3, t3, 4                    # Ajouter 4 a t3 ; resultat dans t3
    addi t2, t2, -1                   # Ajouter -1 a t2 ; resultat dans t2
    j L_afficher_effacer              # Aller a L_afficher_effacer

L_afficher_debut:
    li s2, 0                          # Indice de la premiere cellule

L_afficher_boucle:
    bge s2, s1, L_afficher_fin        # Si s2 est superieur ou egal a s1, aller a L_afficher_fin

    # Dessiner la cellule courante en blanc
    mv a0, s2                         # Copier s2 dans a0
    li a1, 0x00FFFFFF                 # Placer 0x00FFFFFF dans a1
    mv a2, s0                         # Copier s0 dans a2
    jal ra, L_afficherCellule         # Appeler L_afficherCellule et memoriser le retour dans ra

    # Cellule suivante
    addi s2, s2, 1                    # Ajouter 1 a s2 ; resultat dans s2
    j L_afficher_boucle               # Aller a L_afficher_boucle

L_afficher_fin:
    lw a2, 24(sp)                     # Charger dans a2 la valeur situee a 24(sp)
    lw a1, 20(sp)                     # Charger dans a1 la valeur situee a 20(sp)
    lw a0, 16(sp)                     # Charger dans a0 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 32                   # Ajouter 32 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

#           a1 = adresse du labyrinthe
#
# Precondition :
# labyrinthe neuf, toutes les cellules non visitees

# ============================================================
# FONCTION L_generer
# Entree(s) : a0 = indice depart, a1 = labyrinthe
# Objectif : Genere le labyrinthe avec exploration et retour arriere
# ============================================================

L_generer:
    addi sp, sp, -48                  # Ajouter -48 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw a0, 28(sp)                     # Sauvegarder a0 dans 28(sp)
    sw a1, 32(sp)                     # Sauvegarder a1 dans 32(sp)
    sw a2, 36(sp)                     # Sauvegarder a2 dans 36(sp)

    mv s0, a0                         # Cellule de depart
    mv s1, a1                         # Adresse du labyrinthe

    # Creer une pile pouvant contenir toutes les cellules
    lw t0, 0(s1)                      # Nombre de colonnes
    lw t1, 4(s1)                      # Nombre de lignes
    mul a0, t0, t1                    # Multiplier t0 et t1 ; resultat dans a0
    jal ra, P_creer                   # Appeler P_creer et memoriser le retour dans ra
    mv s2, a0                         # Adresse de la pile

    # Marquer la cellule de depart comme visitee
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_defVisitee              # Appeler L_defVisitee et memoriser le retour dans ra

    # Empiler la cellule de depart
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s0                         # Copier s0 dans a1
    jal ra, P_empiler                 # Appeler P_empiler et memoriser le retour dans ra

L_generer_boucle:
    # Terminer si la pile est vide
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_estVide                 # Appeler P_estVide et memoriser le retour dans ra
    bnez a0, L_generer_fin            # Si different de zero, aller a L_generer_fin

    # Lire la cellule au sommet sans la retirer
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_sommet                  # Appeler P_sommet et memoriser le retour dans ra
    mv s3, a0                         # Cellule courante

    # Chercher ses voisins non visites
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_voisinsNonVisitees      # Appeler L_voisinsNonVisitees et memoriser le retour dans ra

    # Aucun voisin disponible : revenir en arriere
    beqz a0, L_generer_retour         # Si egal a zero, aller a L_generer_retour

    # Choisir une direction parmi celles trouvees
    jal ra, L_directionAleatoire      # Appeler L_directionAleatoire et memoriser le retour dans ra
    mv s4, a0                         # Direction choisie

    # Coordonnees de la cellule courante
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_indiceToCoords          # Appeler L_indiceToCoords et memoriser le retour dans ra

    # Coordonnees du voisin choisi
    mv a2, s4                         # Copier s4 dans a2
    jal ra, L_voisinDir               # Appeler L_voisinDir et memoriser le retour dans ra

    # Convertir ces coordonnees en indice
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_coordsToIndice          # Appeler L_coordsToIndice et memoriser le retour dans ra
    mv s5, a0                         # Indice du voisin choisi

    # Casser le mur du cote de la cellule courante
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s4                         # Copier s4 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_casserMur               # Appeler L_casserMur et memoriser le retour dans ra

    # Calculer la direction opposee : (direction + 2) % 4
    addi t0, s4, 2                    # Ajouter 2 a s4 ; resultat dans t0
    andi t0, t0, 3                    # Appliquer le masque 3 a t0 ; resultat dans t0

    # Casser le mur oppose du cote du voisin
    mv a0, s5                         # Copier s5 dans a0
    mv a1, t0                         # Copier t0 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_casserMur               # Appeler L_casserMur et memoriser le retour dans ra

    # Marquer le voisin comme visite
    mv a0, s5                         # Copier s5 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_defVisitee              # Appeler L_defVisitee et memoriser le retour dans ra

    # Empiler le voisin pour continuer depuis cette cellule
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s5                         # Copier s5 dans a1
    jal ra, P_empiler                 # Appeler P_empiler et memoriser le retour dans ra

    j L_generer_boucle                # Aller a L_generer_boucle

L_generer_retour:
    # Retirer la cellule qui n'a plus de voisin non visite
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_depiler                 # Appeler P_depiler et memoriser le retour dans ra
    j L_generer_boucle                # Aller a L_generer_boucle

L_generer_fin:
    lw a2, 36(sp)                     # Charger dans a2 la valeur situee a 36(sp)
    lw a1, 32(sp)                     # Charger dans a1 la valeur situee a 32(sp)
    lw a0, 28(sp)                     # Charger dans a0 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 48                   # Ajouter 48 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# DEPENDANCES REQUISES DE LA PARTIE 1
# ============================================================

# FONCTION printInt : Affiche un entier decimal
printInt:

# printInt

    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a7, 0(sp)                      # Sauvegarder a7 dans 0(sp)

    # Afficher l'entier en decimal
    li a7, 1                          # Service 1 : afficher un entier
    ecall                             # Executer le service RARS selectionne dans a7

    # ===== Epilogue =====
    # Restaurer a7 et liberer la pile
    lw a7, 0(sp)                      # Charger dans a7 la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp

    ret                               # Retourner a la fonction appelante


# FONCTION printIntEsp : Affiche un entier et un espace
printIntEsp:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # sauvegarde de l'adresse de retour (on appelle printInt)
    sw   a0, 4(sp)                    # sauvegarde de a0
    sw   a7, 8(sp)                    # Sauvegarder a7

    jal  printInt                     # affiche l'entier en decimal

    la   a0, espace                   # Charger l'adresse de espace dans a0
    li   a7, 4                        # ecall 4 : print string
    ecall                             # Executer le service RARS selectionne dans a7

    # ===== Epilogue =====
    lw   a7, 8(sp)                    # restauration de a7
    lw   a0, 4(sp)                    # restauration de a0
    lw   ra, 0(sp)                    # restauration de ra
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION auHasard : Retourne un entier aleatoire dans a0
auHasard:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a1, 0(sp)                    # sauvegarde de a1
    sw   a7, 4(sp)                    # sauvegarde de a7

    addi a1, a0, 1                    # a1 = borne haute EXCLUE (a0 + 1)
    li   a0, 0                        # a0 = id du generateur
    li   a7, 42                       # ecall 42 : RandIntRange -> a0 dans [0, a1)
    ecall                             # a0 = resultat

    # ===== Epilogue =====
    lw   a7, 4(sp)                    # restauration de a7
    lw   a1, 0(sp)                    # restauration de a1
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# ============================================================
# DEPENDANCES REQUISES DE LA PARTIE 2
# ============================================================

# FONCTION I_creer : Alloue largeur x hauteur x 4 octets, adresse dans a0
I_creer:

    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a7, 0(sp)                      # Sauvegarder a7 dans 0(sp)

    # Calculer le nombre de pixels (units)
    lw t0, largeur_img                # Charger la largeur dans t0
    lw t1, hauteur_img                # Charger la hauteur dans t1
    mul t2, t0, t1                    # Multiplier t0 et t1 ; resultat dans t2
    slli a0, t2, 2                    # Decaler a gauche de 2 a t2 ; resultat dans a0
    li a7, 9                          # ecall 9 : sbrk (allocation dans le tas)
    ecall                             # Executer le service RARS selectionne dans a7

    lw a7, 0(sp)                      # restauration de a7
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION I_plot : Ecrit la couleur du pixel
I_plot:

# Colorie le pixel P : adresse = base + indice * 4

    slli t0, a0, 2                    # t0 = indice * 4 (decalage en octets)
    add  t0, a2, t0                   # t0 = base + decalage = adresse du pixel
    sw   a1, 0(t0)                    # ecrit la couleur dans la memoire image
    ret                               # Retourner a la fonction appelante

# Chaque pixel occupe 4 octets.


# ============================================================
# DEPENDANCES REQUISES DE LA PARTIE 3
# ============================================================

# FONCTION P_creer : Cree la pile, retourne son adresse dans a0
P_creer:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a7, 0(sp)                    # sauvegarde de a7

    mv   t0, a0                       # t0 = capacite (a0 va etre ecrase par l'ecall)
    addi t1, a0, 2                    # t1 = capacite + 2 (2 mots de gestion)
    slli a0, t1, 2                    # a0 = nombre d'octets = (capacite + 2) * 4
    li   a7, 9                        # ecall 9 : sbrk (allocation dans le tas)
    ecall                             # a0 = adresse de la plage allouee

    sw   t0, 0(a0)                    # pile[0] = capacite
    sw   zero, 4(a0)                  # pile[1] = taille = 0 (pile vide)

    # ===== Epilogue =====
    lw   a7, 0(sp)                    # restauration de a7
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION P_estVide : Retourne 1 si vide, sinon 0
P_estVide:
    lw   t0, 4(a0)                    # t0 = taille (nombre d'entiers actuel)
    beqz t0, P_estVide_oui            # si taille == 0 -> la pile est vide

    li a0, 0                          # taille != 0 -> pas vide, retourne 0
    ret                               # Retourner a la fonction appelante

P_estVide_oui:
    li a0, 1                          # taille == 0 -> vide, retourne 1
    ret                               # Retourner a la fonction appelante

#          (si pile vide : message d'erreur, a0 inchange)
# Adresse du sommet = pile + 8 + 4 * (taille - 1)
# Si vide : message d'erreur, a0 conserve


# FONCTION P_sommet : Retourne la valeur du sommet sans depiler
P_sommet:
    lw t0, 4(a0)                      # Nombre d'elements
    beqz t0, P_sommet_vide            # Si egal a zero, aller a P_sommet_vide
    addi t0, t0, -1                   # Indice du dernier element
    slli t0, t0, 2                    # Indice * 4
    add t0, a0, t0                    # Ajouter a0 et t0 ; resultat dans t0
    lw a0, 8(t0)                      # Lire l'element apres l'entete
    ret                               # Retourner a la fonction appelante

P_sommet_vide:
    la t0, msgVide                    # Charger l'adresse de msgVide dans t0
    j P_erreur                        # Aller a P_erreur

# Si pleine : message d'erreur, rien n'est ajoute


# FONCTION P_empiler : Ajoute un element en sommet
P_empiler:
    lw   t0, 0(a0)                    # t0 = capacite
    lw   t1, 4(a0)                    # t1 = taille

    bgeu t1, t0, P_empiler_pleine     # taille >= capacite

    slli t2, t1, 2                    # t2 = taille * 4
    add  t2, a0, t2                   # t2 = pile + taille * 4
    sw   a1, 8(t2)                    # element[taille] = a1

    addi t1, t1, 1                    # taille + 1
    sw   t1, 4(a0)                    # ecrit la nouvelle taille
    ret                               # Retourner a la fonction appelante

P_empiler_pleine:
    la   t0, msgPleine                # t0 = adresse du message
    j    P_erreur                     # P_erreur fait le ret a notre place

# Si vide : message d'erreur, sinon taille = taille - 1


# FONCTION P_depiler : Retire l'element en sommet
P_depiler:
    lw   t0, 4(a0)                    # t0 = taille
    beqz t0, P_depiler_vide           # taille == 0 -> vide

    addi t0, t0, -1                   # taille - 1
    sw   t0, 4(a0)                    # ecrit la nouvelle taille
    ret                               # Retourner a la fonction appelante

P_depiler_vide:
    la   t0, msgVide                  # t0 = adresse du message
    j    P_erreur                     # Aller a P_erreur

# Affiche les entiers du plus ancien au plus recent


# FONCTION P_print : Affiche les elements dans l'ordre
P_print:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   s0, 4(sp)                    # Sauvegarder s0 dans 4(sp)
    sw   s1, 8(sp)                    # Sauvegarder s1 dans 8(sp)
    sw   a0, 12(sp)                   # Sauvegarder a0 dans 12(sp)

    lw   s1, 4(a0)                    # s1 = nombre d'elements restants
    addi s0, a0, 8                    # s0 = adresse de l'element 0

P_print_boucle:
    beqz s1, P_print_fin              # plus d'elements -> fin
    lw   a0, 0(s0)                    # a0 = element courant
    jal  printIntEsp                  # affiche l'element + espace
    addi s0, s0, 4                    # element suivant
    addi s1, s1, -1                   # un de moins
    j    P_print_boucle               # Aller a P_print_boucle

P_print_fin:
    lw   a0, 12(sp)                   # Charger dans a0 la valeur situee a 12(sp)
    lw   s1, 8(sp)                    # Charger dans s1 la valeur situee a 8(sp)
    lw   s0, 4(sp)                    # Charger dans s0 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# Code commun aux cas d'erreur


# FONCTION P_erreur : Affiche un message d'erreur
P_erreur:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a0, 0(sp)                      # Sauvegarder a0 dans 0(sp)
    sw a7, 4(sp)                      # Sauvegarder a7 dans 4(sp)
    mv a0, t0                         # Copier t0 dans a0
    li a7, 4                          # Afficher une chaine
    ecall                             # Executer le service RARS selectionne dans a7
    lw a0, 0(sp)                      # Charger dans a0 la valeur situee a 0(sp)
    lw a7, 4(sp)                      # Charger dans a7 la valeur situee a 4(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# ============================================================
# DEPENDANCES REQUISES DE LA PARTIE 4
# ============================================================

# FONCTION B_getBit : Retourne le bit (0 ou 1)
B_getBit:
    srl  t0, a0, a1                   # t0 = a0 >> a1 (le bit voulu devient le bit 0)
    andi a0, t0, 1                    # a0 = t0 & 1 (on garde seulement ce bit)
    ret                               # Retourner a la fonction appelante


# FONCTION B_setBit : Modifie le bit, resultat dans a0
B_setBit:
    li   t0, 1                        # Placer 1 dans t0
    sll  t0, t0, a1                   # t0 = 1 << a1 (masque : un seul bit a 1)
    not  t0, t0                       # t0 = ~masque (tous les bits a 1 sauf le bit a1)
    and  a0, a0, t0                   # a0 = a0 avec le bit a1 mis a 0
    sll  t1, a2, a1                   # t1 = a2 << a1 (la nouvelle valeur a sa place)
    or   a0, a0, t1                   # a0 = a0 | t1 : le bit a1 vaut maintenant a2
    ret                               # Retourner a la fonction appelante

# Affiche les 32 bits (poids fort d'abord), un espace entre chaque octet


# FONCTION B_getByte : Retourne un octet dans a0
B_getByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    srl  t0, a0, t0                   # t0 = a0 >> (a1 * 8)
    andi a0, t0, 255                  # a0 = t0 & 0xFF (on garde 8 bits)
    ret                               # Retourner a la fonction appelante


# FONCTION B_setByte : Modifie un octet, resultat dans a0
B_setByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    li   t1, 255                      # t1 = 0xFF
    sll  t1, t1, t0                   # t1 = 0xFF << decalage (masque de l'octet)
    not  t1, t1                       # t1 = ~masque
    and  a0, a0, t1                   # a0 = a0 avec l'octet a1 mis a 0
    sll  t2, a2, t0                   # t2 = a2 << decalage (nouvelle valeur a sa place)
    or   a0, a0, t2                   # a0 = a0 | t2
    ret                               # Retourner a la fonction appelante


# ============================================================
# DEPENDANCES REQUISES DE LA PARTIE 5
# ============================================================

# FONCTION L_creer : Cree le labyrinthe ferme, adresse dans a0
L_creer:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a7, 0(sp)                    # Sauvegarder a7 dans 0(sp)

    lw   t0, largeur_img              # Charger dans t0 la valeur situee a largeur_img
    lw   t1, hauteur_img              # Charger dans t1 la valeur situee a hauteur_img
    li   t2, 3                        # Placer 3 dans t2

    divu t0, t0, t2                   # Nombre de colonnes
    divu t1, t1, t2                   # Nombre de lignes

    mul  t3, t0, t1                   # Nombre total de cellules
    slli a0, t3, 2                    # 4 octets par cellule
    addi a0, a0, 8                    # Ajouter les dimensions

    li   a7, 9                        # sbrk
    ecall                             # Executer le service RARS selectionne dans a7

    sw   t0, 0(a0)                    # Sauvegarder t0 dans 0(a0)
    sw   t1, 4(a0)                    # Sauvegarder t1 dans 4(a0)

    addi t4, a0, 8                    # Adresse de la premiere cellule
    li   t5, 15                       # Bits 0, 1, 2 et 3 a 1

L_creer_boucle:
    beqz t3, L_creer_fin              # Si egal a zero, aller a L_creer_fin
    sw   t5, 0(t4)                    # Initialiser une cellule
    addi t4, t4, 4                    # Cellule suivante
    addi t3, t3, -1                   # Ajouter -1 a t3 ; resultat dans t3
    j    L_creer_boucle               # Aller a L_creer_boucle

L_creer_fin:
    lw   a7, 0(sp)                    # Charger dans a7 la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_indiceToCoords : Retourne x dans a0 et y dans a1
L_indiceToCoords:
    lw   t0, 0(a1)                    # t0 = nombre de colonnes
    remu t1, a0, t0                   # t1 = x
    divu t2, a0, t0                   # t2 = y
    mv   a0, t1                       # Copier t1 dans a0
    mv   a1, t2                       # Copier t2 dans a1
    ret                               # Retourner a la fonction appelante


# FONCTION L_coordsToIndice : Retourne l'indice de la cellule dans a0
L_coordsToIndice:
    lw   t0, 0(a2)                    # t0 = nombre de colonnes
    mul  t1, a1, t0                   # t1 = y * colonnes
    add  a0, t1, a0                   # a0 = y * colonnes + x
    ret                               # Retourner a la fonction appelante

#          a2 = adresse du labyrinthe


# FONCTION L_aUnMur : Retourne 1 si un mur est present
L_aUnMur:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a2, t0                   # Ajouter a2 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    jal  ra, B_getBit                 # a1 = numero du bit = direction

    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# Ne casse que ce cote (la voisine doit casser son mur oppose)


# FONCTION L_casserMur : Efface le bit du mur pour ce seul cote
L_casserMur:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a2, 8(sp)                    # Sauvegarder a2 dans 8(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a2, t0                   # Ajouter a2 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    li   a2, 0                        # bit a 0
    jal  ra, B_setBit                 # Appeler B_setBit et memoriser le retour dans ra

    lw   t1, 4(sp)                    # indice
    lw   t2, 8(sp)                    # adresse du labyrinthe
    slli t1, t1, 2                    # Decaler a gauche de 2 a t1 ; resultat dans t1
    add  t1, t2, t1                   # Ajouter t2 et t1 ; resultat dans t1
    sw   a0, 8(t1)                    # ecrit la nouvelle valeur

    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    lw   a0, 4(sp)                    # Charger dans a0 la valeur situee a 4(sp)
    lw   a2, 8(sp)                    # Charger dans a2 la valeur situee a 8(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_estDepart : Teste le bit 4 : depart
L_estDepart:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 4                        # Bit "depart"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra

    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_estArrivee : Teste le bit 5 : arrivee
L_estArrivee:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 5                        # Bit "arrivee"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra

    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_estVisitee : Teste le bit 6 : visitee
L_estVisitee:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 6                        # Bit "visitee"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra

    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_estSolution : Teste le bit 7 : solution
L_estSolution:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 7                        # Bit "solution"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra

    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_defDepart : Active le bit 4 : depart
L_defDepart:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    li   a1, 4                        # Bit "depart"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # a0 = nouvelle valeur

    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)

    lw   a0, 4(sp)                    # Charger dans a0 la valeur situee a 4(sp)
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_defArrivee : Active le bit 5 : arrivee
L_defArrivee:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 5                        # Bit "arrivee"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Appeler B_setBit et memoriser le retour dans ra

    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)

    lw   a0, 4(sp)                    # Charger dans a0 la valeur situee a 4(sp)
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_defVisitee : Active le bit 6 : visitee
L_defVisitee:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 6                        # Bit "visitee"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Appeler B_setBit et memoriser le retour dans ra

    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)

    lw   a0, 4(sp)                    # Charger dans a0 la valeur situee a 4(sp)
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_defSolution : Active le bit 7 : solution
L_defSolution:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)

    slli t0, a0, 2                    # Decaler a gauche de 2 a a0 ; resultat dans t0
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 7                        # Bit "solution"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Appeler B_setBit et memoriser le retour dans ra

    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)

    lw   a0, 4(sp)                    # Charger dans a0 la valeur situee a 4(sp)
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante


# FONCTION L_estDedans : Retourne 1 si (x,y) est dans le labyrinthe
L_estDedans:
    blt  a0, zero, L_estDedans_non    # Si a0 est inferieur a zero, aller a L_estDedans_non
    blt  a1, zero, L_estDedans_non    # Si a1 est inferieur a zero, aller a L_estDedans_non

    lw   t0, 0(a2)                    # t0 = nombre de colonnes
    lw   t1, 4(a2)                    # t1 = nombre de lignes

    bge  a0, t0, L_estDedans_non      # Si a0 est superieur ou egal a t0, aller a L_estDedans_non
    bge  a1, t1, L_estDedans_non      # Si a1 est superieur ou egal a t1, aller a L_estDedans_non

    li   a0, 1                        # Placer 1 dans a0
    ret                               # Retourner a la fonction appelante

L_estDedans_non:
    li   a0, 0                        # Placer 0 dans a0
    ret                               # Retourner a la fonction appelante

#          a2 = direction (0 haut, 1 droite, 2 bas, 3 gauche)


# FONCTION L_voisinDir : Retourne les coordonnees du voisin
L_voisinDir:
    beqz a2, L_voisin_haut            # Si egal a zero, aller a L_voisin_haut

    li   t0, 1                        # Placer 1 dans t0
    beq  a2, t0, L_voisin_droite      # Si a2 est egaux a t0, aller a L_voisin_droite

    li   t0, 2                        # Placer 2 dans t0
    beq  a2, t0, L_voisin_bas         # Si a2 est egaux a t0, aller a L_voisin_bas

    li   t0, 3                        # Placer 3 dans t0
    beq  a2, t0, L_voisin_gauche      # Si a2 est egaux a t0, aller a L_voisin_gauche

    ret                               # Retourner a la fonction appelante

L_voisin_haut:
    addi a1, a1, -1                   # y = y - 1
    ret                               # Retourner a la fonction appelante

L_voisin_droite:
    addi a0, a0, 1                    # x = x + 1
    ret                               # Retourner a la fonction appelante

L_voisin_bas:
    addi a1, a1, 1                    # y = y + 1
    ret                               # Retourner a la fonction appelante

L_voisin_gauche:
    addi a0, a0, -1                   # x = x - 1
    ret                               # Retourner a la fonction appelante

#          a1 = adresse du labyrinthe
#          a1 = y du centre dans l'image


# FONCTION L_posCelluleImage : Retourne le centre de la cellule dans l'image
L_posCelluleImage:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)

    # Convertir indice en coordonnees de cellule
    jal  ra, L_indiceToCoords         # Appeler L_indiceToCoords et memoriser le retour dans ra

    # Calculer le centre dans l'image
    li   t0, 3                        # Placer 3 dans t0

    mul  a0, a0, t0                   # x = x * 3
    addi a0, a0, 1                    # x_image = 3*x + 1

    mul  a1, a1, t0                   # y = y * 3
    addi a1, a1, 1                    # y_image = 3*y + 1

    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

#           a1 = couleur
#           a2 = adresse du labyrinthe


# FONCTION L_afficherCellule : Dessine le centre et les passages sans mur
L_afficherCellule:
    addi sp, sp, -48                  # Ajouter -48 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw a7, 28(sp)                     # Sauvegarder a7 dans 28(sp)

    # Conserver les arguments
    mv s0, a0                         # Indice de la cellule
    mv s1, a1                         # Couleur
    mv s2, a2                         # Adresse du labyrinthe

    # Charger l'adresse de l'image
    la t0, adresse_image              # Charger l'adresse de adresse_image dans t0
    lw s3, 0(t0)                      # Charger dans s3 la valeur situee a 0(t0)

    # Trouver les coordonnees du centre
    mv a0, s0                         # Indice de la cellule
    mv a1, s2                         # Adresse du labyrinthe
    jal ra, L_posCelluleImage         # Appeler L_posCelluleImage et memoriser le retour dans ra

    # Indice du centre = y * largeur + x
    lw t0, largeur_img                # Charger dans t0 la valeur situee a largeur_img
    mul s4, a1, t0                    # Multiplier a1 et t0 ; resultat dans s4
    add s4, s4, a0                    # Ajouter s4 et a0 ; resultat dans s4

    # Colorier le centre
    mv a0, s4                         # Copier s4 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s3                         # Copier s3 dans a2
    jal ra, I_plot                    # Appeler I_plot et memoriser le retour dans ra

    # Direction initiale : haut
    li s5, 0                          # Placer 0 dans s5

L_afficherCellule_boucle:
    # Terminer apres les 4 directions
    li t0, 4                          # Placer 4 dans t0
    bge s5, t0, L_afficherCellule_fin # Si s5 est superieur ou egal a t0, aller a L_afficherCellule_fin

    # Tester la presence d'un mur
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s5                         # Copier s5 dans a1
    mv a2, s2                         # Copier s2 dans a2
    jal ra, L_aUnMur                  # Appeler L_aUnMur et memoriser le retour dans ra

    # Mur present : passer a la direction suivante
    bnez a0, L_afficherCellule_suite  # Si different de zero, aller a L_afficherCellule_suite

    # Partir de l'indice du centre
    mv t0, s4                         # Copier s4 dans t0

    beqz s5, L_afficherCellule_haut   # Si egal a zero, aller a L_afficherCellule_haut

    li t1, 1                          # Placer 1 dans t1
    beq s5, t1, L_afficherCellule_droite # Si s5 est egaux a t1, aller a L_afficherCellule_droite

    li t1, 2                          # Placer 2 dans t1
    beq s5, t1, L_afficherCellule_bas # Si s5 est egaux a t1, aller a L_afficherCellule_bas

    # Gauche : indice - 1
    addi t0, t0, -1                   # Ajouter -1 a t0 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_haut:
    # Haut : indice - largeur
    lw t1, largeur_img                # Charger dans t1 la valeur situee a largeur_img
    sub t0, t0, t1                    # Soustraire t0 et t1 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_droite:
    # Droite : indice + 1
    addi t0, t0, 1                    # Ajouter 1 a t0 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_bas:
    # Bas : indice + largeur
    lw t1, largeur_img                # Charger dans t1 la valeur situee a largeur_img
    add t0, t0, t1                    # Ajouter t0 et t1 ; resultat dans t0

L_afficherCellule_tracer:
    # Colorier le passage
    mv a0, t0                         # Copier t0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s3                         # Copier s3 dans a2
    jal ra, I_plot                    # Appeler I_plot et memoriser le retour dans ra

L_afficherCellule_suite:
    addi s5, s5, 1                    # Ajouter 1 a s5 ; resultat dans s5
    j L_afficherCellule_boucle        # Aller a L_afficherCellule_boucle

L_afficherCellule_fin:
    # Restaurer les arguments AVANT les registres s
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s2                         # Copier s2 dans a2
    lw a7, 28(sp)                     # Charger dans a7 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 48                   # Ajouter 48 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

