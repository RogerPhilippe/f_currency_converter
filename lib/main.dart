import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=60df7606";

void main() {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white)));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Widgets Builder's

  Widget _buildAppBar() {
    return AppBar(
      title: Text("\$ Currency Converter \$"),
      backgroundColor: Colors.amber,
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return FutureBuilder<Map>(
      future: getData(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
                child: Text("Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center));
          default:
            if (snapshot.hasError) {
              return Center(
                  child: Text("Erro ao Carregar Dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center));
            } else {
              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on,
                        size: 150.0, color: Colors.amber),
                    _buildTextField(
                        "Reais", "R\$", realController, _realChanged),
                    Divider(),
                    _buildTextField(
                        "Dólares", "US\$", dolarController, _dolarChanged),
                    Divider(),
                    _buildTextField("Euros", "€", euroController, _euroChanged)
                  ],
                ),
              );
            }
        }
      },
    );
  }

  Widget _buildTextField(String hint, String prefix,
      TextEditingController controller, Function func) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: func,
      keyboardType: TextInputType.number,
    );
  }
}
