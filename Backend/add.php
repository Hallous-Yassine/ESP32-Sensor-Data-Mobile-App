<?php
include("connect.php");  // Ensure this file is correctly setting up database connection
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Read the raw POST data
    $data = file_get_contents("php://input");
    $json = json_decode($data, true);

    if (json_last_error() === JSON_ERROR_NONE) {
        $temperature = $json['temperature'];
        $humidity = $json['humidity'];
        $device_name = $json['device_name'];

        session_start();
        error_log($_SESSION['user_id']."\n");
        if (isset($_SESSION['user_id'])) {
            $user_id = $_SESSION['user_id'];
        } else {
            echo json_encode(['status' => 'error', 'message' => 'User not authenticated']);
        }

        // Retrieve device ID based on device name
        $sql = "SELECT id FROM device_data WHERE device_name = ?";
        $stmt = $con->prepare($sql);
        $stmt->bind_param("s", $device_name);
        $stmt->execute();
        $stmt->bind_result($device_id);
        
        if ($stmt->fetch()) {
            $stmt->close();
            $sql = "INSERT INTO sensor_data (device_id, user_id, temperature, humidity) VALUES (?, ?, ?, ?)";
            $stmt = $con->prepare($sql);
            $stmt->bind_param("iidd", $device_id, $user_id, $temperature, $humidity);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success']);
            } else {
                echo json_encode(['status' => 'error', 'message' => $stmt->error]);
            }
        } else {
            // Device ID not found
            echo json_encode(['status' => 'error', 'message' => 'Device not found']);
        }
        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

$con->close();
?>
