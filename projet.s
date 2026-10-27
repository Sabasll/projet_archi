# ============================================================
# PROJET LABYRINTHE - PARTIES 1 A 7
# ============================================================

.data
largeur_img:   .word 64                 # Largeur de l'image
hauteur_img:   .word 64                 # Hauteur de l'image
adresse_image: .word 0                  # Adresse de l'image
espace:        .asciz " "               # Pour afficher les entiers
msgVide:       .asciz "Erreur : la pile est vide\n"
msgPleine:     .asciz "Erreur : la pile est pleine\n"

.text
.globl main

# ============================================================
# MAIN
# ============================================================
main:
    # ===== Creer l'image et le labyrinthe =====
    jal ra, I_creer                      # Creer l'image
    la t0, adresse_image                 # Adresse de la variable
    sw a0, 0(t0)                         # Garder l'adresse de l'image

    jal ra, L_creer                      # Creer le labyrinthe
    mv s0, a0                            # Garder son adresse

    # ===== Generer le labyrinthe =====
    li a0, 0                             # Premiere cellule
    mv a1, s0                            # Adresse du labyrinthe
    jal ra, L_generer                    # Creer les passages

    # ===== Definir le depart et l'arrivee =====
    li a0, 0                             # Premiere cellule
    mv a1, s0                            # Adresse du labyrinthe
    jal ra, L_defDepart                  # Marquer le depart

    lw t0, 0(s0)                         # Nombre de colonnes
    lw t1, 4(s0)                         # Nombre de lignes
    mul s1, t0, t1                       # Nombre total de cellules
    addi s1, s1, -1                      # Derniere cellule
    mv a0, s1                            # Indice de l'arrivee
    mv a1, s0                            # Adresse du labyrinthe
    jal ra, L_defArrivee                 # Marquer l'arrivee

    # ===== Resoudre le labyrinthe =====
    li a0, 0                             # Depart
    mv a1, s1                            # Arrivee
    mv a2, s0                            # Adresse du labyrinthe
    jal ra, L_resoudre                   # Trouver le chemin

    # ===== Afficher les couleurs =====
    mv a0, s0                            # Adresse du labyrinthe
    jal ra, L_afficher                   # Murs noirs, passages blancs
    mv a0, s0                            # Adresse du labyrinthe
    jal ra, L_afficherImpassesExplorees  # Impasses explorees en rouge
    mv a0, s0                            # Adresse du labyrinthe
    jal ra, L_afficherSolution           # Solution en jaune

    li a0, 0                             # Cellule de depart
    li a1, 0x0000FF00                    # Vert
    mv a2, s0                            # Adresse du labyrinthe
    jal ra, L_afficherCellule            # Dessiner le depart

    mv a0, s1                            # Cellule d'arrivee
    li a1, 0x000000FF                    # Bleu
    mv a2, s0                            # Adresse du labyrinthe
    jal ra, L_afficherCellule            # Dessiner l'arrivee

    # ===== Fin =====
    li a7, 10                            # Terminer le programme
    ecall

# ============================================================
# FONCTIONS DES PARTIES 1 A 7
# ============================================================

L_afficherImpassesExplorees:
    addi sp, sp, -48                 # Reserver la memoire de sauvegarde
    sw ra, 0(sp)                     # Sauvegarder l'adresse de retour
    sw s0, 4(sp)                     # Sauvegarder s0
    sw s1, 8(sp)                     # Sauvegarder s1
    sw s2, 12(sp)                    # Sauvegarder s2
    sw s3, 16(sp)                    # Sauvegarder s3
    sw s4, 20(sp)                    # Sauvegarder s4
    sw s5, 24(sp)                    # Sauvegarder s5
    sw s6, 28(sp)                    # Sauvegarder s6
    sw s7, 32(sp)                    # Sauvegarder s7
    sw s8, 36(sp)                    # Sauvegarder s8
    mv s0, a0                        # Adresse du labyrinthe
    lw t0, 0(s0)                     # Nombre de colonnes
    lw t1, 4(s0)                     # Nombre de lignes
    mul s1, t0, t1                   # Nombre total de cellules
    lw s3, adresse_image             # Adresse de base du Bitmap Display
    li s5, 0x00EF4444                # Rouge des essais abandonnes
    li s2, 0                         # Commencer par la cellule 0

L_afficherImpassesExplorees_boucle:
    bge s2, s1, L_afficherImpassesExplorees_fin # Toutes les cellules sont examinees
    mv a0, s2                        # Charger l'indice courant
    mv a1, s0                        # Charger le labyrinthe
    jal ra, L_estVisitee             # Verifier si DFS a visite la cellule
    beqz a0, L_afficherImpassesExplorees_suivante # Ne jamais rougir une cellule non visitee
    mv a0, s2                        # Charger l'indice courant
    mv a1, s0                        # Charger le labyrinthe
    jal ra, L_estSolution            # Verifier si la cellule est dans la solution
    bnez a0, L_afficherImpassesExplorees_suivante # Garder la solution pour le jaune
    mv a0, s2                        # Indice de la cellule abandonnee
    mv a1, s0                        # Adresse du labyrinthe
    jal ra, L_posCelluleImage        # Obtenir les coordonnees du centre
    lw t0, largeur_img               # Largeur de l'image en pixels
    mul s4, a1, t0                   # Calculer y * largeur
    add s4, s4, a0                   # Ajouter x pour obtenir l'indice du centre
    mv a0, s4                        # Indice du centre
    mv a1, s5                        # Couleur rouge
    mv a2, s3                        # Adresse de l'image
    jal ra, I_plot                   # Colorier le centre en rouge
    li s7, 0                         # Commencer par la direction haut

L_afficherImpassesExplorees_direction:
    li t0, 4                         # Quatre directions possibles
    bge s7, t0, L_afficherImpassesExplorees_suivante # Passer a la prochaine cellule
    mv a0, s2                        # Indice de la cellule courante
    mv a1, s7                        # Direction courante
    mv a2, s0                        # Adresse du labyrinthe
    jal ra, L_aUnMur                 # Tester si le passage est ouvert
    bnez a0, L_afficherImpassesExplorees_directionSuivante # Ignorer un mur ferme
    mv a0, s2                        # Indice de la cellule rouge
    mv a1, s0                        # Adresse du labyrinthe
    jal ra, L_indiceToCoords         # Recuperer x et y de la cellule
    mv a2, s7                        # Direction recherchee
    jal ra, L_voisinDir              # Calculer x et y du voisin
    mv s6, a0                        # Sauvegarder x du voisin
    mv s8, a1                        # Sauvegarder y du voisin
    mv a0, s6                        # x du voisin
    mv a1, s8                        # y du voisin
    mv a2, s0                        # Adresse du labyrinthe
    jal ra, L_estDedans              # Verifier que le voisin est dans la grille
    beqz a0, L_afficherImpassesExplorees_directionSuivante # Ignorer l'exterieur
    mv a0, s6                        # x du voisin
    mv a1, s8                        # y du voisin
    mv a2, s0                        # Adresse du labyrinthe
    jal ra, L_coordsToIndice         # Convertir le voisin en indice
    mv a1, s0                        # Adresse du labyrinthe
    jal ra, L_estVisitee             # Tester si la recherche a atteint ce voisin
    beqz a0, L_afficherImpassesExplorees_directionSuivante # Garder le couloir blanc si non visite
    beqz s7, L_afficherImpassesExplorees_haut # Direction 0 : haut
    li t0, 1                         # Numero de la direction droite
    beq s7, t0, L_afficherImpassesExplorees_droite # Direction 1 : droite
    li t0, 2                         # Numero de la direction bas
    beq s7, t0, L_afficherImpassesExplorees_bas # Direction 2 : bas
    li s8, -1                        # Direction 3 : gauche = -1 pixel
    j L_afficherImpassesExplorees_tracer # Dessiner le passage

L_afficherImpassesExplorees_haut:
    lw s8, largeur_img               # Une ligne d'image
    sub s8, zero, s8                 # Haut = moins une ligne
    j L_afficherImpassesExplorees_tracer # Dessiner le passage

