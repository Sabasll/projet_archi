# ============================================================
# PARTIE 4 - les bits 
# ============================================================

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    li a0, 13                # Entier de depart
    li a1, 2                 # Numero du bit a lire
    jal ra, B_getBit         # Lire le bit 2 de 13
    li a7, 1                 # Service d'affichage d'un entier
    ecall                    # Afficher 1
    li a0, 10                # Retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Afficher le retour a la ligne

    li a0, 13                # Entier de depart
    li a1, 1                 # Numero du bit a modifier
    li a2, 1                 # Nouvelle valeur du bit
    jal ra, B_setBit         # Mettre le bit 1 a 1
    li a7, 1                 # Service d'affichage d'un entier
    ecall                    # Afficher 15
    li a0, 10                # Retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Afficher le retour a la ligne

    li a0, 276               # Valeur binaire a afficher
    jal ra, B_print          # Afficher ses 32 bits
    li a0, 10                # Retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Afficher le retour a la ligne

    li a0, 0x12345678        # Entier de depart
    li a1, 1                 # Numero de l'octet a lire
    jal ra, B_getByte        # Lire l'octet 1
    li a7, 1                 # Service d'affichage d'un entier
    ecall                    # Afficher 86
    li a0, 10                # Retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Afficher le retour a la ligne

    li a0, 0x12345678        # Entier de depart
    li a1, 1                 # Numero de l'octet a modifier
    li a2, 255               # Nouvelle valeur de l'octet
    jal ra, B_setByte        # Remplacer l'octet 1
    li a7, 34                # Service d'affichage hexadecimal
    ecall                    # Afficher 0x1234FF78
    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION B_getBit
# Entree(s) : a0 = entier, a1 = indice bit
# Objectif : Retourne le bit (0 ou 1)
# ============================================================

B_getBit:
    srl  t0, a0, a1                   # t0 = a0 >> a1 (le bit voulu devient le bit 0)
    andi a0, t0, 1                    # a0 = t0 & 1 (on garde seulement ce bit)
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION B_setBit
# Entree(s) : a0 = entier, a1 = indice bit, a2 = valeur
# Objectif : Modifie le bit, resultat dans a0
# ============================================================

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
# FONCTION B_print
# Entree(s) : a0 = entier
# Objectif : Affiche les 32 bits de gauche a droite
# ============================================================

B_print:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a0, 0(sp)                    # sauvegarde de a0
    sw   a7, 4(sp)                    # sauvegarde de a7

    mv   t0, a0                       # t0 = l'entier a afficher
    li   t1, 31                       # t1 = numero du bit courant (on commence par 31)

B_print_boucle:
    srl  t2, t0, t1                   # t2 = t0 >> t1
    andi a0, t2, 1                    # a0 = bit numero t1
    li   a7, 1                        # ecall 1 : print integer
    ecall                             # Executer le service RARS selectionne dans a7

    andi t2, t1, 7                    # t2 = t1 % 8
    bnez t2, B_print_suite            # pas la fin d'un octet -> pas d'espace
    beqz t1, B_print_suite            # dernier bit (bit 0) -> pas d'espace final
    li   a0, 32                       # a0 = code ASCII de l'espace
    li   a7, 11                       # ecall 11 : print char
    ecall                             # Executer le service RARS selectionne dans a7

B_print_suite:
    addi t1, t1, -1                   # bit suivant (vers le poids faible)
    bgez t1, B_print_boucle           # tant que t1 >= 0, on continue

    lw   a7, 4(sp)                    # restauration de a7
    lw   a0, 0(sp)                    # restauration de a0
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION B_getByte
# Entree(s) : a0 = entier, a1 = indice octet
# Objectif : Retourne un octet dans a0
# ============================================================

B_getByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    srl  t0, a0, t0                   # t0 = a0 >> (a1 * 8)
    andi a0, t0, 255                  # a0 = t0 & 0xFF (on garde 8 bits)
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION B_setByte
# Entree(s) : a0 = entier, a1 = indice octet, a2 = valeur
# Objectif : Modifie un octet, resultat dans a0
# ============================================================

B_setByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    li   t1, 255                      # t1 = 0xFF
    sll  t1, t1, t0                   # t1 = 0xFF << decalage (masque de l'octet)
    not  t1, t1                       # t1 = ~masque
    and  a0, a0, t1                   # a0 = a0 avec l'octet a1 mis a 0
    sll  t2, a2, t0                   # t2 = a2 << decalage (nouvelle valeur a sa place)
    or   a0, a0, t2                   # a0 = a0 | t2
    ret                               # Retourner a la fonction appelante
