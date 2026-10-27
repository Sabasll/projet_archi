
# ============================================================
# PARTIE 5 : LES CELLULES DU LABYRINTHE
# ============================================================

.data

adresse_image: .word 0              # Adresse de base de l'image

.text
.globl main                         # Declarer main comme point d'entree


# ============================================================
# MAIN DE TEST
# Creer un labyrinthe et afficher deux cellules voisines
# ============================================================

main:

    # ===== Creation de l'image =====

    jal ra, I_creer                  # Allouer la memoire pour une image de 64 x 64 pixels
    la t0, adresse_image             # Charger l'adresse de la variable adresse_image
    sw a0, 0(t0)                     # Memoriser l'adresse de base de l'image

    # ===== Creation du labyrinthe =====

    jal ra, L_creer                  # Creer un labyrinthe de 21 x 21 cellules
    mv s0, a0                        # Conserver l'adresse du labyrinthe dans s0

    # ===== Casser le mur droit de la cellule 0 =====

    li a0, 0                         # Indice de la premiere cellule
    li a1, 1                         # Direction droite
    mv a2, s0                        # Charger l'adresse du labyrinthe
    jal ra, L_casserMur              # Supprimer le mur droit de la cellule 0

    # ===== Casser le mur gauche de la cellule 1 =====

    li a0, 1                         # Indice de la cellule voisine
    li a1, 3                         # Direction gauche
    mv a2, s0                        # Charger l'adresse du labyrinthe
    jal ra, L_casserMur              # Supprimer le mur gauche de la cellule 1

    # ===== Afficher la cellule 0 en rouge =====

    li a0, 0                         # Indice de la premiere cellule
    li a1, 0x00FF0000                # Couleur rouge au format RGB
    mv a2, s0                        # Charger l'adresse du labyrinthe
    jal ra, L_afficherCellule        # Dessiner la cellule 0 et son passage

    # ===== Afficher la cellule 1 en vert =====

    li a0, 1                         # Indice de la deuxieme cellule
    li a1, 0x0000FF00                # Couleur verte au format RGB
    mv a2, s0                        # Charger l'adresse du labyrinthe
    jal ra, L_afficherCellule        # Dessiner la cellule 1 et son passage

    # ===== Fin du programme =====

    li a7, 10                        # Service 10 : terminer le programme
    ecall                            # Arreter l'execution


# ============================================================
# FONCTION L_creer
# Entree : aucune
# Sortie : a0 = adresse du labyrinthe
# Objectif : creer un labyrinthe avec tous les murs fermes
# ============================================================

L_creer:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw a7, 0(sp)                     # Sauvegarder la valeur initiale de a7

    # ===== Calcul des dimensions =====

    lw t0, largeur_img               # Charger la largeur de l'image
    lw t1, hauteur_img               # Charger la hauteur de l'image
    li t2, 3                         # Les centres des cellules sont espaces de 3 pixels

    divu t0, t0, t2                  # Calculer le nombre de colonnes
    divu t1, t1, t2                  # Calculer le nombre de lignes

    # ===== Calcul de la memoire necessaire =====

    mul t3, t0, t1                   # Calculer le nombre total de cellules
    slli a0, t3, 2                   # Multiplier par 4 octets par cellule
    addi a0, a0, 8                   # Ajouter 8 octets pour les dimensions

    # ===== Allocation de memoire =====

    li a7, 9                         # Service 9 : allocation avec sbrk
    ecall                            # Allouer la memoire dans le tas

    # ===== Stockage des dimensions =====

    sw t0, 0(a0)                     # Stocker le nombre de colonnes
    sw t1, 4(a0)                     # Stocker le nombre de lignes

    # ===== Initialisation des cellules =====

    addi t4, a0, 8                   # Pointer vers la premiere cellule
    li t5, 15                        # Initialiser les quatre bits des murs a 1

