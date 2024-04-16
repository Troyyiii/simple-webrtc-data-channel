import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webrtc_chat/models/message_model.dart';

class MessageTextItem extends StatelessWidget {
  final MessageModel message;

  const MessageTextItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: message.sender != 'Alice'
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: message.sender != 'Alice'
                        ? const Radius.circular(0)
                        : const Radius.circular(15),
                    topRight: message.sender != 'Alice'
                        ? const Radius.circular(15)
                        : const Radius.circular(0),
                    bottomLeft: const Radius.circular(15),
                    bottomRight: const Radius.circular(15),
                  ),
                  border: Border.all(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: message.sender != 'Alice'
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.sender,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(message.message),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat.Hm().format(message.time!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