L_afficherImpassesExplorees_droite:
    li s8, 1                         # Droite = plus un pixel
    j L_afficherImpassesExplorees_tracer # Dessiner le passage

L_afficherImpassesExplorees_bas:
    lw s8, largeur_img               # Bas = plus une ligne

L_afficherImpassesExplorees_tracer:
    add a0, s4, s8                   # Premier pixel du passage depuis le centre
    mv a1, s5                        # Couleur rouge
    mv a2, s3                        # Adresse de l'image
    jal ra, I_plot                   # Dessiner le premier pixel
    slli t0, s8, 1                   # Deux fois le decalage d'un pixel
    add a0, s4, t0                   # Deuxieme pixel du passage
    mv a1, s5                        # Couleur rouge
    mv a2, s3                        # Adresse de l'image
    jal ra, I_plot                   # Dessiner le deuxieme pixel

L_afficherImpassesExplorees_directionSuivante:
    addi s7, s7, 1                   # Passer a la direction suivante
    j L_afficherImpassesExplorees_direction # Continuer l'examen des passages

L_afficherImpassesExplorees_suivante:
    addi s2, s2, 1                   # Passer a la cellule suivante
    j L_afficherImpassesExplorees_boucle # Continuer le parcours

L_afficherImpassesExplorees_fin:
    lw s8, 36(sp)                    # Restaurer s8
    lw s7, 32(sp)                    # Restaurer s7
    lw s6, 28(sp)                    # Restaurer s6
    lw s5, 24(sp)                    # Restaurer s5
    lw s4, 20(sp)                    # Restaurer s4
    lw s3, 16(sp)                    # Restaurer s3
    lw s2, 12(sp)                    # Restaurer s2
    lw s1, 8(sp)                     # Restaurer s1
    lw s0, 4(sp)                     # Restaurer s0
    lw ra, 0(sp)                     # Restaurer l'adresse de retour
    addi sp, sp, 48                  # Liberer les sauvegardes
    ret                              # Retourner a la fonction appelante
# PARTIE 1 : AFFICHAGE ET HASARD

printInt:
# Entree : a0 = entier a afficher
# Sortie : aucune
    addi sp, sp, -16
    sw a7, 0(sp)
    li a7, 1
    ecall
    lw a7, 0(sp)
    addi sp, sp, 16
    ret

printIntEsp:
    addi sp, sp, -16      
    sw   ra, 0(sp)         # sauvegarde de l'adresse de retour (on appelle printInt)
    sw   a0, 4(sp)         # sauvegarde de a0
    sw   a7, 8(sp)         # sauvegarde de a0
    jal  printInt          # affiche l'entier en decimal
    la   a0, espace        # a0 = adresse de la chaine " " // code assci espace = 32
    li   a7, 4             # ecall 4 : print string
    ecall
    lw   a7, 8(sp)         # restauration de a7
    lw   a0, 4(sp)         # restauration de a0
    lw   ra, 0(sp)         # restauration de ra
    addi sp, sp, 16
    ret

printHex:
    addi sp, sp, -16
    sw   a0, 0(sp)         # sauvegarde de a0 (sera modifie pour afficher l'espace)
    sw   a7, 4(sp)         # sauvegarde de a7
    li   a7, 34            # ecall 34 : print integer in hexadecimal
    ecall
    la   a0, espace        # adresse de la chaine espace
    li   a7, 4            # ecall 11 : print char
    ecall
    lw   a7, 4(sp)         # restauration de a7
    lw   a0, 0(sp)         # restauration de a0
    addi sp, sp, 16
    ret
auHasard: 
    addi sp, sp, -16
    sw   a1, 0(sp)         # sauvegarde de a1 
    sw   a7, 4(sp)         # sauvegarde de a7
    addi a1, a0, 1         # a1 = borne haute EXCLUE (a0 + 1)
    li   a0, 0             # a0 = id du generateur
    li   a7, 42            # ecall 42 : RandIntRange -> a0 dans [0, a1)
    ecall                  # a0 = resultat
    lw   a7, 4(sp)         # restauration de a7
    lw   a1, 0(sp)         # restauration de a1
    addi sp, sp, 16
    ret
# PARTIE 2 : IMAGE
# PARTIE 2 : FONCTIONS IMAGE
# FONCTION I_creer
# Objectif : Alloue largeur x hauteur x 4 octets, adresse dans a0

I_creer:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw a7, 0(sp)                      # Sauvegarder a7 dans 0(sp)
    lw t0, largeur_img                # Charger la largeur dans t0
    lw t1, hauteur_img                # Charger la hauteur dans t1
    mul t2, t0, t1                    # Multiplier t0 et t1 ; resultat dans t2
    slli a0, t2, 2                    # Decaler a gauche de 2 a t2 ; resultat dans a0
    li a7, 9                          # ecall 9 : sbrk (allocation dans le tas)
    ecall                             # Executer le service RARS selectionne dans a7
    lw a7, 0(sp)                      # restauration de a7
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
# FONCTION I_coordToAdresse
# Objectif : Retourne l'adresse memoire du pixel dans a0

I_coordToAdresse:
    lw   t0, largeur_img              # t0 = largeur (en units)
    mul  t1, a1, t0                   # t1 = y * largeur
    add  t1, t1, a0                   # t1 = y * largeur + x  (indice du pixel)
    slli t1, t1, 2                    # t1 = indice * 4  (decalage en octets)
    add  a0, a2, t1                   # a0 = base + decalage
    ret                               # Retourner a la fonction appelante
# FONCTION I_adresseToCoord
# Objectif : Retourne x dans a0 et y dans a1

I_adresseToCoord:
    sub  t0, a0, a1                   # t0 = decalage en octets (adresse - base)
    srli t0, t0, 2                    # t0 = indice du pixel (decalage / 4)
    lw   t1, largeur_img              # t1 = largeur (en units)
    rem  a0, t0, t1                   # a0 = x = indice % largeur
    div  a1, t0, t1                   # a1 = y = indice / largeur
    ret                               # Retourner a la fonction appelante
# FONCTION I_plot
# Objectif : Ecrit la couleur du pixel

I_plot:
    slli t0, a0, 2                    # t0 = indice * 4 (decalage en octets)
    add  t0, a2, t0                   # t0 = base + decalage = adresse du pixel
    sw   a1, 0(t0)                    # ecrit la couleur dans la memoire image
    ret                               # Retourner a la fonction appelante
# PARTIE 3 : PILES
# Entree : a0 = capacite (nombre max d'entiers de la pile)
# Sortie : a0 = adresse de la pile (dans le tas)

P_creer:
    addi sp, sp, -16
    sw   a7, 0(sp)         # sauvegarde de a7
    mv   t0, a0            # t0 = capacite (a0 va etre ecrase par l'ecall)
    addi t1, a0, 2         # t1 = capacite + 2 (2 mots de gestion)
    slli a0, t1, 2         # a0 = nombre d'octets = (capacite + 2) * 4
    li   a7, 9             # ecall 9 : sbrk (allocation dans le tas)
    ecall                  # a0 = adresse de la plage allouee
    sw   t0, 0(a0)         # pile[0] = capacite
    sw   zero, 4(a0)       # pile[1] = taille = 0 (pile vide)
    lw   a7, 0(sp)         # restauration de a7
    addi sp, sp, 16
    ret
    # Entree : a0 = adresse de la pile
    # Sortie : a0 = 1 si la pile est vide, 0 sinon

P_estVide:
    lw   t0, 4(a0)              # t0 = taille (nombre d'entiers actuel)
    beqz t0, P_estVide_oui      # si taille == 0 -> la pile est vide
    li a0, 0                    # taille != 0 -> pas vide, retourne 0
    ret

P_estVide_oui:
    li a0, 1                    # taille == 0 -> vide, retourne 1
    ret
# Entree : a0 = adresse de la pile
# Sortie : a0 = valeur du dernier element empile
# Entree : a0 = adresse de la pile
# Sortie : a0 = dernier element empile

