# TEST AUTONOME RARS RV32 (une seule partie par fichier)

# ===== MAIN DE TEST =====
.data
adresse_image: .word 0
p5_title:   .asciz "--- Partie 5 : labyrinthe (64x64 units) ---\n"
p5_dim:     .asciz "L_creer : colonnes = "
p5_by:      .asciz ", lignes = "
p5_ic:      .asciz "\nL_indiceToCoords(25) -> x,y = "
p5_ci:      .asciz "\nL_coordsToIndice(4,1) -> indice = "
p5_wall1:   .asciz "\nL_aUnMur(25,droite) avant -> "
p5_wall2:   .asciz "\nL_aUnMur(25,droite) apres L_casserMur -> "
p5_de:      .asciz "\nL_estDepart(25) apres L_defDepart -> "
p5_ar:      .asciz "\nL_estArrivee(26) apres L_defArrivee -> "
p5_vi:      .asciz "\nL_estVisitee(25) apres L_defVisitee -> "
p5_so:      .asciz "\nL_estSolution(25) apres L_defSolution -> "
p5_in1:     .asciz "\nL_estDedans(20,20) -> "
p5_in2:     .asciz "\nL_estDedans(21,0) -> "
p5_vo:      .asciz "\nL_voisinDir(4,1,droite) -> x,y = "
p5_pos:     .asciz "\nL_posCelluleImage(25) -> x,y = "
p5_im:      .asciz "\nL_afficherCellule(25 rouge, 26 vert) : regarder Bitmap Display.\n"
p5_comma:   .asciz ", "

.text
.globl main
main:
    la a0, p5_title
    li a7, 4
    ecall

    # Creer l'image en heap et memoriser son adresse
    jal I_creer
    mv s0, a0
    la t0, adresse_image
    sw s0, 0(t0)

    # Mettre l'image entiere au noir
    lw t0, largeur_img
    lw t1, hauteur_img
    mul t0, t0, t1
    mv t1, s0
p5_clear:
    beqz t0, p5_clear_fin
    sw zero, 0(t1)
    addi t1, t1, 4
    addi t0, t0, -1
    j p5_clear
