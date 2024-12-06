<?php
// Inclure le fichier de connexion à la base de données
require_once 'connect.php';

// Vérifier si les données POST sont définies
if (isset($_POST['username']) && isset($_POST['password'])) {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Préparer une requête SQL pour vérifier si le nom d'utilisateur existe
    $sql = "SELECT * FROM user_data WHERE username = ? LIMIT 1";
    $stmt = mysqli_prepare($con, $sql);

    // Lier les paramètres (s signifie string)
    mysqli_stmt_bind_param($stmt, "s", $username);

    // Exécuter la requête
    mysqli_stmt_execute($stmt);

    // Obtenir le résultat
    $result = mysqli_stmt_get_result($stmt);

    // Vérifier si le nom d'utilisateur existe
    if ($row = mysqli_fetch_assoc($result)) {
        // Vérifier le mot de passe
        if (password_verify($password, $row['password'])) {
            // Connexion réussie
            $user_id = $row['id'];

            // Supprimer l'ancien utilisateur connecté (si existe)
            $deleteCurrentUser = "DELETE FROM `current_user`";
            mysqli_query($con, $deleteCurrentUser);

            // Insérer l'utilisateur connecté dans la table current_user
            $insertCurrentUser = "INSERT INTO `current_user` (user_id) VALUES (?)";
            $stmtInsert = mysqli_prepare($con, $insertCurrentUser);
            mysqli_stmt_bind_param($stmtInsert, "i", $user_id);
            mysqli_stmt_execute($stmtInsert);

            $response = [
                'status' => 'success',
                'message' => 'Connexion reussie',
                'user_id' => $user_id
            ];
        } else {
            // Mot de passe incorrect
            $response = [
                'status' => 'error',
                'message' => 'Mot de passe incorrect'
            ];
        }
    } else {
        // Nom d'utilisateur non trouvé
        $response = [
            'status' => 'error',
            'message' => 'Nom d\'utilisateur non trouvé'
        ];
    }
} else {
    // Si les données POST manquent
    $response = [
        'status' => 'error',
        'message' => 'Nom d\'utilisateur ou mot de passe non fourni'
    ];
}

// Retourner la réponse en JSON
echo json_encode($response);

// Fermer la connexion à la base de données
mysqli_close($con);
?>
