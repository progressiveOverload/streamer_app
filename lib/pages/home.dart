import 'package:flutter/material.dart';
import 'package:streamer_app/pages/director.dart';
import 'package:streamer_app/pages/participant.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _channelName = TextEditingController();
  final _userName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/streamer_2.png"),
            const SizedBox(height: 5),
            const Text("Real time streaming with Friends"),
            const SizedBox(height: 40),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _userName,
                  decoration: InputDecoration(
                      hintText: "User Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey))),
                )),
            const SizedBox(height: 8),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _channelName,
                  decoration: InputDecoration(
                      hintText: "Channel Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey))),
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => Participant(
                            channelName: _channelName.toString(),
                            userName: _userName.toString(),
                          ))));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Participant ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Icon(Icons.live_tv)
                  ],
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => Director(
                            channelName: _channelName.toString(),
                          ))));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Director ",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    Icon(
                      Icons.cut,
                      color: Colors.black,
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
