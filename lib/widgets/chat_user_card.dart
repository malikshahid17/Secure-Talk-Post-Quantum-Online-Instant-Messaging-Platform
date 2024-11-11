import 'package:SecureTalk/utils/encrypt_new.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import '../test.dart';
import 'dialogs/profile_dialog.dart';
import 'profile_image.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null --> no message)
  String? private_key;
  Message? _message;

  String? decryptedMessage; // Store the decrypted message here.

  // Function to decrypt message
  void decryptMessage() async {
    print("decryptMessage");
    print(_message!.fromId);
    String? decryptedMsg =
        EncryptData().decryptDataTwo(private_key!!, _message!.msg, _message!!);

    setState(() {
      decryptedMessage =
          decryptedMsg; // Update the state with decrypted message.
      print("decryptedMessage");
      print(decryptedMessage);
    });
  }

  DocumentSnapshot? userKeys;

  // Function to get user keys asynchronously
  Future<void> getUserKeys() async {
    if (_message != null && _message!.fromId == APIs.user.uid) {
      DocumentSnapshot documentSnapshot =
          await APIs.getUserKeys(_message!.toId);
      setState(() {
        userKeys = documentSnapshot; // Update the userKeys after fetching
      });
    } else {
      DocumentSnapshot documentSnapshot =
          await APIs.getUserKeys(_message!.fromId);
      setState(() {
        userKeys = documentSnapshot; // Update the userKeys after fetching
      });
    }
  }

  Future<void> getKey() async {
    DocumentSnapshot documentSnapshot = await APIs.getMyKey();
    setState(() {
      private_key =
          documentSnapshot.get("temp_public_key"); // Update state with the key
      print("DATA=>>>>>>>>>>>>>>>>>>>>>");
      print(private_key);
      print(private_key);
    });
  }

  @override
  void initState() {
    super.initState();
    decryptMessage(); // Call the function to decrypt on init.
    getKey();
  }

  @override
  Widget build(BuildContext context) {
    // Asynchronous function to decrypt the message

    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () {
            //for navigating to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              getUserKeys();

              return ListTile(
                //user profile picture
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ProfileImage(
                      size: mq.height * .055, url: widget.user.image),
                ),

                //user name
                title: Text(widget.user.name),

                //last message
                subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'image'
                            : userKeys != null
                                ? EncryptData().decryptData(
                                    userKeys!.get("temp_public_key"),
                                    _message!.msg)
                                : 'Loading...'
                        : widget.user.about,
                    maxLines: 1),

                //last message time
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ?
                        //show for unread message
                        const SizedBox(
                            width: 15,
                            height: 15,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 230, 119),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          )
                        :
                        //message sent time
                        Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
