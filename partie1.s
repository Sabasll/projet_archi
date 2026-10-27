
# PARTIE 1 - UTILITAIRES
# Programme de test autonome sous RARS RV32

.data

p1_title: .asciz "--- Partie 1 : utilitaires ---\n"  # Titre du programme
p1_msg1:  .asciz "printInt(42) = "                  # Message pour printInt
p1_msg2:  .asciz "printIntEsp(17) = "               # Message pour printIntEsp
p1_msg3:  .asciz "printHex(0x1234ABCD) = "         # Message pour printHex
p1_msg4:  .asciz "auHasard(9), entre 0 et 9 = "     # Message pour auHasard
p1_nl:    .asciz "\n"                              # Retour a la ligne
espace:   .asciz " "                               # Chaine contenant un espace

.text
.globl main                        # Declarer main comme point d'entree


# MAIN DE TEST
# Tester les quatre fonctions de la partie 1

main:

    # Affichage du titre
    la a0, p1_title               # Charger l'adresse du titre dans a0
    li a7, 4                      # Service 4 : afficher une chaine de caracteres
    ecall                         # Afficher le titre dans la console

    # Test de printInt
    la a0, p1_msg1                # Charger l'adresse du message de printInt
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher "printInt(42) = "

    li a0, 42                     # Placer l'entier 42 dans a0
    jal printInt                  # Appeler printInt pour afficher 42

    la a0, p1_nl                  # Charger l'adresse du retour a la ligne
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Passer a la ligne suivante

    # Test de printIntEsp
    la a0, p1_msg2                # Charger l'adresse du message de printIntEsp
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher "printIntEsp(17) = "

    li a0, 17                     # Placer l'entier 17 dans a0
    jal printIntEsp               # Appeler printIntEsp pour afficher 17 suivi d'un espace

    la a0, p1_nl                  # Charger l'adresse du retour a la ligne
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Passer a la ligne suivante

    # Test de printHex
    la a0, p1_msg3                # Charger l'adresse du message de printHex
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher le message hexadecimal

    li a0, 0x1234ABCD             # Placer une valeur hexadecimale dans a0
    jal printHex                  # Appeler printHex pour afficher cette valeur

    la a0, p1_nl                  # Charger l'adresse du retour a la ligne
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Passer a la ligne suivante

    # Test de auHasard
    la a0, p1_msg4                # Charger l'adresse du message du tirage aleatoire
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher le message avant le resultat

    li a0, 9                      # Fixer la borne maximale incluse a 9
    jal auHasard                  # Tirer un entier aleatoire entre 0 et 9

    li a7, 1                      # Service 1 : afficher un entier decimal
    ecall                         # Afficher le nombre aleatoire retourne dans a0

    la a0, p1_nl                  # Charger l'adresse du retour a la ligne
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Passer a la ligne suivante

    # Fin du programme
    li a7, 10                     # Service 10 : terminer le programme
    ecall                         # Arreter l'execution


# FONCTION printInt
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0 et a7
# Objectif : afficher un entier en base 10

printInt:

    # Prologue
    addi sp, sp, -16              # Reserver 16 octets sur la pile
    sw a7, 0(sp)                  # Sauvegarder la valeur initiale de a7

    # Affichage de l'entier
    li a7, 1                      # Service 1 : afficher un entier decimal
    ecall                         # Afficher la valeur contenue dans a0

    # Epilogue
    lw a7, 0(sp)                  # Restaurer la valeur initiale de a7
    addi sp, sp, 16               # Liberer les 16 octets reserves

    ret                           # Retourner a l'instruction suivant l'appel


# FONCTION printIntEsp
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0, a7 et ra
# Objectif : afficher un entier decimal suivi d'un espace

printIntEsp:

    # Prologue
    addi sp, sp, -16              # Reserver 16 octets sur la pile
    sw ra, 0(sp)                  # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                  # Sauvegarder l'entier initial
    sw a7, 8(sp)                  # Sauvegarder le numero de service initial

    # Affichage de l'entier
    jal printInt                  # Appeler printInt pour afficher a0 en decimal

    # Affichage de l'espace
    la a0, espace                 # Charger l'adresse de la chaine contenant un espace
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher un espace apres l'entier

    # Epilogue
    lw a7, 8(sp)                  # Restaurer la valeur initiale de a7
    lw a0, 4(sp)                  # Restaurer la valeur initiale de a0
    lw ra, 0(sp)                  # Restaurer l'adresse de retour
    addi sp, sp, 16               # Liberer les 16 octets reserves

    ret                           # Retourner a la fonction appelante


# FONCTION printHex
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0 et a7
# Objectif : afficher un entier en hexadecimal suivi d'un espace

printHex:

    # Prologue
    addi sp, sp, -16              # Reserver 16 octets sur la pile
    sw a0, 0(sp)                  # Sauvegarder l'entier a afficher
    sw a7, 4(sp)                  # Sauvegarder le numero de service initial

    # Affichage hexadecimal
    li a7, 34                     # Service 34 : afficher a0 en hexadecimal
    ecall                         # Afficher l'entier en base 16

    # Affichage de l'espace
    la a0, espace                 # Charger l'adresse de la chaine espace
    li a7, 4                      # Service 4 : afficher une chaine
    ecall                         # Afficher un espace apres l'entier

    # Epilogue
    lw a7, 4(sp)                  # Restaurer la valeur initiale de a7
    lw a0, 0(sp)                  # Restaurer la valeur initiale de a0
    addi sp, sp, 16               # Liberer les 16 octets reserves

    ret                           # Retourner a la fonction appelante


# FONCTION auHasard
# Entree : a0 = borne maximale incluse
# Sortie : a0 = entier aleatoire entre 0 et la borne
# Preserve : a1 et a7
# Objectif : tirer un entier aleatoire dans [0, a0]

auHasard:

    # Prologue
    addi sp, sp, -16              # Reserver 16 octets sur la pile
    sw a1, 0(sp)                  # Sauvegarder la valeur initiale de a1
    sw a7, 4(sp)                  # Sauvegarder le numero de service initial

    # Preparation du tirage
    addi a1, a0, 1                # Borne superieure exclue = borne maximale + 1
    li a0, 0                      # Selectionner le generateur aleatoire numero 0
    li a7, 42                     # Service 42 : nombre aleatoire dans [0, a1)
    ecall                         # Generer le nombre aleatoire et le placer dans a0

    # Epilogue
    lw a7, 4(sp)                  # Restaurer la valeur initiale de a7
    lw a1, 0(sp)                  # Restaurer la valeur initiale de a1
    addi sp, sp, 16               # Liberer les 16 octets reserves

    ret                           # Retourner le resultat aleatoire dans a0
