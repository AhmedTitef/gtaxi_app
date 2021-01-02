import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtaxi_app/brand_colors.dart';
import 'package:gtaxi_app/dataprovider/appdata.dart';
import 'package:gtaxi_app/helpers/helpermethods.dart';
import 'package:gtaxi_app/screens/searchpage.dart';
import 'package:gtaxi_app/styles/styles.dart';
import 'package:gtaxi_app/widgets/BrandDivider.dart';
import 'package:gtaxi_app/widgets/ProgressDialog.dart';
import 'package:gtaxi_app/widgets/TaxiButton.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'dart:io';

class MainPage extends StatefulWidget {
  static const String id = "mainpage";

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  double rideDetailsSheetHeight = 0; //


  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPaddingForGoogleMaps = 0;


  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polyLines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};


  Geolocator geoLocator = Geolocator();
  Position currentPosition;

  void setUpPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14,);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));


    String address = await HelperMethods.findCordinatedAdress(position,
        context); //vip  saves the infomation to app data to be used anywhere in the app using provider


  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future <void> getDirection() async {
    var pickup = Provider
        .of<AppData>(context, listen: false)
        .pickupAddress;
    var desitnation = Provider
        .of<AppData>(context, listen: false)
        .destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var desitantionLatLng = LatLng(desitnation.latitude, desitnation.longitude);


    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Please wait...",)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickLatLng, desitantionLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(
        thisDetails.encodedPoints);

    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      //loop through all pointlatlng points and convert them
      // to a list of latlng, required by the polyline

      results.forEach((PointLatLng pointLatLng) {
        polyLineCoordinates.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    _polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("polyid"),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,

      );
      _polyLines.add(polyline);
    });


    //make polyline to fit into map

    LatLngBounds bounds;

    if (pickLatLng.latitude > desitantionLatLng.latitude &&
        pickLatLng.longitude > desitantionLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: desitantionLatLng, northeast: pickLatLng);
    }

    else if (pickLatLng.longitude > desitantionLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, desitantionLatLng.longitude),
          northeast: LatLng(desitantionLatLng.latitude, pickLatLng.longitude));
    }
    else if (pickLatLng.latitude > desitantionLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(desitantionLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, desitantionLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: desitantionLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));


    Marker pickupMarker = Marker(markerId: MarkerId("pickup"),
        position: pickLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
            title: pickup.placeName, snippet: "My Location"));
    Marker destinationMarker = Marker(markerId: MarkerId("destination"),
        position: desitantionLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: desitnation.placeName, snippet: "Destination"));

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });


    Circle pickupCircle = Circle(circleId: CircleId("pickup"),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 12,
        center: pickLatLng,
        fillColor: BrandColors.colorGreen);
    Circle destinationCircle = Circle(circleId: CircleId("destination"),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: desitantionLatLng,
        fillColor: BrandColors.colorAccentPurple);


    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });


    // print(thisDetails.encodedPoints);
  }


  void showDetailSheet() {
   
    setState(() {
      searchSheetHeight= 0;
      rideDetailsSheetHeight = Platform.isAndroid? 235 : 260;
      mapBottomPaddingForGoogleMaps = Platform.isAndroid? 240 : 230;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: Container(
          width: 250,
          color: Colors.white,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                Container(
                  color: Colors.white,
                  height: 160,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,

                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/user_icon.png", height: 60, width: 60,),
                        SizedBox(width: 15,),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ahmed", style: TextStyle(
                                fontSize: 20, fontFamily: "Brand-Bold"),),
                            SizedBox(height: 5,),
                            Text("View Profile"),

                          ],
                        )


                      ],
                    ),
                  ),
                ),
                BrandDivider(),
                SizedBox(height: 10,)
                ,
                ListTile(
                  leading: Icon(OMIcons.cardGiftcard),
                  title: Text("Free Rides", style: kDrawerItemStyle,),
                ),
                ListTile(
                  leading: Icon(OMIcons.creditCard),
                  title: Text("Payments", style: kDrawerItemStyle,),
                ),
                ListTile(
                  leading: Icon(OMIcons.history),
                  title: Text("Ride History", style: kDrawerItemStyle,),
                ),
                ListTile(
                  leading: Icon(OMIcons.contactSupport),
                  title: Text("Support", style: kDrawerItemStyle,),
                ),
                ListTile(
                  leading: Icon(OMIcons.info),
                  title: Text("About", style: kDrawerItemStyle,),
                )
              ],
            ),

          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPaddingForGoogleMaps),
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polyLines,
              markers: _markers,
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapBottomPaddingForGoogleMaps = (Platform.isAndroid) ? 280 : 270;
                });

                setUpPositionLocator();
              },
            ),
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  scaffoldKey.currentState.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                              0.7, 0.7
                          ),


                        )
                      ]
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.menu, color: Colors.black87,),
                  ),
                ),
              ),
            ),


            ///Search Sheet **************************************

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(microseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  height: searchSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 0.6,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Nice to see you",
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          "Where are you going?",
                          style: TextStyle(
                              fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var response = await Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) => SearchPage()
                            ));


                            ///VIP orders info to the previous page
                            if (response == "getDirection") {
                              await getDirection();
                              showDetailSheet();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 0.5,
                                    offset: Offset(
                                      0.7,
                                      0.7,
                                    ),
                                  ),
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Search Desitination")
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          children: [
                            Icon(
                              OMIcons.home,
                              color: BrandColors.colorDimText,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            //outline icons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add Home"),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Your residential address",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText),
                                ),
                              ],
                            ),

                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        BrandDivider(),
                        SizedBox(height: 16,),
                        Row(
                          children: [
                            Icon(
                              OMIcons.workOutline,
                              color: BrandColors.colorDimText,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            //outline icons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add Work"),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Your office address",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///Ride Details sheet


            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(microseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7 , 0.7
                          ),


                        ),
                      ],
                  ),
                  height: rideDetailsSheetHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(

                        children: [
                          Container(
                            width: double.infinity,
                        color: BrandColors.colorAccent1,



                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16,),
                              child: Row(
                                children: [
                                  Image.asset("images/taxi.png", height: 70 , width: 70,),
                                  SizedBox(width: 16,),
                                  Column(
                                    children: [
                                      Text("Taxii", style: TextStyle(fontSize: 18 , fontFamily: "Brand-Bold"), ),
                                      Text("14 miles" , style: TextStyle(fontSize: 16 , color: BrandColors.colorTextLight),),

                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Text("13" , style: TextStyle(fontSize: 18 , fontFamily: "Brand-Bold"),)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 22,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [

                                Icon(FontAwesomeIcons.moneyBillAlt , size: 18 , color: BrandColors.colorTextLight,),
                                SizedBox(width: 16,),
                                Text("Cash"),
                                SizedBox(width: 5,),
                                Icon(Icons.keyboard_arrow_down , color: BrandColors.colorTextLight , size: 16),
                              ],
                            ),
                          ),
                          SizedBox(height: 22,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TaxiButton(
                              title: "REQUEST CAB",
                              color: BrandColors.colorGreen,
                              onPressed: (){

                              },
                            ),
                          )

                        ],
                      ),
                    ),

                ),
              ),
            )
          ],
        ));
  }
}
