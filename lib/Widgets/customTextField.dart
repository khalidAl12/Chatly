import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



Container customTextField({sendText, sendImage,TextEditingController msgTextController}) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, boxShadow: [
      BoxShadow(
        color: Colors.grey[300],
        offset: Offset(-2, 0),
        blurRadius: 5,
      ),
    ]),
    child: Row(
      children: <Widget>[
        IconButton(icon: Icon(FontAwesomeIcons.image,color: Colors.green[300],),onPressed: sendImage),
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        Flexible(
          child: TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: '..أكتب رسالة',
              border: InputBorder.none,
            ),
            controller: msgTextController,
            maxLines: 3,
            minLines: 1,
          ),
        ),
        IconButton(
          onPressed: sendText,
          icon: Icon(
            Icons.send,
            color: Colors.green,
          ),
        )
      ],
    ),
  );
}

