import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const uri = "https://api.hgbrasil.com/finance?format=json&key=9d96a577";

Future<Map> recuperaMoedas() async {
  http.Response response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    return json.decode(response.body)["results"]["currencies"];
  } else {
    throw Exception('Erro na requisição');
  }
}

void main() async {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar = 0;
  double euro = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text("Conversor \$\$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: recuperaMoedas(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text(
                  "None API",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Acessando API",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ;(",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["USD"]["buy"];
                euro = snapshot.data["EUR"]["buy"];
                debugPrint(snapshot.toString());
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      Text("Dolar " + dolar.toString(), style: TextStyle(fontSize: 40),),
                      Text("Euro " + euro.toString(), style: TextStyle(fontSize: 40),),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
