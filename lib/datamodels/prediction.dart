class Prediction {
  String placeID;
  String mainText;
  String secondaryText;

  Prediction({
    this.placeID,
    this.mainText,
    this.secondaryText,
  });

  Prediction.fromJson(Map<String, dynamic> json){
    placeID= json["place_id"];
    mainText = json["structured_formatting"]["main_text"];
    secondaryText = json["structured_formatting"]["secondary_text"];
  }
}
