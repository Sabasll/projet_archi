# ============================================================
# PARTIE 2 - les images 
# ============================================================

.data                              # Section des donnees
largeur_img: .word 64           # Largeur de l'image en pixels
hauteur_img: .word 64           # Hauteur de l'image en pixels

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    jal ra, I_creer          # Allouer l'image de 64 x 64 pixels
    mv s0, a0                # Garder l'adresse de base de l'image

    lw t0, largeur_img       # Charger la largeur
    lw t1, hauteur_img       # Charger la hauteur
    mul t0, t0, t1           # Nombre total de pixels
    mv t1, s0                # Adresse du pixel courant
main_noir:
    beqz t0, main_image      # Arreter si tous les pixels sont effaces
    sw zero, 0(t1)           # Mettre le pixel en noir
    addi t1, t1, 4           # Passer au pixel suivant
    addi t0, t0, -1          # Diminuer le nombre de pixels restants
    j main_noir              # Continuer la boucle

main_image:
    li a0, 10                # Coordonnee x du premier pixel
    li a1, 5                 # Coordonnee y du premier pixel
    mv a2, s0                # Adresse de base de l'image
    jal ra, I_coordToAdresse # Calculer l'adresse du pixel
    li t0, 0x00FF0000        # Couleur rouge
    sw t0, 0(a0)             # Colorier le premier pixel en rouge

    li a0, 331               # Indice du pixel (11,5) = 5*64+11
    li a1, 0x000000FF        # Couleur bleue
    mv a2, s0                # Adresse de base de l'image
    jal ra, I_plot           # Colorier le second pixel en bleu

    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION I_creer
# Entree(s) : aucune
# Objectif : Alloue largeur x hauteur x 4 octets, adresse dans a0
# ============================================================

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

# ============================================================
# FONCTION I_coordToAdresse
# Entree(s) : a0 = x, a1 = y, a2 = base image
# Objectif : Retourne l'adresse memoire du pixel dans a0
# ============================================================

I_coordToAdresse:

    lw   t0, largeur_img              # t0 = largeur (en units)
    mul  t1, a1, t0                   # t1 = y * largeur
    add  t1, t1, a0                   # t1 = y * largeur + x  (indice du pixel)
    slli t1, t1, 2                    # t1 = indice * 4  (decalage en octets)
    add  a0, a2, t1                   # a0 = base + decalage
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION I_adresseToCoord
# Entree(s) : a0 = adresse du pixel, a1 = base image
# Objectif : Retourne x dans a0 et y dans a1
# ============================================================

I_adresseToCoord:

# x = indice % largeur ; y = indice / largeur

    sub  t0, a0, a1                   # t0 = decalage en octets (adresse - base)
    srli t0, t0, 2                    # t0 = indice du pixel (decalage / 4)
    lw   t1, largeur_img              # t1 = largeur (en units)
    rem  a0, t0, t1                   # a0 = x = indice % largeur
    div  a1, t0, t1                   # a1 = y = indice / largeur
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION I_plot
# Entree(s) : a0 = indice du pixel, a1 = couleur, a2 = base image
# Objectif : Ecrit la couleur du pixel
# ============================================================

I_plot:

# Colorie le pixel P : adresse = base + indice * 4

    slli t0, a0, 2                    # t0 = indice * 4 (decalage en octets)
    add  t0, a2, t0                   # t0 = base + decalage = adresse du pixel
    sw   a1, 0(t0)                    # ecrit la couleur dans la memoire image
    ret                               # Retourner a la fonction appelante

# Chaque pixel occupe 4 octets.
