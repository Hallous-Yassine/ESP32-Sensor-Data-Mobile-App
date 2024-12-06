<?php
include("connect.php");  // Ensure this file is correctly setting up the database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Read the raw POST data
    $data = file_get_contents("php://input");
    $json = json_decode($data, true);

    if (json_last_error() === JSON_ERROR_NONE) {
        // Extract the data from JSON
        $temperature = $json['temperature'];
        $humidity = $json['humidity'];
        $device_name = $json['device_name'];

        // Retrieve device ID and approval status based on device name
        $sql = "SELECT id, approved FROM device_data WHERE device_name = ?";
        $stmt = $con->prepare($sql);
        $stmt->bind_param("s", $device_name);
        $stmt->execute();
        $stmt->bind_result($device_id, $approved);

        if ($stmt->fetch()) {
            $stmt->close();

            // Check if the device is approved (approved = 1)
            if ($approved == 1) {
                // Get the current user from the current_user table
                $sql = "SELECT user_id FROM `current_user` LIMIT 1";
                $result = $con->query($sql);
                
                if ($result && $result->num_rows > 0) {
                    $current_user = $result->fetch_assoc();
                    $current_user_id = $current_user['user_id'];

                    // Insert the sensor data into the sensor_data table along with the current user ID
                    $sql = "INSERT INTO sensor_data (device_id, temperature, humidity, user_id) VALUES (?, ?, ?, ?)";
                    $stmt = $con->prepare($sql);
                    $stmt->bind_param("iddi", $device_id, $temperature, $humidity, $current_user_id);

                    if ($stmt->execute()) {
                        echo json_encode(['status' => 'success']);
                    } else {
                        echo json_encode(['status' => 'error', 'message' => $stmt->error]);
                    }
                    $stmt->close();
                } else {
                    echo json_encode(['status' => 'error', 'message' => 'No current user found']);
                }
            } else {
                // Device is not approved
                echo json_encode(['status' => 'error', 'message' => 'Device not approved to send data']);
            }
        } else {
            // Device ID not found
            echo json_encode(['status' => 'error', 'message' => 'Device not found']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

// Close the database connection
$con->close();
?>
