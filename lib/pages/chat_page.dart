import 'package:chatme/pages/group_info.dart';
import 'package:chatme/service/check_internet_connectivity.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/common_widgets.dart';
import 'package:chatme/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  bool clear = false;

  QuerySnapshot<Map<String, dynamic>>? searchresult;

  Widget? appBarTitle;

  List chatHistory = [];

  List matechedList = [];
  int currentIndex = 0;

   bool isConnected = true;
  CheckInternetConnectivity c = CheckInternetConnectivity();

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

  final scrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    final node = FocusManager.instance.primaryFocus;
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
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _isSearching = true;
                setState(() {});
              },
            ),
          if (_isSearching && _controller.text.isNotEmpty)
            Row(
              children: [
                // Top Arrow Icon with Scroll Logic
                IconButton(
                    onPressed: () async {
                      node!.unfocus();

                      if (currentIndex >= 0 &&
                          currentIndex < matechedList.length) {
                        await scrollToIndexValue(matechedList[currentIndex]);
                        print(
                            "Chat History1 $matechedList : ${matechedList[currentIndex]}");
                      }

                      if (matechedList.length >= 0 &&
                          currentIndex < matechedList.length) {
                        print(
                            "Chat History2 $matechedList : ${matechedList[currentIndex]}");
                        currentIndex++;
                      }
                      setState(() {});
                      print("CCCCCCCCCCCCCC : $currentIndex");
                    },
                    icon: Icon(Icons.keyboard_arrow_down_sharp)),

                // Down Arrow Icon with Scroll Logic
                IconButton(
                    onPressed: () async {
                      node!.unfocus();
                      print("cuuuurent minus : $currentIndex");

                      if (currentIndex != 0 &&
                          currentIndex <= matechedList.length) {
                        currentIndex--;

                        await scrollToIndexValue(matechedList[currentIndex]);
                        print(
                            "Chat History4 $matechedList index $currentIndex : ${matechedList[currentIndex]}");
                      }

                      setState(() {});
                    },
                    icon: Icon(Icons.keyboard_arrow_up_sharp)),
              ],
            ),
          if (!_isSearching)
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
      floatingActionButton: _controller.text.length > 0
          ? Transform.translate(
              offset: const Offset(0, -80),
              child: Container(
                height: 20,
                width: 60,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                child: Center(
                  child: Text("$currentIndex of ${matechedList.length}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            )
          : const SizedBox(
              height: 0,
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
          if (scrollController.hasClients) {
            _controller.text.isEmpty
                ? scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut)
                : null;
          } else {
            setState(() => {});
          }
        });

        if (snapshot.hasData) {
          chatHistory = snapshot.data.docs.map((e) => e['message']).toList();
          chatHistory.forEach((element) {});
        }

        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return AutoScrollTag(
                      key: ValueKey(index),
                      controller: scrollController,
                      index: index,
                      child: MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        searchTextCtrl: _controller.text,
                        scrollerCtrl: scrollController,
                        chatMsgHistory: chatHistory,
                        index: index,
                      ),
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  Future<void> scrollToIndexValue(int index) async {
    await scrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }

   sendMessage() async {
     isConnected = await c.checkInternetConnection();
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
          onChanged: (val) {
            currentIndex = 0;
            if (matechedList.length > 0) matechedList.length = 0;
            RegExp regexSearchText = RegExp(val, caseSensitive: false);
            int i = 0;
            for (final item in chatHistory) {
              if (regexSearchText.hasMatch(item)) {
                matechedList.add(i);
              }

              i++;
            }

            if (matechedList.length > 0) {
              scrollToIndexValue(matechedList[0]);
            }
            setState(() {});
          },

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
