part of mobile_sensing_app;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoadingPage(),
    );
  }
}

class LoadingPage extends StatelessWidget {
  /// This methods is used to set up the entire app, including:
  ///  * initialize the bloc
  ///  * authenticate the user
  ///  * get the invitation
  ///  * get the study
  ///  * initialize sensing
  ///  * start sensing
  Future<bool> init(BuildContext context) async {
    // only initialize the CARP backend bloc, if needed
    if (bloc.deploymentMode != DeploymentMode.LOCAL) {
      await CarpBackend().initialize();
      await CarpBackend().authenticate(context, username: 'jakob@bardram.net');

      // check if there is a local deploymed id
      // if not, get a deployment id based on an invitation
      if (bloc.studyDeploymentId == null) {
        await CarpBackend().getStudyInvitation(context);
      }
    }
    await Sensing().initialize();
    LocationManager().initialize();

    BlocDataCollector().pause();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(context),
      builder: (context, snapshot) => (!snapshot.hasData)
          ? Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()],
              )))
          : CarpMobileSensingApp(key: key),
    );
  }
}

class CarpMobileSensingApp extends StatefulWidget {
  CarpMobileSensingApp({Key? key}) : super(key: key);
  @override
  CarpMobileSensingAppState createState() => CarpMobileSensingAppState();
}

class CarpMobileSensingAppState extends State<CarpMobileSensingApp> {
  int _selectedIndex = 0;
  //static ValueNotifier<int> _usageDays = ValueNotifier<int>(0);

  final _pages = [
    // NavigatePage(),
    PageMaps(),
    PersonalInfoPage(),
    DataReviewPage()
    //PersonalInfoSurvey()
    //SimpleMarkerAnimationExample()
    //StudyDeploymentPage(),
    //ProbesList(),
    // DataVisualization(),
    // DevicesList(),
    //TestPage(),
  ];


