# TEST AUTONOME RARS RV32 (une seule partie par fichier)

# ===== MAIN DE TEST =====
.data
p2_title: .asciz "--- Partie 2 : image ---\n"
p2_msg1: .asciz "I_coordToAdresse(10,5) et I_adresseToCoord -> (x,y) = "
p2_msg2: .asciz "\nDeux units colorees : rouge (10,5), bleu (11,5).\n"
p2_comma: .asciz ", "
p2_nl: .asciz "\n"

.text
.globl main
main:
    jal I_creer
    mv s0, a0              # s0 = adresse image

    # Fond noir : initialiser les largeur * hauteur units
    lw t0, largeur_img
    lw t1, hauteur_img
    mul t0, t0, t1
    mv t1, s0
p2_clear:
    beqz t0, p2_clear_fin
    sw zero, 0(t1)
    addi t1, t1, 4
    addi t0, t0, -1
    j p2_clear
p2_clear_fin:
    # (10,5) -> adresse ; stocker une couleur rouge
    li a0, 10
    li a1, 5
    mv a2, s0
    jal I_coordToAdresse
    mv s1, a0              # Adresse de l'unit (10,5)
    li t0, 0x00FF0000
    sw t0, 0(s1)

    # Adresse -> (x,y)
    mv a0, s1
    mv a1, s0
    jal I_adresseToCoord
    mv s2, a0
    mv s3, a1

    la a0, p2_title
    li a7, 4
    ecall
    la a0, p2_msg1
    li a7, 4
    ecall
    mv a0, s2
    li a7, 1
    ecall
    la a0, p2_comma
    li a7, 4
    ecall
    mv a0, s3
    li a7, 1
    ecall

    # I_plot: (11,5), indice = 5*64 + 11 = 331
    lw t0, largeur_img
    li t1, 5
    mul a0, t1, t0
    addi a0, a0, 11
    li a1, 0x000000FF    # Bleu
    mv a2, s0
    jal I_plot

    la a0, p2_msg2
    li a7, 4
    ecall
    li a7, 10
    ecall

# ===== FONCTIONS DE LA PARTIE =====
.data
# Dimensions de l'image en units (variables globales tolerees par le sujet)
largeur_img:  .word 64
hauteur_img:  .word 64

.text
# I_creer
# Entree : aucune
# Sortie : a0 = adresse du premier octet de la plage allouee (1 entier par pixel)
# Preserve a7
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
    

I_coordToAdresse:

# I_coordToAdresse
# Entree : a0 = x (abscisse), a1 = y (ordonnee), a2 = adresse du premier pixel
# Sortie : a0 = adresse de l'entier associe au pixel (x,y)
# Formule : adresse = base + (y * largeur + x) * 4
# Preserve a1, a2

    lw   t0, largeur_img        # t0 = largeur (en units)
    mul  t1, a1, t0        # t1 = y * largeur
    add  t1, t1, a0        # t1 = y * largeur + x  (indice du pixel)
    slli t1, t1, 2         # t1 = indice * 4  (decalage en octets)
    add  a0, a2, t1        # a0 = base + decalage
    ret


I_adresseToCoord:

# I_adresseToCoord
# Entree : a0 = adresse d'un pixel, a1 = adresse du premier pixel
# Sortie : a0 = x (abscisse), a1 = y (ordonnee)
# Formules : indice = (adresse - base) / 4
# x = indice % largeur ; y = indice / largeur

    sub  t0, a0, a1        # t0 = decalage en octets (adresse - base)
    srli t0, t0, 2         # t0 = indice du pixel (decalage / 4) 
    lw   t1, largeur_img   # t1 = largeur (en units)
    rem  a0, t0, t1        # a0 = x = indice % largeur
    div  a1, t0, t1        # a1 = y = indice / largeur
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

# CHOIX DE REPRESENTATION D'UN PIXEL (tache 5)
# Dans tout le projet, un pixel (une unit) est represente par
# un seul entier : l'ADRESSE de sa case dans la memoire image.
# Consequence : quand une fonction "retourne un pixel" ou
# "prend un pixel en argument", il s'agit de cette adresse.