p5_clear_fin:

    jal L_creer
    mv s1, a0                 # Adresse labyrinthe

    la a0, p5_dim
    li a7, 4
    ecall
    lw a0, 0(s1)
    li a7, 1
    ecall
    la a0, p5_by
    li a7, 4
    ecall
    lw a0, 4(s1)
    li a7, 1
    ecall

    # Question 2
    la a0, p5_ic
    li a7, 4
    ecall
    li a0, 25
    mv a1, s1
    jal L_indiceToCoords
    mv s2, a0
    mv s3, a1
    mv a0, s2
    li a7, 1
    ecall
    la a0, p5_comma
    li a7, 4
    ecall
    mv a0, s3
    li a7, 1
    ecall

    # Question 3
    la a0, p5_ci
    li a7, 4
    ecall
    li a0, 4
    li a1, 1
    mv a2, s1
    jal L_coordsToIndice
    li a7, 1
    ecall

    # Questions 4 et 5
    la a0, p5_wall1
    li a7, 4
    ecall
    li a0, 25
    li a1, 1                  # droite
    mv a2, s1
    jal L_aUnMur
    li a7, 1
    ecall

    li a0, 25
    li a1, 1
    mv a2, s1
    jal L_casserMur
    li a0, 26
    li a1, 3                  # cote gauche du voisin
    mv a2, s1
    jal L_casserMur

    la a0, p5_wall2
    li a7, 4
    ecall
    li a0, 25
    li a1, 1
    mv a2, s1
    jal L_aUnMur
    li a7, 1
    ecall

    # Questions 6 et 7: les 4 couples def/est
    li a0, 25
    mv a1, s1
    jal L_defDepart
    la a0, p5_de
    li a7, 4
    ecall
    li a0, 25
    mv a1, s1
    jal L_estDepart
    li a7, 1
    ecall

    li a0, 26
    mv a1, s1
    jal L_defArrivee
    la a0, p5_ar
    li a7, 4
    ecall
    li a0, 26
    mv a1, s1
    jal L_estArrivee
    li a7, 1
    ecall

    li a0, 25
    mv a1, s1
    jal L_defVisitee
    la a0, p5_vi
    li a7, 4
    ecall
    li a0, 25
    mv a1, s1
    jal L_estVisitee
    li a7, 1
    ecall

    li a0, 25
    mv a1, s1
    jal L_defSolution
    la a0, p5_so
    li a7, 4
    ecall
    li a0, 25
    mv a1, s1
    jal L_estSolution
    li a7, 1
    ecall

    # Question 8: dedans puis dehors
    la a0, p5_in1
    li a7, 4
    ecall
    li a0, 20
    li a1, 20
    mv a2, s1
    jal L_estDedans
    li a7, 1
    ecall

    la a0, p5_in2
    li a7, 4
    ecall
    li a0, 21
    li a1, 0
    mv a2, s1
    jal L_estDedans
    li a7, 1
    ecall

    # Question 9
    la a0, p5_vo
    li a7, 4
    ecall
    li a0, 4
    li a1, 1
    li a2, 1
    jal L_voisinDir
    mv s2, a0
    mv s3, a1
    mv a0, s2
    li a7, 1
    ecall
    la a0, p5_comma
    li a7, 4
    ecall
    mv a0, s3
    li a7, 1
    ecall

    # Question 10
    la a0, p5_pos
    li a7, 4
    ecall
    li a0, 25
    mv a1, s1
    jal L_posCelluleImage
    mv s2, a0
    mv s3, a1
    mv a0, s2
    li a7, 1
    ecall
    la a0, p5_comma
    li a7, 4
    ecall
    mv a0, s3
    li a7, 1
    ecall

    # Question 11: colorier deux cellules voisines
    li a0, 25
    li a1, 0x00FF0000        # rouge
    mv a2, s1
    jal L_afficherCellule
    li a0, 26
    li a1, 0x0000FF00        # vert
    mv a2, s1
    jal L_afficherCellule
    la a0, p5_im
    li a7, 4
    ecall

    li a7, 10
    ecall

# ===== FONCTIONS DE LA PARTIE =====
.data
largeur_img: .word 64       # Largeur de l'image en units
hauteur_img: .word 64       # Hauteur de l'image en units

.text
# ============================================
# L_creer
# Entree : aucune
# Sortie : a0 = adresse du labyrinthe
#
# Structure :
#   0(a0) : nombre de colonnes
#   4(a0) : nombre de lignes
#   8(a0) : premiere cellule
# Preserve a7

L_creer:
    addi sp, sp, -16
    sw   a7, 0(sp)

    lw   t0, largeur_img
    lw   t1, hauteur_img
    li   t2, 3

    divu t0, t0, t2         # Nombre de colonnes
    divu t1, t1, t2         # Nombre de lignes

    mul  t3, t0, t1         # Nombre total de cellules
    slli a0, t3, 2          # 4 octets par cellule
    addi a0, a0, 8          # Ajouter les dimensions

    li   a7, 9              # sbrk
    ecall

    sw   t0, 0(a0)
    sw   t1, 4(a0)

    addi t4, a0, 8          # Adresse de la premiere cellule
    li   t5, 15             # Bits 0, 1, 2 et 3 a 1

L_creer_boucle:
    beqz t3, L_creer_fin
    sw   t5, 0(t4)          # Initialiser une cellule
    addi t4, t4, 4          # Cellule suivante
    addi t3, t3, -1
    j    L_creer_boucle

