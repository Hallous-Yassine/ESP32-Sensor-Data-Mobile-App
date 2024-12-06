import requests
import random
import time
import json

# Server IP (replace with your actual PHP server address)
SERVER_IP = ' http://192.168.250.15'

# Device information (simulating MAC address and IP)
device_name = "00:00:00:00:00:00"  # Simulated device name
ip_address = "192.168.1.100"  # Simulated IP address

# Function to send data to the PHP script
def send_data_to_php(temperature, humidity):
    url = SERVER_IP + '/api/add_test.php'  # Replace with your actual API URL
    
    # Payload to send
    post_data = {
        "device_name": device_name,
        "temperature": round(temperature, 2),
        "humidity": round(humidity, 2)
    }

    # Send the data via POST request
    try:
        response = requests.post(url, json=post_data)
        if response.status_code == 200:
            print(f"Data sent successfully: {post_data}")
        else:
            print(f"Failed to send data, status code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending data: {e}")

# Function to verify the device in the database
def verify_device_in_db():
    url = SERVER_IP + '/api/verify_test.php'  # Replace with your actual API URL
    
    # Payload for device verification
    post_data = {
        "device_name": device_name,
        "last_ip": ip_address
    }

    # Send the verification request via POST
    try:
        response = requests.post(url, json=post_data)
        if response.status_code == 200:
            print(f"Device verified: {post_data}")
            return True
        else:
            print(f"Device verification failed, status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"Error verifying device: {e}")
        return False

# Function to delete old data from the database
def delete_old_data():
    url = SERVER_IP + '/api/delete.php'  # Replace with your actual API URL
    
    # Send the request to delete old data
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print("Old data deleted successfully")
        else:
            print(f"Failed to delete old data, status code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Error deleting old data: {e}")

# Main loop to generate and send data
def main():
    # Verify the device before sending data
    if verify_device_in_db():
        while True:
            # Generate random temperature and humidity
            temperature = random.uniform(15.0, 35.0)  # Random temperature between 15°C and 35°C
            humidity = random.uniform(20.0, 80.0)  # Random humidity between 20% and 80%

            # Send the data to the PHP server
            send_data_to_php(temperature, humidity)

            # Wait for 10 seconds before sending the next set of data
            time.sleep(10)

            # Delete old data every 10 seconds
            delete_old_data()

if __name__ == '__main__':
    main()
