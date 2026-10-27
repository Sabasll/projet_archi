# ============================================================
# PARTIE 3 : LES PILES
# ============================================================

.data

msgVide:   .asciz "Erreur : la pile est vide\n"    # Message si la pile est vide
msgPleine: .asciz "Erreur : la pile est pleine\n"  # Message si la pile est pleine

.text
.globl main                                        # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Creer une pile, empiler, afficher et depiler
# ============================================================

main:

    # ===== Creation de la pile =====

    li a0, 3                       # Capacite maximale de la pile = 3
    jal ra, P_creer                # Creer une pile vide
    mv s0, a0                      # Conserver l'adresse de la pile

    # ===== Empiler les entiers =====

    mv a0, s0                      # Charger l'adresse de la pile
    li a1, 10                      # Valeur du premier element
    jal ra, P_empiler              # Empiler 10

    mv a0, s0                      # Charger l'adresse de la pile
    li a1, 20                      # Valeur du deuxieme element
    jal ra, P_empiler              # Empiler 20

    mv a0, s0                      # Charger l'adresse de la pile
    li a1, 30                      # Valeur du troisieme element
    jal ra, P_empiler              # Empiler 30

    # ===== Affichage de la pile =====

    mv a0, s0                      # Charger l'adresse de la pile
    jal ra, P_print                # Afficher les elements : 10 20 30

    li a0, 10                      # Code ASCII du retour a la ligne
    li a7, 11                      # Service 11 : afficher un caractere
    ecall                          # Passer a la ligne suivante

    # ===== Depiler un element =====

    mv a0, s0                      # Charger l'adresse de la pile
    jal ra, P_depiler              # Retirer le dernier element : 30

    # ===== Affichage apres depilement =====

    mv a0, s0                      # Charger l'adresse de la pile
    jal ra, P_print                # Afficher les elements restants : 10 20

    # ===== Fin du programme =====

    li a7, 10                      # Service 10 : terminer le programme
    ecall                          # Arreter l'execution


# ============================================================
# FONCTION P_creer
# Entree : a0 = capacite maximale
# Sortie : a0 = adresse de la pile
# Objectif : creer une pile vide dans le tas
# ============================================================

