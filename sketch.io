#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

const char* ssid = "Wokwi-GUEST";
const char* password = "";

String apiKey = "OWA9DCDSN3FA1QA3";

#define DHTPIN 15
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);

const char* server = "http://api.thingspeak.com/update";

void setup() {
  Serial.begin(115200);

  dht.begin();

  WiFi.begin(ssid, password, 6);

  Serial.print("Menghubungkan ke WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("WiFi berhasil terhubung!");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {

    float suhu = dht.readTemperature();
    float kelembapan = dht.readHumidity();

    if (isnan(suhu) || isnan(kelembapan)) {
      Serial.println("Gagal membaca sensor DHT22");
      delay(20000);
      return;
    }

    Serial.println("Data Sensor:");
    Serial.print("Suhu: ");
    Serial.println(suhu);

    Serial.print("Kelembapan: ");
    Serial.println(kelembapan);

    HTTPClient http;

    String url = String(server) +
      "?api_key=" + apiKey +
      "&field1=" + String(suhu) +
      "&field2=" + String(kelembapan);

    http.begin(url);

    int httpCode = http.GET();

    Serial.print("HTTP Response: ");
    Serial.println(httpCode);

    if (httpCode == 200) {
      String response = http.getString();
      Serial.print("ThingSpeak Entry ID: ");
      Serial.println(response);

      if (response.toInt() > 0) {
        Serial.println("Data berhasil dikirim!");
      } else {
        Serial.println("Data belum berhasil disimpan!");
      }
    }

    http.end();

  } else {
    Serial.println("WiFi terputus!");
  }

  delay(20000);
}
