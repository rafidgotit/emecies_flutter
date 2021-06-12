import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import 'database_helper.dart';
import 'downloader.dart';
import 'list.dart';
import 'main_provider.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key key, this.position}) : super(key: key);

  final Position position;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Position position = widget.position;

    return Selector<MainProvider, String>(
        selector: (_, provider) => provider.listId,
        builder: (context, listId, child) {
        return Scaffold(
          body: FutureBuilder<List<Data>>(
            future: getData(position: position, id: listId),
            builder: (context, snapshot) {
              List<Marker> markers = [
                new Marker(
                  width: 27.0,
                  height: 27.0,
                  point: new LatLng(position.latitude, position.longitude),
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
              ];

              if(snapshot.hasData && listId != Ids.CALL_CENTER_ID && listId != null){
                List<Data> services = snapshot.data;
                Uint8List icon;
                if(listId != Ids.AMBULANCE_ID) icon = base64Decode(services[0].icon);
                for(int i=0; i<services.length; i++){
                  markers.add( Marker(
                      width: 35.0,
                      height: 35.0,
                      point: new LatLng(double.parse(services[i].lat), double.parse(services[i].lon)),
                      builder: (ctx) =>
                      GestureDetector(
                        onTap: (){
                          showDetails(context, services[i], listId, position);
                        },
                        child: new Container(
                          child: (listId == Ids.AMBULANCE_ID)?
                          Image.asset('asset/image/ambulance.png'):Image.memory(icon),
                        ),
                      ),
                    )
                  );
                }
              }
              return FlutterMap(
                options: MapOptions(
                  center: LatLng(position.latitude, position.longitude),
                  zoom: 14,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: 'https://api.mapbox.com/styles/v1/rafid08/ckjatwo4z9hd319nj5l0il0sl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmFmaWQwOCIsImEiOiJja2F5eDI5aWQwMmJsMnhudndwaHdtdzJpIn0.GiqmkAEgOFbDLoPi0kT6mA',
                    additionalOptions: {
                      'id': 'mapbox.mapbox-streets-v8'
                  }),
                  MarkerLayerOptions(
                    markers: markers,
                  ),
                ],
              );
            }
          ),
        );
      }
    );
  }
}
