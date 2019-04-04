import 'dart:convert';
import 'package:http/http.dart' as http;

class Urunler {
  String stockCode;
  int id;
  String productName;
  String img;
  String remoteImg;
  String remoteLink;


  Urunler({
    this.stockCode,
    this.id,
    this.productName,
    this.img,
    this.remoteImg,
    this.remoteLink
  });

  factory Urunler.fromJson(Map<String,dynamic> parsedJson) {
    return Urunler(
        stockCode: parsedJson['stock_code'] as String,
        id: int.parse(parsedJson['id']),
        productName: parsedJson['product_name'] as String,
        img: parsedJson['img'] as String,
        remoteImg: parsedJson['remote_img'] as String,
        remoteLink: parsedJson['remote_link'] as String
    );
  }
}


class UrunlerViewModel {
  static List<Urunler> urunler;

  static Future loadUrunler() async {
    try {
      final String url = "http://likyone.tk/api/liste.php?s=0";
      urunler = new List<Urunler>();
      //String jsonString = await rootBundle.loadString('assets/players.json');
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      List parsedJson = json.decode(res.body);
      var categoryJson = parsedJson;
      for (int i = 0; i < categoryJson.length; i++) {
        urunler.add(new Urunler.fromJson(categoryJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}