P_sommet:
    lw t0, 4(a0)               # Nombre d'elements
    beqz t0, P_sommet_vide
    addi t0, t0, -1            # Indice du dernier element
    slli t0, t0, 2             # Indice * 4
    add t0, a0, t0
    lw a0, 8(t0)               # Lire l'element apres l'entete
    ret

P_sommet_vide:
    la t0, msgVide
    j P_erreur
# Entree : a0 = adresse de la pile, a1 = entier a empiler
# Sortie : aucune

P_empiler:
    lw   t0, 0(a0)             # t0 = capacite
    lw   t1, 4(a0)             # t1 = taille
    bgeu t1, t0, P_empiler_pleine  # Si taille >= capacite, pile pleine
    slli t2, t1, 2             # t2 = taille * 4
    add  t2, a0, t2            # t2 = pile + taille * 4
    sw   a1, 8(t2)             # element[taille] = a1
    addi t1, t1, 1             # Augmenter la taille de la pile
    sw   t1, 4(a0)             # Enregistrer la nouvelle taille
    ret

P_empiler_pleine:
    la   t0, msgPleine         # t0 = adresse du message
    j    P_erreur              # P_erreur fait le ret a notre place
# Entree : a0 = adresse de la pile
# Sortie : aucune

P_depiler:
    lw   t0, 4(a0)             # t0 = taille
    beqz t0, P_depiler_vide    # taille == 0 -> vide
    addi t0, t0, -1            # taille - 1
    sw   t0, 4(a0)             # ecrit la nouvelle taille
    ret

P_depiler_vide:
    la   t0, msgVide           # t0 = adresse du message
    j    P_erreur
# Entree : a0 = adresse de la pile
# Sortie : aucune

P_print:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   a0, 12(sp)
    lw   s1, 4(a0)             # s1 = nombre d'elements restants
    addi s0, a0, 8             # s0 = adresse de l'element 0

P_print_boucle:
    beqz s1, P_print_fin       # plus d'elements -> fin
    lw   a0, 0(s0)             # a0 = element courant
    jal  printIntEsp           # affiche l'element + espace
    addi s0, s0, 4             # element suivant
    addi s1, s1, -1            # un de moins
    j    P_print_boucle

P_print_fin:
    lw   a0, 12(sp)
    lw   s1, 8(sp)
    lw   s0, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    ret
# Entree : t0 = adresse du message

P_erreur:
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a7, 4(sp)
    mv a0, t0
    li a7, 4                   # Afficher une chaine
    ecall
    lw a0, 0(sp)
    lw a7, 4(sp)
    addi sp, sp, 16
    ret
# PARTIE 4 : BITS ET OCTETS
# PARTIE 4 : FONCTIONS BITS ET OCTETS
# FONCTION B_getBit
# Objectif : Retourne le bit (0 ou 1)

B_getBit:
    srl  t0, a0, a1                   # t0 = a0 >> a1 (le bit voulu devient le bit 0)
    andi a0, t0, 1                    # a0 = t0 & 1 (on garde seulement ce bit)
    ret                               # Retourner a la fonction appelante
# FONCTION B_setBit
# Objectif : Modifie le bit, resultat dans a0

B_setBit:
    li   t0, 1                        # Placer 1 dans t0
    sll  t0, t0, a1                   # t0 = 1 << a1 (masque : un seul bit a 1)
    not  t0, t0                       # t0 = ~masque (tous les bits a 1 sauf le bit a1)
    and  a0, a0, t0                   # a0 = a0 avec le bit a1 mis a 0
    sll  t1, a2, a1                   # t1 = a2 << a1 (la nouvelle valeur a sa place)
    or   a0, a0, t1                   # a0 = a0 | t1 : le bit a1 vaut maintenant a2
    ret                               # Retourner a la fonction appelante
# FONCTION B_print
# Objectif : Affiche les 32 bits de gauche a droite

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
# FONCTION B_getByte
# Objectif : Retourne un octet dans a0

B_getByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    srl  t0, a0, t0                   # t0 = a0 >> (a1 * 8)
    andi a0, t0, 255                  # a0 = t0 & 0xFF (on garde 8 bits)
    ret                               # Retourner a la fonction appelante
# FONCTION B_setByte
# Objectif : Modifie un octet, resultat dans a0

B_setByte:
    slli t0, a1, 3                    # t0 = a1 * 8 (decalage en bits)
    li   t1, 255                      # t1 = 0xFF
    sll  t1, t1, t0                   # t1 = 0xFF << decalage (masque de l'octet)
    not  t1, t1                       # t1 = ~masque
    and  a0, a0, t1                   # a0 = a0 avec l'octet a1 mis a 0
    sll  t2, a2, t0                   # t2 = a2 << decalage (nouvelle valeur a sa place)
    or   a0, a0, t2                   # a0 = a0 | t2
    ret                               # Retourner a la fonction appelante
# PARTIE 5 : CELLULES DU LABYRINTHE
# PARTIE 5 : LES CELLULES DU LABYRINTHE

L_creer:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   a7, 0(sp)                    # Sauvegarder a7 avant le service RARS
    lw   t0, largeur_img              # Lire la largeur de l'image
    lw   t1, hauteur_img              # Lire la hauteur de l'image
    li   t2, 3                        # Chaque cellule utilise 3 pixels par direction
    divu t0, t0, t2                   # Nombre de colonnes
    divu t1, t1, t2                   # Nombre de lignes
    mul  t3, t0, t1                   # Nombre total de cellules
    slli a0, t3, 2                    # 4 octets par cellule
    addi a0, a0, 8                    # Ajouter les dimensions
    li   a7, 9                        # sbrk
    ecall                             # Allouer la memoire du labyrinthe et retourner sa base
    sw   t0, 0(a0)                    # Stocker le nombre de colonnes
    sw   t1, 4(a0)                    # Stocker le nombre de lignes
    addi t4, a0, 8                    # Adresse de la premiere cellule
    li   t5, 15                       # Bits 0, 1, 2 et 3 a 1

L_creer_boucle:
    beqz t3, L_creer_fin              # Arreter quand toutes les cellules sont initialisees
    sw   t5, 0(t4)                    # Initialiser une cellule
    addi t4, t4, 4                    # Cellule suivante
    addi t3, t3, -1                   # Decrementer le nombre de cellules restantes
    j    L_creer_boucle               # Initialiser la cellule suivante

L_creer_fin:
    lw   a7, 0(sp)                    # Restaurer a7
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_indiceToCoords
# Objectif : Retourne x dans a0 et y dans a1

L_indiceToCoords:
    lw   t0, 0(a1)                    # t0 = nombre de colonnes
    remu t1, a0, t0                   # t1 = x
    divu t2, a0, t0                   # t2 = y
    mv   a0, t1                       # Copier t1 dans a0
    mv   a1, t2                       # Copier t2 dans a1
    ret                               # Retourner a la fonction appelante
# FONCTION L_coordsToIndice
# Objectif : Retourne l'indice de la cellule dans a0

L_coordsToIndice:
    lw   t0, 0(a2)                    # t0 = nombre de colonnes
    mul  t1, a1, t0                   # t1 = y * colonnes
    add  a0, t1, a0                   # a0 = y * colonnes + x
    ret                               # Retourner a la fonction appelante
# FONCTION L_aUnMur
# Objectif : Retourne 1 si un mur est present

L_aUnMur:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a2, t0                   # Pointer vers les donnees de la cellule
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    jal  ra, B_getBit                 # a1 = numero du bit = direction
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_casserMur
# Objectif : Efface le bit du mur pour ce seul cote

L_casserMur:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a2, 8(sp)                    # Sauvegarder a2 dans 8(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a2, t0                   # Pointer vers les donnees de la cellule
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    li   a2, 0                        # bit a 0
    jal  ra, B_setBit                 # Modifier le bit et recuperer la cellule modifiee
    lw   t1, 4(sp)                    # indice
    lw   t2, 8(sp)                    # adresse du labyrinthe
    slli t1, t1, 2                    # Decaler a gauche de 2 a t1 ; resultat dans t1
    add  t1, t2, t1                   # Ajouter t2 et t1 ; resultat dans t1
    sw   a0, 8(t1)                    # ecrit la nouvelle valeur
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    lw   a0, 4(sp)                    # Restaurer l'indice initial de cellule
    lw   a2, 8(sp)                    # Restaurer l'adresse du labyrinthe
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_estDepart
# Objectif : Teste le bit 4 : depart

