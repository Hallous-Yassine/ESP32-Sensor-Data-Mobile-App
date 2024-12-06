<?php

include 'connect.php';

// Get the type of request
$requestType = isset($_GET['type']) ? $_GET['type'] : '';

// Initialize the response array
$response = [];

// Handle the request based on the type
switch ($requestType) {
    case 'current_temperature':
        $query = "
            SELECT 
                temperature AS current_temperature, 
                (SELECT MAX(temperature) FROM sensor_data WHERE timestamp >= NOW() - INTERVAL 10 MINUTE) AS max_temperature, 
                (SELECT MIN(temperature) FROM sensor_data WHERE timestamp >= NOW() - INTERVAL 10 MINUTE) AS min_temperature, 
                (SELECT AVG(temperature) FROM sensor_data WHERE timestamp >= NOW() - INTERVAL 10 MINUTE) AS average_temperature 
            FROM sensor_data 
            ORDER BY timestamp DESC 
            LIMIT 1";

        $result = mysqli_query($con, $query);

        if ($result && mysqli_num_rows($result) > 0) {
            $response = mysqli_fetch_assoc($result);
        } else {
            $response = ['error' => 'No data found'];
        }
        break;

    case 'temperature_chart':
        $query = "SELECT timestamp, temperature FROM sensor_data ORDER BY timestamp ASC";

        $result = mysqli_query($con, $query);

        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) {
                $response[] = [
                    'timestamp' => $row['timestamp'],
                    'temperature' => $row['temperature']
                ];
            }
        } else {
            $response = ['error' => 'No data found'];
        }
        break;

    case 'history_temperature':
        $query = "SELECT temperature, timestamp FROM sensor_data ORDER BY timestamp DESC";
        $result = mysqli_query($con, $query);

        if (mysqli_num_rows($result) > 0) {
            while ($row = mysqli_fetch_assoc($result)) {
                $response[] = $row;
            }
        } else {
            $response = [];
        }
        break;

    default:
        $response = ['error' => 'Invalid request type'];
        break;
}

// Return the response as JSON
echo json_encode($response);

// Close the database connection
mysqli_close($con);

?>
