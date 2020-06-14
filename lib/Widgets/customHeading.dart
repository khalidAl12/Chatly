import 'package:flutter/material.dart';

Container customHeading({title}) {
  return Container(
    margin: EdgeInsets.only(top: 10, bottom: 10),
    child: Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 15,
          width: 30,
          height: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 1],
                colors: [
                  Colors.greenAccent,
                  Colors.green,
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}