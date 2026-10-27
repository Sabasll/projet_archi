
# ============================================================
# PARTIE 2 - IMAGE
# TEST AUTONOME RARS RV32
# ============================================================

# ===================== MAIN DE TEST =====================

.data                              # Debut de la section des donnees

p2_title: .asciz "--- Partie 2 : image ---\n" # Titre du test
p2_msg1: .asciz "I_coordToAdresse(10,5) et I_adresseToCoord -> (x,y) = " # Message de conversion
p2_msg2: .asciz "\nDeux units colorees : rouge (10,5), bleu (11,5).\n" # Message final
p2_comma: .asciz ", "             # Separateur entre x et y
p2_nl: .asciz "\n"               # Retour a la ligne, non utilise dans ce main

.text                              # Debut de la section des instructions
.globl main                        # Declarer main comme point d'entree

main:                              # Debut du programme principal

    # ---------- Creation de l'image ----------

    jal I_creer                    # Appeler I_creer pour allouer la memoire image
    mv s0, a0                      # Sauvegarder l'adresse de base de l'image dans s0

    # ---------- Initialiser le fond en noir ----------

    lw t0, largeur_img             # Charger la largeur de l'image dans t0
    lw t1, hauteur_img             # Charger la hauteur de l'image dans t1
    mul t0, t0, t1                 # Calculer le nombre total de pixels
    mv t1, s0                      # t1 pointe vers le premier pixel de l'image

p2_clear:                          # Debut de la boucle d'initialisation

    beqz t0, p2_clear_fin          # Si aucun pixel ne reste, sortir de la boucle
    sw zero, 0(t1)                 # Ecrire 0 dans le pixel courant : couleur noire
    addi t1, t1, 4                 # Avancer de 4 octets vers le pixel suivant
    addi t0, t0, -1                # Diminuer le nombre de pixels restants
    j p2_clear                    # Recommencer la boucle

p2_clear_fin:                      # Fin de l'initialisation du fond noir

    # ---------- Colorier le pixel (10,5) en rouge ----------

    li a0, 10                      # Charger x = 10 dans a0
    li a1, 5                       # Charger y = 5 dans a1
    mv a2, s0                      # Charger l'adresse de base de l'image dans a2
    jal I_coordToAdresse           # Convertir les coordonnees (10,5) en adresse memoire
    mv s1, a0                      # Sauvegarder l'adresse du pixel rouge dans s1
    li t0, 0x00FF0000              # Charger la couleur rouge au format RGB
    sw t0, 0(s1)                   # Ecrire le rouge dans la memoire du pixel (10,5)

    # ---------- Convertir l'adresse en coordonnees ----------

    mv a0, s1                      # a0 recoit l'adresse du pixel rouge
    mv a1, s0                      # a1 recoit l'adresse de base de l'image
    jal I_adresseToCoord           # Convertir l'adresse du pixel en (x,y)
    mv s2, a0                      # Sauvegarder la coordonnee x dans s2
    mv s3, a1                      # Sauvegarder la coordonnee y dans s3

    # ---------- Afficher le titre dans la console ----------

    la a0, p2_title                # Charger l'adresse du titre
    li a7, 4                       # Service 4 : afficher une chaine de caracteres
    ecall                          # Afficher le titre

    # ---------- Afficher le message de conversion ----------

    la a0, p2_msg1                 # Charger l'adresse du message
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    # ---------- Afficher la coordonnee x ----------

    mv a0, s2                      # Placer x dans a0
    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher x dans la console

    # ---------- Afficher une virgule ----------

    la a0, p2_comma                # Charger l'adresse de la chaine ", "
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher la virgule et l'espace

    # ---------- Afficher la coordonnee y ----------

    mv a0, s3                      # Placer y dans a0
    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher y dans la console

    # ---------- Colorier le pixel (11,5) en bleu ----------

    lw t0, largeur_img             # Charger la largeur de l'image dans t0
    li t1, 5                       # Charger y = 5 dans t1
    mul a0, t1, t0                 # Calculer y * largeur
    addi a0, a0, 11                # Ajouter x = 11 pour obtenir l'indice du pixel
    li a1, 0x000000FF              # Charger la couleur bleue au format RGB
    mv a2, s0                      # Charger l'adresse de base de l'image
    jal I_plot                     # Colorier le pixel d'indice a0 en bleu

    # ---------- Afficher le message final ----------

    la a0, p2_msg2                 # Charger l'adresse du message final
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message final

    # ---------- Fin du programme ----------

    li a7, 10                      # Service 10 : terminer le programme
    ecall                          # Arreter l'execution


