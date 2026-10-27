
# ============================================================
# PARTIE 2 : IMAGE
# Programme de test autonome sous RARS RV32
# ============================================================

.data

p2_title: .asciz "Partie 2 : image\n"              # Titre du programme
p2_msg1: .asciz "I_coordToAdresse(10,5) et I_adresseToCoord : (x,y) = " # Message de conversion
p2_msg2: .asciz "\nDeux units colorees : rouge (10,5), bleu (11,5).\n" # Message final
p2_comma: .asciz ", "                              # Separateur entre x et y

largeur_img: .word 64                              # Largeur de l'image en units
hauteur_img: .word 64                              # Hauteur de l'image en units

.text
.globl main                                        # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Tester la creation de l'image, les conversions et I_plot
# ============================================================

main:

    # ===== Creation de l'image =====

    jal I_creer                    # Allouer la memoire de l'image
    mv s0, a0                      # Sauvegarder l'adresse de base dans s0

    # ===== Initialisation du fond noir =====

    lw t0, largeur_img             # Charger la largeur de l'image
    lw t1, hauteur_img             # Charger la hauteur de l'image
    mul t0, t0, t1                 # Calculer le nombre total de pixels
    mv t1, s0                      # t1 pointe vers le premier pixel

p2_clear:
    beqz t0, p2_clear_fin          # Terminer si tous les pixels sont traites
    sw zero, 0(t1)                 # Colorier le pixel courant en noir
    addi t1, t1, 4                 # Passer au pixel suivant
    addi t0, t0, -1                # Diminuer le nombre de pixels restants
    j p2_clear                     # Recommencer la boucle

p2_clear_fin:

    # ===== Test de I_coordToAdresse =====

    li a0, 10                      # Charger x = 10
    li a1, 5                       # Charger y = 5
    mv a2, s0                      # Adresse de base de l'image
    jal I_coordToAdresse           # Convertir (10,5) en adresse memoire

    mv s1, a0                      # Sauvegarder l'adresse du pixel
    li t0, 0x00FF0000              # Charger la couleur rouge
    sw t0, 0(s1)                   # Colorier le pixel en rouge

    # ===== Test de I_adresseToCoord =====

    mv a0, s1                      # Adresse du pixel rouge
    mv a1, s0                      # Adresse de base de l'image
    jal I_adresseToCoord           # Convertir l'adresse en coordonnees

    mv s2, a0                      # Sauvegarder x dans s2
    mv s3, a1                      # Sauvegarder y dans s3

    # ===== Affichage du titre =====

    la a0, p2_title                # Charger l'adresse du titre
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le titre

    # ===== Affichage des coordonnees =====

    la a0, p2_msg1                 # Charger le message de conversion
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s2                      # Charger x dans a0
    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher x

    la a0, p2_comma                # Charger le separateur
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher la virgule

    mv a0, s3                      # Charger y dans a0
    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher y

    # ===== Test de I_plot =====

    lw t0, largeur_img             # Charger la largeur de l'image
    li t1, 5                       # Charger y = 5
    mul a0, t1, t0                 # Calculer y * largeur
    addi a0, a0, 11                # Ajouter x = 11 pour obtenir l'indice 331

    li a1, 0x000000FF              # Charger la couleur bleue
    mv a2, s0                      # Adresse de base de l'image
    jal I_plot                     # Colorier le pixel (11,5) en bleu

    # ===== Affichage du message final =====

    la a0, p2_msg2                 # Charger le message final
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    # ===== Fin du programme =====

    li a7, 10                      # Service 10 : terminer le programme
    ecall                          # Arreter l'execution


# ============================================================
# FONCTION I_creer
# Entree : aucune
# Sortie : a0 = adresse de base de l'image
# Preserve : a7
# Objectif : allouer la memoire necessaire pour l'image
# ============================================================

I_creer:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw a7, 0(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Calcul de la taille =====

    lw t0, largeur_img             # Charger la largeur
    lw t1, hauteur_img             # Charger la hauteur
    mul t2, t0, t1                 # Calculer le nombre de pixels
    slli a0, t2, 2                 # Multiplier par 4 octets par pixel

    # ===== Allocation de memoire =====

    li a7, 9                       # Service 9 : allocation avec sbrk
    ecall                          # Allouer la memoire et retourner son adresse

    # ===== Epilogue =====

    lw a7, 0(sp)                   # Restaurer a7
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner l'adresse de l'image


# ============================================================
# FONCTION I_coordToAdresse
# Entrees : a0 = x, a1 = y, a2 = adresse de base
# Sortie : a0 = adresse du pixel (x,y)
# Formule : adresse = base + (y * largeur + x) * 4
# ============================================================

I_coordToAdresse:

    lw t0, largeur_img             # Charger la largeur de l'image
    mul t1, a1, t0                 # Calculer y * largeur
    add t1, t1, a0                 # Ajouter x pour obtenir l'indice
    slli t1, t1, 2                 # Convertir l'indice en octets
    add a0, a2, t1                 # Calculer l'adresse du pixel
    ret                            # Retourner l'adresse dans a0


# ============================================================
# FONCTION I_adresseToCoord
# Entrees : a0 = adresse du pixel, a1 = adresse de base
# Sorties : a0 = x, a1 = y
# Formules :
# indice = (adresse - base) / 4
# x = indice % largeur
# y = indice / largeur
# ============================================================

I_adresseToCoord:

    sub t0, a0, a1                 # Calculer le decalage depuis la base
    srli t0, t0, 2                 # Diviser par 4 pour obtenir l'indice
    lw t1, largeur_img             # Charger la largeur de l'image
    rem a0, t0, t1                 # Calculer x avec le reste
    div a1, t0, t1                 # Calculer y avec le quotient
    ret                            # Retourner les coordonnees


# ============================================================
# FONCTION I_plot
# Entrees : a0 = indice du pixel, a1 = couleur, a2 = base
# Sortie : aucune
# Objectif : modifier la couleur d'un pixel
# ============================================================

I_plot:

    slli t0, a0, 2                 # Multiplier l'indice par 4
    add t0, a2, t0                 # Calculer l'adresse du pixel
    sw a1, 0(t0)                   # Ecrire la couleur du pixel
    ret                            # Retourner a la fonction appelante


# ============================================================
# CHOIX DE REPRESENTATION D'UN PIXEL
# I_plot utilise l'indice du pixel comme argument.
# I_coordToAdresse calcule son adresse memoire.
# I_adresseToCoord retrouve les coordonnees.
# Chaque pixel occupe 4 octets en memoire.
# ============================================================
