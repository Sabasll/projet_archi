
# ============================================================
# PARTIE 4 : LES BITS
# ============================================================

.text
.globl main                  # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Tester les fonctions de manipulation des bits et octets
# ============================================================

main:

    # ===== Test de B_getBit =====

    li a0, 13                # Entier de depart = 13
    li a1, 2                 # Numero du bit a lire = 2
    jal ra, B_getBit         # Lire le bit 2 de 13

    li a7, 1                 # Service 1 : afficher un entier
    ecall                    # Afficher le resultat : 1

    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service 11 : afficher un caractere
    ecall                    # Passer a la ligne suivante


    # ===== Test de B_setBit =====

    li a0, 13                # Entier initial = 13
    li a1, 1                 # Numero du bit a modifier = 1
    li a2, 1                 # Nouvelle valeur du bit = 1
    jal ra, B_setBit         # Mettre le bit 1 a 1

    li a7, 1                 # Service 1 : afficher un entier
    ecall                    # Afficher le resultat : 15

    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service 11 : afficher un caractere
    ecall                    # Passer a la ligne suivante


    # ===== Test de B_print =====

    li a0, 276               # Entier a afficher en binaire
    jal ra, B_print          # Afficher les 32 bits de 276

    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service 11 : afficher un caractere
    ecall                    # Passer a la ligne suivante


    # ===== Test de B_getByte =====

    li a0, 0x12345678        # Entier hexadecimal initial
    li a1, 1                 # Numero de l'octet a lire = 1
    jal ra, B_getByte        # Extraire l'octet numero 1

    li a7, 1                 # Service 1 : afficher un entier decimal
    ecall                    # Afficher le resultat : 86

    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service 11 : afficher un caractere
    ecall                    # Passer a la ligne suivante


    # ===== Test de B_setByte =====

    li a0, 0x12345678        # Entier hexadecimal initial
    li a1, 1                 # Numero de l'octet a modifier = 1
    li a2, 255               # Nouvelle valeur = 255 (0xFF)
    jal ra, B_setByte        # Remplacer l'octet 1 par 0xFF

    li a7, 34                # Service 34 : afficher en hexadecimal
    ecall                    # Afficher le resultat : 0x1234ff78


    # ===== Fin du programme =====

    li a7, 10                # Service 10 : terminer le programme
    ecall                    # Arreter l'execution


# ============================================================
# FONCTION B_getBit
# Entrees : a0 = entier, a1 = numero du bit (0..31)
# Sortie : a0 = valeur du bit (0 ou 1)
# Objectif : lire un bit d'un entier
# ============================================================

B_getBit:

    srl t0, a0, a1           # Decaler le bit choisi vers la position 0
    andi a0, t0, 1           # Garder uniquement ce bit

    ret                      # Retourner la valeur du bit dans a0


# ============================================================
# FONCTION B_setBit
# Entrees : a0 = entier, a1 = numero du bit, a2 = valeur
# Sortie : a0 = entier modifie
# Objectif : mettre un bit a 0 ou a 1
# ============================================================

B_setBit:

    # ===== Creation du masque =====

    li t0, 1                 # Initialiser le masque avec 1
    sll t0, t0, a1           # Placer le 1 sur le bit choisi
    not t0, t0               # Inverser le masque pour effacer ce bit

    # ===== Modification du bit =====

    and a0, a0, t0           # Mettre le bit choisi a 0
    sll t1, a2, a1           # Placer la nouvelle valeur sur le bit choisi
    or a0, a0, t1            # Inserer la nouvelle valeur dans l'entier

    ret                      # Retourner l'entier modifie dans a0


# ============================================================
# FONCTION B_print
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0 et a7
# Objectif : afficher les 32 bits avec un espace par octet
# ============================================================

B_print:

    # ===== Prologue =====

    addi sp, sp, -16         # Reserver 16 octets sur la pile
    sw a0, 0(sp)             # Sauvegarder l'entier initial
    sw a7, 4(sp)             # Sauvegarder la valeur initiale de a7

    # ===== Initialisation =====

    mv t0, a0                # Conserver l'entier a afficher
    li t1, 31                # Commencer par le bit de poids fort


B_print_boucle:

    # ===== Affichage du bit courant =====

    srl t2, t0, t1           # Decaler le bit courant vers la position 0
    andi a0, t2, 1           # Extraire la valeur du bit (0 ou 1)

    li a7, 1                 # Service 1 : afficher un entier
    ecall                    # Afficher le bit courant

    # ===== Separation des octets =====

    andi t2, t1, 7           # Calculer le reste de t1 modulo 8
    bnez t2, B_print_suite   # Continuer si l'octet n'est pas termine
    beqz t1, B_print_suite   # Ne pas afficher d'espace apres le dernier bit

    li a0, 32                # Code ASCII 32 = espace
    li a7, 11                # Service 11 : afficher un caractere
    ecall                    # Afficher un espace entre deux octets


B_print_suite:

    addi t1, t1, -1          # Passer au bit suivant
    bgez t1, B_print_boucle  # Continuer jusqu'au bit numero 0

    # ===== Epilogue =====

    lw a7, 4(sp)             # Restaurer la valeur initiale de a7
    lw a0, 0(sp)             # Restaurer l'entier initial
    addi sp, sp, 16          # Liberer les 16 octets reserves

    ret                      # Retourner a la fonction appelante


# ============================================================
# FONCTION B_getByte
# Entrees : a0 = entier, a1 = numero de l'octet (0..3)
# Sortie : a0 = valeur de l'octet (0..255)
# Objectif : extraire un octet d'un entier
# ============================================================

B_getByte:

    slli t0, a1, 3           # Calculer le decalage : numero * 8 bits
    srl t0, a0, t0           # Placer l'octet choisi a droite
    andi a0, t0, 255         # Garder uniquement ses 8 bits

    ret                      # Retourner la valeur de l'octet dans a0


# ============================================================
# FONCTION B_setByte
# Entrees : a0 = entier, a1 = numero de l'octet, a2 = valeur
# Sortie : a0 = entier modifie
# Objectif : remplacer un octet d'un entier
# ============================================================

B_setByte:

    # ===== Calcul du decalage =====

    slli t0, a1, 3           # Calculer le decalage : numero * 8 bits

    # ===== Creation du masque =====

    li t1, 255               # Charger 0xFF, un octet avec 8 bits a 1
    sll t1, t1, t0           # Placer le masque sur l'octet choisi
    not t1, t1               # Inverser le masque pour effacer cet octet

    # ===== Modification de l'octet =====

    and a0, a0, t1           # Mettre l'ancien octet a 0
    sll t2, a2, t0           # Placer la nouvelle valeur a sa position
    or a0, a0, t2            # Inserer le nouvel octet dans l'entier

    ret                      # Retourner l'entier modifie dans a0