# ============================================================
# FONCTIONS DE LA PARTIE 2
# ============================================================

.data                              # Section des donnees

# Dimensions globales de l'image
largeur_img: .word 64              # Largeur de l'image = 64 units
hauteur_img: .word 64              # Hauteur de l'image = 64 units

.text                              # Section des instructions


# ============================================================
# I_creer
#
# Entree : aucune
# Sortie : a0 = adresse de base de l'image
# Preserve : a7
#
# Objectif : allouer un espace memoire pour l'image
# Chaque pixel occupe 4 octets
# ============================================================

I_creer:                           # Debut de la fonction

    # ---------- Prologue ----------

    addi sp, sp, -16               # Reserver 16 octets dans la pile
    sw a7, 0(sp)                   # Sauvegarder la valeur initiale de a7

    # ---------- Calculer la taille de l'image ----------

    lw t0, largeur_img             # Charger la largeur de l'image dans t0
    lw t1, hauteur_img             # Charger la hauteur de l'image dans t1
    mul t2, t0, t1                 # Calculer le nombre total de pixels
    slli a0, t2, 2                 # Multiplier le nombre de pixels par 4 octets

    # ---------- Allouer la memoire ----------

    li a7, 9                       # Service 9 : allocation dynamique sbrk
    ecall                          # Allouer a0 octets ; retourner l'adresse dans a0

    # ---------- Epilogue ----------

    lw a7, 0(sp)                   # Restaurer la valeur initiale de a7
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner l'adresse du debut de l'image dans a0


# ============================================================
# I_coordToAdresse
#
# Entrees :
# a0 = x, abscisse du pixel
# a1 = y, ordonnee du pixel
# a2 = adresse de base de l'image
#
# Sortie : a0 = adresse memoire du pixel (x,y)
#
# Formule :
# adresse = base + (y * largeur + x) * 4
# ============================================================

I_coordToAdresse:                  # Debut de la fonction

    lw t0, largeur_img             # Charger la largeur de l'image
    mul t1, a1, t0                 # Calculer y * largeur
    add t1, t1, a0                 # Ajouter x pour obtenir l'indice du pixel
    slli t1, t1, 2                 # Multiplier l'indice par 4 octets
    add a0, a2, t1                 # Ajouter le decalage a l'adresse de base
    ret                            # Retourner l'adresse memoire du pixel dans a0


# ============================================================
# I_adresseToCoord
#
# Entrees :
# a0 = adresse memoire du pixel
# a1 = adresse de base de l'image
#
# Sorties :
# a0 = x, abscisse
# a1 = y, ordonnee
#
# Formules :
# indice = (adresse - base) / 4
# x = indice % largeur
# y = indice / largeur
# ============================================================

I_adresseToCoord:                  # Debut de la fonction

    sub t0, a0, a1                 # Calculer le decalage en octets depuis la base
    srli t0, t0, 2                 # Diviser le decalage par 4 pour obtenir l'indice
    lw t1, largeur_img             # Charger la largeur de l'image
    rem a0, t0, t1                 # Calculer x avec le reste de la division
    div a1, t0, t1                 # Calculer y avec le quotient entier
    ret                            # Retourner les coordonnees (x,y)


# ============================================================
# I_plot
#
# Entrees :
# a0 = indice du pixel P
# a1 = couleur du pixel
# a2 = adresse de base de l'image
#
# Sortie : aucune
#
# Objectif : modifier la couleur d'un pixel
# Formule : adresse = base + indice * 4
# ============================================================

I_plot:                            # Debut de la fonction

    slli t0, a0, 2                 # Convertir l'indice en decalage de 4 octets
    add t0, a2, t0                 # Calculer l'adresse memoire du pixel
    sw a1, 0(t0)                   # Ecrire la couleur dans la memoire image
    ret                            # Retourner a la fonction appelante


# ============================================================
# CHOIX DE REPRESENTATION D'UN PIXEL
#
# I_plot utilise l'indice du pixel comme argument.
# I_coordToAdresse calcule son adresse memoire.
# I_adresseToCoord retrouve ses coordonnees.
# Chaque pixel occupe 4 octets en memoire.
# ============================================================
