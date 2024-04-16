import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_chat/models/message_model.dart';
import 'package:webrtc_chat/views/widgets/message_text_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late RTCPeerConnection alice;
  late RTCPeerConnection bob;

  RTCDataChannel? aliceChannel;
  RTCDataChannel? bobChannel;

  List<MessageModel> messages = [];

  TextEditingController messageController = TextEditingController();
  final scrollController = ScrollController();

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
        ]
      },
    ]
  };

  @override
  void initState() {
    _initWebrtc();
    super.initState();
  }

  @override
  void dispose() {
    alice.close();
    bob.close();
    super.dispose();
  }

  _initWebrtc() async {
    alice = await createPeerConnection(_configuration);
    bob = await createPeerConnection(_configuration);

    alice.onIceCandidate = (event) {
      if (event.candidate != null) {
        bob.addCandidate(event);
      }
    };

    bob.onIceCandidate = (event) {
      if (event.candidate != null) {
        alice.addCandidate(event);
      }
    };

    aliceChannel = await alice.createDataChannel('test', RTCDataChannelInit());
    bobChannel = await bob.createDataChannel('test', RTCDataChannelInit());

    alice.onDataChannel = (channel) {
      _setupDataChannel(channel, 'Bob');
    };

    bob.onDataChannel = (channel) {
      _setupDataChannel(channel, 'Alice');
    };

    final offer = await alice.createOffer();
    await alice.setLocalDescription(offer);
    // log('Alice local description set: ${offer.sdp}');
    await bob.setRemoteDescription(offer);
    // log('Bob remote description set: ${offer.sdp}');

    final answer = await bob.createAnswer();
    await bob.setLocalDescription(answer);
    // log('Bob local description set: ${answer.sdp}');
    await alice.setRemoteDescription(answer);
    // log('Alice remote description set: ${answer.sdp}');
  }

  _setupDataChannel(RTCDataChannel channel, String sender) {
    channel.onMessage = (data) {
      log('$sender: ${data.text}');
      setState(() {
        messages.add(MessageModel(
            sender: sender, message: data.text, time: DateTime.now()));
      });
    };
  }

  Future<void> _sendAlice(String message) async {
    messageController.clear();
    await aliceChannel!.send(RTCDataChannelMessage(message));
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _sendBob(String message) async {
    messageController.clear();
    await bobChannel!.send(RTCDataChannelMessage(message));
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('WebRTC DataChannel Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageTextItem(message: messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      _sendAlice(messageController.text);
                    }
                  },
                  child: const Text('Alice'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      _sendBob(messageController.text);
                    }
                  },
                  child: const Text('Bob'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
