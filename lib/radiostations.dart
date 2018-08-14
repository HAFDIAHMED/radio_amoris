import 'package:flutter/material.dart';
import 'package:radio_amoris/audioctl.dart';
import 'package:radio_amoris/listitem.dart';
import 'package:radio_amoris/stationsdata.dart';

// https://flutterbyexample.com/set-up-inherited-widget-app-state/
class SharedSelection extends InheritedWidget {
  // The data is whatever this widget is passing down.
  final int uid;

  SharedSelection({
    Key key,
    @required this.uid,
    @required Widget child,
  }) : super(key: key, child: child);

  static SharedSelection of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SharedSelection);
  }

  @override
  bool updateShouldNotify(SharedSelection old) => uid != old.uid;
}

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
  int _selected = -1;

  @override
  void initState() {
    super.initState();
    _playerCtl =  initAudioPlayer();
    initAmorisData(_playerCtl);
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
        body: SharedSelection(
          child: ListView(
                children: _widgetArr,
              ),
          uid: _selected,
          )
      ),
    );
  }

  void initAmorisData(AudioCtl player) {
    var keys = StationsData.keys;
    _widgetArr = new List<Widget>(keys.length * 2);
    for(var i=0; i < _widgetArr.length; i += 2){
      int uid = keys.elementAt(i ~/ 2);
      var item = StationsData[uid];
      _widgetArr[i] = new Station(player, uid, item['descr'], item['url'],
      itemSelectedCallback: (uid){
        setState(() {
            _selected = uid;
          });
      });
      _widgetArr[i+1] = new Divider();
    }
  }

  AudioCtl initAudioPlayer() {
    _playerCtl = new AudioCtl();
    _playerCtl.callbacks['audio.onCreate'] = _onCreated;
    _playerCtl.callbacks['audio.onPause'] = _onPaused;
    _playerCtl.callbacks['audio.onResume'] = _onResumed;
    _playerCtl.callbacks['audio.onError'] = _onError;
    _playerCtl.create();
    return _playerCtl;
  }

  _onCreated(){
    _playerCtl.playerState = PlayerState.created;
  }

  _onError(){
    print("error received");
  }

  _onPaused(){
    _playerCtl.playerState = PlayerState.paused;
  }

  _onResumed(){
    _playerCtl.playerState = PlayerState.playing;
  }
}
