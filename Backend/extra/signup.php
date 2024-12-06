<?php
// Include the database connection file
require_once 'connect.php';

// Check if all necessary POST data is provided
if (isset($_POST['username']) && isset($_POST['password']) && isset($_POST['email'])) {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $email = $_POST['email']; // Correctly assign the email value

    // Check if the username already exists
    $sql = "SELECT * FROM user_data WHERE username = ? LIMIT 1";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "s", $username);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_fetch_assoc($result)) {
        // Username already exists
        $response = [
            'status' => 'error',
            'message' => 'Username already exists'
        ];
    } else {
        // Hash the password for security
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Insert the new user into the database
        $insert_sql = "INSERT INTO user_data (username, password, email) VALUES (?, ?, ?)";
        $insert_stmt = mysqli_prepare($con, $insert_sql);
        mysqli_stmt_bind_param($insert_stmt, "sss", $username, $hashed_password, $email);

        if (mysqli_stmt_execute($insert_stmt)) {
            // Signup successful
            $response = [
                'status' => 'success',
                'message' => 'User registered successfully'
            ];
        } else {
            // Error while inserting data
            $response = [
                'status' => 'error',
                'message' => 'Failed to register user'
            ];
        }
    }
} else {
    // If required POST data is missing
    $response = [
        'status' => 'error',
        'message' => 'Username, password, and email are required'
    ];
}

// Return the response as JSON
echo json_encode($response);

// Close the database connection
mysqli_close($con);
?>
