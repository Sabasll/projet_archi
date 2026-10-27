# ============================================================
# PARTIE 3 - PROGRAMME RARS RV32
# ============================================================

.data                              # Section des donnees
msgVide:   .asciz "Erreur : la pile est vide\n"     # Message en cas de pile vide
msgPleine: .asciz "Erreur : la pile est pleine\n" # Message en cas de pile pleine
espace: .asciz " "                # Dependence de printIntEsp

.text                              # Section des instructions
.globl main                        # Rendre main accessible

# ============================================================
# MAIN DE TEST
# ============================================================
main:
    li a0, 3                 # Capacite maximale de la pile
    jal ra, P_creer          # Creer une pile vide
    mv s0, a0                # Conserver l'adresse de la pile

    mv a0, s0                # Charger l'adresse de la pile
    li a1, 10                # Premier entier
    jal ra, P_empiler        # Empiler 10
    mv a0, s0                # Charger l'adresse de la pile
    li a1, 20                # Deuxieme entier
    jal ra, P_empiler        # Empiler 20
    mv a0, s0                # Charger l'adresse de la pile
    li a1, 30                # Troisieme entier
    jal ra, P_empiler        # Empiler 30

    mv a0, s0                # Charger l'adresse de la pile
    jal ra, P_print          # Afficher 10 20 30
    li a0, 10                # Code ASCII du retour a la ligne
    li a7, 11                # Service d'affichage d'un caractere
    ecall                    # Passer a la ligne

    mv a0, s0                # Charger l'adresse de la pile
    jal ra, P_depiler        # Retirer 30
    mv a0, s0                # Charger l'adresse de la pile
    jal ra, P_print          # Afficher 10 20

    li a7, 10                # Service de fin de programme
    ecall                    # Terminer le programme

# ============================================================
# FONCTION P_creer
# Entree(s) : a0 = capacite
# Objectif : Cree la pile, retourne son adresse dans a0
# ============================================================

P_creer:
    # ===== Prologue =====
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   a7, 0(sp)                    # sauvegarde de a7

    mv   t0, a0                       # t0 = capacite (a0 va etre ecrase par l'ecall)
    addi t1, a0, 2                    # t1 = capacite + 2 (2 mots de gestion)
    slli a0, t1, 2                    # a0 = nombre d'octets = (capacite + 2) * 4
    li   a7, 9                        # ecall 9 : sbrk (allocation dans le tas)
    ecall                             # a0 = adresse de la plage allouee

    sw   t0, 0(a0)                    # pile[0] = capacite
    sw   zero, 4(a0)                  # pile[1] = taille = 0 (pile vide)

    # ===== Epilogue =====
    lw   a7, 0(sp)                    # restauration de a7
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# FONCTION P_estVide
# Entree(s) : a0 = adresse pile
# Objectif : Retourne 1 si vide, sinon 0
# ============================================================

P_estVide:
    lw   t0, 4(a0)                    # t0 = taille (nombre d'entiers actuel)
    beqz t0, P_estVide_oui            # si taille == 0 -> la pile est vide

    li a0, 0                          # taille != 0 -> pas vide, retourne 0
    ret                               # Retourner a la fonction appelante

P_estVide_oui:
    li a0, 1                          # taille == 0 -> vide, retourne 1
    ret                               # Retourner a la fonction appelante

#          (si pile vide : message d'erreur, a0 inchange)
# Adresse du sommet = pile + 8 + 4 * (taille - 1)
# Si vide : message d'erreur, a0 conserve

# ============================================================
# FONCTION P_sommet
# Entree(s) : a0 = adresse pile
# Objectif : Retourne la valeur du sommet sans depiler
# ============================================================

P_sommet:
    lw t0, 4(a0)                      # Nombre d'elements
    beqz t0, P_sommet_vide            # Si egal a zero, aller a P_sommet_vide
    addi t0, t0, -1                   # Indice du dernier element
    slli t0, t0, 2                    # Indice * 4
    add t0, a0, t0                    # Ajouter a0 et t0 ; resultat dans t0
    lw a0, 8(t0)                      # Lire l'element apres l'entete
    ret                               # Retourner a la fonction appelante

