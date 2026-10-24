# ============================================
# L_voisinsNonVisitees
# Entrees : a0 = indice de la cellule C
#           a1 = adresse du labyrinthe
# Sorties : a0 = nombre de voisines non visitees
#           a1 = directions, une par octet (octet 0 = 1ere trouvee...)
# ============================================
L_voisinsNonVisitees:
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw a2, 40(sp)

    mv s0, a0                  # indice de C
    mv s1, a1                  # adresse du labyrinthe

    # (x, y) de C ; a0 et a1 contiennent deja les bons arguments
    jal ra, L_indiceToCoords
    mv s2, a0                  # x de C
    mv s3, a1                  # y de C

    li s4, 0                   # direction courante (0..3)
    li s5, 0                   # nombre de voisines non visitees
    li s6, 0                   # directions regroupees (un octet chacune)

L_voisinsNonVisitees_boucle:
    li t0, 4
    bge s4, t0, L_voisinsNonVisitees_fin

    # (x, y) du voisin dans la direction s4
    mv a0, s2
    mv a1, s3
    mv a2, s4
    jal ra, L_voisinDir
    mv s7, a0                  # x du voisin
    mv s8, a1                  # y du voisin (a1 sera ecrase par les appels)

    # Le voisin est-il dans le labyrinthe ?
    mv a0, s7
    mv a1, s8
    mv a2, s1
    jal ra, L_estDedans
    beqz a0, L_voisinsNonVisitees_suite

    # Indice du voisin
    mv a0, s7
    mv a1, s8
    mv a2, s1
    jal ra, L_coordsToIndice

    # Le voisin a-t-il deja ete visite ?
    mv a1, s1
    jal ra, L_estVisitee
    bnez a0, L_voisinsNonVisitees_suite

    # Ranger la direction s4 dans l'octet numero s5
    mv a0, s6
    mv a1, s5
    mv a2, s4
    jal ra, B_setByte
    mv s6, a0
    addi s5, s5, 1             # une voisine de plus

L_voisinsNonVisitees_suite:
    addi s4, s4, 1             # direction suivante
    j L_voisinsNonVisitees_boucle

L_voisinsNonVisitees_fin:
    mv a0, s5                  # nombre de voisines
    mv a1, s6                  # directions

    lw a2, 40(sp)
    lw s8, 36(sp)
    lw s7, 32(sp)
    lw s6, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 48
    ret

# ============================================
# L_directionAleatoire
# Entrees : a0 = n (nombre de directions, n >= 1)
#           a1 = directions, une par octet (n octets de poids faible)
# Sortie  : a0 = une direction (0..3) tiree au hasard
# ============================================
L_directionAleatoire:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)

    mv s0, a1                  # sauvegarder les directions
    addi a0, a0, -1            # auHasard est inclusif : tirage dans [0, n-1]
    jal ra, auHasard           # a0 = numero d'octet au hasard

    mv a1, a0                  # a1 = numero d'octet
    mv a0, s0                  # a0 = directions regroupees
    jal ra, B_getByte          # a0 = la direction choisie

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_afficher
# Entree : a0 = adresse du labyrinthe
# Sortie : aucune
# Murs : noirs ; passages : blancs
# ============================================

L_afficher:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)

    mv s0, a0                  # Adresse du labyrinthe

    # Nombre total de cellules = colonnes * lignes
    lw t0, 0(s0)
    lw t1, 4(s0)
    mul s1, t0, t1

    # Nombre de points de l'image
    lw t0, largeur_img
    lw t1, hauteur_img
    mul t2, t0, t1

    # Adresse du premier point
    lw t3, adresse_image

L_afficher_effacer:
    beqz t2, L_afficher_debut

    # Mettre le point en noir
    sw zero, 0(t3)

    addi t3, t3, 4
    addi t2, t2, -1
    j L_afficher_effacer

L_afficher_debut:
    li s2, 0                   # Indice de la premiere cellule

L_afficher_boucle:
    bge s2, s1, L_afficher_fin

    # Dessiner la cellule courante en blanc
    mv a0, s2
    li a1, 0x00FFFFFF
    mv a2, s0
    jal ra, L_afficherCellule

    # Cellule suivante
    addi s2, s2, 1
    j L_afficher_boucle

L_afficher_fin:
    lw a2, 24(sp)
    lw a1, 20(sp)
    lw a0, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    ret

# ============================================
# L_generer
# Entrees : a0 = indice de la cellule de depart
#           a1 = adresse du labyrinthe
# Sortie : aucune
#
# Precondition :
# labyrinthe neuf, toutes les cellules non visitees
# ============================================

L_generer:
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw a0, 28(sp)
    sw a1, 32(sp)
    sw a2, 36(sp)

    mv s0, a0                  # Cellule de depart
    mv s1, a1                  # Adresse du labyrinthe

    # Creer une pile pouvant contenir toutes les cellules
    lw t0, 0(s1)               # Nombre de colonnes
    lw t1, 4(s1)               # Nombre de lignes
    mul a0, t0, t1
    jal ra, P_creer
    mv s2, a0                  # Adresse de la pile

    # Marquer la cellule de depart comme visitee
    mv a0, s0
    mv a1, s1
    jal ra, L_defVisitee

    # Empiler la cellule de depart
    mv a0, s2
    mv a1, s0
    jal ra, P_empiler

L_generer_boucle:
    # Terminer si la pile est vide
    mv a0, s2
    jal ra, P_estVide
    bnez a0, L_generer_fin

    # Lire la cellule au sommet sans la retirer
    mv a0, s2
    jal ra, P_sommet
    mv s3, a0                  # Cellule courante

    # Chercher ses voisins non visites
    mv a0, s3
    mv a1, s1
    jal ra, L_voisinsNonVisitees

    # Aucun voisin disponible : revenir en arriere
    beqz a0, L_generer_retour

    # Choisir une direction parmi celles trouvees
    jal ra, L_directionAleatoire
    mv s4, a0                  # Direction choisie

    # Coordonnees de la cellule courante
    mv a0, s3
    mv a1, s1
    jal ra, L_indiceToCoords

    # Coordonnees du voisin choisi
    mv a2, s4
    jal ra, L_voisinDir

    # Convertir ces coordonnees en indice
    mv a2, s1
    jal ra, L_coordsToIndice
    mv s5, a0                  # Indice du voisin choisi

    # Casser le mur du cote de la cellule courante
    mv a0, s3
    mv a1, s4
    mv a2, s1
    jal ra, L_casserMur

    # Calculer la direction opposee : (direction + 2) % 4
    addi t0, s4, 2
    andi t0, t0, 3

    # Casser le mur oppose du cote du voisin
    mv a0, s5
    mv a1, t0
    mv a2, s1
    jal ra, L_casserMur

    # Marquer le voisin comme visite
    mv a0, s5
    mv a1, s1
    jal ra, L_defVisitee

    # Empiler le voisin pour continuer depuis cette cellule
    mv a0, s2
    mv a1, s5
    jal ra, P_empiler

    j L_generer_boucle

L_generer_retour:
    # Retirer la cellule qui n'a plus de voisin non visite
    mv a0, s2
    jal ra, P_depiler
    j L_generer_boucle

L_generer_fin:
    lw a2, 36(sp)
    lw a1, 32(sp)
    lw a0, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 48
    ret