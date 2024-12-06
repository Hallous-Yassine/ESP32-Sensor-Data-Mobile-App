<?php
// Include the database connection
require_once 'connect.php';

// Clear the current user session
$sql = "DELETE FROM `current_user`"; // Clear any existing session
$result = mysqli_query($con, $sql);

if ($result) {
    // Insert a new record with user_id = null
    $insertCurrentUser = "INSERT INTO `current_user` (user_id) VALUES (NULL)";
    if (mysqli_query($con, $insertCurrentUser)) {
        echo json_encode(['status' => 'success', 'message' => 'User ID reset to null']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to reset user ID']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to delete current user']);
}

// Close the database connection
mysqli_close($con);
?>
