# TEST AUTONOME RARS RV32 (une seule partie par fichier)

# ===== MAIN DE TEST =====
.data
p4_title: .asciz "--- Partie 4 : bits ---\n"
p4_msg1: .asciz "B_getBit(13,2) -> attendu 1 : "
p4_msg2: .asciz "\nB_setBit(13,1,1) -> attendu 15 : "
p4_msg3: .asciz "\nB_print(276) -> "
p4_msg4: .asciz "\nB_getByte(0x12345678,1) -> attendu 86 : "
p4_msg5: .asciz "\nB_setByte(0x12345678,1,255) -> attendu 0x1234ff78 : "
p4_nl: .asciz "\n"

.text
.globl main
main:
    la a0, p4_title
    li a7, 4
    ecall

    la a0, p4_msg1
    li a7, 4
    ecall
    li a0, 13
    li a1, 2
    jal B_getBit
    li a7, 1
    ecall

    la a0, p4_msg2
    li a7, 4
    ecall
    li a0, 13
    li a1, 1
    li a2, 1
    jal B_setBit
    li a7, 1
    ecall

    la a0, p4_msg3
    li a7, 4
    ecall
    li a0, 276
    jal B_print

    la a0, p4_msg4
    li a7, 4
    ecall
    li a0, 0x12345678
    li a1, 1
    jal B_getByte
    li a7, 1
    ecall

    la a0, p4_msg5
    li a7, 4
    ecall
    li a0, 0x12345678
    li a1, 1
    li a2, 255
    jal B_setByte
    li a7, 34
    ecall

    la a0, p4_nl
    li a7, 4
    ecall
    li a7, 10
    ecall

# ===== FONCTIONS DE LA PARTIE =====
.text
# B_getBit
# Entree : a0 = entier, a1 = numero du bit (0..31)
# Sortie : a0 = valeur du bit (0 ou 1)
B_getBit:
    srl  t0, a0, a1            # t0 = a0 >> a1 (le bit voulu devient le bit 0)
    andi a0, t0, 1             # a0 = t0 & 1 (on garde seulement ce bit)
    ret

# B_setBit
# Entree : a0 = entier, a1 = numero du bit (0..31), a2 = valeur (0 ou 1)
# Sortie : a0 = a0 avec le bit a1 egal a a2
B_setBit:
    li   t0, 1
    sll  t0, t0, a1            # t0 = 1 << a1 (masque : un seul bit a 1)
    not  t0, t0                # t0 = ~masque (tous les bits a 1 sauf le bit a1)
    and  a0, a0, t0            # a0 = a0 avec le bit a1 mis a 0
    sll  t1, a2, a1            # t1 = a2 << a1 (la nouvelle valeur a sa place)
    or   a0, a0, t1            # a0 = a0 | t1 : le bit a1 vaut maintenant a2
    ret

# B_print
# Entree : a0 = entier quelconque
# Sortie : aucune
# Affiche les 32 bits (poids fort d'abord), un espace entre chaque octet
# Preserve a0, a7
B_print:
    addi sp, sp, -16
    sw   a0, 0(sp)             # sauvegarde de a0
    sw   a7, 4(sp)             # sauvegarde de a7

    mv   t0, a0                # t0 = l'entier a afficher
    li   t1, 31                # t1 = numero du bit courant (on commence par 31)

B_print_boucle:
    srl  t2, t0, t1            # t2 = t0 >> t1
    andi a0, t2, 1             # a0 = bit numero t1
    li   a7, 1                 # ecall 1 : print integer
    ecall

    andi t2, t1, 7             # t2 = t1 % 8
    bnez t2, B_print_suite     # pas la fin d'un octet -> pas d'espace
    beqz t1, B_print_suite     # dernier bit (bit 0) -> pas d'espace final
    li   a0, 32            # a0 = code ASCII de l'espace
    li   a7, 11                # ecall 11 : print char
    ecall

B_print_suite:
    addi t1, t1, -1            # bit suivant (vers le poids faible)
    bgez t1, B_print_boucle    # tant que t1 >= 0, on continue

    lw   a7, 4(sp)             # restauration de a7
    lw   a0, 0(sp)             # restauration de a0
    addi sp, sp, 16
    ret

# B_getByte
# Entree : a0 = entier, a1 = numero de l'octet (0..3, 0 = poids faible)
# Sortie : a0 = valeur de l'octet (0..255)
B_getByte:
    slli t0, a1, 3             # t0 = a1 * 8 (decalage en bits)
    srl  t0, a0, t0            # t0 = a0 >> (a1 * 8)
    andi a0, t0, 255           # a0 = t0 & 0xFF (on garde 8 bits)
    ret

# B_setByte
# Entree : a0 = entier, a1 = numero de l'octet (0..3), a2 = valeur (0..255)
# Sortie : a0 = a0 avec l'octet a1 egal a a2
B_setByte:
    slli t0, a1, 3             # t0 = a1 * 8 (decalage en bits)
    li   t1, 255               # t1 = 0xFF
    sll  t1, t1, t0            # t1 = 0xFF << decalage (masque de l'octet)
    not  t1, t1                # t1 = ~masque
    and  a0, a0, t1            # a0 = a0 avec l'octet a1 mis a 0
    sll  t2, a2, t0            # t2 = a2 << decalage (nouvelle valeur a sa place)
    or   a0, a0, t2            # a0 = a0 | t2
    ret
