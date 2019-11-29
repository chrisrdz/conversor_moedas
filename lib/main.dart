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
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white)));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar = 0;
  double euro = 0;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _limparCampos() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _textoAlterado(String valor, String campo) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }
    double valorF = double.parse(valor);

    if (campo == "Real") {
      dolarController.text = (valorF / dolar).toStringAsFixed(2);
      euroController.text = (valorF / euro).toStringAsFixed(2);
    } else if (campo == "Dolar") {
      realController.text = (valorF * dolar).toStringAsFixed(2);
      euroController.text = ((valorF * dolar) / euro).toStringAsFixed(2);
    } else if (campo == "Euro") {
      realController.text = (valorF * euro).toStringAsFixed(2);
      dolarController.text = ((valorF * euro) / dolar).toStringAsFixed(2);
    }
  }

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
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      constroiTextField(
                          "Real", "R\$", realController, _textoAlterado),
                      Divider(),
                      constroiTextField(
                          "Dolar", "\$", dolarController, _textoAlterado),
                      Divider(),
                      constroiTextField(
                          "Euro", "\€", euroController, _textoAlterado),
                      Divider(),
                      Divider(),
                      Text(
                        "Dolar " + dolar.toString(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      Text(
                        "Euro " + euro.toString(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
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

Widget constroiTextField(
    String label, String prefix, TextEditingController ct, Function f) {
  return TextField(
    controller: ct,
    decoration: InputDecoration(
        labelText: label.toString(),
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix.toString()),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: (val) {
      f(val, label.toString());
    },
    keyboardType: TextInputType.number,
  );
}
