import 'package:chatme/pages/group_info.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:chatme/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helper/httpClient.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String? token;

  const ChatPage({Key? key, required this.groupId, required this.groupName, required this.userName, this.token}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // print(
    //     "UserName : ${widget.userName} : GroupName : ${widget.groupName} \n Token : ${widget.token} "
    //     " \n : ${widget.groupId}");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          // chat messages here
          chatMessages(),
          Container(
            // color: Colors.redAccent.withOpacity(0.5),
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(0.5),
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            setState(() => null);
          }
        });
        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName == snapshot.data.docs[index]['sender']);
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      await sendPushNotificationToMembers(chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  Future sendPushNotificationToMembers(chatMessageMap) async {
    var gp = await FirebaseFirestore.instance.collection('groups').where('groupId', isEqualTo: widget.groupId).get();

    CollectionReference query = FirebaseFirestore.instance.collection('users');

    Map gpData = gp.docs.first.data();
    // print("Group Mem : ${gpData}");
    List memberList = gpData['members'];
    String gpAdmin = gpData['admin'];

    memberList.forEach((element) async {
      String memberId = element.toString().substring(0, 28);
      String chatUserName = element.toString().substring(29);

      var userQuery = await query.where('uid', isEqualTo: memberId).get();
      var userInfo = userQuery.docs.first.data() as Map;
      String userToken = userInfo['token'];
      List userGroups = userInfo['groups'];
      String uid = userInfo['uid'];

      if (userGroups.contains("${widget.groupId}_${widget.groupName}")) {
        try {
          print('Chat User Name : $chatUserName != ${widget.userName} ${widget.userName != chatUserName}');
          if (widget.userName != chatUserName) {
            var resp = await httpClient.pushNotification(fcmToken: userToken, title: widget.groupName, body: "\n${widget.userName}\n${chatMessageMap['message']}");

            if (resp.statusCode == 200) {
              print("$chatUserName - Token : $userToken ");
              print("Push Notification send Status : ${resp.body}");
            } else {
              print("Failed to send Notification");
            }
          }
        } catch (errors) {
          print("Error : $errors");
        }
      }
    });
  }
}
