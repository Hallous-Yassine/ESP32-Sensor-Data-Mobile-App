<?php

include("connect.php");

// Read the JSON input
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Set content type to JSON
header('Content-Type: application/json');

// Check if the JSON was parsed successfully
if (json_last_error() === JSON_ERROR_NONE) {
    $id = isset($data['id']) ? $data['id'] : null;
    $temperature = isset($data['temperature']) ? $data['temperature'] : null;
    $humidity = isset($data['humidity']) ? $data['humidity'] : null;

    // Check for null values and ensure they are not empty
    if ($id === null || $temperature === null || $humidity === null) {
        echo json_encode(["status" => "error", "message" => "ID, Temperature, or Humidity is missing"]);
    } else {
        // Prepare and execute SQL statement with parameterized query to avoid SQL injection
        $stmt = $con->prepare("UPDATE sensor_data SET temperature = ?, humidity = ? WHERE id = ?");
        if ($stmt) {
            $stmt->bind_param("ddi", $temperature, $humidity, $id);

            if ($stmt->execute()) {
                echo json_encode(["status" => "success", "message" => "Data updated successfully"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to update data: " . $stmt->error]);
            }

            $stmt->close();
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to prepare statement"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid JSON"]);
}

$con->close();
?>
