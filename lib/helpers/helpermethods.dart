import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:gtaxi_app/datamodels/address.dart';
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


}