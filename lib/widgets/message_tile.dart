import 'package:flutter/material.dart';
import 'package:search_highlight_text/search_highlight_text.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final String? searchTextCtrl;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe,
      this.searchTextCtrl})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            SearchTextInheritedWidget(
                searchText: widget.searchTextCtrl,
                highlightStyle: const TextStyle(backgroundColor: Colors.grey, fontSize: 16,
                      color: Colors.white,),
                child: SearchHighlightText(widget.message,style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),)),

            // RichText(
            //     text: TextSpan(
            //         children: hilightChartText(
            //             widget.message, widget.searchTextCtrl!),
            //         style: const TextStyle(
            //           fontSize: 16,
            //           color: Colors.white,
            //         ))),
          ],
        ),
      ),
    );
  }

  List<TextSpan> hilightChartText(String chatText, String textCtrl) {
    if (textCtrl.isEmpty ||
        !chatText.toLowerCase().contains(textCtrl.toLowerCase())) {
      return [
        TextSpan(
            text: chatText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ))
      ];
    }

    var matches;
    List ctrl = textCtrl.split('');
    if (chatText.toLowerCase().contains(textCtrl.toLowerCase())) {
      matches = chatText.toLowerCase().allMatches(textCtrl.toLowerCase());
    }

    print("matches ree ; == $matches");

    int lastMatchEnd = 0;

    final List<TextSpan> children = [];

    if (matches.length > 0) {
      print("Rehaman Matches Data Found:  ${matches.length}");

      for (int i = 0; i < matches.length; i++) {
        final match = matches.elementAt(i);
        print("Match : ${match.end} \n Match Start : ${match.start}");

        if (match.start != lastMatchEnd) {
          children.add(TextSpan(
              text: chatText.substring(lastMatchEnd, match.start),
              style:
                  const TextStyle(backgroundColor: Colors.grey, fontSize: 16)));
        }

        children.add(TextSpan(
            text: chatText.substring(match.start, match.end),
            style:
                const TextStyle(backgroundColor: Colors.grey, fontSize: 16)));

        if (i == matches.length - 1 && match.end != chatText.length) {
          children.add(TextSpan(
            text: chatText.substring(match.end, chatText.length),
          ));
        }

        lastMatchEnd = match.end;
        print("enddddd : $lastMatchEnd");
      }
    } else {
      print("Matches not found");
    }

    if (textCtrl.isEmpty ||
        !chatText.toLowerCase().contains(textCtrl.toLowerCase())) {
      return [
        TextSpan(
            text: chatText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ))
      ];
    }

    return children;
  }
}
