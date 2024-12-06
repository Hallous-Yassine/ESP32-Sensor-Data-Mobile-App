<?php
// Inclure le fichier de connexion
include 'connect.php';

// Requête SQL pour récupérer les données de température
$sql = "SELECT humidity, timestamp FROM sensor_data ORDER BY timestamp DESC";
$result = mysqli_query($con, $sql);

// Vérifier si des données ont été trouvées
if (mysqli_num_rows($result) > 0) {
    $historyData = array();
    
    // Récupérer les données et les ajouter au tableau
    while ($row = mysqli_fetch_assoc($result)) {
        $historyData[] = $row;
    }

    // Retourner les données en format JSON
    echo json_encode($historyData);
} else {
    // Si aucune donnée n'est trouvée, retourner un tableau vide
    echo json_encode([]);
}

// Fermer la connexion à la base de données
mysqli_close($con);
?>
