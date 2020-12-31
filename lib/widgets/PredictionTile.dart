import 'package:flutter/material.dart';
import 'package:gtaxi_app/datamodels/address.dart';
import 'package:gtaxi_app/datamodels/prediction.dart';
import 'package:gtaxi_app/dataprovider/appdata.dart';
import 'package:gtaxi_app/globalvariable.dart';
import 'package:gtaxi_app/helpers/requestHelper.dart';
import 'package:gtaxi_app/widgets/ProgressDialog.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';

class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});


  void getPlaceDetails(String placeID , context) async{

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: "Please wait...",)
    );

    String url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey";
    var response  = await RequestHelper.getRequest(url);

    Navigator.pop(context); //closes the dialog after loading details of a specific place in the prediction list

    if (response == "failed"){
      return;
    }

    if (response["status"] == "OK"){
      Address thisPlace = Address();
      thisPlace.placeName = response["result"]["name"];
      thisPlace.placeID = placeID;
      thisPlace.latitude = response["result"]["geometry"]["location"]["lat"];
      thisPlace.longitude = response["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context , listen: false).updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(

      onPressed: (){

        getPlaceDetails(prediction.placeID, context);

      },
      padding: EdgeInsets.all(0),

      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8,),
            Row(
              children: [

                Icon(OMIcons.locationOn, color: BrandColors.colorDimText,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prediction.mainText,overflow: TextOverflow.ellipsis, maxLines: 1,style: TextStyle(fontSize: 16),),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText ,overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 12 , color: BrandColors.colorDimText),) ,

                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}