L_creer_boucle:

    beqz t3, L_creer_fin             # Terminer si toutes les cellules sont initialisees
    sw t5, 0(t4)                     # Fermer les quatre murs de la cellule
    addi t4, t4, 4                   # Passer a la cellule suivante
    addi t3, t3, -1                  # Diminuer le nombre de cellules restantes
    j L_creer_boucle                 # Recommencer l'initialisation

L_creer_fin:

    # ===== Epilogue =====

    lw a7, 0(sp)                     # Restaurer la valeur initiale de a7
    addi sp, sp, 16                  # Liberer les 16 octets reserves
    ret                              # Retourner l'adresse du labyrinthe


# ============================================================
# FONCTION L_indiceToCoords
# Entrees : a0 = indice, a1 = adresse du labyrinthe
# Sorties : a0 = x, a1 = y
# Objectif : convertir un indice en coordonnees
# ============================================================

L_indiceToCoords:

    lw t0, 0(a1)                     # Charger le nombre de colonnes
    remu t1, a0, t0                  # Calculer x = indice modulo colonnes
    divu t2, a0, t0                  # Calculer y = indice divise par colonnes
    mv a0, t1                        # Retourner x dans a0
    mv a1, t2                        # Retourner y dans a1
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_coordsToIndice
# Entrees : a0 = x, a1 = y, a2 = adresse du labyrinthe
# Sortie : a0 = indice
# Objectif : convertir les coordonnees en indice
# ============================================================

L_coordsToIndice:

    lw t0, 0(a2)                     # Charger le nombre de colonnes
    mul t1, a1, t0                   # Calculer y * colonnes
    add a0, t1, a0                   # Ajouter x pour obtenir l'indice
    ret                              # Retourner l'indice dans a0


# ============================================================
# FONCTION L_aUnMur
# Entrees : a0 = indice, a1 = direction, a2 = labyrinthe
# Sortie : a0 = 1 si le mur existe, 0 sinon
# Directions : 0 haut, 1 droite, 2 bas, 3 gauche
# ============================================================

L_aUnMur:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour

    # ===== Lire la cellule =====

    slli t0, a0, 2                   # Calculer indice * 4 octets
    add t0, a2, t0                   # Ajouter le decalage a la base du labyrinthe
    lw a0, 8(t0)                     # Charger les bits de la cellule

    # ===== Tester le mur =====

    jal ra, B_getBit                 # Lire le bit correspondant a la direction

    # ===== Epilogue =====

    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer les 16 octets reserves
    ret                              # Retourner 1 ou 0 dans a0


# ============================================================
# FONCTION L_casserMur
# Entrees : a0 = indice, a1 = direction, a2 = labyrinthe
# Sortie : aucune
# Objectif : supprimer un mur d'une cellule
# ============================================================

L_casserMur:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                     # Sauvegarder l'indice de la cellule
    sw a2, 8(sp)                     # Sauvegarder l'adresse du labyrinthe

    # ===== Lire les bits de la cellule =====

    slli t0, a0, 2                   # Calculer le decalage indice * 4
    add t0, a2, t0                   # Calculer l'adresse de la cellule
    lw a0, 8(t0)                     # Charger la valeur de la cellule

    # ===== Effacer le bit du mur =====

    li a2, 0                         # Choisir la valeur 0 pour le bit
    jal ra, B_setBit                 # Mettre a 0 le bit du mur indique par a1

    # ===== Enregistrer la cellule modifiee =====

    lw t1, 4(sp)                     # Recuperer l'indice de la cellule
    lw t2, 8(sp)                     # Recuperer l'adresse du labyrinthe
    slli t1, t1, 2                   # Convertir l'indice en decalage
    add t1, t2, t1                   # Calculer l'adresse de la cellule
    sw a0, 8(t1)                     # Enregistrer les bits modifies

    # ===== Epilogue =====

    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    lw a0, 4(sp)                     # Restaurer l'indice initial
    lw a2, 8(sp)                     # Restaurer l'adresse du labyrinthe
    addi sp, sp, 16                  # Liberer les 16 octets reserves
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_estDepart
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : a0 = valeur du bit 4
# Objectif : savoir si la cellule est le depart
# ============================================================