L_estDepart:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 4                        # Bit "depart"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra
    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_estArrivee
# Objectif : Teste le bit 5 : arrivee

L_estArrivee:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 5                        # Bit "arrivee"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra
    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_estVisitee
# Objectif : Teste le bit 6 : visitee

L_estVisitee:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 6                        # Bit "visitee"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra
    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_estSolution
# Objectif : Teste le bit 7 : solution

L_estSolution:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a1, 4(sp)                    # Sauvegarder a1 dans 4(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 7                        # Bit "solution"
    jal  ra, B_getBit                 # Appeler B_getBit et memoriser le retour dans ra
    lw   a1, 4(sp)                    # Charger dans a1 la valeur situee a 4(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_defDepart
# Objectif : Active le bit 4 : depart

L_defDepart:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # a0 = valeur de la cellule
    li   a1, 4                        # Bit "depart"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # a0 = nouvelle valeur
    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)
    lw   a0, 4(sp)                    # Restaurer l'indice initial de cellule
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_defArrivee
# Objectif : Active le bit 5 : arrivee

L_defArrivee:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 5                        # Bit "arrivee"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Modifier le bit et recuperer la cellule modifiee
    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)
    lw   a0, 4(sp)                    # Restaurer l'indice initial de cellule
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_defVisitee
# Objectif : Active le bit 6 : visitee

L_defVisitee:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 6                        # Bit "visitee"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Modifier le bit et recuperer la cellule modifiee
    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)
    lw   a0, 4(sp)                    # Restaurer l'indice initial de cellule
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_defSolution
# Objectif : Active le bit 7 : solution

L_defSolution:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    sw   a0, 4(sp)                    # Sauvegarder a0 dans 4(sp)
    sw   a1, 8(sp)                    # Sauvegarder a1 dans 8(sp)
    sw   a2, 12(sp)                   # Sauvegarder a2 dans 12(sp)
    slli t0, a0, 2                    # Decalage de 4 octets par cellule
    add  t0, a1, t0                   # Ajouter a1 et t0 ; resultat dans t0
    lw   a0, 8(t0)                    # Charger dans a0 la valeur situee a 8(t0)
    li   a1, 7                        # Bit "solution"
    li   a2, 1                        # Placer 1 dans a2
    jal  ra, B_setBit                 # Modifier le bit et recuperer la cellule modifiee
    lw   t0, 4(sp)                    # Charger dans t0 la valeur situee a 4(sp)
    lw   t1, 8(sp)                    # Charger dans t1 la valeur situee a 8(sp)
    slli t0, t0, 2                    # Decaler a gauche de 2 a t0 ; resultat dans t0
    add  t0, t1, t0                   # Ajouter t1 et t0 ; resultat dans t0
    sw   a0, 8(t0)                    # Sauvegarder a0 dans 8(t0)
    lw   a0, 4(sp)                    # Restaurer l'indice initial de cellule
    lw   a1, 8(sp)                    # Charger dans a1 la valeur situee a 8(sp)
    lw   a2, 12(sp)                   # Charger dans a2 la valeur situee a 12(sp)
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_estDedans
# Objectif : Retourne 1 si (x,y) est dans le labyrinthe

L_estDedans:
    blt  a0, zero, L_estDedans_non    # Si a0 est inferieur a zero, aller a L_estDedans_non
    blt  a1, zero, L_estDedans_non    # Si a1 est inferieur a zero, aller a L_estDedans_non
    lw   t0, 0(a2)                    # t0 = nombre de colonnes
    lw   t1, 4(a2)                    # t1 = nombre de lignes
    bge  a0, t0, L_estDedans_non      # Si a0 est superieur ou egal a t0, aller a L_estDedans_non
    bge  a1, t1, L_estDedans_non      # Si a1 est superieur ou egal a t1, aller a L_estDedans_non
    li   a0, 1                        # Placer 1 dans a0
    ret                               # Retourner a la fonction appelante

L_estDedans_non:
    li   a0, 0                        # Placer 0 dans a0
    ret                               # Retourner a la fonction appelante
# FONCTION L_voisinDir
# Objectif : Retourne les coordonnees du voisin

L_voisinDir:
    beqz a2, L_voisin_haut            # Si egal a zero, aller a L_voisin_haut
    li   t0, 1                        # Placer 1 dans t0
    beq  a2, t0, L_voisin_droite      # Si a2 est egaux a t0, aller a L_voisin_droite
    li   t0, 2                        # Placer 2 dans t0
    beq  a2, t0, L_voisin_bas         # Si a2 est egaux a t0, aller a L_voisin_bas
    li   t0, 3                        # Placer 3 dans t0
    beq  a2, t0, L_voisin_gauche      # Si a2 est egaux a t0, aller a L_voisin_gauche
    ret                               # Retourner a la fonction appelante

L_voisin_haut:
    addi a1, a1, -1                   # y = y - 1
    ret                               # Retourner a la fonction appelante

L_voisin_droite:
    addi a0, a0, 1                    # x = x + 1
    ret                               # Retourner a la fonction appelante

L_voisin_bas:
    addi a1, a1, 1                    # y = y + 1
    ret                               # Retourner a la fonction appelante

L_voisin_gauche:
    addi a0, a0, -1                   # x = x - 1
    ret                               # Retourner a la fonction appelante
# FONCTION L_posCelluleImage
# Objectif : Retourne le centre de la cellule dans l'image

L_posCelluleImage:
    addi sp, sp, -16                  # Reserver 16 octets sur la pile
    sw   ra, 0(sp)                    # Sauvegarder ra dans 0(sp)
    jal  ra, L_indiceToCoords         # Appeler L_indiceToCoords et memoriser le retour dans ra
    li   t0, 3                        # Placer 3 dans t0
    mul  a0, a0, t0                   # x = x * 3
    addi a0, a0, 1                    # x_image = 3*x + 1
    mul  a1, a1, t0                   # y = y * 3
    addi a1, a1, 1                    # y_image = 3*y + 1
    lw   ra, 0(sp)                    # Restaurer l'adresse de retour
    addi sp, sp, 16                   # Liberer les 16 octets reserves
    ret                               # Retourner a la fonction appelante
# FONCTION L_afficherCellule
# Objectif : Dessine le centre et les passages sans mur

L_afficherCellule:
    addi sp, sp, -48                  # Reserver 48 octets sur la pile
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw a7, 28(sp)                     # Sauvegarder a7 dans 28(sp)
    mv s0, a0                         # Indice de la cellule
    mv s1, a1                         # Couleur
    mv s2, a2                         # Adresse du labyrinthe
    la t0, adresse_image              # Charger l'adresse de adresse_image dans t0
    lw s3, 0(t0)                      # Charger dans s3 la valeur situee a 0(t0)
    mv a0, s0                         # Indice de la cellule
    mv a1, s2                         # Adresse du labyrinthe
    jal ra, L_posCelluleImage         # Appeler L_posCelluleImage et memoriser le retour dans ra
    lw t0, largeur_img                # Lire la largeur de l'image
    mul s4, a1, t0                    # Multiplier a1 et t0 ; resultat dans s4
    add s4, s4, a0                    # Ajouter s4 et a0 ; resultat dans s4
    mv a0, s4                         # Copier s4 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s3                         # Copier s3 dans a2
    jal ra, I_plot                    # Appeler I_plot et memoriser le retour dans ra
    li s5, 0                          # Placer 0 dans s5

