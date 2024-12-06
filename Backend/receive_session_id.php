<?php
include 'connect.php';  // Include the database connection file

header('Content-Type: application/json');

$data = file_get_contents("php://input");
$request = json_decode($data, true);

if (isset($request['session_id'])) {
    $session_id = $request['session_id'];

    // Store or use the session ID as needed, e.g., in a database or in memory

    // Respond with the session ID
    echo json_encode([
        "status" => "success",
        "message" => "Session ID received",
        "session_id" => $session_id
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Session ID not provided"
    ]);
}

$con->close();
?>
