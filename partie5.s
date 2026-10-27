# ============================================================
# PARTIE 5 - les cellules du labyrinthe
# ============================================================

.data                              # Section des donnees
largeur_img: .word 64           # Largeur de l'image
hauteur_img: .word 64           # Hauteur de l'image
adresse_image: .word 0          # Adresse de l'image utilisee pour dessiner

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    jal ra, I_creer          # Allouer la memoire de l'image
    la t0, adresse_image     # Charger l'adresse de la variable image
    sw a0, 0(t0)             # Memoriser la base de l'image

    jal ra, L_creer          # Creer un labyrinthe de 21 x 21 cellules
    mv s0, a0                # Conserver l'adresse du labyrinthe

    li a0, 0                 # Indice de la premiere cellule
    li a1, 1                 # Direction droite
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_casserMur      # Ouvrir le mur droit de la cellule 0

    li a0, 1                 # Indice de la cellule voisine
    li a1, 3                 # Direction gauche
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_casserMur      # Ouvrir le mur gauche de la cellule 1

    li a0, 0                 # Indice de la premiere cellule
    li a1, 0x00FF0000        # Couleur rouge
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_afficherCellule # Dessiner la premiere cellule

    li a0, 1                 # Indice de la deuxieme cellule
    li a1, 0x0000FF00        # Couleur verte
    mv a2, s0                # Adresse du labyrinthe
    jal ra, L_afficherCellule # Dessiner la deuxieme cellule

    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION L_creer
# Entree(s) : aucune
# Objectif : Cree le labyrinthe ferme, adresse dans a0
# ============================================================

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

# ============================================================
# FONCTION L_indiceToCoords
# Entree(s) : a0 = indice cellule, a1 = labyrinthe
# Objectif : Retourne x dans a0 et y dans a1
# ============================================================

L_indiceToCoords:
    lw   t0, 0(a1)                    # t0 = nombre de colonnes
    remu t1, a0, t0                   # t1 = x
    divu t2, a0, t0                   # t2 = y
    mv   a0, t1                       # Copier t1 dans a0
    mv   a1, t2                       # Copier t2 dans a1
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION L_coordsToIndice
# Entree(s) : a0 = x, a1 = y, a2 = labyrinthe
# Objectif : Retourne l'indice de la cellule dans a0
# ============================================================

L_coordsToIndice:
    lw   t0, 0(a2)                    # t0 = nombre de colonnes
    mul  t1, a1, t0                   # t1 = y * colonnes
    add  a0, t1, a0                   # a0 = y * colonnes + x
    ret                               # Retourner a la fonction appelante

#          a2 = adresse du labyrinthe

# ============================================================
# FONCTION L_aUnMur
# Entree(s) : a0 = indice, a1 = direction, a2 = labyrinthe
# Objectif : Retourne 1 si un mur est present
# ============================================================

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

# ============================================================
# FONCTION L_casserMur
# Entree(s) : a0 = indice, a1 = direction, a2 = labyrinthe
# Objectif : Efface le bit du mur pour ce seul cote
# ============================================================

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

# ============================================================
# FONCTION L_estDepart
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Teste le bit 4 : depart
# ============================================================

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

# ============================================================
# FONCTION L_estArrivee
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Teste le bit 5 : arrivee
# ============================================================

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

# ============================================================
# FONCTION L_estVisitee
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Teste le bit 6 : visitee
# ============================================================

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

# ============================================================
# FONCTION L_estSolution
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Teste le bit 7 : solution
# ============================================================

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

# ============================================================
# FONCTION L_defDepart
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Active le bit 4 : depart
# ============================================================

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

# ============================================================
# FONCTION L_defArrivee
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Active le bit 5 : arrivee
# ============================================================

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

# ============================================================
# FONCTION L_defVisitee
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Active le bit 6 : visitee
# ============================================================

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

# ============================================================
# FONCTION L_defSolution
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Active le bit 7 : solution
# ============================================================

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

# ============================================================
# FONCTION L_estDedans
# Entree(s) : a0 = x, a1 = y, a2 = labyrinthe
# Objectif : Retourne 1 si (x,y) est dans le labyrinthe
# ============================================================

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

# ============================================================
# FONCTION L_voisinDir
# Entree(s) : a0 = x, a1 = y, a2 = direction
# Objectif : Retourne les coordonnees du voisin
# ============================================================

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

# ============================================================
# FONCTION L_posCelluleImage
# Entree(s) : a0 = indice, a1 = labyrinthe
# Objectif : Retourne le centre de la cellule dans l'image
# ============================================================

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

# ============================================================
# FONCTION L_afficherCellule
# Entree(s) : a0 = indice, a1 = couleur, a2 = labyrinthe
# Objectif : Dessine le centre et les passages sans mur
# ============================================================

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