  @override
  void dispose() {
    bloc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.adb), label: 'Probes'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Data'),
          //BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Devices'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: restart,
      //   tooltip: 'Restart study & probes',
      //   child: bloc.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      // ),
    );
  }

  //#region PERSISTENT NAVIGATION BAR

  // PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  //
  // List<PersistentBottomNavBarItem> _navBarsItems() {
  //   return [
  //     PersistentBottomNavBarItem(
  //       icon: Icon(CupertinoIcons.map),
  //       title: ("Navigation"),
  //       activeColorPrimary: CupertinoColors.activeBlue,
  //       inactiveColorPrimary: CupertinoColors.systemGrey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(CupertinoIcons.person),
  //       title: ("Personal Information"),
  //       activeColorPrimary: CupertinoColors.activeBlue,
  //       inactiveColorPrimary: CupertinoColors.systemGrey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(CupertinoIcons.book),
  //       title: ("Data Review"),
  //       activeColorPrimary: CupertinoColors.activeBlue,
  //       inactiveColorPrimary: CupertinoColors.systemGrey,
  //     ),
  //   ];
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return PersistentTabView(
  //   context,
  //   controller: _controller,
  //   screens: _pages,
  //   items: _navBarsItems(),
  //   confineInSafeArea: true,
  //   backgroundColor: Colors.black, // Default is Colors.white.
  //   handleAndroidBackButtonPress: true, // Default is true.
  //   resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
  //   stateManagement: true, // Default is true.
  //   hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
  //   decoration: NavBarDecoration(
  //   borderRadius: BorderRadius.circular(10.0),
  //   colorBehindNavBar: Colors.black,
  //   ),
  //   popAllScreensOnTapOfSelectedTab: true,
  //   popActionScreens: PopActionScreensType.all,
  //   itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
  //   duration: Duration(milliseconds: 200),
  //   curve: Curves.ease,
  //   ),
  //   screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
  //   animateTabTransition: true,
  //   curve: Curves.ease,
  //   duration: Duration(milliseconds: 200),
  //   ),
  //   navBarStyle: NavBarStyle.style13, // Choose the nav bar style with this property.
  //   );
  // }

  //#endregion PERSISTENT NAVIGATION BAR

  static ValueNotifier<double> _speed = ValueNotifier<double>(0.0);
  static ValueNotifier<Duration> _timer = ValueNotifier<Duration>(Duration(hours:0,minutes:0,seconds:0));
  static ValueNotifier<double> _gyro = ValueNotifier<double>(0.0);
  static ValueNotifier<int> _heartRate = ValueNotifier<int>(0);
  //static ValueNotifier<double> _heartRate = ValueNotifier<double>(0.0);

  static ValueNotifier<String> _weather = ValueNotifier<String>("-");
  static ValueNotifier<double> _windSpeed = ValueNotifier<double>(0.0);

  static ValueNotifier<double> _latitude = ValueNotifier<double>(_NavigatePageState._kGooglePlex.target.latitude);
  static ValueNotifier<double> _longitude = ValueNotifier<double>(_NavigatePageState._kGooglePlex.target.longitude);


  static ValueNotifier<double> _totalDistance = ValueNotifier<double>(0.0);

  bool isTimerOn = false;
  static ValueNotifier<Duration> _totalTime = ValueNotifier<Duration>(Duration(hours:0,minutes:0,seconds:0));


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      //Sensing().controller?.data.listen((dataPoint) => _onMapRebuild(dataPoint));
    });
  }

  void restart() {
    setState(() {
      if (bloc.isRunning) {
        bloc.pause();
        //_time.value = Duration(seconds: 0);
        isTimerOn = false;
        _totalTime.value += _timer.value;
      } else {
        bloc.resume();
        isTimerOn = true;

        DateTime startTime = DateTime.now();
        Timer.periodic(new Duration(seconds: 1), (timer) {
            if (!isTimerOn){
              timer.cancel();
            }
            else{
              _timer.value = _onTimerUpdated(startTime);
            }
        });

        //Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == SensorSamplingPackage.ACCELEROMETER).
        Sensing().controller?.data
        //.where((dataPoint) => dataPoint.data!.format.toString() == ContextSamplingPackage.LOCATION)
        .listen((dataPoint) => _onMoveAcquired(dataPoint));

        Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == PolarSamplingPackage.POLAR_HR)
            .listen((dataPoint) => _onHeartRateAcquired(dataPoint));

        Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == ContextSamplingPackage.WEATHER)
            .listen((dataPoint) => _onWeatherAcquired(dataPoint));

        Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == ContextSamplingPackage.MOBILITY)
            .listen((dataPoint) => _onMobilityAcquired(dataPoint));



        // Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == SensorSamplingPackage.GYROSCOPE)
        //     .listen((dataPoint) => _onGyroAcquired(dataPoint));
        // Sensing().controller?.data.where((dataPoint) => dataPoint.data!.format.toString() == ContextSamplingPackage.LOCATION)
        //     .listen((dataPoint) => _onLocationUpdated(dataPoint));


      }
    });
  }

  // void onData(DataPoint dataPoint) {
  //   _onSpeedAcquired(dataPoint);
  // }

  //
  // Future<CameraPosition> _onMapRebuild(DataPoint data) async {
  //   var dataDict = data.carpBody;
  //   CameraPosition _kGooglePlex = CameraPosition(
  //          target: LatLng(dataDict!["latitude"] as double, dataDict!["longitude"] as double),
  //          zoom: 14.4746,
  //          );
  //   return _kGooglePlex;
  // }
  //

  void _onMoveAcquired(DataPoint data) async {
    var dataDict = data.carpBody;
    _speed.value = dataDict!["speed"]*3.6 as double;

    //_time.value = dataDict!["distance_travelled"] as double;

  }

  void _onWeatherAcquired(DataPoint data) async {
    var dataDict = data.carpBody;
    _weather.value = dataDict!["weather_main"] as String;
    _windSpeed.value = dataDict!["wind_speed"] as double;
  }

  void _onHeartRateAcquired(DataPoint data) async {
    var dataDict = data.carpBody;
    _heartRate.value = dataDict!["hr"] as int;
  }

  void _onMobilityAcquired(DataPoint data) async {
    var dataDict = data.carpBody;
    _totalDistance.value = dataDict!["distance_travelled"] as double;


  }

  Duration _onTimerUpdated(DateTime startTime) {
    return DateTime.now().difference(startTime);
  }

}
