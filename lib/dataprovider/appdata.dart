import 'package:flutter/cupertino.dart';
import 'package:gtaxi_app/datamodels/address.dart';

class AppData extends ChangeNotifier{

  Address pickupAddress;

  Address destinationAddress;

  void updateDestinationAddress(Address destination){
    destinationAddress = destination;
    notifyListeners();
  }


  void updatePickupAddress(Address pickup){
    pickupAddress = pickup;
    notifyListeners();
  }


}