L_estDepart:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a1, 4(sp)                     # Sauvegarder l'adresse du labyrinthe

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger les bits de la cellule
    li a1, 4                         # Choisir le bit 4 : depart
    jal ra, B_getBit                 # Lire la valeur du bit depart

    lw a1, 4(sp)                     # Restaurer l'adresse du labyrinthe
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner le resultat dans a0


# ============================================================
# FONCTION L_estArrivee
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : a0 = valeur du bit 5
# Objectif : savoir si la cellule est l'arrivee
# ============================================================

L_estArrivee:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a1, 4(sp)                     # Sauvegarder l'adresse du labyrinthe

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger les bits de la cellule
    li a1, 5                         # Choisir le bit 5 : arrivee
    jal ra, B_getBit                 # Lire la valeur du bit arrivee

    lw a1, 4(sp)                     # Restaurer l'adresse du labyrinthe
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner le resultat dans a0


# ============================================================
# FONCTION L_estVisitee
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : a0 = valeur du bit 6
# Objectif : savoir si la cellule a deja ete visitee
# ============================================================

L_estVisitee:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a1, 4(sp)                     # Sauvegarder l'adresse du labyrinthe

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger les bits de la cellule
    li a1, 6                         # Choisir le bit 6 : visitee
    jal ra, B_getBit                 # Lire le bit visitee

    lw a1, 4(sp)                     # Restaurer l'adresse du labyrinthe
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner le resultat dans a0


# ============================================================
# FONCTION L_estSolution
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : a0 = valeur du bit 7
# Objectif : savoir si la cellule appartient a la solution
# ============================================================

L_estSolution:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a1, 4(sp)                     # Sauvegarder l'adresse du labyrinthe

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger les bits de la cellule
    li a1, 7                         # Choisir le bit 7 : solution
    jal ra, B_getBit                 # Lire le bit solution

    lw a1, 4(sp)                     # Restaurer l'adresse du labyrinthe
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner le resultat dans a0


# ============================================================
# FONCTION L_defDepart
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : aucune
# Objectif : activer le bit 4 : depart
# ============================================================

L_defDepart:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                     # Sauvegarder l'indice de la cellule
    sw a1, 8(sp)                     # Sauvegarder la base du labyrinthe
    sw a2, 12(sp)                    # Sauvegarder a2

    # ===== Lire et modifier la cellule =====

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger les bits de la cellule
    li a1, 4                         # Choisir le bit 4 : depart
    li a2, 1                         # Choisir la nouvelle valeur 1
    jal ra, B_setBit                 # Activer le bit depart

    # ===== Enregistrer la modification =====

    lw t0, 4(sp)                     # Recuperer l'indice de la cellule
    lw t1, 8(sp)                     # Recuperer la base du labyrinthe
    slli t0, t0, 2                   # Convertir l'indice en octets
    add t0, t1, t0                   # Localiser la cellule
    sw a0, 8(t0)                     # Enregistrer la cellule modifiee

    # ===== Epilogue =====

    lw a0, 4(sp)                     # Restaurer l'indice initial
    lw a1, 8(sp)                     # Restaurer la base du labyrinthe
    lw a2, 12(sp)                    # Restaurer a2
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_defArrivee
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : aucune
# Objectif : activer le bit 5 : arrivee
# ============================================================

L_defArrivee:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                     # Sauvegarder l'indice de la cellule
    sw a1, 8(sp)                     # Sauvegarder l'adresse du labyrinthe
    sw a2, 12(sp)                    # Sauvegarder a2

    # ===== Activer le bit arrivee =====

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger la valeur de la cellule
    li a1, 5                         # Choisir le bit 5 : arrivee
    li a2, 1                         # Choisir la nouvelle valeur 1
    jal ra, B_setBit                 # Activer le bit arrivee

    # ===== Enregistrer la modification =====

    lw t0, 4(sp)                     # Recuperer l'indice de la cellule
    lw t1, 8(sp)                     # Recuperer la base du labyrinthe
    slli t0, t0, 2                   # Convertir l'indice en octets
    add t0, t1, t0                   # Localiser la cellule
    sw a0, 8(t0)                     # Enregistrer la cellule modifiee

    # ===== Epilogue =====

    lw a0, 4(sp)                     # Restaurer l'indice initial
    lw a1, 8(sp)                     # Restaurer la base du labyrinthe
    lw a2, 12(sp)                    # Restaurer a2
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_defVisitee
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : aucune
# Objectif : activer le bit 6 : visitee
# ============================================================