L_afficherCellule_boucle:
    li t0, 4                          # Placer 4 dans t0
    bge s5, t0, L_afficherCellule_fin # Si s5 est superieur ou egal a t0, aller a L_afficherCellule_fin
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s5                         # Copier s5 dans a1
    mv a2, s2                         # Copier s2 dans a2
    jal ra, L_aUnMur                  # Appeler L_aUnMur et memoriser le retour dans ra
    bnez a0, L_afficherCellule_suite  # Si different de zero, aller a L_afficherCellule_suite
    mv t0, s4                         # Copier s4 dans t0
    beqz s5, L_afficherCellule_haut   # Si egal a zero, aller a L_afficherCellule_haut
    li t1, 1                          # Placer 1 dans t1
    beq s5, t1, L_afficherCellule_droite # Si s5 est egaux a t1, aller a L_afficherCellule_droite
    li t1, 2                          # Placer 2 dans t1
    beq s5, t1, L_afficherCellule_bas # Si s5 est egaux a t1, aller a L_afficherCellule_bas
    addi t0, t0, -1                   # Ajouter -1 a t0 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_haut:
    lw t1, largeur_img                # Charger dans t1 la valeur situee a largeur_img
    sub t0, t0, t1                    # Soustraire t0 et t1 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_droite:
    addi t0, t0, 1                    # Ajouter 1 a t0 ; resultat dans t0
    j L_afficherCellule_tracer        # Aller a L_afficherCellule_tracer

L_afficherCellule_bas:
    lw t1, largeur_img                # Charger dans t1 la valeur situee a largeur_img
    add t0, t0, t1                    # Ajouter t0 et t1 ; resultat dans t0

L_afficherCellule_tracer:
    mv a0, t0                         # Copier t0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s3                         # Copier s3 dans a2
    jal ra, I_plot                    # Appeler I_plot et memoriser le retour dans ra

L_afficherCellule_suite:
    addi s5, s5, 1                    # Ajouter 1 a s5 ; resultat dans s5
    j L_afficherCellule_boucle        # Aller a L_afficherCellule_boucle

L_afficherCellule_fin:
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    mv a2, s2                         # Copier s2 dans a2
    lw a7, 28(sp)                     # Charger dans a7 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Restaurer l'adresse de retour
    addi sp, sp, 48                   # Liberer les 48 octets reserves
    ret                               # Retourner a la fonction appelante
# PARTIE 6 : GENERATION DU LABYRINTHE
# PARTIE 6 : GENERATION DU LABYRINTHE
# FONCTION L_voisinsNonVisitees
# Objectif : Retourne nombre dans a0, directions par octets dans a1

L_voisinsNonVisitees:
    addi sp, sp, -48                  # Ajouter -48 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw s6, 28(sp)                     # Sauvegarder s6 dans 28(sp)
    sw s7, 32(sp)                     # Sauvegarder s7 dans 32(sp)
    sw s8, 36(sp)                     # Sauvegarder s8 dans 36(sp)
    sw a2, 40(sp)                     # Sauvegarder a2 dans 40(sp)
    mv s0, a0                         # indice de C
    mv s1, a1                         # adresse du labyrinthe
    jal ra, L_indiceToCoords          # Appeler L_indiceToCoords et memoriser le retour dans ra
    mv s2, a0                         # x de C
    mv s3, a1                         # y de C
    li s4, 0                          # direction courante (0..3)
    li s5, 0                          # nombre de voisines non visitees
    li s6, 0                          # directions regroupees (un octet chacune)

L_voisinsNonVisitees_boucle:
    li t0, 4                          # Placer 4 dans t0
    bge s4, t0, L_voisinsNonVisitees_fin # Si s4 est superieur ou egal a t0, aller a L_voisinsNonVisitees_fin
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s3                         # Copier s3 dans a1
    mv a2, s4                         # Copier s4 dans a2
    jal ra, L_voisinDir               # Appeler L_voisinDir et memoriser le retour dans ra
    mv s7, a0                         # x du voisin
    mv s8, a1                         # y du voisin (a1 sera ecrase par les appels)
    mv a0, s7                         # Copier s7 dans a0
    mv a1, s8                         # Copier s8 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_estDedans               # Appeler L_estDedans et memoriser le retour dans ra
    beqz a0, L_voisinsNonVisitees_suite # Si egal a zero, aller a L_voisinsNonVisitees_suite
    mv a0, s7                         # Copier s7 dans a0
    mv a1, s8                         # Copier s8 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_coordsToIndice          # Appeler L_coordsToIndice et memoriser le retour dans ra
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_estVisitee              # Appeler L_estVisitee et memoriser le retour dans ra
    bnez a0, L_voisinsNonVisitees_suite # Si different de zero, aller a L_voisinsNonVisitees_suite
    mv a0, s6                         # Copier s6 dans a0
    mv a1, s5                         # Copier s5 dans a1
    mv a2, s4                         # Copier s4 dans a2
    jal ra, B_setByte                 # Appeler B_setByte et memoriser le retour dans ra
    mv s6, a0                         # Copier a0 dans s6
    addi s5, s5, 1                    # une voisine de plus

L_voisinsNonVisitees_suite:
    addi s4, s4, 1                    # direction suivante
    j L_voisinsNonVisitees_boucle     # Aller a L_voisinsNonVisitees_boucle

L_voisinsNonVisitees_fin:
    mv a0, s5                         # nombre de voisines
    mv a1, s6                         # directions
    lw a2, 40(sp)                     # Charger dans a2 la valeur situee a 40(sp)
    lw s8, 36(sp)                     # Charger dans s8 la valeur situee a 36(sp)
    lw s7, 32(sp)                     # Charger dans s7 la valeur situee a 32(sp)
    lw s6, 28(sp)                     # Charger dans s6 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 48                   # Ajouter 48 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
# FONCTION L_directionAleatoire
# Objectif : Retourne une direction choisie au hasard

L_directionAleatoire:
    addi sp, sp, -16                  # Ajouter -16 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    mv s0, a1                         # sauvegarder les directions
    addi a0, a0, -1                   # auHasard est inclusif : tirage dans [0, n-1]
    jal ra, auHasard                  # a0 = numero d'octet au hasard
    mv a1, a0                         # a1 = numero d'octet
    mv a0, s0                         # a0 = directions regroupees
    jal ra, B_getByte                 # a0 = la direction choisie
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 16                   # Ajouter 16 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
# FONCTION L_afficher
# Objectif : Dessine murs noirs et passages blancs

L_afficher:
    addi sp, sp, -32                  # Ajouter -32 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw a0, 16(sp)                     # Sauvegarder a0 dans 16(sp)
    sw a1, 20(sp)                     # Sauvegarder a1 dans 20(sp)
    sw a2, 24(sp)                     # Sauvegarder a2 dans 24(sp)
    mv s0, a0                         # Adresse du labyrinthe
    lw t0, 0(s0)                      # Charger dans t0 la valeur situee a 0(s0)
    lw t1, 4(s0)                      # Charger dans t1 la valeur situee a 4(s0)
    mul s1, t0, t1                    # Multiplier t0 et t1 ; resultat dans s1
    lw t0, largeur_img                # Charger dans t0 la valeur situee a largeur_img
    lw t1, hauteur_img                # Charger dans t1 la valeur situee a hauteur_img
    mul t2, t0, t1                    # Multiplier t0 et t1 ; resultat dans t2
    lw t3, adresse_image              # Charger dans t3 la valeur situee a adresse_image

L_afficher_effacer:
    beqz t2, L_afficher_debut         # Si egal a zero, aller a L_afficher_debut
    sw zero, 0(t3)                    # Sauvegarder zero dans 0(t3)
    addi t3, t3, 4                    # Ajouter 4 a t3 ; resultat dans t3
    addi t2, t2, -1                   # Ajouter -1 a t2 ; resultat dans t2
    j L_afficher_effacer              # Aller a L_afficher_effacer

L_afficher_debut:
    li s2, 0                          # Indice de la premiere cellule

L_afficher_boucle:
    bge s2, s1, L_afficher_fin        # Si s2 est superieur ou egal a s1, aller a L_afficher_fin
    mv a0, s2                         # Copier s2 dans a0
    li a1, 0x00FFFFFF                 # Placer 0x00FFFFFF dans a1
    mv a2, s0                         # Copier s0 dans a2
    jal ra, L_afficherCellule         # Appeler L_afficherCellule et memoriser le retour dans ra
    addi s2, s2, 1                    # Ajouter 1 a s2 ; resultat dans s2
    j L_afficher_boucle               # Aller a L_afficher_boucle

