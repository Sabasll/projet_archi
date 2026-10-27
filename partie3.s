
# ============================================================
# PARTIE 3 : PILE
# Programme de test autonome sous RARS RV32
# ============================================================

.data

p3_title: .asciz "Partie 3 : pile\n"                         # Titre du programme
p3_msg1: .asciz "P_estVide apres creation (attendu 1) = "    # Message du premier test
p3_msg2: .asciz "\nP_print apres empiler 10,20,30 (attendu 10 20 30) = " # Message apres empiler
p3_msg3: .asciz "\nP_sommet (attendu 30) = "                 # Message pour tester le sommet
p3_msg4: .asciz "\nP_print apres depiler (attendu 10 20) = " # Message apres depiler
p3_msg5: .asciz "\nP_estVide apres 3 depilements (attendu 1) = " # Message pour tester pile vide
p3_msg6: .asciz "\nTest d'erreur (depiler pile vide) : "    # Message du test d'erreur

msgVide:   .asciz "Erreur : la pile est vide\n"            # Message d'erreur si pile vide
msgPleine: .asciz "Erreur : la pile est pleine\n"          # Message d'erreur si pile pleine


.text
.globl main                                                 # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Tester la creation, l'empilement, le depilement et l'affichage
# ============================================================

main:

    # ===== Affichage du titre =====

    la a0, p3_title                # Charger l'adresse du titre
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le titre dans la console


    # ===== Creation de la pile =====

    li a0, 3                       # Capacite maximale de la pile = 3 entiers
    jal P_creer                    # Creer une pile avec une capacite de 3

    mv s0, a0                      # Sauvegarder l'adresse de la pile dans s0


    # ===== Test de P_estVide apres creation =====

    la a0, p3_msg1                 # Charger le premier message
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile dans a0
    jal P_estVide                  # Verifier si la pile est vide

    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher le resultat (1 attendu)


    # ===== Test de P_empiler =====

    mv a0, s0                      # Adresse de la pile
    li a1, 10                      # Premier entier a empiler = 10
    jal P_empiler                  # Ajouter 10 dans la pile

    mv a0, s0                      # Adresse de la pile
    li a1, 20                      # Deuxieme entier a empiler = 20
    jal P_empiler                  # Ajouter 20 dans la pile

    mv a0, s0                      # Adresse de la pile
    li a1, 30                      # Troisieme entier a empiler = 30
    jal P_empiler                  # Ajouter 30 dans la pile


    # ===== Test de P_print =====

    la a0, p3_msg2                 # Charger le message apres empilement
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_print                    # Afficher les elements : 10 20 30


    # ===== Test de P_sommet =====

    la a0, p3_msg3                 # Charger le message du sommet
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_sommet                   # Recuperer le dernier element empile

    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher la valeur du sommet (30 attendu)


    # ===== Test de P_depiler =====

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_depiler                  # Retirer le sommet de la pile (30)

    la a0, p3_msg4                 # Charger le message apres depilement
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_print                    # Afficher les elements restants : 10 20


    # ===== Vider completement la pile =====

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_depiler                  # Retirer 20 de la pile

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_depiler                  # Retirer 10 de la pile


    # ===== Test de P_estVide apres depilements =====

    la a0, p3_msg5                 # Charger le message pour la pile vide
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile
    jal P_estVide                  # Verifier si la pile est vide

    li a7, 1                       # Service 1 : afficher un entier
    ecall                          # Afficher le resultat (1 attendu)


    # ===== Test d'erreur sur une pile vide =====

    la a0, p3_msg6                 # Charger le message du test d'erreur
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message

    mv a0, s0                      # Charger l'adresse de la pile vide
    jal P_depiler                  # Tenter de depiler une pile vide
                                  # Afficher un message d'erreur


    # ===== Fin du programme =====

    li a7, 10                      # Service 10 : terminer le programme
    ecall                          # Arreter l'execution


