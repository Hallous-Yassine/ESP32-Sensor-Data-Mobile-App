<?php

include("connect.php");

// Set content type to JSON
header('Content-Type: application/json');

// Delete records older than 10 minutes
$sql_delete = "DELETE FROM sensor_data WHERE timestamp < NOW() - INTERVAL 10 MINUTE";
$result = $con->query($sql_delete);

if ($result) {
    $deleted_rows = $con->affected_rows;
    if ($deleted_rows > 0) {
        echo json_encode(["status" => "success", "message" => "$deleted_rows records deleted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No records found older than 10 minutes"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete data: " . $con->error]);
}

$con->close();
?>
