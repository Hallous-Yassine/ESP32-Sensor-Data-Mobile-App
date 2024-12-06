<?php
include 'connect.php';  // Include the database connection file

// Set content type to JSON
header('Content-Type: application/json');

// Read the raw POST data
$data = file_get_contents("php://input");
$request = json_decode($data, true);

// Check if the required data is present
if (isset($request['device_name']) ) {
    $device_name = mysqli_real_escape_string($con, $request['device_name']);
    
    // First, verify if the device already exists
    $sql = "SELECT * FROM device_data WHERE device_name='$device_name' ";
    $result = mysqli_query($con, $sql);

    if (mysqli_num_rows($result) > 0) {
        // Device and user match found
        echo json_encode(["status" => "success", "message" => "Device verified"]);
    } else {
        // Device and user do not match, check if the last_ip is provided for adding the device
        if (isset($request['last_ip'])) {
            $last_ip = mysqli_real_escape_string($con, $request['last_ip']);
            
            // Prepare the SQL statement for adding the device
            $stmt = $con->prepare("INSERT INTO device_data (device_name, last_ip) VALUES (? , ?)");
            $stmt->bind_param("ss", $device_name, $last_ip);

            if ($stmt->execute()) {
                echo json_encode(["status" => "success", "message" => "Device added successfully"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to add device: " . $stmt->error]);
            }

            // Close the prepared statement
            $stmt->close();
        } else {
            // Device not found and no last_ip provided
            echo json_encode(["status" => "error", "message" => "Device not found and no last_ip provided for addition"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

// Close the database connection
mysqli_close($con);
?>