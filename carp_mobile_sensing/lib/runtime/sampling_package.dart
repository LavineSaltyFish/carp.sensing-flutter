part of runtime;

/// A registry of [SamplingPackage] packages.
class SamplingPackageRegistry {
  final List<SamplingPackage> _packages = [];
  final List<Permission> _permissions = [];
  SamplingSchema? _combinedSchemas;

  static final SamplingPackageRegistry _instance = SamplingPackageRegistry._();

  /// Get the singleton [SamplingPackageRegistry].
  factory SamplingPackageRegistry() => _instance;

  /// A list of registered packages.
  List<SamplingPackage> get packages => _packages;

  /// The list of [Permission] needed for the entire list of packages (combined list).
  List<Permission> get permissions => _permissions;

  SamplingPackageRegistry._() {
    // register the built-in packages
    register(DeviceSamplingPackage());
    register(SensorSamplingPackage());
  }

  /// Register a sampling package.
  void register(SamplingPackage package) {
    _combinedSchemas = null;
    _packages.add(package);
    for (var permission in package.permissions) {
      if (!_permissions.contains(permission)) _permissions.add(permission);
    }
    CAMSDataType.add(package.dataTypes);

    // register the package's device in the device registry
    DeviceController()
        .registerDevice(package.deviceType, package.deviceManager);

    // call back to the package
    package.onRegister();
  }

  /// Lookup the [SamplingPackage]s that support the [type] of data.
  ///
  /// Typically, only one package supports a specific type. Howerver, if
  /// more than one package does, all packages are returned.
  /// Can be an empty list.
  Set<SamplingPackage> lookup(String type) {
    final Set<SamplingPackage> supportedPackages = {};

    for (var package in packages) {
      if (package.dataTypes.contains(type)) supportedPackages.add(package);
    }

    return supportedPackages;
  }

  /// The combined list of all measure types in all packages.
  List<String> get dataTypes {
    List<String> dataTypes = [];
    for (var package in packages) {
      dataTypes.addAll(package.dataTypes);
    }
    return dataTypes;
  }

  /// The combined sampling schema for all measure types in all packages.
  SamplingSchema get samplingSchema {
    if (_combinedSchemas == null) {
      _combinedSchemas = SamplingSchema();
      // join sampling schemas from each registered sampling package.
      for (var package in packages) {
        _combinedSchemas!.addSamplingSchema(package.samplingSchema);
      }
    }
    return _combinedSchemas!;
  }

  /// Create an instance of a probe based on its data type.
  ///
  /// This methods search this sampling package registry for a [SamplingPackage]
  /// which has a probe of the specified [type].
  ///
  /// Returns `null` if no probe is found for the specified [type].
  Probe? create(String type) {
    Probe? probe;

    final packages = lookup(type);

    if (packages.isNotEmpty) {
      if (packages.length > 1) {
        warning(
            "$runtimeType - Creating probe, but it seems like the data type '$type' is defined in more than one sampling package.");
      }
      probe = packages.first.create(type);
      probe?.deviceManager = packages.first.deviceManager;
    }

    return probe;
  }
}

/// Interface for a sampling package.
///
/// A sampling package provides information on sampling:
///  * [dataTypes] - the data types supported
///  * [samplingSchema] - the default [SamplingSchema] containing a set of [SamplingConfiguration]s for each data type.
///  * [permissions] - a list of [Permission] needed for this package
///  * [deviceType] - what type of device this package supports
///
/// It also contains factory methods for:
///  * creating a [Probe] based on a [Measure] type
///  * creating a [DeviceManager] based on a device type
abstract class SamplingPackage {
  /// The list of data type this package supports.
  List<String> get dataTypes;

  /// The default sampling schema for all [dataTypes] in this package.
  SamplingSchema get samplingSchema;

  /// The list of permissions that this package need.
  ///
  /// See [PermissionGroup](https://pub.dev/documentation/permission_handler/latest/permission_handler/PermissionGroup-class.html)
  /// for a list of possible permissions.
  ///
  /// For Android permission in the Manifest.xml file,
  /// see [Manifest.permission](https://developer.android.com/reference/android/Manifest.permission.html)
  List<Permission> get permissions;

  /// Creates a new [Probe] of the specified [type].
  /// Returns `null` if a probe cannot be created for this [type].
  Probe? create(String type);

  /// What device type is this package using?
  ///
  /// This device type is matched with the [DeviceDescriptor.roleName] when a
  /// [MasterDeviceDeployment] is deployed on the phone and executed by a
  /// [SmartphoneDeploymentController].
  ///
  /// Default value is a smartphone. Override this if another type is supported.
  ///
  /// Note that it is assumed that a sampling package only supports **one**
  /// type of device.
  String get deviceType;

  /// Get the [DeviceManager] for the device used by this package.
  DeviceManager get deviceManager;

  /// Callback method when this package is being registered.
  void onRegister();
}

/// An abstract class for all sampling packages that run on the phone itself.
abstract class SmartphoneSamplingPackage implements SamplingPackage {
  final SmartphoneDeviceManager _deviceManager = SmartphoneDeviceManager();
  @override
  String get deviceType => Smartphone.DEVICE_TYPE;

  @override
  DeviceManager get deviceManager => _deviceManager;
}
