<?php
include 'connect.php';  // Include the database connection file

// Set content type to JSON
header('Content-Type: application/json');

// Read the raw POST data
$data = file_get_contents("php://input");
$request = json_decode($data, true);

// Check if the required data is present
if (isset($request['device_name']) && isset($request['last_ip'])) {
    $device_name = $request['device_name'];
    $last_ip = $request['last_ip'];
    
    // First, verify if the device already exists
    $stmt = $con->prepare("SELECT * FROM device_data WHERE device_name = ?");
    $stmt->bind_param("s", $device_name);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Device found
        echo json_encode(["status" => "success", "message" => "Device verified"]);
    } else {
        // Device not found, add it
        $stmt = $con->prepare("INSERT INTO device_data (device_name, last_ip) VALUES (?, ?)");
        $stmt->bind_param("ss", $device_name, $last_ip);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Device added successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to add device: " . $stmt->error]);
        }
        $stmt->close();
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input, 'device_name' and 'last_ip' are required"]);
}

// Close the database connection
mysqli_close($con);
?>
