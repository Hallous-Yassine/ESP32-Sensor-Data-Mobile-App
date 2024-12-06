#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "esp_wifi.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/event_groups.h"
#include "esp_http_server.h"
#include "esp_http_client.h"
#include "esp32-dht11.h"  // Include the correct DHT11 library
#include "my_data.h" 

#define CONFIG_DHT11_PIN GPIO_NUM_4
#define CONFIG_CONNECTION_TIMEOUT 5

static char ip_address[16] = {0}; 
static const char *TAG = "Web-Data-Base";

// Global variables for temperature and humidity
static float temperature = 0.0;
static float humidity = 0.0;

// MAC address buffer
static char device_name[18] = {0};
static bool mac_address_obtained = false;

// Function to retrieve the MAC address
void get_mac_address() {
    uint8_t mac[6];
    esp_wifi_get_mac(ESP_IF_WIFI_STA, mac);
    snprintf(device_name, sizeof(device_name),
             "%02x:%02x:%02x:%02x:%02x:%02x",
             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
    mac_address_obtained = true;
}

// Function to send data to the PHP script
void send_data_to_php(float temperature, float humidity) {
    char post_data[512];
    snprintf(post_data, sizeof(post_data),
             "{\"device_name\": \"%s\", \"temperature\": %.2f, \"humidity\": %.2f }",
             device_name, temperature, humidity);

    ESP_LOGI(TAG, "Device sent data: %s", post_data);

    esp_http_client_config_t config = {
        .url = SERVER_IP "/api/add.php"
    };

    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_http_client_set_method(client, HTTP_METHOD_POST);
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, post_data, strlen(post_data));
    
    esp_err_t err = esp_http_client_perform(client);

    if (err == ESP_OK) {
        ESP_LOGI(TAG, "Data sent successfully");
    } else {
        ESP_LOGE(TAG, "Failed to send data: %s", esp_err_to_name(err));
    }

    esp_http_client_cleanup(client);
}

// Function to delete old data from the database
void delete_old_data() {
    esp_http_client_config_t config = {
        .url = SERVER_IP "/api/delete.php", 
        .method = HTTP_METHOD_GET
    };

    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_err_t err = esp_http_client_perform(client);

    if (err == ESP_OK) {
        ESP_LOGI(TAG, "Old data deleted successfully");
    } else {
        ESP_LOGE(TAG, "Failed to delete old data: %s", esp_err_to_name(err));
    }

    esp_http_client_cleanup(client);
}

static bool device_verified = false;

// Function to verify the device in the database
void verify_device_in_db() {
    char post_data[512];
    snprintf(post_data, sizeof(post_data),
             "{\"device_name\": \"%s\", \"last_ip\": \"%s\"}",
             device_name, ip_address);

    ESP_LOGI(TAG, "Verifying device with data: %s", post_data);  // Log the data being sent

    esp_http_client_config_t config = {
        .url = SERVER_IP "/api/verify_device.php",
    };

    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_http_client_set_method(client, HTTP_METHOD_POST);
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, post_data, strlen(post_data));

    int retry_count = 3;  // Number of retries
    esp_err_t err;

    do {
        err = esp_http_client_perform(client);
        if (err == ESP_OK) {
            ESP_LOGI(TAG, "Device verified successfully and/or added to the database");
            device_verified = true;
            break;
        } else {
            ESP_LOGE(TAG, "Device verification failed: %s, retrying...", esp_err_to_name(err));
            vTaskDelay(2000 / portTICK_PERIOD_MS);  // Delay before retry
        }
    } while (--retry_count > 0);

    if (!device_verified) {
        ESP_LOGE(TAG, "Device verification failed after retries");
    }

    esp_http_client_cleanup(client);
}

// Task to send DHT11 data periodically
void data_send_task(void *pvParameters) {
    dht11_t dht11_sensor;
    dht11_sensor.dht11_pin = CONFIG_DHT11_PIN;

    while (1) {
        if (!dht11_read(&dht11_sensor, CONFIG_CONNECTION_TIMEOUT)) {
            temperature = dht11_sensor.temperature;
            humidity = dht11_sensor.humidity;
            ESP_LOGI(TAG, "Temperature: %.2f, Humidity: %.2f", temperature, humidity);

            send_data_to_php(temperature, humidity);  // Send data after reading
        } else {
            ESP_LOGE(TAG, "Failed to read from DHT11 sensor");
        }

        // Wait for the next interval before reading and sending data again
        vTaskDelay(10000 / portTICK_PERIOD_MS);
    }
}

// Task to periodically delete old data
void delete_data_task(void *pvParameter) {
    while (1) {
        delete_old_data();
        vTaskDelay(600000 / portTICK_PERIOD_MS);  // Delay for 10 minutes
    }
}

static bool ip_obtained = false;

static void wifi_event_handler(void *event_handler_arg, esp_event_base_t event_base, int32_t event_id, void *event_data) {
    switch (event_id) {
        case WIFI_EVENT_STA_START:
            ESP_LOGI(TAG, "WiFi connecting...");
            break;
        case WIFI_EVENT_STA_CONNECTED:
            ESP_LOGI(TAG, "WiFi connected...");
            break;
        case WIFI_EVENT_STA_DISCONNECTED:
            ESP_LOGI(TAG, "WiFi lost connection...");
            esp_wifi_connect();  // Attempt to reconnect
            ip_obtained = false; // Reset IP obtained flag
            break;
        case IP_EVENT_STA_GOT_IP:
            ESP_LOGI(TAG, "WiFi got IP...");
            ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
            snprintf(ip_address, sizeof(ip_address), IPSTR, IP2STR(&event->ip_info.ip));
            ESP_LOGI(TAG, "IP Address: %s", ip_address);  // Print IP address to the serial monitor
            ip_obtained = true;
            break;
        default:
            break;
    }
}

// Wi-Fi initialization
void wifi_connection() {
    nvs_flash_init();
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_sta();
    wifi_init_config_t wifi_initiation = WIFI_INIT_CONFIG_DEFAULT();
    esp_wifi_init(&wifi_initiation);
    esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL);
    esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL);
    wifi_config_t wifi_configuration = {
        .sta = {
            .ssid = SSID,
            .password = PASS
        }
    };
    esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_configuration);
    esp_wifi_start();
    esp_wifi_connect();
}

// Main application
void app_main() {
    srand(time(NULL));  // Initialize random seed for later use

    wifi_connection();

    // Wait for the IP address to be obtained
    while (!ip_obtained) {
        vTaskDelay(100 / portTICK_PERIOD_MS);  // Small delay to avoid busy-waiting
    }

    // Retrieve MAC address once Wi-Fi is connected
    get_mac_address();

    // Ensure MAC address has been obtained
    while (!mac_address_obtained) {
        vTaskDelay(100 / portTICK_PERIOD_MS);  // Small delay to avoid busy-waiting
    }

    // Verify the device in the database
    if (ip_obtained && mac_address_obtained) {
        verify_device_in_db();
    }

    // Ensure the device is verified before proceeding
    while (!device_verified) {
        vTaskDelay(100 / portTICK_PERIOD_MS);  // Small delay to avoid busy-waiting
    }

    // Create the data sending task
    xTaskCreate(&data_send_task, "data_send_task", 8192, NULL, 5, NULL);
    
    // Create a task to delete old data periodically
    xTaskCreate(&delete_data_task, "delete_data_task", 4096, NULL, 5, NULL);
}
