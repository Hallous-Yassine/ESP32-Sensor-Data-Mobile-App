<?php
include 'connect.php';  // Include the database connection file

// Read the raw POST data
$data = file_get_contents("php://input");
$request = json_decode($data, true);

// Check if the required data is present
if (isset($request['device_name']) && isset($request['user_name']) && isset($request['last_ip'])) {
    $device_name = $request['device_name'];
    $user_name = $request['user_name'];
    $last_ip = $request['last_ip'];

    // Prepare the SQL statement
    $stmt = $con->prepare("INSERT INTO device_data (device_name, user_name, last_ip) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $device_name, $user_name, $last_ip);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Device added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to add device: " . $stmt->error]);
    }

    // Close the prepared statement
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

// Close the database connection
mysqli_close($con);
?>