L_afficher_fin:
    lw a2, 24(sp)                     # Charger dans a2 la valeur situee a 24(sp)
    lw a1, 20(sp)                     # Charger dans a1 la valeur situee a 20(sp)
    lw a0, 16(sp)                     # Charger dans a0 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 32                   # Ajouter 32 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
# FONCTION L_generer
# Objectif : Genere le labyrinthe avec exploration et retour arriere

L_generer:
    addi sp, sp, -48                  # Ajouter -48 a sp ; resultat dans sp
    sw ra, 0(sp)                      # Sauvegarder ra dans 0(sp)
    sw s0, 4(sp)                      # Sauvegarder s0 dans 4(sp)
    sw s1, 8(sp)                      # Sauvegarder s1 dans 8(sp)
    sw s2, 12(sp)                     # Sauvegarder s2 dans 12(sp)
    sw s3, 16(sp)                     # Sauvegarder s3 dans 16(sp)
    sw s4, 20(sp)                     # Sauvegarder s4 dans 20(sp)
    sw s5, 24(sp)                     # Sauvegarder s5 dans 24(sp)
    sw a0, 28(sp)                     # Sauvegarder a0 dans 28(sp)
    sw a1, 32(sp)                     # Sauvegarder a1 dans 32(sp)
    sw a2, 36(sp)                     # Sauvegarder a2 dans 36(sp)
    mv s0, a0                         # Cellule de depart
    mv s1, a1                         # Adresse du labyrinthe
    lw t0, 0(s1)                      # Nombre de colonnes
    lw t1, 4(s1)                      # Nombre de lignes
    mul a0, t0, t1                    # Multiplier t0 et t1 ; resultat dans a0
    jal ra, P_creer                   # Appeler P_creer et memoriser le retour dans ra
    mv s2, a0                         # Adresse de la pile
    mv a0, s0                         # Copier s0 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_defVisitee              # Appeler L_defVisitee et memoriser le retour dans ra
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s0                         # Copier s0 dans a1
    jal ra, P_empiler                 # Appeler P_empiler et memoriser le retour dans ra

L_generer_boucle:
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_estVide                 # Appeler P_estVide et memoriser le retour dans ra
    bnez a0, L_generer_fin            # Si different de zero, aller a L_generer_fin
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_sommet                  # Appeler P_sommet et memoriser le retour dans ra
    mv s3, a0                         # Cellule courante
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_voisinsNonVisitees      # Appeler L_voisinsNonVisitees et memoriser le retour dans ra
    beqz a0, L_generer_retour         # Si egal a zero, aller a L_generer_retour
    jal ra, L_directionAleatoire      # Appeler L_directionAleatoire et memoriser le retour dans ra
    mv s4, a0                         # Direction choisie
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_indiceToCoords          # Appeler L_indiceToCoords et memoriser le retour dans ra
    mv a2, s4                         # Copier s4 dans a2
    jal ra, L_voisinDir               # Appeler L_voisinDir et memoriser le retour dans ra
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_coordsToIndice          # Appeler L_coordsToIndice et memoriser le retour dans ra
    mv s5, a0                         # Indice du voisin choisi
    mv a0, s3                         # Copier s3 dans a0
    mv a1, s4                         # Copier s4 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_casserMur               # Appeler L_casserMur et memoriser le retour dans ra
    addi t0, s4, 2                    # Ajouter 2 a s4 ; resultat dans t0
    andi t0, t0, 3                    # Appliquer le masque 3 a t0 ; resultat dans t0
    mv a0, s5                         # Copier s5 dans a0
    mv a1, t0                         # Copier t0 dans a1
    mv a2, s1                         # Copier s1 dans a2
    jal ra, L_casserMur               # Appeler L_casserMur et memoriser le retour dans ra
    mv a0, s5                         # Copier s5 dans a0
    mv a1, s1                         # Copier s1 dans a1
    jal ra, L_defVisitee              # Appeler L_defVisitee et memoriser le retour dans ra
    mv a0, s2                         # Copier s2 dans a0
    mv a1, s5                         # Copier s5 dans a1
    jal ra, P_empiler                 # Appeler P_empiler et memoriser le retour dans ra
    j L_generer_boucle                # Aller a L_generer_boucle

L_generer_retour:
    mv a0, s2                         # Copier s2 dans a0
    jal ra, P_depiler                 # Appeler P_depiler et memoriser le retour dans ra
    j L_generer_boucle                # Aller a L_generer_boucle

L_generer_fin:
    lw a2, 36(sp)                     # Charger dans a2 la valeur situee a 36(sp)
    lw a1, 32(sp)                     # Charger dans a1 la valeur situee a 32(sp)
    lw a0, 28(sp)                     # Charger dans a0 la valeur situee a 28(sp)
    lw s5, 24(sp)                     # Charger dans s5 la valeur situee a 24(sp)
    lw s4, 20(sp)                     # Charger dans s4 la valeur situee a 20(sp)
    lw s3, 16(sp)                     # Charger dans s3 la valeur situee a 16(sp)
    lw s2, 12(sp)                     # Charger dans s2 la valeur situee a 12(sp)
    lw s1, 8(sp)                      # Charger dans s1 la valeur situee a 8(sp)
    lw s0, 4(sp)                      # Charger dans s0 la valeur situee a 4(sp)
    lw ra, 0(sp)                      # Charger dans ra la valeur situee a 0(sp)
    addi sp, sp, 48                   # Ajouter 48 a sp ; resultat dans sp
    ret                               # Retourner a la fonction appelante
# PARTIE 7 : RESOLUTION DU LABYRINTHE

L_resoudre:
    addi sp, sp, -64                  # Reserver 64 octets pour sauvegardes locales.
    sw ra, 0(sp)                      # Sauvegarder ra sur la pile systeme.
    sw s0, 4(sp)                      # Sauvegarder s0 sur la pile systeme.
    sw s1, 8(sp)                      # Sauvegarder s1 sur la pile systeme.
    sw s2, 12(sp)                     # Sauvegarder s2 sur la pile systeme.
    sw s3, 16(sp)                     # Sauvegarder s3 sur la pile systeme.
    sw s4, 20(sp)                     # Sauvegarder s4 sur la pile systeme.
    sw s5, 24(sp)                     # Sauvegarder s5 sur la pile systeme.
    sw s6, 28(sp)                     # Sauvegarder s6 sur la pile systeme.
    sw s7, 32(sp)                     # Sauvegarder s7 sur la pile systeme.
    sw s8, 36(sp)                     # Sauvegarder s8 sur la pile systeme.
    sw a1, 40(sp)                     # Sauvegarder a1 sur la pile systeme.
    sw a2, 44(sp)                     # Sauvegarder a2 sur la pile systeme.
    mv s0, a0                         # Depart | Copier a0 dans s0 ; la source reste inchangee.
    mv s1, a1                         # Arrivee | Copier a1 dans s1 ; la source reste inchangee.
    mv s2, a2                         # Adresse du labyrinthe | Copier a2 dans s2 ; la source reste inchangee.
    lw t0, 0(s2)                      # Lire un mot de 4 octets a 0(s2) dans t0.
    lw t1, 4(s2)                      # Lire un mot de 4 octets a 4(s2) dans t1.
    mul s4, t0, t1                    # s4 = t0 * t1.
    bgeu s0, s4, L_resoudre_echec     # Si s0 >= (non signe) s4, aller a L_resoudre_echec.
    bgeu s1, s4, L_resoudre_echec     # Si s1 >= (non signe) s4, aller a L_resoudre_echec.
    li s5, 0                          # Charger la constante 0 dans s5.

