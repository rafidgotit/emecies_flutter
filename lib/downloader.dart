import 'dart:convert';
import 'dart:typed_data';

import 'package:emecies_flutter/database_helper.dart';
import 'package:emecies_flutter/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class DownloadScreen extends StatefulWidget {
  DownloadScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  DBProvider dbProvider = DBProvider.db;

  int downloaded = 0;
  double progress = 0;
  int maxProgress = 0;

  final databaseReference = FirebaseDatabase.instance.reference();
  Uint8List a;

  List rootData = List();
  List<ItemData> ambulances = List<ItemData>();
  List fireServices = List();
  List policeStations = List();
  List callCenters = List();

  @override
  void initState() {
    super.initState();
    dbProvider.initDB();
    dbProvider.clearTables();

    try{
      cookData();
    } catch(e){
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    if(progress==1){
      Future.delayed(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => MyApp()
        ));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: WillPopScope(
        onWillPop: (){
          return Future.value(false);
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 230, width: 230,
                  child: Image.asset('asset/image/loading.png'),
                ),
                SizedBox(height: 30,),
                Container(
                  width: 250,
                  child: LinearProgressIndicator(
                    value: progress,
                  ),
                ),
                Text(
                  '${(progress*100).toInt()}% downloaded',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ItemData> getData({Map<dynamic, dynamic> value}){
    List<ItemData> lists = List<ItemData>();
    value.forEach((key, values) {
      lists.add(ItemData.fromJson(values));
    });
    return lists;
  }

  cookData() async{
    DataSnapshot snapshot = await databaseReference.once();

    ambulances = getData(value: snapshot.value['ambulance']);
    fireServices = getData(value: snapshot.value['fire_service']);
    policeStations = getData(value: snapshot.value['police_station']);
    callCenters = getData(value: snapshot.value['call_center']);

    maxProgress = ambulances.length + fireServices.length + policeStations.length + callCenters.length;

    print('max $maxProgress');
    for(int i=0; i<ambulances.length; i++){
      get(ambulances[i].iconUrl).then((icon) async{
        var cover = await get(ambulances[i].coverUrl);
        get(ambulances[i].coverUrl);
        Data data = Data(
            id: null,
            name: ambulances[i].name,
            phone: ambulances[i].phone,
            address: '',
            lat: ambulances[i].lat,
            lon: ambulances[i].lon,
            icon: base64.encode(icon.bodyBytes),
            cover: base64.encode(cover.bodyBytes)
        );
        dbProvider.insertData(table: 'Ambulance', data: data.toMap());
        downloaded++;
        print(downloaded);
        if(this.mounted) setState(() => progress = downloaded/maxProgress);
        try{

        }catch(e){
          print('ambulance $i $e');
        }
      });
    }

    get(fireServices[0].iconUrl).then((icon) async{
      try{
        var cover = await get(fireServices[0].coverUrl);

        for(int i=0; i<fireServices.length; i++){
          Data data = Data(
              id: null,
              name: fireServices[i].name,
              phone: fireServices[i].phone,
              address: '',
              lat: fireServices[i].lat,
              lon: fireServices[i].lon,
              icon: base64.encode(icon.bodyBytes),
              cover: base64.encode(cover.bodyBytes)
          );
          dbProvider.insertData(table: 'FireService', data: data.toMap());
          downloaded++;
          print(downloaded);
          if(this.mounted) setState(() => progress = downloaded/maxProgress);
        }
      }catch(e){
        print('fire $e');
      }
    });

    get(policeStations[0].iconUrl).then((icon) async{
      for(int i=0; i<policeStations.length; i++) {
        try{
          var cover = await get(policeStations[i].coverUrl);
          Data data = Data(
              id: null,
              name: policeStations[i].name,
              phone: policeStations[i].phone,
              address: '',
              lat: policeStations[i].lat,
              lon: policeStations[i].lon,
              icon: base64.encode(icon.bodyBytes),
              cover: base64.encode(cover.bodyBytes)
          );
          dbProvider.insertData(table: 'PoliceStation', data: data.toMap());
          downloaded++;
          print(downloaded);
          if(this.mounted) setState(() => progress = downloaded/maxProgress);
        }catch(e){
          print('police $i $e');
        }
      }
    });

    for(int i=0; i<callCenters.length; i++){
      get(callCenters[i].iconUrl).then((icon) async{
        try{
          var cover = await get(callCenters[i].coverUrl);
          Data data = Data(
              id: null,
              name: callCenters[i].name,
              phone: callCenters[i].phone,
              address: '',
              lat: callCenters[i].lat,
              lon: callCenters[i].lon,
              icon: base64.encode(icon.bodyBytes),
              cover: base64.encode(cover.bodyBytes)
          );
          dbProvider.insertData(table: 'CallCenter', data: data.toMap());
          downloaded++;
          print(downloaded);
          if(this.mounted) setState(() => progress = downloaded/maxProgress);
        }catch(e){
          print('call $i $e');
        }
      });
    }
  }
}

class ItemData{
  String name;
  String phone;
  String lat;
  String lon;
  String iconUrl;
  String coverUrl;

  ItemData({this.name, this.phone, this.lat, this.lon, this.iconUrl, this.coverUrl});

  factory ItemData.fromJson(Map<dynamic, dynamic> json) {
    return ItemData(
      name: json['name'],
      phone: json['phone'],
      lat: json['latitude'],
      lon: json['longitude'],
      iconUrl: json['profilePhotoUri'],
      coverUrl: json['coverPhotoUri']
    );
  }
}

class Data{
  int id;
  String name;
  String phone;
  String address;
  String lat;
  String lon;
  double distance;
  String icon;
  String cover;

  Data({this.id, this.name, this.phone, this.address, this.lat, this.lon, this.icon, this.cover, this.distance});

  factory Data.fromMap(Map<String, dynamic> json) {
    return Data(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        address: json['address'],
        lat: json['lat'],
        lon: json['lon'],
        distance: json['distance'],
        icon: json['icon'],
        cover: json['cover']
    );
  }

  Map<String, dynamic> toMap() => {
    'id' : id,
    'name' : name,
    'phone' : phone,
    'address' : address,
    'lat' : lat,
    'lon' : lon,
    'icon' : icon,
    'cover' : cover,
  };
}