L_defVisitee:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                     # Sauvegarder l'indice de la cellule
    sw a1, 8(sp)                     # Sauvegarder l'adresse du labyrinthe
    sw a2, 12(sp)                    # Sauvegarder a2

    # ===== Activer le bit visitee =====

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger la valeur de la cellule
    li a1, 6                         # Choisir le bit 6 : visitee
    li a2, 1                         # Choisir la nouvelle valeur 1
    jal ra, B_setBit                 # Activer le bit visitee

    # ===== Enregistrer la modification =====

    lw t0, 4(sp)                     # Recuperer l'indice de la cellule
    lw t1, 8(sp)                     # Recuperer la base du labyrinthe
    slli t0, t0, 2                   # Convertir l'indice en octets
    add t0, t1, t0                   # Localiser la cellule
    sw a0, 8(t0)                     # Enregistrer la cellule modifiee

    # ===== Epilogue =====

    lw a0, 4(sp)                     # Restaurer l'indice initial
    lw a1, 8(sp)                     # Restaurer la base du labyrinthe
    lw a2, 12(sp)                    # Restaurer a2
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_defSolution
# Entrees : a0 = indice, a1 = labyrinthe
# Sortie : aucune
# Objectif : activer le bit 7 : solution
# ============================================================

L_defSolution:

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw a0, 4(sp)                     # Sauvegarder l'indice de la cellule
    sw a1, 8(sp)                     # Sauvegarder l'adresse du labyrinthe
    sw a2, 12(sp)                    # Sauvegarder a2

    # ===== Activer le bit solution =====

    slli t0, a0, 2                   # Calculer indice * 4
    add t0, a1, t0                   # Localiser la cellule
    lw a0, 8(t0)                     # Charger la valeur de la cellule
    li a1, 7                         # Choisir le bit 7 : solution
    li a2, 1                         # Choisir la nouvelle valeur 1
    jal ra, B_setBit                 # Activer le bit solution

    # ===== Enregistrer la modification =====

    lw t0, 4(sp)                     # Recuperer l'indice de la cellule
    lw t1, 8(sp)                     # Recuperer la base du labyrinthe
    slli t0, t0, 2                   # Convertir l'indice en octets
    add t0, t1, t0                   # Localiser la cellule
    sw a0, 8(t0)                     # Enregistrer la cellule modifiee

    # ===== Epilogue =====

    lw a0, 4(sp)                     # Restaurer l'indice initial
    lw a1, 8(sp)                     # Restaurer la base du labyrinthe
    lw a2, 12(sp)                    # Restaurer a2
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer la pile
    ret                              # Retourner a la fonction appelante


# ============================================================
# FONCTION L_estDedans
# Entrees : a0 = x, a1 = y, a2 = labyrinthe
# Sortie : a0 = 1 si dedans, 0 sinon
# Objectif : verifier les limites du labyrinthe
# ============================================================

L_estDedans:

    blt a0, zero, L_estDedans_non     # Refuser une coordonnee x negative
    blt a1, zero, L_estDedans_non     # Refuser une coordonnee y negative

    lw t0, 0(a2)                     # Charger le nombre de colonnes
    lw t1, 4(a2)                     # Charger le nombre de lignes

    bge a0, t0, L_estDedans_non       # Refuser x si x >= colonnes
    bge a1, t1, L_estDedans_non       # Refuser y si y >= lignes

    li a0, 1                         # Les coordonnees sont dans le labyrinthe
    ret                              # Retourner 1