L_resoudre_reset:
    bge s5, s4, L_resoudre_creerPile  # Si s5 >= s4, aller a L_resoudre_creerPile.
    slli t0, s5, 2                    # Decaler s5 de 2 bits vers la gauche, resultat dans t0.
    add t0, s2, t0                    # t0 = s2 + t0.
    lw t1, 8(t0)                      # Lire un mot de 4 octets a 8(t0) dans t1.
    andi t1, t1, -193                 # Masque 0xFFFFFF3F : effacer visitee (bit 6) et solution (bit 7), conserver tous les autres bits.
    sw t1, 8(t0)                      # Ecrire le mot t1 a 8(t0).
    addi s5, s5, 1                    # s5 = s5 + (1).
    j L_resoudre_reset                # Aller a L_resoudre_reset sans modifier ra.

L_resoudre_creerPile:
    mv a0, s4                         # Copier s4 dans a0 ; la source reste inchangee.
    jal ra, P_creer                   # Appeler P_creer ; ra recoit l adresse de retour.
    mv s3, a0                         # Copier a0 dans s3 ; la source reste inchangee.
    mv a0, s0                         # Copier s0 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_defVisitee              # Appeler L_defVisitee ; ra recoit l adresse de retour.
    mv a0, s0                         # Copier s0 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_defSolution             # Appeler L_defSolution ; ra recoit l adresse de retour.
    mv a0, s3                         # Copier s3 dans a0 ; la source reste inchangee.
    mv a1, s0                         # Copier s0 dans a1 ; la source reste inchangee.
    jal ra, P_empiler                 # Appeler P_empiler ; ra recoit l adresse de retour.

L_resoudre_boucle:
    mv a0, s3                         # Copier s3 dans a0 ; la source reste inchangee.
    jal ra, P_estVide                 # Appeler P_estVide ; ra recoit l adresse de retour.
    bnez a0, L_resoudre_echec         # Si a0 != 0, aller a L_resoudre_echec ; sinon continuer.
    mv a0, s3                         # Copier s3 dans a0 ; la source reste inchangee.
    jal ra, P_sommet                  # Appeler P_sommet ; ra recoit l adresse de retour.
    mv s5, a0                         # Copier a0 dans s5 ; la source reste inchangee.
    beq s5, s1, L_resoudre_succes     # Si s5 == s1, aller a L_resoudre_succes.
    li s6, 0                          # Charger la constante 0 dans s6.

L_resoudre_direction:
    li t0, 4                          # Charger la constante 4 dans t0.
    bge s6, t0, L_resoudre_retour     # Si s6 >= t0, aller a L_resoudre_retour.
    mv a0, s5                         # Copier s5 dans a0 ; la source reste inchangee.
    mv a1, s6                         # Copier s6 dans a1 ; la source reste inchangee.
    mv a2, s2                         # Copier s2 dans a2 ; la source reste inchangee.
    jal ra, L_aUnMur                  # Appeler L_aUnMur ; ra recoit l adresse de retour.
    bnez a0, L_resoudre_directionSuivante  # Si a0 != 0, aller a L_resoudre_directionSuivante ; sinon continuer.
    mv a0, s5                         # Copier s5 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_indiceToCoords          # Appeler L_indiceToCoords ; ra recoit l adresse de retour.
    mv a2, s6                         # Copier s6 dans a2 ; la source reste inchangee.
    jal ra, L_voisinDir               # Appeler L_voisinDir ; ra recoit l adresse de retour.
    mv s7, a0                         # Copier a0 dans s7 ; la source reste inchangee.
    mv s8, a1                         # Copier a1 dans s8 ; la source reste inchangee.
    mv a0, s7                         # Copier s7 dans a0 ; la source reste inchangee.
    mv a1, s8                         # Copier s8 dans a1 ; la source reste inchangee.
    mv a2, s2                         # Copier s2 dans a2 ; la source reste inchangee.
    jal ra, L_estDedans               # Appeler L_estDedans ; ra recoit l adresse de retour.
    beqz a0, L_resoudre_directionSuivante  # Si a0 == 0, aller a L_resoudre_directionSuivante ; sinon continuer.
    mv a0, s7                         # Copier s7 dans a0 ; la source reste inchangee.
    mv a1, s8                         # Copier s8 dans a1 ; la source reste inchangee.
    mv a2, s2                         # Copier s2 dans a2 ; la source reste inchangee.
    jal ra, L_coordsToIndice          # Appeler L_coordsToIndice ; ra recoit l adresse de retour.
    mv s4, a0                         # Copier a0 dans s4 ; la source reste inchangee.
    mv a0, s4                         # Copier s4 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_estVisitee              # Appeler L_estVisitee ; ra recoit l adresse de retour.
    bnez a0, L_resoudre_directionSuivante  # Si a0 != 0, aller a L_resoudre_directionSuivante ; sinon continuer.
    mv a0, s4                         # Copier s4 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_defVisitee              # Appeler L_defVisitee ; ra recoit l adresse de retour.
    mv a0, s4                         # Copier s4 dans a0 ; la source reste inchangee.
    mv a1, s2                         # Copier s2 dans a1 ; la source reste inchangee.
    jal ra, L_defSolution             # Appeler L_defSolution ; ra recoit l adresse de retour.
    mv a0, s3                         # Copier s3 dans a0 ; la source reste inchangee.
    mv a1, s4                         # Copier s4 dans a1 ; la source reste inchangee.
    jal ra, P_empiler                 # Appeler P_empiler ; ra recoit l adresse de retour.
    j L_resoudre_boucle                # Aller a L_resoudre_boucle sans modifier ra.

L_resoudre_directionSuivante:
    addi s6, s6, 1                      # s6 = s6 + (1).
    j L_resoudre_direction              # Aller a L_resoudre_direction sans modifier ra.

L_resoudre_retour:
    slli t0, s5, 2                      # Decaler s5 de 2 bits vers la gauche, resultat dans t0.
    add t0, s2, t0                      # t0 = s2 + t0.
    lw t1, 8(t0)                        # Lire un mot de 4 octets a 8(t0) dans t1.
    andi t1, t1, -129                   # Masque 0xFFFFFF7F : effacer solution (bit 7), conserver notamment visitee.
    sw t1, 8(t0)                        # Ecrire le mot t1 a 8(t0).
    mv a0, s3                           # Copier s3 dans a0 ; la source reste inchangee.
    jal ra, P_depiler                   # Appeler P_depiler ; ra recoit l adresse de retour.
    j L_resoudre_boucle                 # Aller a L_resoudre_boucle sans modifier ra.

L_resoudre_succes:
    li a0, 1                            # Charger la constante 1 dans a0.
    j L_resoudre_fin                    # Aller a L_resoudre_fin sans modifier ra.

L_resoudre_echec:
    li a0, 0                            # Charger la constante 0 dans a0.

L_resoudre_fin:
    lw a2, 44(sp)                       # Restaurer/relire a2 depuis la pile systeme.
    lw a1, 40(sp)                       # Restaurer/relire a1 depuis la pile systeme.
    lw s8, 36(sp)                       # Restaurer/relire s8 depuis la pile systeme.
    lw s7, 32(sp)                       # Restaurer/relire s7 depuis la pile systeme.
    lw s6, 28(sp)                       # Restaurer/relire s6 depuis la pile systeme.
    lw s5, 24(sp)                       # Restaurer/relire s5 depuis la pile systeme.
    lw s4, 20(sp)                       # Restaurer/relire s4 depuis la pile systeme.
    lw s3, 16(sp)                       # Restaurer/relire s3 depuis la pile systeme.
    lw s2, 12(sp)                       # Restaurer/relire s2 depuis la pile systeme.
    lw s1, 8(sp)                        # Restaurer/relire s1 depuis la pile systeme.
    lw s0, 4(sp)                        # Restaurer/relire s0 depuis la pile systeme.
    lw ra, 0(sp)                        # Restaurer/relire ra depuis la pile systeme.
    addi sp, sp, 64                     # Liberer les 64 octets de cette fonction.
    ret                                 # Retourner a l adresse contenue dans ra.
    
# FONCTION L_afficherSolution
# Entree : a0 = adresse du labyrinthe
# Sortie : aucune
# Objectif : colorier en jaune les cellules du chemin solution

