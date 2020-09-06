
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';


void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoListController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  Future<Null> _refresh() async{
  await Future.delayed(Duration(seconds: 1));
  setState((){
    _toDoList.sort((a,b){
    if (a["ok"] && !b["ok"]) return 1;
    else if (!a["ok"] && b["ok"]) return -1;
    else return 0;
  });
  _saveData();
  });
  return null;
}

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState((){
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoListController,
                    decoration: InputDecoration(
                      labelText: "Novo Produto",
                      labelStyle: TextStyle(color: Colors.orange)
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.orange,
                  child: Icon(Icons.add, color: Colors.white,),
                  onPressed: _addItenList,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
              itemBuilder: (context, index){
                return Dismissible(
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  background: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment(-0.9, 0.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  direction: DismissDirection.startToEnd,
                  child: CheckboxListTile(
                  title: Text(_toDoList[index]["title"], style: TextStyle(color: Colors.black),),
                  value: _toDoList[index]["ok"], 
                  activeColor: Colors.orange,
                  secondary: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error,
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (c){
                    setState(() {
                      _toDoList[index]["ok"] = c;
                      _saveData();
                    });
                  },
                ),
                onDismissed: (direction) {
                  setState((){
                    _lastRemoved = Map.from(_toDoList[index]);
                    _lastRemovedPos = index;
                    _toDoList.removeAt(index);

                    _saveData();

                    final snack = SnackBar(
                      content: Text("O PRODUTO ${_lastRemoved["title"]} FOI REMOVIDO!"),
                      action: SnackBarAction(
                        label: "DESFAZER",
                        onPressed: (){
                          setState(() {
                            _toDoList.insert(_lastRemovedPos, _lastRemoved);
                            _saveData();
                          });
                        },
                      ),
                      duration: Duration(seconds: 5),
                    );
                    Scaffold.of(context).removeCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(snack);
                  });
                },
              );
                
                
              },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void  _addItenList() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoListController.text;
      _toDoListController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
    
  }

  Future<File> _getFile() async {
  final directory = await getApplicationSupportDirectory();
  return File("${directory.path}/data.json");
}

Future<File> _saveData() async {
  String data = json.encode(_toDoList);
  final file = await _getFile();
  return file.writeAsString(data);
}

Future<String> _readData() async {
  try{

    final file = await _getFile();
    return file.readAsString();

  } catch(e) {

    return null;

  }
}



}



