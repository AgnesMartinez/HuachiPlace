import 'package:http/http.dart' as http;
import 'dart:convert';

//Simple http session manager
class Session {
  
  //For JSWT authentication
  Map<String, String> headers = {'Authorization': 'access_token='};

  //Backend main url for API requests
  String mainUrl = "";

  String colorChange = "/mplace/modificar_tile";

  String currentGrid = "/mplace/current_grid";

  //Ask for grid background
  Future<List> getGrid() async {

    Uri target = Uri.parse(mainUrl + currentGrid);

    http.Response response = await http.get(target, headers: headers);

    return [response.statusCode, response.bodyBytes];
  }

  //Sends color changes made by user
  Future<List> postColor(dynamic data) async {

    Uri target = Uri.parse(mainUrl + colorChange);

    var payload = json.encode(data);

    http.Response response =
        await http.post(target, body: payload, headers: headers);

    return [
      response.statusCode,
      json.decode(utf8.decode(response.bodyBytes))["data"]
    ];
  }
}