P_creer:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile systeme
    sw a7, 0(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Calcul de la taille =====

    mv t0, a0                      # Conserver la capacite dans t0
    addi t1, a0, 2                 # Ajouter 2 mots pour capacite et taille
    slli a0, t1, 2                 # Calculer le nombre d'octets necessaires

    # ===== Allocation de memoire =====

    li a7, 9                       # Service 9 : allocation avec sbrk
    ecall                          # Allouer la memoire et retourner son adresse

    # ===== Initialisation =====

    sw t0, 0(a0)                   # Enregistrer la capacite maximale
    sw zero, 4(a0)                 # Initialiser la taille de la pile a 0

    # ===== Epilogue =====

    lw a7, 0(sp)                   # Restaurer a7
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner l'adresse de la pile


# ============================================================
# FONCTION P_estVide
# Entree : a0 = adresse de la pile
# Sortie : a0 = 1 si vide, 0 sinon
# Objectif : verifier si la pile est vide
# ============================================================

P_estVide:

    lw t0, 4(a0)                   # Charger la taille actuelle
    beqz t0, P_estVide_oui         # Si taille = 0, la pile est vide

    li a0, 0                       # Retourner 0 si la pile n'est pas vide
    ret                            # Retourner a la fonction appelante

P_estVide_oui:

    li a0, 1                       # Retourner 1 si la pile est vide
    ret                            # Retourner a la fonction appelante


# ============================================================
# FONCTION P_sommet
# Entree : a0 = adresse de la pile
# Sortie : a0 = valeur du sommet
# Objectif : lire le dernier element sans le retirer
# ============================================================

P_sommet:

    # ===== Verification de la pile =====

    lw t0, 4(a0)                   # Charger le nombre d'elements
    beqz t0, P_sommet_vide         # Afficher une erreur si la pile est vide

    # ===== Calcul de l'adresse du sommet =====

    addi t0, t0, -1                # Calculer l'indice du dernier element
    slli t0, t0, 2                 # Multiplier cet indice par 4 octets
    add t0, a0, t0                 # Ajouter le decalage a l'adresse de la pile
    lw a0, 8(t0)                   # Lire le dernier element apres l'entete

    ret                            # Retourner la valeur du sommet

P_sommet_vide:

    la t0, msgVide                 # Charger l'adresse du message d'erreur
    j P_erreur                     # Afficher l'erreur et retourner


# ============================================================
# FONCTION P_empiler
# Entrees : a0 = adresse de la pile, a1 = entier
# Sortie : aucune
# Objectif : ajouter un element au sommet de la pile
# ============================================================

P_empiler:

    # ===== Verification de la capacite =====

    lw t0, 0(a0)                   # Charger la capacite maximale
    lw t1, 4(a0)                   # Charger la taille actuelle
    bgeu t1, t0, P_empiler_pleine  # Si taille >= capacite, la pile est pleine

    # ===== Ajout du nouvel element =====

    slli t2, t1, 2                 # Calculer taille * 4 octets
    add t2, a0, t2                 # Calculer le decalage depuis la base
    sw a1, 8(t2)                   # Ecrire le nouvel element apres l'entete

    # ===== Mise a jour de la taille =====

    addi t1, t1, 1                 # Augmenter la taille de 1
    sw t1, 4(a0)                   # Enregistrer la nouvelle taille
    ret                            # Retourner a la fonction appelante

P_empiler_pleine:

    la t0, msgPleine               # Charger l'adresse du message pile pleine
    j P_erreur                     # Afficher l'erreur et retourner


# ============================================================
# FONCTION P_depiler
# Entree : a0 = adresse de la pile
# Sortie : aucune
# Objectif : retirer le dernier element de la pile
# ============================================================

P_depiler:

    # ===== Verification de la pile =====

    lw t0, 4(a0)                   # Charger la taille actuelle
    beqz t0, P_depiler_vide        # Afficher une erreur si la pile est vide

    # ===== Retrait du sommet =====

    addi t0, t0, -1                # Diminuer la taille de 1
    sw t0, 4(a0)                   # Enregistrer la nouvelle taille
    ret                            # Retourner a la fonction appelante

P_depiler_vide:

    la t0, msgVide                 # Charger le message pile vide
    j P_erreur                     # Afficher l'erreur et retourner


# ============================================================
# FONCTION P_print
# Entree : a0 = adresse de la pile
# Sortie : aucune
# Objectif : afficher les elements du plus ancien au plus recent
# ============================================================

P_print:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile systeme
    sw ra, 0(sp)                   # Sauvegarder l'adresse de retour
    sw s0, 4(sp)                   # Sauvegarder s0
    sw s1, 8(sp)                   # Sauvegarder s1
    sw a0, 12(sp)                  # Sauvegarder l'adresse de la pile

    # ===== Preparation de l'affichage =====

    lw s1, 4(a0)                   # Nombre d'elements a afficher
    addi s0, a0, 8                 # Adresse du premier element

P_print_boucle:

    beqz s1, P_print_fin           # Terminer si tous les elements sont affiches
    lw a0, 0(s0)                   # Charger l'element courant dans a0
    jal ra, printIntEsp            # Afficher l'entier suivi d'un espace
    addi s0, s0, 4                 # Passer a l'element suivant
    addi s1, s1, -1                # Diminuer le nombre d'elements restants
    j P_print_boucle               # Continuer la boucle

P_print_fin:

    # ===== Epilogue =====

    lw a0, 12(sp)                  # Restaurer l'adresse initiale de la pile
    lw s1, 8(sp)                   # Restaurer s1
    lw s0, 4(sp)                   # Restaurer s0
    lw ra, 0(sp)                   # Restaurer l'adresse de retour
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner a la fonction appelante


# ============================================================
# FONCTION P_erreur
# Entree : t0 = adresse du message d'erreur
# Sortie : aucune
# Objectif : afficher une erreur de pile vide ou pleine
# ============================================================

P_erreur:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile systeme
    sw a0, 0(sp)                   # Sauvegarder a0
    sw a7, 4(sp)                   # Sauvegarder a7

    # ===== Affichage du message =====

    mv a0, t0                      # Charger l'adresse du message dans a0
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message d'erreur

    # ===== Epilogue =====

    lw a0, 0(sp)                   # Restaurer a0
    lw a7, 4(sp)                   # Restaurer a7
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner a la fonction appelante


# ============================================================
# FONCTION printIntEsp
# Fonction auxiliaire utilisee par P_print
# Entree : a0 = entier a afficher
# Sortie : aucune
# Objectif : afficher un entier suivi d'un espace
# ============================================================

printIntEsp:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile systeme
    sw a0, 0(sp)                   # Sauvegarder l'entier initial
    sw a7, 4(sp)                   # Sauvegarder a7

    # ===== Affichage de l'entier =====

    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher l'entier contenu dans a0

    # ===== Affichage de l'espace =====

    li a0, 32                      # Code ASCII 32 : espace
    li a7, 11                      # Service 11 : afficher un caractere
    ecall                          # Afficher un espace

    # ===== Epilogue =====

    lw a7, 4(sp)                   # Restaurer a7
    lw a0, 0(sp)                   # Restaurer l'entier initial
    addi sp, sp, 16                # Liberer les 16 octets reserves
    ret                            # Retourner a la fonction appelante