L_afficherSolution:
    addi sp, sp, -48  # Reserver 48 octets pour sauvegardes locales.
    sw ra, 0(sp)  # Sauvegarder ra sur la pile systeme.
    sw s0, 4(sp)  # Sauvegarder s0 sur la pile systeme.
    sw s1, 8(sp)  # Sauvegarder s1 sur la pile systeme.
    sw s2, 12(sp)  # Sauvegarder s2 sur la pile systeme.
    sw s3, 16(sp)  # Sauvegarder s3 sur la pile systeme.
    sw s4, 20(sp)  # Sauvegarder s4 sur la pile systeme.
    sw s5, 24(sp)  # Sauvegarder s5 sur la pile systeme.
    sw s6, 28(sp)  # Sauvegarder s6 sur la pile systeme.
    sw a0, 32(sp)  # Sauvegarder a0 sur la pile systeme.
    sw a1, 36(sp)  # Sauvegarder a1 sur la pile systeme.
    sw a2, 40(sp)  # Sauvegarder a2 sur la pile systeme.
    mv s0, a0  # Copier a0 dans s0 ; la source reste inchangee.
    lw s6, 0(s0)  # Lire un mot de 4 octets a 0(s0) dans s6.
    lw t0, 4(s0)  # Lire un mot de 4 octets a 4(s0) dans t0.
    mul s1, s6, t0  # s1 = s6 * t0.
    lw s3, adresse_image  # Lire un mot de 4 octets a adresse_image dans s3.
    li s5, 0x00FFFF00  # Charger la constante 0x00FFFF00 dans s5.
    li s2, 0  # Charger la constante 0 dans s2.

L_afficherSolution_boucle:
    bge s2, s1, L_afficherSolution_fin  # Si s2 >= s1, aller a L_afficherSolution_fin.
    mv a0, s2  # Copier s2 dans a0 ; la source reste inchangee.
    mv a1, s0  # Copier s0 dans a1 ; la source reste inchangee.
    jal ra, L_estSolution  # Appeler L_estSolution ; ra recoit l adresse de retour.
    beqz a0, L_afficherSolution_suivante  # Si a0 == 0, aller a L_afficherSolution_suivante ; sinon continuer.
    mv a0, s2  # Copier s2 dans a0 ; la source reste inchangee.
    mv a1, s0  # Copier s0 dans a1 ; la source reste inchangee.
    jal ra, L_posCelluleImage  # Appeler L_posCelluleImage ; ra recoit l adresse de retour.
    lw t0, largeur_img  # Lire un mot de 4 octets a largeur_img dans t0.
    mul s4, a1, t0  # s4 = a1 * t0.
    add s4, s4, a0  # s4 = s4 + a0.
    mv a0, s4  # Copier s4 dans a0 ; la source reste inchangee.
    mv a1, s5  # Copier s5 dans a1 ; la source reste inchangee.
    mv a2, s3  # Copier s3 dans a2 ; la source reste inchangee.
    jal ra, I_plot  # Appeler I_plot ; ra recoit l adresse de retour.
    remu t0, s2, s6  # t0 = s2 reste non signe de s6.
    addi t1, s6, -1  # t1 = s6 + (-1).
    bge t0, t1, L_afficherSolution_bas  # Si t0 >= t1, aller a L_afficherSolution_bas.
    mv a0, s2  # Copier s2 dans a0 ; la source reste inchangee.
    li a1, 1  # Charger la constante 1 dans a1.
    mv a2, s0  # Copier s0 dans a2 ; la source reste inchangee.
    jal ra, L_aUnMur  # Appeler L_aUnMur ; ra recoit l adresse de retour.
    bnez a0, L_afficherSolution_bas  # Si a0 != 0, aller a L_afficherSolution_bas ; sinon continuer.
    addi a0, s2, 1  # a0 = s2 + (1).
    mv a1, s0  # Copier s0 dans a1 ; la source reste inchangee.
    jal ra, L_estSolution  # Appeler L_estSolution ; ra recoit l adresse de retour.
    beqz a0, L_afficherSolution_bas  # Si a0 == 0, aller a L_afficherSolution_bas ; sinon continuer.
    addi a0, s4, 1  # a0 = s4 + (1).
    mv a1, s5  # Copier s5 dans a1 ; la source reste inchangee.
    mv a2, s3  # Copier s3 dans a2 ; la source reste inchangee.
    jal ra, I_plot  # Appeler I_plot ; ra recoit l adresse de retour.
    addi a0, s4, 2  # a0 = s4 + (2).
    mv a1, s5  # Copier s5 dans a1 ; la source reste inchangee.
    mv a2, s3  # Copier s3 dans a2 ; la source reste inchangee.
    jal ra, I_plot  # Appeler I_plot ; ra recoit l adresse de retour.

L_afficherSolution_bas:
    add t0, s2, s6  # t0 = s2 + s6.
    bge t0, s1, L_afficherSolution_suivante  # Si t0 >= s1, aller a L_afficherSolution_suivante.
    mv a0, s2  # Copier s2 dans a0 ; la source reste inchangee.
    li a1, 2  # Charger la constante 2 dans a1.
    mv a2, s0  # Copier s0 dans a2 ; la source reste inchangee.
    jal ra, L_aUnMur  # Appeler L_aUnMur ; ra recoit l adresse de retour.
    bnez a0, L_afficherSolution_suivante  # Si a0 != 0, aller a L_afficherSolution_suivante ; sinon continuer.
    add a0, s2, s6  # a0 = s2 + s6.
    mv a1, s0  # Copier s0 dans a1 ; la source reste inchangee.
    jal ra, L_estSolution  # Appeler L_estSolution ; ra recoit l adresse de retour.
    beqz a0, L_afficherSolution_suivante  # Si a0 == 0, aller a L_afficherSolution_suivante ; sinon continuer.
    lw t0, largeur_img  # Lire un mot de 4 octets a largeur_img dans t0.
    add a0, s4, t0  # a0 = s4 + t0.
    mv a1, s5  # Copier s5 dans a1 ; la source reste inchangee.
    mv a2, s3  # Copier s3 dans a2 ; la source reste inchangee.
    jal ra, I_plot  # Appeler I_plot ; ra recoit l adresse de retour.
    lw t0, largeur_img  # Lire un mot de 4 octets a largeur_img dans t0.
    slli t0, t0, 1  # Decaler t0 de 1 bits vers la gauche, resultat dans t0.
    add a0, s4, t0  # a0 = s4 + t0.
    mv a1, s5  # Copier s5 dans a1 ; la source reste inchangee.
    mv a2, s3  # Copier s3 dans a2 ; la source reste inchangee.
    jal ra, I_plot  # Appeler I_plot ; ra recoit l adresse de retour.

L_afficherSolution_suivante:
    addi s2, s2, 1  # s2 = s2 + (1).
    j L_afficherSolution_boucle  # Aller a L_afficherSolution_boucle sans modifier ra.

L_afficherSolution_fin:
    lw a2, 40(sp)  # Restaurer/relire a2 depuis la pile systeme.
    lw a1, 36(sp)  # Restaurer/relire a1 depuis la pile systeme.
    lw a0, 32(sp)  # Restaurer/relire a0 depuis la pile systeme.
    lw s6, 28(sp)  # Restaurer/relire s6 depuis la pile systeme.
    lw s5, 24(sp)  # Restaurer/relire s5 depuis la pile systeme.
    lw s4, 20(sp)  # Restaurer/relire s4 depuis la pile systeme.
    lw s3, 16(sp)  # Restaurer/relire s3 depuis la pile systeme.
    lw s2, 12(sp)  # Restaurer/relire s2 depuis la pile systeme.
    lw s1, 8(sp)  # Restaurer/relire s1 depuis la pile systeme.
    lw s0, 4(sp)  # Restaurer/relire s0 depuis la pile systeme.
    lw ra, 0(sp)  # Restaurer/relire ra depuis la pile systeme.
    addi sp, sp, 48  # Liberer les 48 octets de cette fonction.
    ret  # Retourner a l adresse contenue dans ra.