L_creer_fin:
    lw   a7, 0(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_indiceToCoords
# Entree : a0 = indice de la cellule, a1 = adresse du labyrinthe
# Sortie : a0 = abscisse (x), a1 = ordonnee (y)

L_indiceToCoords:
    lw   t0, 0(a1)          # t0 = nombre de colonnes
    remu t1, a0, t0         # t1 = x
    divu t2, a0, t0         # t2 = y
    mv   a0, t1
    mv   a1, t2
    ret

# ============================================
# L_coordsToIndice
# Entree : a0 = x, a1 = y, a2 = adresse du labyrinthe
# Sortie : a0 = indice de la cellule

L_coordsToIndice:
    lw   t0, 0(a2)          # t0 = nombre de colonnes
    mul  t1, a1, t0         # t1 = y * colonnes
    add  a0, t1, a0         # a0 = y * colonnes + x
    ret

# ============================================
# L_aUnMur
# Entree : a0 = indice, a1 = direction (0 haut, 1 droite, 2 bas, 3 gauche),
#          a2 = adresse du labyrinthe
# Sortie : a0 = 1 si mur, 0 sinon
# Preserve a1, a2, ra

L_aUnMur:
    addi sp, sp, -16
    sw   ra, 0(sp)

    slli t0, a0, 2
    add  t0, a2, t0
    lw   a0, 8(t0)          # a0 = valeur de la cellule
    jal  ra, B_getBit       # a1 = numero du bit = direction

    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_casserMur
# Entree : a0 = indice, a1 = direction, a2 = adresse du labyrinthe
# Sortie : aucune
# Ne casse que ce cote (la voisine doit casser son mur oppose)
# Preserve a0, a1, a2, ra

L_casserMur:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a2, 8(sp)

    slli t0, a0, 2
    add  t0, a2, t0
    lw   a0, 8(t0)          # a0 = valeur de la cellule
    li   a2, 0              # bit a 0
    jal  ra, B_setBit

    lw   t1, 4(sp)          # indice
    lw   t2, 8(sp)          # adresse du labyrinthe
    slli t1, t1, 2
    add  t1, t2, t1
    sw   a0, 8(t1)          # ecrit la nouvelle valeur

    lw   ra, 0(sp)
    lw   a0, 4(sp)
    lw   a2, 8(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_estDepart / L_estArrivee / L_estVisitee / L_estSolution
# Entree : a0 = indice de la cellule, a1 = adresse du labyrinthe
# Sortie : a0 = 1 si oui, 0 sinon
# Preserve a1, ra

L_estDepart:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a1, 4(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 4              # Bit "depart"
    jal  ra, B_getBit

    lw   a1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_estArrivee:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a1, 4(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 5              # Bit "arrivee"
    jal  ra, B_getBit

    lw   a1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_estVisitee:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a1, 4(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 6              # Bit "visitee"
    jal  ra, B_getBit

    lw   a1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_estSolution:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a1, 4(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 7              # Bit "solution"
    jal  ra, B_getBit

    lw   a1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_defDepart / L_defArrivee / L_defVisitee / L_defSolution
# Entree : a0 = indice de la cellule, a1 = adresse du labyrinthe
# Sortie : aucune
# Preserve a0, a1, a2, ra

L_defDepart:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)          # a0 = valeur de la cellule
    li   a1, 4              # Bit "depart"
    li   a2, 1
    jal  ra, B_setBit       # a0 = nouvelle valeur

    lw   t0, 4(sp)
    lw   t1, 8(sp)
    slli t0, t0, 2
    add  t0, t1, t0
    sw   a0, 8(t0)

    lw   a0, 4(sp)
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_defArrivee:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 5              # Bit "arrivee"
    li   a2, 1
    jal  ra, B_setBit

    lw   t0, 4(sp)
    lw   t1, 8(sp)
    slli t0, t0, 2
    add  t0, t1, t0
    sw   a0, 8(t0)

    lw   a0, 4(sp)
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_defVisitee:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 6              # Bit "visitee"
    li   a2, 1
    jal  ra, B_setBit

    lw   t0, 4(sp)
    lw   t1, 8(sp)
    slli t0, t0, 2
    add  t0, t1, t0
    sw   a0, 8(t0)

    lw   a0, 4(sp)
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

L_defSolution:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    sw   a1, 8(sp)
    sw   a2, 12(sp)

    slli t0, a0, 2
    add  t0, a1, t0
    lw   a0, 8(t0)
    li   a1, 7              # Bit "solution"
    li   a2, 1
    jal  ra, B_setBit

    lw   t0, 4(sp)
    lw   t1, 8(sp)
    slli t0, t0, 2
    add  t0, t1, t0
    sw   a0, 8(t0)

    lw   a0, 4(sp)
    lw   a1, 8(sp)
    lw   a2, 12(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret

# ============================================
# L_estDedans
# Entree : a0 = x, a1 = y, a2 = adresse du labyrinthe
# Sortie : a0 = 1 si dedans, 0 sinon

L_estDedans:
    blt  a0, zero, L_estDedans_non
    blt  a1, zero, L_estDedans_non

    lw   t0, 0(a2)          # t0 = nombre de colonnes
    lw   t1, 4(a2)          # t1 = nombre de lignes

    bge  a0, t0, L_estDedans_non
    bge  a1, t1, L_estDedans_non

    li   a0, 1
    ret

L_estDedans_non:
    li   a0, 0
    ret


# ============================================
# L_voisinDir
# Entree : a0 = x, a1 = y
#          a2 = direction (0 haut, 1 droite, 2 bas, 3 gauche)
# Sortie : a0 = x du voisin, a1 = y du voisin

L_voisinDir:
    beqz a2, L_voisin_haut

    li   t0, 1
    beq  a2, t0, L_voisin_droite

    li   t0, 2
    beq  a2, t0, L_voisin_bas

    li   t0, 3
    beq  a2, t0, L_voisin_gauche

    ret

L_voisin_haut:
    addi a1, a1, -1       # y = y - 1
    ret

L_voisin_droite:
    addi a0, a0, 1        # x = x + 1
    ret

L_voisin_bas:
    addi a1, a1, 1        # y = y + 1
    ret

L_voisin_gauche:
    addi a0, a0, -1       # x = x - 1
    ret


# ============================================
# L_posCelluleImage
# Entree : a0 = indice de la cellule
#          a1 = adresse du labyrinthe
# Sortie : a0 = x du centre dans l'image
#          a1 = y du centre dans l'image
# Preserve ra

L_posCelluleImage:
    addi sp, sp, -16
    sw   ra, 0(sp)

    # Convertir indice en coordonnees de cellule
    jal  ra, L_indiceToCoords

    # Calculer le centre dans l'image
    li   t0, 3

    mul  a0, a0, t0       # x = x * 3
    addi a0, a0, 1        # x_image = 3*x + 1

    mul  a1, a1, t0       # y = y * 3
    addi a1, a1, 1        # y_image = 3*y + 1

    lw   ra, 0(sp)
    addi sp, sp, 16
    ret


# ============================================
# L_afficherCellule
# Entrees : a0 = indice de la cellule
#           a1 = couleur
#           a2 = adresse du labyrinthe
# Sortie : aucune
# ============================================

L_afficherCellule:
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw a7, 28(sp)

    # Conserver les arguments
    mv s0, a0                 # Indice de la cellule
    mv s1, a1                 # Couleur
    mv s2, a2                 # Adresse du labyrinthe

    # Charger l'adresse de l'image
    la t0, adresse_image
    lw s3, 0(t0)

    # Trouver les coordonnees du centre
    mv a0, s0                 # Indice de la cellule
    mv a1, s2                 # Adresse du labyrinthe
    jal ra, L_posCelluleImage

    # Indice du centre = y * largeur + x
    lw t0, largeur_img
    mul s4, a1, t0
    add s4, s4, a0

    # Colorier le centre
    mv a0, s4
    mv a1, s1
    mv a2, s3
    jal ra, I_plot

    # Direction initiale : haut
    li s5, 0

L_afficherCellule_boucle:
    # Terminer apres les 4 directions
    li t0, 4
    bge s5, t0, L_afficherCellule_fin

    # Tester la presence d'un mur
    mv a0, s0
    mv a1, s5
    mv a2, s2
    jal ra, L_aUnMur

    # Mur present : passer a la direction suivante
    bnez a0, L_afficherCellule_suite

    # Partir de l'indice du centre
    mv t0, s4

    beqz s5, L_afficherCellule_haut

    li t1, 1
    beq s5, t1, L_afficherCellule_droite

    li t1, 2
    beq s5, t1, L_afficherCellule_bas

    # Gauche : indice - 1
    addi t0, t0, -1
    j L_afficherCellule_tracer

L_afficherCellule_haut:
    # Haut : indice - largeur
    lw t1, largeur_img
    sub t0, t0, t1
    j L_afficherCellule_tracer

L_afficherCellule_droite:
    # Droite : indice + 1
    addi t0, t0, 1
    j L_afficherCellule_tracer

L_afficherCellule_bas:
    # Bas : indice + largeur
    lw t1, largeur_img
    add t0, t0, t1

L_afficherCellule_tracer:
    # Colorier le passage
    mv a0, t0
    mv a1, s1
    mv a2, s3
    jal ra, I_plot

L_afficherCellule_suite:
    addi s5, s5, 1
    j L_afficherCellule_boucle

L_afficherCellule_fin:
    # Restaurer les arguments AVANT les registres s
    mv a0, s0
    mv a1, s1
    mv a2, s2
    lw a7, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 48
    ret

# === Dependances de Partie 4 ===
B_getBit:
    srl  t0, a0, a1            # t0 = a0 >> a1 (le bit voulu devient le bit 0)
    andi a0, t0, 1             # a0 = t0 & 1 (on garde seulement ce bit)
    ret

# B_setBit
# Entree : a0 = entier, a1 = numero du bit (0..31), a2 = valeur (0 ou 1)
# Sortie : a0 = a0 avec le bit a1 egal a a2
B_setBit:
    li   t0, 1
    sll  t0, t0, a1            # t0 = 1 << a1 (masque : un seul bit a 1)
    not  t0, t0                # t0 = ~masque (tous les bits a 1 sauf le bit a1)
    and  a0, a0, t0            # a0 = a0 avec le bit a1 mis a 0
    sll  t1, a2, a1            # t1 = a2 << a1 (la nouvelle valeur a sa place)
    or   a0, a0, t1            # a0 = a0 | t1 : le bit a1 vaut maintenant a2
    ret


# === Dependances de Partie 2 ===
I_creer:

    #prologue:
    addi sp, sp, -16
    sw   a7, 0(sp)

    # Calculer le nombre de pixels (units)
    lw t0, largeur_img          # t1 = largeur (en units)
    lw t1, hauteur_img          # t2 = hauteur (en units)
    mul t2, t0, t1
    slli a0, t2, 2              # a0 = nombre d'octets = nombre de pixels * 4 // # Chaque pixel occupe 4 octets
    li a7, 9                    # ecall 9 : sbrk (allocation dans le tas)
    ecall

    lw a7, 0(sp)                # restauration de a7
    addi sp, sp, 16
    ret
    


I_plot:

# I_plot
# Entree : a0 = indice du pixel P, a1 = couleur, a2 = adresse du premier pixel
# Sortie : aucune
# Colorie le pixel P : adresse = base + indice * 4
# Preserve a0, a1, a2

    slli t0, a0, 2         # t0 = indice * 4 (decalage en octets)
    add  t0, a2, t0        # t0 = base + decalage = adresse du pixel
    sw   a1, 0(t0)         # ecrit la couleur dans la memoire image
    ret

