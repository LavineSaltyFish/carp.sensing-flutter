/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of connectivity;

/// A [Datum] that holds connectivity status of the phone.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ConnectivityDatum extends Datum {
  @override
  DataFormat get format =>
      DataFormat.fromString(ConnectivitySamplingPackage.CONNECTIVITY);

  /// The status of the connectivity.
  /// - WiFi: Device connected via Wi-Fi
  /// - Mobile: Device connected to cellular network
  /// - None: Device not connected to any network
  String connectivityStatus = "unknown";

  ConnectivityDatum() : super();

  ConnectivityDatum.fromConnectivityResult(ConnectivityResult result)
      : connectivityStatus = _parseConnectivityStatus(result),
        super();

  factory ConnectivityDatum.fromJson(Map<String, dynamic> json) =>
      _$ConnectivityDatumFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConnectivityDatumToJson(this);

  static String _parseConnectivityStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return "wifi";
      case ConnectivityResult.mobile:
        return "mobile";
      case ConnectivityResult.none:
        return "none";
      default:
        return "unknown";
    }
  }

  @override
  String toString() =>
      '${super.toString()}, connectivityStatus: $connectivityStatus';
}

/// A [Datum] that holds information of nearby Bluetooth devices.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BluetoothDatum extends Datum {
  @override
  DataFormat get format =>
      DataFormat.fromString(ConnectivitySamplingPackage.BLUETOOTH);

  List<BluetoothDevice> scanResult = [];

  BluetoothDatum() : super();

  factory BluetoothDatum.fromScanResults(List<ScanResult> results) =>
      BluetoothDatum()
        ..scanResult =
            results.map((r) => BluetoothDevice.fromScanResult(r)).toList();

  factory BluetoothDatum.fromJson(Map<String, dynamic> json) =>
      _$BluetoothDatumFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BluetoothDatumToJson(this);

  @override
  String toString() => '${super.toString()}, scanResult: $scanResult';
}

/// Bluetooth device data.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BluetoothDevice {
  /// The bluetooth advertising name of the device.
  String advertisementName;

  /// The bluetooth id of the nearby device.
  String bluetoothDeviceId;

  /// The bluetooth name of the nearby device.
  String bluetoothDeviceName;

  /// The type of bluetooth device:
  /// - classic
  /// - dual
  /// - le
  /// - unknown
  String bluetoothDeviceType;

  /// Is the device connectable.
  bool connectable;

  /// The power level of the device in percentage.
  int? txPowerLevel;

  /// The RSSI signal strength to the device.
  int rssi;

  BluetoothDevice({
    required this.advertisementName,
    required this.bluetoothDeviceId,
    required this.bluetoothDeviceName,
    required this.bluetoothDeviceType,
    required this.connectable,
    required this.rssi,
    this.txPowerLevel,
  }) : super();

  factory BluetoothDevice.fromScanResult(ScanResult result) => BluetoothDevice(
      bluetoothDeviceId: result.device.id.id,
      bluetoothDeviceName: result.device.name,
      connectable: result.advertisementData.connectable,
      txPowerLevel: result.advertisementData.txPowerLevel,
      advertisementName: result.advertisementData.localName,
      rssi: result.rssi,
      bluetoothDeviceType: getBluetoothDeviceType(
        result.device.type,
      ));

  static String getBluetoothDeviceType(BluetoothDeviceType type) {
    switch (type) {
      case BluetoothDeviceType.classic:
        return "classic";
      case BluetoothDeviceType.dual:
        return "dual";
      case BluetoothDeviceType.le:
        return "le";
      default:
        return "unknown";
    }
  }

  factory BluetoothDevice.fromJson(Map<String, dynamic> json) =>
      _$BluetoothDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$BluetoothDeviceToJson(this);

  @override
  String toString() => '$runtimeType - '
      ', advertisementName: $advertisementName'
      ', id: $bluetoothDeviceId'
      ', name: $bluetoothDeviceName'
      ', type: $bluetoothDeviceType'
      ', connectable: $connectable'
      ', rssi: $rssi';
}

/// A [Datum] that holds wifi connectivity status in terms of connected SSID
/// and BSSID.
///
/// Note that it wifi information cannot be collected on emulators.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class WifiDatum extends Datum {
  @override
  DataFormat get format =>
      DataFormat.fromString(ConnectivitySamplingPackage.WIFI);

  /// The wifi service set ID (SSID) of the connected network
  String? ssid;

  /// The basic service set identifier (BSSID) of the connected network
  String? bssid;

  /// The internet protocol (IP) address of the connected network
  String? ip;

  WifiDatum({
    this.ssid,
    this.bssid,
    this.ip,
  }) : super();

  factory WifiDatum.fromJson(Map<String, dynamic> json) =>
      _$WifiDatumFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WifiDatumToJson(this);

  @override
  String toString() =>
      '${super.toString()}, SSID: $ssid, BSSID: $bssid, IP: $ip';
}
