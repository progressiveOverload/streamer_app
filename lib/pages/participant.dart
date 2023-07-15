import 'dart:ffi';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:streamer_app/app_id/app_id.dart';

class Participant extends StatefulWidget {
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

    await _engine?.joinChannel(null, widget.channelName, null, widget.uid);

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
      print('Connection state changed: ' +
          state.toString() +
          ', reason ' +
          reason.toString());

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

  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Participant")),
    );
  }
}
