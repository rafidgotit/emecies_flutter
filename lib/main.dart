import 'package:emecies_flutter/database_helper.dart';
import 'package:emecies_flutter/downloader.dart';
import 'package:emecies_flutter/list.dart';
import 'package:emecies_flutter/map.dart';
import 'package:emecies_flutter/main_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MainProvider(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emecies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return Main(title: 'Emecies');
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
}

class Main extends StatefulWidget {
  Main({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
          future: _isDataAvailable(),
          builder: (context, dataAvailable) {
            if(dataAvailable.hasData){
              if(!dataAvailable.data){
                return DownloadScreen();
              }
              return MyHomePage();
            }
            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Emecies'),
      ),
      body: FutureBuilder<Position>(
          future: getLocation(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              Position position = snapshot.data;
              return WillPopScope(
                onWillPop: (){
                  if(pageController.page == 1){
                    MainProvider provider = Provider.of<MainProvider>(context, listen: false);
                    provider.closeList(pageController);
                    return Future.value(false);
                  }
                  return Future.value(true);
                },
                child: SlidingUpPanel(
                  body: MapScreen(position: position),
                  collapsed: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 27,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  panel: PageView(
                    children: [
                      Home(
                        onServiceTapped: (id){
                          MainProvider provider = Provider.of<MainProvider>(context, listen: false);
                          provider.openList(pageController, id);
                        },
                      ),
                      ListScreen(
                        position: position,
                        controller: pageController,
                      ),
                    ],
                    onPageChanged: (index){
                    },
                    controller: pageController,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                  defaultPanelState: PanelState.OPEN,
                  parallaxEnabled: true,
                  parallaxOffset: 0.65,
                  maxHeight: screenSize.height*0.72,
                  minHeight: 50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }

  Future<Position> getLocation() async{
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}

class Home extends StatefulWidget{
  Home({Key key, this.onServiceTapped}) : super(key: key);
  final ValueChanged<String> onServiceTapped;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'SERVICES',
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Flexible(
                      flex: 1,
                      child: serviceButton(
                          imagePath: 'asset/image/call.png',
                          text: 'Call Centers',
                          onTap:(){
                            widget.onServiceTapped(Ids.CALL_CENTER_ID);
                          }
                      )
                  ),
                  Flexible(
                      flex: 1,
                      child: serviceButton(
                          imagePath: 'asset/image/ambulance.png',
                          text: 'Ambulances',
                          onTap:(){
                            widget.onServiceTapped(Ids.AMBULANCE_ID);
                          }
                      )
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: serviceButton(
                            imagePath: 'asset/image/fire.png',
                            text: 'Fire Services',
                            onTap:(){
                              widget.onServiceTapped(Ids.FIRE_SERVICE_ID);
                            }
                        )
                    ),
                    Flexible(
                        flex: 1,
                        child: serviceButton(
                            imagePath: 'asset/image/police.png',
                            text: 'Police Stations',
                            onTap:(){
                              widget.onServiceTapped(Ids.POLICE_STATION_ID);
                            }
                        )
                    ),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }

  Widget serviceButton({@required String imagePath, @required String text, @required VoidCallback onTap}){
    return ClipRRect(
      borderRadius: BorderRadius.circular(200),
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.black26,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 85,
                width: 85,
                child: FittedBox(
                    child: Image.asset(imagePath)
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  text,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _isDataAvailable() async {
  final db = await DBProvider.db.database;

  var ambulanceData = await db.query("Ambulance");
  List<Data> ambulance = ambulanceData.isNotEmpty ? ambulanceData.map((c) => Data.fromMap(c)).toList() : [];

  var policeData = await db.query("PoliceStation");
  List<Data> police = policeData.isNotEmpty ? ambulanceData.map((c) => Data.fromMap(c)).toList() : [];

  var fireData = await db.query("FireService");
  List<Data> fire = fireData.isNotEmpty ? ambulanceData.map((c) => Data.fromMap(c)).toList() : [];

  var callData = await db.query("CallCenter");
  List<Data> call = callData.isNotEmpty ? ambulanceData.map((c) => Data.fromMap(c)).toList() : [];

  if(ambulance.length==0 || police.length==0 || fire.length==0 || call.length==0){
    return false;
  }
  return true;
}