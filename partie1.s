# ============================================================
# PARTIE 1 - PROGRAMME RARS RV32
# ============================================================

.data                              # Section des donnees
espace: .asciz " "                # Chaine contenant un espace

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    li a0, 42                # Valeur a afficher en decimal
    jal ra, printInt         # Tester printInt
    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Passer a la ligne

    li a0, 17                # Valeur a afficher avec un espace
    jal ra, printIntEsp      # Tester printIntEsp
    li a0, 0x1234ABCD        # Valeur a afficher en hexadecimal
    jal ra, printHex         # Tester printHex

    li a0, 9                 # Borne maximale du tirage
    jal ra, auHasard         # Tirer une valeur entre 0 et 9
    li a7, 1                 # Service d'affichage d'un entier
    ecall                    # Afficher la valeur tiree
    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION printInt
# Entree(s) : a0 = entier
# Objectif : Affiche un entier decimal
# ============================================================

printInt:

# printInt

    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a7, 0(sp)                      # Sauvegarder a7 dans 0(sp)

    # Afficher l'entier en decimal
    li a7, 1                          # Service 1 : afficher un entier
    ecall                             # Executer le service RARS selectionne dans a7

    # ===== Epilogue =====
    # Restaurer a7 et liberer la pile
    lw a7, 0(sp)                      # Charger dans a7 la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp

    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION printIntEsp
# Entree(s) : a0 = entier
# Objectif : Affiche un entier et un espace
# ============================================================

printIntEsp:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # sauvegarde de l'adresse de retour (on appelle printInt)
    sw   a0, 4(sp)                    # sauvegarde de a0
    sw   a7, 8(sp)                    # Sauvegarder a7

    jal  printInt                     # affiche l'entier en decimal

    la   a0, espace                   # Charger l'adresse de espace dans a0
    li   a7, 4                        # ecall 4 : print string
    ecall                             # Executer le service RARS selectionne dans a7

    # ===== Epilogue =====
    lw   a7, 8(sp)                    # restauration de a7
    lw   a0, 4(sp)                    # restauration de a0
    lw   ra, 0(sp)                    # restauration de ra
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION printHex
# Entree(s) : a0 = entier
# Objectif : Affiche un entier hexadecimal et un espace
# ============================================================

printHex:

    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a0, 0(sp)                    # sauvegarde de a0 (sera modifie pour afficher l'espace)
    sw   a7, 4(sp)                    # sauvegarde de a7

    li   a7, 34                       # ecall 34 : print integer in hexadecimal
    ecall                             # Executer le service RARS selectionne dans a7

    la   a0, espace                   # Charger l'adresse de la chaine espace
    li   a7, 4                        # Service 4 : afficher une chaine
    ecall                             # Executer le service RARS selectionne dans a7

    # ===== Epilogue =====
    lw   a7, 4(sp)                    # restauration de a7
    lw   a0, 0(sp)                    # restauration de a0
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION auHasard
# Entree(s) : a0 = borne maximale incluse
# Objectif : Retourne un entier aleatoire dans a0
# ============================================================

auHasard:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a1, 0(sp)                    # sauvegarde de a1
    sw   a7, 4(sp)                    # sauvegarde de a7

    addi a1, a0, 1                    # a1 = borne haute EXCLUE (a0 + 1)
    li   a0, 0                        # a0 = id du generateur
    li   a7, 42                       # ecall 42 : RandIntRange -> a0 dans [0, a1)
    ecall                             # a0 = resultat

    # ===== Epilogue =====
    lw   a7, 4(sp)                    # restauration de a7
    lw   a1, 0(sp)                    # restauration de a1
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
