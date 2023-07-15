// ignore_for_file: library_prefixes, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:js';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:streamer_app/app_id/app_id.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;

class Participant extends StatefulWidget {
  bool muted = false;
  bool videoDisabled = false;
  final String channelName;
  final String userName;
  final int uid;
  Participant(
      {Key? key,
      required this.channelName,
      required this.userName,
      required this.uid})
      : super(key: key);

  @override
  State<Participant> createState() => _ParticipantState();
}

class _ParticipantState extends State<Participant> {
  List<int> _users = [];
  late RtcEngine _engine;
  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;

 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    _channel = await _client?.createChannel(widget.channelName);
    await _channel?.join();

    await _engine.joinChannel(null, widget.channelName, null, widget.uid);

    _engine = await RtcEngine.createWithContext(RtcEngineContext(
        appId)); //createWithContext(RtcEngineContext(appId: appId));
    _client = await AgoraRtmClient.createInstance(appId);

    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
//Callbacks for the RTC Engine
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          _users.add(uid);
        });
      },
    ));

    _client?.onConnectionStateChanged2 = (state, reason) {
      print('Connection state changed: $state, reason $reason');

      if (state == 5) {
        _channel?.leave();
        _client?.logout();
        _client?.release();
        print("Logged out");
      }
    };
    _channel?.onMemberJoined = (member) {
      print("Member joined: " + member.userId + 'channel: ' + member.channelId);
    };
    _channel?.onMemberLeft = (member) {
      print("Member left: " + member.userId + 'channel: ' + member.channelId);
    };
    _channel?.onMessageReceived = (message, fromMember) {
      print("Public message");
    };

    await _client?.login(null, widget.uid.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Scaffold(
        body: Center(
          child: Stack(
            children: [_broadcastView(), _toolbar()],
          ),
        ),
      )),
    );
  }
}

Widget _toolbar() {
  return Container(
    alignment: Alignment.bottomCenter,
    padding: const EdgeInsets.all(48),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RawMaterialButton(
          onPressed: _onToggleMute,
          child: Icon(
            muted ? Icons.mic_off : Icons.mic,
            color: muted ? Colors.white : Colors.blueAccent,
            size: 20,
          ),
          shape: const CircleBorder(),
          elevation: 2,
          fillColor: muted ? Colors.blueAccent : Colors.white,
          padding: const EdgeInsets.all(12),
        ),
        RawMaterialButton(
          onPressed: _onCallEnd(context),
          child: Icon(
            Icons.call_end,
            color: Colors.white,
            size: 35,
          ),
          shape: const CircleBorder(),
          elevation: 2,
          fillColor: Colors.redAccent,
          padding: const EdgeInsets.all(15),
        ),
        RawMaterialButton(
          onPressed: _onToggleVideoDisabled,
          child: Icon(
            videoDisabled ? Icons.videocam_off : Icons.videocam,
            color: videoDisabled ? Colors.white : Colors.blueAccent,
            size: 20,
          ),
          shape: const CircleBorder(),
          elevation: 2,
          fillColor: Colors.redAccent,
          padding: const EdgeInsets.all(15),
        ),
        RawMaterialButton(
          onPressed: _onSwitchCamera,
          child: Icon(
            Icons.switch_camera,
            color: Colors.blueAccent,
            size: 20,
          ),
          shape: const CircleBorder(),
          elevation: 2,
          fillColor: Colors.white,
          padding: const EdgeInsets.all(12),
        )
      ],
    ),
  );
}

Widget _broadcastView() {
  return Expanded(
    child: RtcLocalView.SurfaceView(),
  );
}
