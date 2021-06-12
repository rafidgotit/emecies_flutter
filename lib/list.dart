import 'dart:math';

import 'package:emecies_flutter/database_helper.dart';
import 'package:emecies_flutter/details.dart';
import 'package:emecies_flutter/list_item.dart';
import 'package:emecies_flutter/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'downloader.dart';

List<String> districts = ['Dhaka', 'Narayanganj', 'Cumilla', 'Chattogram'];

class ListScreen extends StatefulWidget{
  ListScreen({Key key, this.position, this.controller}) : super(key: key);
  final Position position;
  final PageController controller;

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen>{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Selector<MainProvider, String>(
          selector: (_, provider) => provider.listId,
          builder: (context, listId, child) {
            if(listId==null)
              return CircularProgressIndicator();
            else{
              String title;
              if(listId==Ids.AMBULANCE_ID) title = 'Nearby Ambulance Services';
              if(listId==Ids.POLICE_STATION_ID) title = 'Nearby Police Stations';
              if(listId==Ids.FIRE_SERVICE_ID) title = 'Nearby Fire Services';
              if(listId==Ids.CALL_CENTER_ID) title = 'Useful Call Centers';
              return FutureBuilder<List<Data>>(
                future: getData(position: widget.position, id: listId),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    List<Data> list = snapshot.data;

                    List<Widget> listView = List<Widget>.generate(list.length, (index) => ListItem(
                      name: list[index].name,
                      icon: list[index].icon,
                      cover: list[index].cover,
                      phone: list[index].phone,
                      id: listId,
                      onTap: (){
                        showDetails(context, list[index], listId, widget.position);
                      },
                    ));

                    listView.insert(0, Container(
                      padding: EdgeInsets.only(bottom: 20, top: 40),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ));

                    return Selector<MainProvider, String>(
                        selector: (_, provider) => provider.district,
                        builder: (context, district, child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if(district==districts[0] || listId==Ids.CALL_CENTER_ID) ListView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              children: listView
                            ),
                            if(district!=districts[0] && listId!=Ids.CALL_CENTER_ID) Opacity(
                              opacity: 0.4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.face, size: 80),
                                  SizedBox(height: 20),
                                  Container(
                                    width: 240,
                                    child: Text(
                                      'No $title Found in $district',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                            topBar(district, listId),
                          ],
                        );
                      }
                    );
                  }
                  return CircularProgressIndicator();
                }
              );
            }
          }
        ),
      ),
    );
  }

  Widget topBar(String value, String listId){
    return Align(
      alignment: Alignment.topCenter,
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(40, 40, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: IconButton(
                    splashRadius: 25,
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                    iconSize: 20,
                    onPressed: (){
                      MainProvider provider = Provider.of<MainProvider>(context, listen: false);
                      provider.closeList(widget.controller);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: IconButton(
                    splashRadius: 25,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.blue,
                    ),
                    iconSize: 20,
                    onPressed: null,
                  ),
                ),
              ),
              if(listId!=Ids.CALL_CENTER_ID) Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: value,
                    items: districts.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: new Text(
                            value,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      var provider = Provider.of<MainProvider>(context, listen: false);
                      provider.updateArea(value);
                    },
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}

showDetails(context, Data data, listId, Position position){
  showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.ease.transform(a1.value)-1;
        return Transform(
          transform: Matrix4.translationValues(0.0, -curvedValue * 200, 0.0),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            elevation: 0,
            insetPadding: EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            child: DetailsScreen(
              data: data,
              id: listId,
              position: position,
            ),
          ),
        );
      },
      pageBuilder: (_, __, ___){}
  );
}

Future<List<Data>> getData({@required Position position, @required String id}) async {
  if(id==null) return null;

  final db = await DBProvider.db.database;
  List<Data> data = List<Data>();

  var ambulanceData = await db.query(id);
  List<Data> temp = ambulanceData.isNotEmpty ? ambulanceData.map((c) => Data.fromMap(c)).toList() : [];

  for(int i=0; i<temp.length; i++){
    data.add(Data(
        name: temp[i].name,
        phone: temp[i].phone,
        cover: temp[i].cover,
        icon: temp[i].icon,
        lat: temp[i].lat,
        lon: temp[i].lon,
        distance: (id!=Ids.CALL_CENTER_ID)?(id==Ids.FIRE_SERVICE_ID && temp[i].name=='Fire Brigade Enquiry')?0.0:
        calculateDistance(position.latitude, position.longitude, double.parse(temp[i].lat), double.parse(temp[i].lon)):null
    ));
  }
  if(id!=Ids.CALL_CENTER_ID) data.sort((a, b) => a.distance.compareTo(b.distance));

  return data;
}

double calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p)/2 +
      c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}