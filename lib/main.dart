import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:background_geolocation_firebase/background_geolocation_firebase.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

void main() {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _enabled;
  late String _locationJSON;
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  @override
  void initState() {
    _enabled = false;
    _locationJSON = "Toggle the switch to start tracking.";

    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      // ignore: avoid_print
      print('[location] $location');
      setState(() {
        _locationJSON = _encoder.convert(location.toMap());
      });
    });

    BackgroundGeolocationFirebase.configure(BackgroundGeolocationFirebaseConfig(
      locationsCollection: "locations",
      updateSingleDocument: false
    ));

    bg.BackgroundGeolocation.ready(bg.Config(
      debug: true,
      distanceFilter: 50,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      stopTimeout: 1,
      stopOnTerminate: false,
      startOnBoot: true
    )).then((bg.State state) {
      setState(() {
        _enabled = state.enabled;
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }


  void _onClickEnable(bool enabled) {
    setState(() {
      _enabled = enabled;
    });

    if (enabled) {
      bg.BackgroundGeolocation.start();
    } else {
      bg.BackgroundGeolocation.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GNSSlog', style: TextStyle(color: Colors.black)),
          backgroundColor: const Color.fromARGB(255, 245, 0, 0),
          actions: <Widget>[
            Switch(value: _enabled, onChanged: _onClickEnable),
          ], systemOverlayStyle: SystemUiOverlayStyle.dark
        ),
        body: Text(_locationJSON)
      ),
    );
  }
}
