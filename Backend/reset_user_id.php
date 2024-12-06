<?php
session_start();

// Check if an action is set and it matches 'reset_user_id'
if (isset($_POST['action']) && $_POST['action'] === 'reset_user_id') {
    // Set the user_id to null
    $_SESSION['user_id'] = null;

    // Prepare a response
    $response = array('status' => 'success', 'message' => 'User ID has been reset.');
    echo json_encode($response);
} else {
    // If the action doesn't match, return an error
    $response = array('status' => 'error', 'message' => 'Invalid action.');
    echo json_encode($response);
}
?>