# ============================================================
# FONCTION printIntEsp
# Fonction auxiliaire necessaire pour P_print
# Entree : a0 = entier a afficher
# Sortie : aucune
# Preserve : a0 et a7
# Objectif : afficher un entier suivi d'un espace
# ============================================================

printIntEsp:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw a0, 0(sp)                   # Sauvegarder l'entier a afficher
    sw a7, 4(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Affichage de l'entier =====

    li a7, 1                       # Service 1 : afficher un entier decimal
    ecall                          # Afficher la valeur contenue dans a0

    # ===== Affichage de l'espace =====

    li a0, 32                      # Code ASCII 32 = espace
    li a7, 11                      # Service 11 : afficher un caractere
    ecall                          # Afficher un espace apres l'entier

    # ===== Epilogue =====

    lw a7, 4(sp)                   # Restaurer la valeur initiale de a7
    lw a0, 0(sp)                   # Restaurer la valeur initiale de a0
    addi sp, sp, 16                # Liberer les 16 octets reserves

    ret                            # Retourner a la fonction appelante


# ============================================================
# STRUCTURE DE LA PILE EN MEMOIRE
#
# Adresse pile + 0 : capacite maximale
# Adresse pile + 4 : taille actuelle
# Adresse pile + 8 : element 0
# Adresse pile + 12 : element 1
# Adresse pile + 8 + 4*i : element i
# ============================================================


# ============================================================
# FONCTION P_creer
# Entree : a0 = capacite maximale
# Sortie : a0 = adresse de la pile
# Preserve : a7
# Objectif : creer une pile vide dans le tas
# ============================================================

P_creer:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw a7, 0(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Calcul de la taille =====

    mv t0, a0                      # Sauvegarder la capacite dans t0
    addi t1, a0, 2                 # Ajouter 2 mots pour capacite et taille
    slli a0, t1, 2                 # Multiplier par 4 pour obtenir le nombre d'octets

    # ===== Allocation de memoire =====

    li a7, 9                       # Service 9 : allocation dynamique avec sbrk
    ecall                          # Allouer la memoire et retourner son adresse dans a0

    # ===== Initialisation de la pile =====

    sw t0, 0(a0)                   # Stocker la capacite maximale
    sw zero, 4(a0)                 # Initialiser la taille a 0 (pile vide)

    # ===== Epilogue =====

    lw a7, 0(sp)                   # Restaurer la valeur initiale de a7
    addi sp, sp, 16                # Liberer les 16 octets reserves

    ret                            # Retourner l'adresse de la pile dans a0


# ============================================================
# FONCTION P_estVide
# Entree : a0 = adresse de la pile
# Sortie : a0 = 1 si vide, 0 sinon
# Objectif : verifier si la pile est vide
# ============================================================

P_estVide:

    lw t0, 4(a0)                   # Charger la taille actuelle de la pile
    beqz t0, P_estVide_oui         # Si taille = 0, la pile est vide

    li a0, 0                       # La pile n'est pas vide : resultat = 0
    ret                            # Retourner 0

P_estVide_oui:

    li a0, 1                       # La pile est vide : resultat = 1
    ret                            # Retourner 1


# ============================================================
# FONCTION P_sommet
# Entree : a0 = adresse de la pile
# Sortie : a0 = valeur du dernier element
# Si vide : afficher un message d'erreur
# Objectif : lire le sommet sans le retirer
# ============================================================

P_sommet:

    # ===== Verifier la taille =====

    lw t0, 4(a0)                   # Charger le nombre d'elements
    beqz t0, P_sommet_vide         # Si taille = 0, afficher une erreur

    # ===== Calculer l'adresse du sommet =====

    addi t0, t0, -1                # Indice du dernier element = taille - 1
    slli t0, t0, 2                 # Multiplier l'indice par 4 octets
    add t0, a0, t0                 # Ajouter le decalage a l'adresse de la pile
    lw a0, 8(t0)                   # Lire l'element apres l'entete de 8 octets

    ret                            # Retourner la valeur du sommet dans a0

P_sommet_vide:

    la t0, msgVide                 # Charger l'adresse du message pile vide
    j P_erreur                     # Afficher l'erreur et retourner


# ============================================================
# FONCTION P_empiler
# Entrees : a0 = adresse de la pile, a1 = entier a ajouter
# Sortie : aucune
# Preserve : a0 et a1
# Objectif : ajouter un element au sommet de la pile
# ============================================================

P_empiler:

    # ===== Verifier la capacite =====

    lw t0, 0(a0)                   # Charger la capacite maximale
    lw t1, 4(a0)                   # Charger la taille actuelle

    bgeu t1, t0, P_empiler_pleine  # Si taille >= capacite, la pile est pleine

    # ===== Calculer l'adresse du nouvel element =====

    slli t2, t1, 2                 # Calculer taille * 4 octets
    add t2, a0, t2                 # Ajouter le decalage a l'adresse de la pile
    sw a1, 8(t2)                   # Stocker le nouvel element apres l'entete

    # ===== Mettre a jour la taille =====

    addi t1, t1, 1                 # Augmenter la taille de 1
    sw t1, 4(a0)                   # Enregistrer la nouvelle taille

    ret                            # Retourner a la fonction appelante

P_empiler_pleine:

    la t0, msgPleine               # Charger le message pile pleine
    j P_erreur                     # Afficher l'erreur et retourner


# ============================================================
# FONCTION P_depiler
# Entree : a0 = adresse de la pile
# Sortie : aucune
# Preserve : a0
# Objectif : retirer l'element au sommet de la pile
# ============================================================

P_depiler:

    # ===== Verifier si la pile est vide =====

    lw t0, 4(a0)                   # Charger la taille actuelle
    beqz t0, P_depiler_vide        # Si taille = 0, afficher une erreur

    # ===== Retirer le dernier element =====

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
# Preserve : a0, s0, s1 et ra
# Objectif : afficher les elements du plus ancien au plus recent
# ============================================================

P_print:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw ra, 0(sp)                   # Sauvegarder l'adresse de retour
    sw s0, 4(sp)                   # Sauvegarder s0
    sw s1, 8(sp)                   # Sauvegarder s1
    sw a0, 12(sp)                  # Sauvegarder l'adresse de la pile

    # ===== Initialisation de l'affichage =====

    lw s1, 4(a0)                   # Charger le nombre d'elements a afficher
    addi s0, a0, 8                 # Pointer vers le premier element de la pile

P_print_boucle:

    beqz s1, P_print_fin           # Terminer si tous les elements sont affiches
    lw a0, 0(s0)                   # Charger la valeur de l'element courant
    jal printIntEsp                # Afficher l'entier suivi d'un espace
    addi s0, s0, 4                 # Passer a l'element suivant
    addi s1, s1, -1                # Diminuer le nombre d'elements restants
    j P_print_boucle               # Continuer l'affichage

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
# Preserve : a0 et a7
# Objectif : afficher un message d'erreur commun
# ============================================================

P_erreur:

    # ===== Prologue =====

    addi sp, sp, -16               # Reserver 16 octets sur la pile
    sw a0, 0(sp)                   # Sauvegarder la valeur initiale de a0
    sw a7, 4(sp)                   # Sauvegarder la valeur initiale de a7

    # ===== Affichage de l'erreur =====

    mv a0, t0                      # Charger l'adresse du message dans a0
    li a7, 4                       # Service 4 : afficher une chaine
    ecall                          # Afficher le message d'erreur

    # ===== Epilogue =====

    lw a0, 0(sp)                   # Restaurer la valeur initiale de a0
    lw a7, 4(sp)                   # Restaurer la valeur initiale de a7
    addi sp, sp, 16                # Liberer les 16 octets reserves

    ret                            # Retourner a la fonction appelante
