/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of esense;

/// Abstract eSense datum class.
abstract class ESenseDatum extends Datum {
  /// The name of eSense device that generated this datum.
  String deviceName;
  ESenseDatum(this.deviceName) : super();

  @override
  String toString() => '${super.toString()}, device name: $deviceName';
}

/// Holds information about an eSense button pressed event.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ESenseButtonDatum extends ESenseDatum {
  @override
  DataFormat get format =>
      DataFormat.fromString(ESenseSamplingPackage.ESENSE_BUTTON);

  ESenseButtonDatum({required String deviceName, required this.pressed})
      : super(deviceName);

  factory ESenseButtonDatum.fromButtonEventChanged(
          String deviceName, ButtonEventChanged event) =>
      ESenseButtonDatum(deviceName: '', pressed: event.pressed);

  factory ESenseButtonDatum.fromJson(Map<String, dynamic> json) =>
      _$ESenseButtonDatumFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ESenseButtonDatumToJson(this);

  /// true if the button is pressed, false if it is released
  bool pressed;

  @override
  String toString() => '${super.toString()}, button pressed: $pressed';
}

/// Holds information about an eSense button pressed event.
///
/// This datum is a 1:1 mapping of the
/// eSense [SensorEvent](https://pub.dev/documentation/esense/latest/esense/SensorEvent-class.html) event.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ESenseSensorDatum extends ESenseDatum {
  @override
  DataFormat get format =>
      DataFormat.fromString(ESenseSamplingPackage.ESENSE_SENSOR);

  /// Sequential number of sensor packets.
  /// The eSense device don't have a clock, so this index reflect the order of reading.
  int? packetIndex;

  /// 3-elements array with X, Y and Z axis for accelerometer
  List<int>? accel;

  /// 3-elements array with X, Y and Z axis for gyroscope
  List<int>? gyro;

  ESenseSensorDatum(
      {required String deviceName,
      DateTime? timestamp,
      this.packetIndex,
      this.accel,
      this.gyro})
      : super(deviceName) {
    if (timestamp != null) this.timestamp = timestamp;
  }

  factory ESenseSensorDatum.fromSensorEvent(
          {required String deviceName, required SensorEvent event}) =>
      ESenseSensorDatum(
          deviceName: deviceName,
          timestamp: event.timestamp,
          packetIndex: event.packetIndex,
          gyro: event.gyro,
          accel: event.accel);

  factory ESenseSensorDatum.fromJson(Map<String, dynamic> json) =>
      _$ESenseSensorDatumFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ESenseSensorDatumToJson(this);

  @override
  String toString() => '${super.toString()}'
      ', packetIndex: $packetIndex'
      ', accl: [${accel![0]},${accel![1]},${accel![2]}]'
      ', gyro: [${gyro![0]},${gyro![1]},${gyro![2]}]';
}
