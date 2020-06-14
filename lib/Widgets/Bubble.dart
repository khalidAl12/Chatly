import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../fullPhoto.dart';

class Bubble extends StatelessWidget {
  Bubble({this.message, this.time, this.delivered, this.type, this.isMe});

  final String message, time, type;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.white : Colors.greenAccent.shade100;
    final icon = delivered ? Icons.done_all : Icons.done;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    final radius = isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 48.0),
                child: type == "text"
                    ? Text("$message")
                    : Container(
                        width: 160,
                        height: 160,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhoto(url: message),
                              ),
                            );
                          },
                          //^2.1.0+1
                          child: CachedNetworkImage(
                            imageUrl: message,
                            placeholder: (context, url) => Container(
                              transform: Matrix4.translationValues(0, 0, 0),
                              child: Container(
                                width: 60,
                                height: 80,
                                child: Center(
                                  child: new CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(
                      "$time",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 7.5,
                      ),
                    ),
                    SizedBox(width: 3.0),
                    Icon(icon,
                        size: 12.0,
                        color: delivered ? Colors.blue : Colors.black38)
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
