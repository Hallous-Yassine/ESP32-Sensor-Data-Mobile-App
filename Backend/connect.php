<?php

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "project_db";

// Establish a connection to the database
$con = mysqli_connect($host, $user, $pass, $dbname);

// Check the connection
if (!$con) {
    // Connection failed
    die("Connection failed: " . mysqli_connect_error());
}

?>
