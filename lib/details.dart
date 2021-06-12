import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';

import 'database_helper.dart';
import 'downloader.dart';

class DetailsScreen extends StatefulWidget{
  DetailsScreen({Key key, @required this.data, @required this.id, @required this.position}) : super(key: key);
  final Data data;
  final String id;
  final Position position;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>{

  @override
  Widget build(BuildContext context) {
    Data data = widget.data;
    Size screenSize = MediaQuery.of(context).size;

    Uint8List icon;
    if(widget.id != Ids.AMBULANCE_ID) icon = base64Decode(data.icon);

    return Container(
      margin: EdgeInsets.only(top: 70),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        color: Colors.white,
      ),
      height: screenSize.height,
      width: screenSize.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                            color: Colors.black26
                        ),
                        child: Image.memory(
                          Uint8List.fromList(base64Decode(data.cover)),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: MemoryImage(Uint8List.fromList(base64Decode(data.icon))),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: RawMaterialButton(
                      onPressed: () => Navigator.pop(context),
                      fillColor: Colors.white,
                      constraints: BoxConstraints(minWidth: 25, maxWidth: 25, maxHeight: 25, minHeight: 25),
                      child: Icon(
                        Icons.close,
                        size: 18.0,
                        color: Colors.blue,
                      ),
                      shape: CircleBorder(),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Text(
                data.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      blurRadius: 2
                    )
                  ]
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 15, 10),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2),
                    blurRadius: 2,
                    spreadRadius: 1.5
                  ),
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          data.phone,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            letterSpacing: 1,
                            fontSize: 17,
                          ),
                        )
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () => launch("tel://${data.phone}"),
                    fillColor: Colors.blue,
                    constraints: BoxConstraints(minWidth: 40, maxWidth: 40, maxHeight: 40, minHeight: 40),
                    child: Icon(
                      Icons.call,
                      size: 20.0,
                      color: Colors.white,
                    ),
                    shape: CircleBorder(),
                  )
                ],
              ),
            ),
            if(widget.id != Ids.CALL_CENTER_ID)Container(
              margin: EdgeInsets.fromLTRB(10, 5, 15, 10),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(2, 2),
                        blurRadius: 2,
                        spreadRadius: 1.5
                    ),
                  ]
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Map',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: _isConnected(),
                          builder: (context, isConnected) {
                            if(!isConnected.data){
                              return Row(
                                children: [
                                  Opacity(
                                    opacity: 0.5,
                                    child: Icon(
                                      Icons.wifi_off,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 0.5,
                                    child: Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }
                            return Container();
                          }
                        )
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 250,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng((widget.position.latitude+double.parse(data.lat))/2, (widget.position.longitude+double.parse(data.lon))/2),
                          zoom: 13.5,
                        ),
                        layers: [
                          TileLayerOptions(
                              urlTemplate: 'https://api.mapbox.com/styles/v1/rafid08/ckjatwo4z9hd319nj5l0il0sl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmFmaWQwOCIsImEiOiJja2F5eDI5aWQwMmJsMnhudndwaHdtdzJpIn0.GiqmkAEgOFbDLoPi0kT6mA',
                              additionalOptions: {
                                'id': 'mapbox.mapbox-streets-v8'
                              }),
                          PolylineLayerOptions(
                              polylines: [
                                Polyline(
                                    points: [
                                      LatLng(widget.position.latitude, widget.position.longitude),
                                      LatLng(double.parse(data.lat), double.parse(data.lon))
                                    ],
                                    strokeWidth: 2,
                                    color: Colors.blue.shade900
                                )
                              ]
                          ),
                          MarkerLayerOptions(
                            markers: [
                              new Marker(
                                width: 27.0,
                                height: 27.0,
                                point: LatLng(widget.position.latitude, widget.position.longitude),
                                builder: (ctx) => Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.withOpacity(0.4),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Marker(
                                width: 27.0,
                                height: 27.0,
                                point: new LatLng(double.parse(data.lat), double.parse(data.lon)),
                                builder: (ctx) =>
                                    new Container(
                                      child: (widget.id == Ids.AMBULANCE_ID)?
                                      Image.asset('asset/image/ambulance.png'):Image.memory(icon),
                                    ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }
  Future<bool> _isConnected() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}