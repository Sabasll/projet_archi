
# ============================================================
# PARTIE 4 : BITS ET OCTETS
# Programme de test autonome sous RARS RV32
# ============================================================

.data

p4_title: .asciz "Partie 4 : bits\n"                              # Titre du programme
p4_msg1: .asciz "B_getBit(13,2) -> attendu 1 : "                # Message pour B_getBit
p4_msg2: .asciz "\nB_setBit(13,1,1) -> attendu 15 : "           # Message pour B_setBit
p4_msg3: .asciz "\nB_print(276) -> "                            # Message pour B_print
p4_msg4: .asciz "\nB_getByte(0x12345678,1) -> attendu 86 : "    # Message pour B_getByte
p4_msg5: .asciz "\nB_setByte(0x12345678,1,255) -> attendu 0x1234ff78 : " # Message pour B_setByte
p4_nl: .asciz "\n"                                             # Retour a la ligne


.text
.globl main                                                     # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Tester les cinq fonctions de la partie 4
# ============================================================

main:

    # ===== Affichage du titre =====

    la a0, p4_title                # Charger l'adresse du titre
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le titre dans la console


    # ===== Test de B_getBit =====

    la a0, p4_msg1                 # Charger le message de B_getBit
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    li a0, 13                      # Charger l'entier 13 dans a0
    li a1, 2                       # Choisir le bit numero 2
    jal B_getBit                   # Recuperer la valeur du bit numero 2

    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher le resultat (1 attendu)


    # ===== Test de B_setBit =====

    la a0, p4_msg2                 # Charger le message de B_setBit
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    li a0, 13                      # Charger l'entier 13
    li a1, 1                       # Choisir le bit numero 1
    li a2, 1                       # Nouvelle valeur du bit = 1
    jal B_setBit                   # Mettre le bit numero 1 a 1

    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher le resultat (15 attendu)


    # ===== Test de B_print =====

    la a0, p4_msg3                 # Charger le message de B_print
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    li a0, 276                     # Charger l'entier 276 dans a0
    jal B_print                    # Afficher ses 32 bits en binaire


    # ===== Test de B_getByte =====

    la a0, p4_msg4                 # Charger le message de B_getByte
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    li a0, 0x12345678              # Charger un entier hexadecimal
    li a1, 1                       # Choisir l'octet numero 1
    jal B_getByte                  # Extraire la valeur de cet octet

    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher le resultat (86 attendu)


    # ===== Test de B_setByte =====

    la a0, p4_msg5                 # Charger le message de B_setByte
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    li a0, 0x12345678              # Charger l'entier hexadecimal initial
    li a1, 1                       # Choisir l'octet numero 1
    li a2, 255                     # Nouvelle valeur de l'octet = 255 (0xFF)
    jal B_setByte                  # Remplacer l'octet numero 1 par 0xFF

    li a7, 34                      # Service 34 : afficher un entier hexadecimal
    ecall                          # Afficher le resultat 0x1234ff78


    # ===== Retour a la ligne =====

    la a0, p4_nl                   # Charger l'adresse du retour a la ligne
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Passer a la ligne suivante


    # ===== Fin du programme =====

    li a7, 10                      # Service 10 : terminer le programme
    ecall                          # Arreter l'execution


# ============================================================
# FONCTION B_getBit
# Entrees : a0 = entier, a1 = numero du bit (0..31)
# Sortie : a0 = valeur du bit (0 ou 1)
# Objectif : recuperer un bit d'un entier
# ============================================================

B_getBit:

    # ===== Decalage vers la droite =====

    srl t0, a0, a1                 # Decaler l'entier de a1 bits vers la droite

    # ===== Extraction du bit =====

    andi a0, t0, 1                 # Garder uniquement le bit de poids faible

    ret                            # Retourner la valeur du bit dans a0


# ============================================================
# FONCTION B_setBit
# Entrees : a0 = entier, a1 = numero du bit, a2 = valeur
# Sortie : a0 = entier avec le bit modifie
# Objectif : mettre un bit a 0 ou a 1
# ============================================================

