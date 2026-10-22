# TEST AUTONOME RARS RV32 (une seule partie par fichier)

# ===== MAIN DE TEST =====
.data
p1_title: .asciz "--- Partie 1 : utilitaires ---\n"
p1_msg1:  .asciz "printInt(42) = "
p1_msg2:  .asciz "printIntEsp(17) = "
p1_msg3:  .asciz "printHex(0x1234ABCD) = "
p1_msg4:  .asciz "auHasard(9), entre 0 et 9 = "
p1_nl:    .asciz "\n"

.text
.globl main
main:
    la a0, p1_title
    li a7, 4
    ecall

    la a0, p1_msg1
    li a7, 4
    ecall
    li a0, 42
    jal printInt
    la a0, p1_nl
    li a7, 4
    ecall

    la a0, p1_msg2
    li a7, 4
    ecall
    li a0, 17
    jal printIntEsp
    la a0, p1_nl
    li a7, 4
    ecall

    la a0, p1_msg3
    li a7, 4
    ecall
    li a0, 0x1234ABCD
    jal printHex
    la a0, p1_nl
    li a7, 4
    ecall

    la a0, p1_msg4
    li a7, 4
    ecall
    li a0, 9
    jal auHasard
    li a7, 1
    ecall
    la a0, p1_nl
    li a7, 4
    ecall

    li a7, 10
    ecall

# ===== FONCTIONS DE LA PARTIE =====
.data
espace: .asciz " "

.text
printInt:

# printInt
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve a0 et a7

    #prologue:
    addi sp, sp, -16
    sw a7, 0(sp)

    # Afficher l'entier en decimal
    li a7, 1
    ecall

    #epilogue: 
    # Restaurer a7 et liberer la pile
    lw a7, 0(sp)
    addi sp, sp, 16

    ret

printIntEsp:
    #prologue:
    addi sp, sp, -16      
    sw   ra, 0(sp)         # sauvegarde de l'adresse de retour (on appelle printInt)
    sw   a0, 4(sp)         # sauvegarde de a0
    sw   a7, 8(sp)         # sauvegarde de a0

    jal  printInt          # affiche l'entier en decimal

    la   a0, espace        # a0 = adresse de la chaine " " // code assci espace = 32
    li   a7, 4             # ecall 4 : print string
    ecall

    #epilogue: 
    lw   a7, 8(sp)         # restauration de a7
    lw   a0, 4(sp)         # restauration de a0
    lw   ra, 0(sp)         # restauration de ra
    addi sp, sp, 16
    ret
    
printHex:

    #prologue:
    addi sp, sp, -16
    sw   a0, 0(sp)         # sauvegarde de a0 (sera modifie pour afficher l'espace)
    sw   a7, 4(sp)         # sauvegarde de a7

    li   a7, 34            # ecall 34 : print integer in hexadecimal
    ecall

    la   a0, espace        # a0 = code ASCII de l'espace
    li   a7, 4            # ecall 11 : print char
    ecall

    #epilogue:
    lw   a7, 4(sp)         # restauration de a7
    lw   a0, 0(sp)         # restauration de a0
    addi sp, sp, 16
    ret

auHasard: 
    #prologue:
    addi sp, sp, -16
    sw   a1, 0(sp)         # sauvegarde de a1 
    sw   a7, 4(sp)         # sauvegarde de a7

    addi a1, a0, 1         # a1 = borne haute EXCLUE (a0 + 1)
    li   a0, 0             # a0 = id du generateur
    li   a7, 42            # ecall 42 : RandIntRange -> a0 dans [0, a1)
    ecall                  # a0 = resultat

    #epilogue:
    lw   a7, 4(sp)         # restauration de a7
    lw   a1, 0(sp)         # restauration de a1
    addi sp, sp, 16
    ret
