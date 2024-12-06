<?php

include 'connect.php';

// Define the query to get temperature data for the last 10 minutes
$query = "
    SELECT timestamp, temperature 
    FROM sensor_data 
    WHERE timestamp >= NOW() - INTERVAL 10 MINUTE 
    ORDER BY timestamp ASC";

$result = mysqli_query($con, $query);

$data = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'timestamp' => $row['timestamp'],
            'temperature' => $row['temperature']
        ];
    }
    
    echo json_encode($data);
} else {
    echo json_encode(['error' => 'No data found']);
}

mysqli_close($con);

?>