B_setBit:

    # ===== Creation du masque =====

    li t0, 1                       # Initialiser le masque avec la valeur 1
    sll t0, t0, a1                 # Decaler le 1 vers la position du bit choisi
    not t0, t0                     # Inverser le masque pour effacer ce bit

    # ===== Effacement du bit =====

    and a0, a0, t0                 # Mettre le bit choisi a 0

    # ===== Insertion de la nouvelle valeur =====

    sll t1, a2, a1                 # Decaler la nouvelle valeur a la bonne position
    or a0, a0, t1                  # Inserer la nouvelle valeur dans l'entier

    ret                            # Retourner l'entier modifie dans a0


# ============================================================
# FONCTION B_print
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0 et a7
# Objectif : afficher les 32 bits d'un entier en binaire
# ============================================================

B_print:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw a0, 0(sp)                   # Sauvegarder l'entier initial
    sw a7, 4(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Initialisation =====

    mv t0, a0                      # Conserver l'entier a afficher dans t0
    li t1, 31                      # Commencer par le bit numero 31


B_print_boucle:

    # ===== Extraction du bit courant =====

    srl t2, t0, t1                 # Decaler le bit courant vers la position 0
    andi a0, t2, 1                 # Extraire uniquement ce bit

    # ===== Affichage du bit =====

    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher le bit courant (0 ou 1)

    # ===== Verifier la fin d'un octet =====

    andi t2, t1, 7                 # Calculer le reste de t1 modulo 8
    bnez t2, B_print_suite         # Si ce n'est pas la fin d'un octet, continuer
    beqz t1, B_print_suite         # Ne pas ajouter d'espace apres le dernier bit

    # ===== Affichage d'un espace =====

    li a0, 32                      # Code ASCII 32 = espace
    li a7, 11                      # Service 11 : afficher un caractere
    ecall                          # Afficher un espace entre deux octets


B_print_suite:

    # ===== Passage au bit suivant =====

    addi t1, t1, -1                # Passer au bit de poids inferieur
    bgez t1, B_print_boucle        # Continuer tant que t1 est positif ou nul

    # ===== Epilogue =====

    lw a7, 4(sp)                   # Restaurer la valeur initiale de a7
    lw a0, 0(sp)                   # Restaurer la valeur initiale de a0
    addi sp, sp, 16                # Liberer les 16 octets reserves

    ret                            # Retourner a la fonction appelante


# ============================================================
# FONCTION B_getByte
# Entrees : a0 = entier, a1 = numero de l'octet (0..3)
# Sortie : a0 = valeur de l'octet (0..255)
# Objectif : extraire un octet d'un entier
# Octet 0 = octet de poids faible
# ============================================================

B_getByte:

    # ===== Calcul du decalage =====

    slli t0, a1, 3                 # Multiplier le numero d'octet par 8 bits

    # ===== Extraction de l'octet =====

    srl t0, a0, t0                 # Decaler l'octet choisi vers la droite
    andi a0, t0, 255               # Garder uniquement les 8 bits de l'octet

    ret                            # Retourner la valeur de l'octet dans a0


# ============================================================
# FONCTION B_setByte
# Entrees : a0 = entier, a1 = numero de l'octet, a2 = valeur
# Sortie : a0 = entier avec l'octet modifie
# Objectif : remplacer un octet d'un entier
# ============================================================

B_setByte:

    # ===== Calcul du decalage =====

    slli t0, a1, 3                 # Multiplier le numero d'octet par 8 bits

    # ===== Creation du masque =====

    li t1, 255                     # Charger 255 = 0xFF
    sll t1, t1, t0                 # Placer le masque sur l'octet choisi
    not t1, t1                     # Inverser le masque

    # ===== Effacement de l'ancien octet =====

    and a0, a0, t1                 # Mettre les 8 bits de l'octet choisi a 0

    # ===== Insertion du nouvel octet =====

    sll t2, a2, t0                 # Decaler la nouvelle valeur a la bonne position
    or a0, a0, t2                  # Inserer le nouvel octet dans l'entier

    ret                            # Retourner l'entier modifie dans a0
