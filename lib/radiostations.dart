import 'dart:async';

import 'package:flutter/material.dart';
import 'package:radio_amoris/audioctl.dart';
import 'package:radio_amoris/listitem.dart';
import 'package:radio_amoris/stationsdata.dart';

class RadioStations extends StatefulWidget {

  RadioStations({ Key key }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new StationlistState();
  }
}

class StationlistState  extends State<RadioStations>{
  List<Widget> _widgetArr;
  AudioCtl _playerCtl;
  Completer _completer;

  @override
  void initState() {
    super.initState();
    initAmorisData();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _playerCtl.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'ANIMA AMORIS';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: _widgetArr,
        ),
      ),
    );
  }

  void initAmorisData() {
    var keys = StationsData.keys;
    _widgetArr = new List<Widget>(keys.length * 2);
    for(var i=0; i < _widgetArr.length; i += 2){
      var item = StationsData[keys.elementAt(i ~/ 2)];
      _widgetArr[i] = new Station(_playerCtl, item['descr'], item['url']);
      _widgetArr[i+1] = new Divider();
    }
  }

  void initAudioPlayer() {
    _playerCtl = new AudioCtl();
    _playerCtl.callbacks['audio.onCreate'] = _onCreated;
    _playerCtl.callbacks['audio.onDestroy'] = _onDestroying;
    _playerCtl.callbacks['audio.onPause'] = _onPaused;
    _playerCtl.callbacks['audio.onResume'] = _onResumed;
    _playerCtl.callbacks['audio.onError'] = _onError;
    _playerCtl.create(StationsData[1]['url']);
  }

  _onCreated(){
    setState(() {
      _playerCtl.playerState = PlayerState.created;
    });
  }

  _onError(){
    print("error received");
    _completer.completeError(null);
  }

  _onDestroying(){
    _playerCtl.playerState = PlayerState.destroyed;
  }

  _onPaused(){
    setState(() {
      _playerCtl.playerState = PlayerState.paused;
    });
  }

  _onResumed(){
    setState(() {
      _playerCtl.playerState = PlayerState.playing;
    });
  }
}