P_sommet_vide:
    la t0, msgVide                    # Charger l'adresse de msgVide dans t0
    j P_erreur                        # Aller a P_erreur

# Si pleine : message d'erreur, rien n'est ajoute

# ============================================================
# FONCTION P_empiler
# Entree(s) : a0 = adresse pile, a1 = valeur
# Objectif : Ajoute un element en sommet
# ============================================================

P_empiler:
    lw   t0, 0(a0)                    # t0 = capacite
    lw   t1, 4(a0)                    # t1 = taille

    bgeu t1, t0, P_empiler_pleine     # taille >= capacite

    slli t2, t1, 2                    # t2 = taille * 4
    add  t2, a0, t2                   # t2 = pile + taille * 4
    sw   a1, 8(t2)                    # element[taille] = a1

    addi t1, t1, 1                    # taille + 1
    sw   t1, 4(a0)                    # ecrit la nouvelle taille
    ret                               # Retourner a la fonction appelante

P_empiler_pleine:
    la   t0, msgPleine                # t0 = adresse du message
    j    P_erreur                     # P_erreur fait le ret a notre place

# Si vide : message d'erreur, sinon taille = taille - 1

# ============================================================
# FONCTION P_depiler
# Entree(s) : a0 = adresse pile
# Objectif : Retire l'element en sommet
# ============================================================

P_depiler:
    lw   t0, 4(a0)                    # t0 = taille
    beqz t0, P_depiler_vide           # taille == 0 -> vide

    addi t0, t0, -1                   # taille - 1
    sw   t0, 4(a0)                    # ecrit la nouvelle taille
    ret                               # Retourner a la fonction appelante

P_depiler_vide:
    la   t0, msgVide                  # t0 = adresse du message
    j    P_erreur                     # Aller a P_erreur

# Affiche les entiers du plus ancien au plus recent

# ============================================================
# FONCTION P_print
# Entree(s) : a0 = adresse pile
# Objectif : Affiche les elements dans l'ordre
# ============================================================

P_print:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   s0, 4(sp)                    # Sauvegarder s0 dans 4(sp)
    sw   s1, 8(sp)                    # Sauvegarder s1 dans 8(sp)
    sw   a0, 12(sp)                   # Sauvegarder a0 dans 12(sp)

    lw   s1, 4(a0)                    # s1 = nombre d'elements restants
    addi s0, a0, 8                    # s0 = adresse de l'element 0

P_print_boucle:
    beqz s1, P_print_fin              # plus d'elements -> fin
    lw   a0, 0(s0)                    # a0 = element courant
    jal  printIntEsp                  # affiche l'element + espace
    addi s0, s0, 4                    # element suivant
    addi s1, s1, -1                   # un de moins
    j    P_print_boucle               # Aller a P_print_boucle

P_print_fin:
    lw   a0, 12(sp)                   # Charger dans a0 la valeur situee a 12(sp)
    lw   s1, 8(sp)                    # Charger dans s1 la valeur situee a 8(sp)
    lw   s0, 4(sp)                    # Charger dans s0 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# Code commun aux cas d'erreur

# ============================================================
# FONCTION P_erreur
# Entree(s) : t0 = adresse du message
# Objectif : Affiche un message d'erreur
# ============================================================

P_erreur:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a0, 0(sp)                      # Sauvegarder a0 dans 0(sp)
    sw a7, 4(sp)                      # Sauvegarder a7 dans 4(sp)
    mv a0, t0                         # Copier t0 dans a0
    li a7, 4                          # Afficher une chaine
    ecall                             # Executer le service RARS selectionne dans a7
    lw a0, 0(sp)                      # Charger dans a0 la valeur situee a 0(sp)
    lw a7, 4(sp)                      # Charger dans a7 la valeur situee a 4(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante

# ============================================================
# DEPENDANCE REQUISE : printIntEsp (PARTIE 1)
# ============================================================

# FONCTION printInt : Affiche un entier decimal
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


# FONCTION printIntEsp : Affiche un entier et un espace
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

