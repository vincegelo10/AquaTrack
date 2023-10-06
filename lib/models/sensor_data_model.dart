class SensorData {
  final double waterTemperature;
  final double ph;
  final int timestamp;
  final DateTime timeUpload;
  final double waterTempInFahrenheit;
  final double dissolvedOxygen;

  SensorData(this.waterTemperature, this.ph, this.timestamp, this.timeUpload,
      this.waterTempInFahrenheit, this.dissolvedOxygen);
}
