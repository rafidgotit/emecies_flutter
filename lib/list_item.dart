import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_helper.dart';

class ListItem extends StatefulWidget{
  ListItem({Key key, @required this.name, @required this.phone, @required this.icon, @required this.cover, @required this.id, @required this.onTap}) : super(key: key);
  final String id;
  final String name;
  final String icon;
  final String phone;
  final String cover;
  final VoidCallback onTap;

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem>{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1,
              spreadRadius: 1,
              offset: Offset(1, 1),

            )
          ]
        ),
        child: Material(
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if(widget.id != Ids.FIRE_SERVICE_ID) ClipRRect(
                    borderRadius: BorderRadius.circular((widget.id == Ids.POLICE_STATION_ID)?8:0),
                    child: Container(
                      height: 70,
                      width: 70,
                      child: FittedBox(
                        fit: (widget.id == Ids.POLICE_STATION_ID)?BoxFit.cover:BoxFit.contain,
                        child: Image.memory(
                          Uint8List.fromList(base64Decode((widget.id == Ids.POLICE_STATION_ID)?widget.cover:widget.icon)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade900
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: IconButton(
                      splashRadius: 25,
                      icon: Icon(
                        Icons.call,
                        color: Colors.blue,
                      ),
                      iconSize: 20,
                      onPressed: () => launch("tel://${widget.phone}"),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}