L_estDedans_non:

    li a0, 0                         # Les coordonnees sont hors du labyrinthe
    ret                              # Retourner 0


# ============================================================
# FONCTION L_voisinDir
# Entrees : a0 = x, a1 = y, a2 = direction
# Sorties : a0 = x du voisin, a1 = y du voisin
# Objectif : calculer les coordonnees d'une cellule voisine
# ============================================================

L_voisinDir:

    beqz a2, L_voisin_haut           # Direction 0 : aller vers le haut

    li t0, 1                         # Direction droite = 1
    beq a2, t0, L_voisin_droite       # Aller a droite si direction = 1

    li t0, 2                         # Direction bas = 2
    beq a2, t0, L_voisin_bas          # Aller en bas si direction = 2

    li t0, 3                         # Direction gauche = 3
    beq a2, t0, L_voisin_gauche       # Aller a gauche si direction = 3

    ret                              # Ne rien modifier si direction invalide

L_voisin_haut:

    addi a1, a1, -1                  # Diminuer y de 1
    ret                              # Retourner les nouvelles coordonnees

L_voisin_droite:

    addi a0, a0, 1                   # Augmenter x de 1
    ret                              # Retourner les nouvelles coordonnees

L_voisin_bas:

    addi a1, a1, 1                   # Augmenter y de 1
    ret                              # Retourner les nouvelles coordonnees

L_voisin_gauche:

    addi a0, a0, -1                  # Diminuer x de 1
    ret                              # Retourner les nouvelles coordonnees


# ============================================================
# FONCTION L_posCelluleImage
# Entrees : a0 = indice, a1 = labyrinthe
# Sorties : a0 = x_image, a1 = y_image
# Objectif : trouver le centre d'une cellule dans l'image
# ============================================================

L_posCelluleImage:

    # ===== Prologue =====

    addi sp, sp, -16                 # Reserver 16 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour

    # ===== Conversion de l'indice =====

    jal ra, L_indiceToCoords         # Obtenir les coordonnees de la cellule

    # ===== Calcul du centre =====

    li t0, 3                         # Les centres sont espaces de 3 pixels

    mul a0, a0, t0                   # Calculer 3 * x
    addi a0, a0, 1                   # Centre horizontal = 3*x + 1

    mul a1, a1, t0                   # Calculer 3 * y
    addi a1, a1, 1                   # Centre vertical = 3*y + 1

    # ===== Epilogue =====

    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 16                  # Liberer les 16 octets reserves
    ret                              # Retourner les coordonnees du centre


# ============================================================
# FONCTION L_afficherCellule
# Entrees : a0 = indice, a1 = couleur, a2 = labyrinthe
# Sortie : aucune
# Objectif : dessiner le centre et les passages ouverts
# ============================================================

L_afficherCellule:

    # ===== Prologue =====

    addi sp, sp, -48                 # Reserver 48 octets sur la pile
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw s0, 4(sp)                     # Sauvegarder s0
    sw s1, 8(sp)                     # Sauvegarder s1
    sw s2, 12(sp)                    # Sauvegarder s2
    sw s3, 16(sp)                    # Sauvegarder s3
    sw s4, 20(sp)                    # Sauvegarder s4
    sw s5, 24(sp)                    # Sauvegarder s5
    sw a7, 28(sp)                    # Sauvegarder a7

    # ===== Conserver les arguments =====

    mv s0, a0                        # Conserver l'indice de la cellule
    mv s1, a1                        # Conserver la couleur
    mv s2, a2                        # Conserver l'adresse du labyrinthe

    # ===== Recuperer la base de l'image =====

    la t0, adresse_image             # Charger l'adresse de la variable globale
    lw s3, 0(t0)                     # Recuperer l'adresse de base de l'image

    # ===== Calculer le centre de la cellule =====

    mv a0, s0                        # Charger l'indice de la cellule
    mv a1, s2                        # Charger l'adresse du labyrinthe
    jal ra, L_posCelluleImage        # Calculer les coordonnees du centre

    lw t0, largeur_img               # Charger la largeur de l'image
    mul s4, a1, t0                   # Calculer y_image * largeur
    add s4, s4, a0                   # Ajouter x_image pour obtenir l'indice du pixel

    # ===== Colorier le centre =====

    mv a0, s4                        # Charger l'indice du pixel central
    mv a1, s1                        # Charger la couleur
    mv a2, s3                        # Charger la base de l'image
    jal ra, I_plot                   # Colorier le centre de la cellule

    # ===== Initialiser la direction =====

    li s5, 0                         # Commencer par la direction haut

