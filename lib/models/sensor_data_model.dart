class SensorData {
  final double waterTemperature;
  final double ph;
  final int timestamp;
  final DateTime timeUpload;
  final double waterTempInFahrenheit;

  SensorData(this.waterTemperature, this.ph, this.timestamp, this.timeUpload,
      this.waterTempInFahrenheit);
}
