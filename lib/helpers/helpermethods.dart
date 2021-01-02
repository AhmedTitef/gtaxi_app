import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtaxi_app/datamodels/address.dart';
import 'package:gtaxi_app/datamodels/directiondetails.dart';
import 'package:gtaxi_app/dataprovider/appdata.dart';
import 'package:gtaxi_app/globalvariable.dart';
import 'package:gtaxi_app/helpers/requestHelper.dart';
import 'package:provider/provider.dart';

class HelperMethods{

 static Future <String> findCordinatedAdress(Position position , context) async{
   String placeAddress = "";
   //checkNetwork  Avalibilty
   var connectivityResult =
   await Connectivity().checkConnectivity();
   if (connectivityResult != ConnectivityResult.mobile &&
       connectivityResult != ConnectivityResult.wifi) {
     return placeAddress;
   }

   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
   var response = await RequestHelper.getRequest(url);
   if(response!="failed"){
     placeAddress = response["results"][0]["formatted_address"];
     Address pickupAddress = Address();

     pickupAddress.longitude = position.longitude;
     pickupAddress.latitude = position.latitude;
     pickupAddress.placeName = placeAddress;


     Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);

     return placeAddress;
   }
 }
static Future<DirectionDetails> getDirectionDetails(LatLng startPosition , LatLng endPosition) async{

   String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey";
   var response = await RequestHelper.getRequest(url);
   if (response == "failed"){
     print("failed getting direction details");
     return null;
   }

   DirectionDetails directionDetails = DirectionDetails();
   directionDetails.durationText = response["routes"][0]["legs"][0]["duration"]["text"];
   directionDetails.durationValue = response["routes"][0]["legs"][0]["duration"]["value"];
   directionDetails.distanceText = response["routes"][0]["legs"][0]["distance"]["text"];
   directionDetails.distanceValue = response["routes"][0]["legs"][0]["distance"]["value"];



   directionDetails.encodedPoints = response["routes"][0]["overview_polyline"]["points"];

   return directionDetails;

}

}