<?php
// Include the database connection
require_once 'connect.php';

// Set the current user ID to -1
$sql = "DELETE FROM `current_user` "; // Clear any existing session
$result = mysqli_query($con, $sql);

if ($result) {
    // Insert a new record with user_id = -1
    $insertCurrentUser = "INSERT INTO `current_user` (user_id) VALUES (-1)";
    if (mysqli_query($con, $insertCurrentUser)) {
        echo json_encode(['status' => 'success', 'message' => 'Continued as guest']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to set guest user']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete current user']);
}

// Close the database connection
mysqli_close($con);
?>
