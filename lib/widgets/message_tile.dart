import 'package:flutter/material.dart';

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
            RichText(
                text: TextSpan(
                    children: hilightSearchText(
                        widget.message, widget.searchTextCtrl!),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ))),
          ],
        ),
      ),
    );
  }

  hilightSearchText(String? text, String? searchText) {
    RegExp? regexSearchText = RegExp(searchText!);
    List<TextSpan> textSpan = [];
    int lastEnd = 0;
    // ignore: unrelated_type_equality_checks
    if (regexSearchText == {} || regexSearchText.pattern.isEmpty) {
      return [
        TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ))
      ];
    }
    for (final match in regexSearchText.allMatches(text!.toLowerCase())) {
      if (match.start > lastEnd) {
        textSpan.add(TextSpan(
            text: text.substring(lastEnd, match.start),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            )));
      }
      textSpan.add(TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            backgroundColor: Colors.grey,
            fontSize: 16,
            color: Colors.white,
          )));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      textSpan.add(TextSpan(
          text: text.substring(lastEnd),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          )));
    }
    return textSpan;
  }
}