L_afficherCellule_boucle:

    # ===== Verifier les quatre directions =====

    li t0, 4                         # Nombre total de directions = 4
    bge s5, t0, L_afficherCellule_fin # Terminer apres les quatre directions

    # ===== Tester si un mur existe =====

    mv a0, s0                        # Charger l'indice de la cellule
    mv a1, s5                        # Charger la direction courante
    mv a2, s2                        # Charger l'adresse du labyrinthe
    jal ra, L_aUnMur                 # Tester la presence du mur

    bnez a0, L_afficherCellule_suite # Passer si un mur bloque la direction

    # ===== Calculer le pixel du passage =====

    mv t0, s4                        # Partir de l'indice du pixel central

    beqz s5, L_afficherCellule_haut  # Traiter la direction haut

    li t1, 1                         # Direction droite = 1
    beq s5, t1, L_afficherCellule_droite # Traiter la direction droite

    li t1, 2                         # Direction bas = 2
    beq s5, t1, L_afficherCellule_bas # Traiter la direction bas

    # ===== Direction gauche =====

    addi t0, t0, -1                  # Pixel situe a gauche du centre
    j L_afficherCellule_tracer       # Passer au dessin du passage

L_afficherCellule_haut:

    lw t1, largeur_img               # Charger la largeur de l'image
    sub t0, t0, t1                   # Pixel situe au-dessus du centre
    j L_afficherCellule_tracer       # Passer au dessin du passage

L_afficherCellule_droite:

    addi t0, t0, 1                   # Pixel situe a droite du centre
    j L_afficherCellule_tracer       # Passer au dessin du passage

L_afficherCellule_bas:

    lw t1, largeur_img               # Charger la largeur de l'image
    add t0, t0, t1                   # Pixel situe en dessous du centre

L_afficherCellule_tracer:

    # ===== Colorier le passage ouvert =====

    mv a0, t0                        # Charger l'indice du pixel du passage
    mv a1, s1                        # Utiliser la couleur de la cellule
    mv a2, s3                        # Charger la base de l'image
    jal ra, I_plot                   # Colorier le passage

L_afficherCellule_suite:

    # ===== Direction suivante =====

    addi s5, s5, 1                   # Augmenter la direction de 1
    j L_afficherCellule_boucle       # Recommencer pour la direction suivante

L_afficherCellule_fin:

    # ===== Restaurer les arguments =====

    mv a0, s0                        # Restaurer l'indice de la cellule
    mv a1, s1                        # Restaurer la couleur
    mv a2, s2                        # Restaurer la base du labyrinthe

    # ===== Epilogue =====

    lw a7, 28(sp)                    # Restaurer a7
    lw s5, 24(sp)                    # Restaurer s5
    lw s4, 20(sp)                    # Restaurer s4
    lw s3, 16(sp)                    # Restaurer s3
    lw s2, 12(sp)                    # Restaurer s2
    lw s1, 8(sp)                     # Restaurer s1
    lw s0, 4(sp)                     # Restaurer s0
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 48                  # Liberer les 48 octets reserves
    ret                              # Retourner a la fonction appelante


# ============================================================
# DEPENDANCES DES PARTIES PRECEDENTES
# ============================================================

.include "partie2.s"    # Fonctions de gestion de l'image
.include "partie4.s"    # Fonctions de manipulation des bits


