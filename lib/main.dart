// ignore_for_file: avoid_print, prefer_const_constructors, non_constant_identifier_names

import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Define App ID and Token
  String APP_ID = '4f4759258e124d928872abea6595df76';
  String Token =
      '0064f4759258e124d928872abea6595df76IABK/zwjzWB9e3232tR2VCsE8aggM1U8jB2jxkw4nzcI4NJjSIgAAAAAEAATtvR9yHwdYgEAAQDIfB1i';

  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter example app'),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                        _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Init Code
  Future<void> initPlatformState() async {
    /// ?????? ?????? ?????? ??????
    await [Permission.camera, Permission.microphone].request();

    /// RTC ???????????? ??????
    RtcEngineContext context = RtcEngineContext(APP_ID);
    var engine = await RtcEngine.createWithContext(context);

    /// ??? ???????????? ?????? ?????? ?????? (????????? ????????? ??????)
    engine.setEventHandler(RtcEngineEventHandler(

        /// ?????? ????????? ???????????? ???
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess $channel $uid');
      setState(() {
        _joined = true;
      });

      /// ????????? ???????????? ???
    }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });

      /// ????????? ???????????? ???
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));

    /// ???????????? ?????????.
    await engine.enableVideo();

    /// ????????? ???????????? ????????? ???????????????.
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);

    /// ????????? ??????????????? ???????????????.
    await engine.setClientRole(ClientRole.Broadcaster);

    /// ????????? ???????????? 123?????? ???????????????.
    await engine.joinChannel(Token, '123', null, 0);
  }

  // Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: '123',
      );
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}
