import 'package:chatme/pages/group_info.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:chatme/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../helper/httpClient.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String? token;

  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      this.token})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  String admin = "";
  String searchQuery = '';
  late bool _isSearching = false;
  String _searchText = "";
  bool clear = false;

  QuerySnapshot<Map<String, dynamic>>? searchresult;

  Widget? appBarTitle;

  bool isConnected = true;
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    getChatandAdmin();
    initialization();
    super.initState();
    _isSearching = false;
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSearching
              ? () {
                  _isSearching = false;
                  _controller.clear();
                  setState(() {});
                }
              : () {
                  Navigator.of(context).pop();
                },
        ),
        title: !_isSearching ? appBarTitle : searchField(),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: !_isSearching
                ? const Icon(Icons.search)
                : const SizedBox(
                    height: 0,
                  ),
            onPressed: () {
              _isSearching = true;
              setState(() {});
            },
          ),
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
              icon: const Icon(Icons.info)),
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

  // void searchOperation(String searchText) async {
  //   searchresult = await FirebaseFirestore.instance
  //       .collection('groups')
  //       .doc(widget.groupId)
  //       .collection('messages')
  //       .where('message', isEqualTo: searchText)
  //       .get();
  // }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            setState(() => {});
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
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                      searchTextCtrl: _controller.text,
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() async {
     isConnected = await checkInternetConnection();
       if (isConnected) {
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
  else {
      const snackBar = SnackBar(
        content: Text('No internet connection'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future sendPushNotificationToMembers(chatMessageMap) async {
    var gp = await FirebaseFirestore.instance
        .collection('groups')
        .where('groupId', isEqualTo: widget.groupId)
        .get();

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
          print(
              'Chat User Name : $chatUserName != ${widget.userName} ${widget.userName != chatUserName}');
          if (widget.userName != chatUserName) {
            var resp = await httpClient.pushNotification(
                fcmToken: userToken,
                title: widget.groupName,
                body: "\n${widget.userName}\n${chatMessageMap['message']}");

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

  void initialization() async {
    _controller.addListener(() {
      clear = _controller.text.length > 0;
      setState(() {});
    });
    searchresult = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .get();

    appBarTitle = Text(
      widget.groupName,
      style: const TextStyle(color: Colors.white),
    );

    setState(() {});
  }

  Widget searchField() => SizedBox(
        width: 800,
        child: TextField(
          controller: _controller,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              hintText: "Search...",
              hintStyle: const TextStyle(color: Colors.white),
              suffixIcon: clear
                  ? IconButton(
                      onPressed: () => _controller.clear(),
                      icon: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.cancel,
                          color: Theme.of(context).primaryColor,
                        ),
                      ))
                  : const SizedBox(
                      height: 0,
                    )),
          // onChanged: searchOperation,
        ),
      );
}
