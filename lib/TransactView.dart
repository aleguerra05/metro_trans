import 'utils/Utils.dart';
import 'utils/Transaccion.dart';
import 'TransactItem.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:call_number/call_number.dart';

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

class TransactView extends StatefulWidget {
  @override
  State<TransactView> createState() => new _TransactViewState();
}

class _TransactViewState extends State<TransactView>
    with TickerProviderStateMixin {
  bool _loading = true;
  List<Transaccion> _transactions;
  int _simNumber = 1;
  bool _isConnected = false;

  final Utils _utils = new Utils();

  // Animation
  AnimationController opacityController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<
      RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    new Timer(const Duration(seconds: 2), () {
      _utils.readTransCup().then(_onReadTransCup);
    });


    // Animation
    opacityController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this, value: 0.0);
  }

  void _onReadTransCup(List<Transaccion> transacciones) {
    _transactions = transacciones;
    print("OnSmsLoaded");
    //cprint(_transactions);
    _checkIfLoadCompleted();
  }

  void _onFinishReload(List<Transaccion> transacciones) {
    _transactions = transacciones;
    print("OnSmsReloaded");
    //print(_transactions);
    if (_transactions != null) {
      setState(() {
        _loading = false;
        //opacityController.animateTo(1.0, curve: Curves.easeIn);
      });
    }
  }

  void _changeSimNumber() {
    setState
      (() {
      if (_simNumber == 1)
        _simNumber = 2;
      else
        _simNumber = 1;
    });
  }

  _initCall(String number) async {
    if(number != null)
      await new CallNumber().callNumber(number);
  }

  void _changeConnectionStatus() {
    setState(() {
      if (_isConnected) {
        //launch("tel:*444*70%23")
        _initCall("*444*70%23")
        ; //desconectarse
      }
      else {
        //launch("tel:*444*40*03%23")
        _initCall("*444*40*03%23")
        ; //conectarse
      }
      _isConnected = !_isConnected;
    });
  }

  void _checkIfLoadCompleted() {
    if (_transactions != null) {
      setState(() {
        _loading = false;
        opacityController.animateTo(1.0, curve: Curves.easeIn);
      });
    }
  }

  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();

    _utils.readTransCup().then(_onFinishReload);

    new Timer(const Duration(seconds: 2), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: const Text('Refresh complete'),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }
          )
      ));
    });
  }

  Future<Null> _aboutDialog(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('MetroTrans v1.0'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(
                    'Visor de Transaciones de Banco Metropolitano. 2018'),
                new Text('aleguerra05@gmail.com'),
                new Text('https://github.com/aleguerra05/metro_trans'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  requestPermission(Permission permission) async {
    //if(! await SimplePermissions.checkPermission(permission)) {
    bool res = await SimplePermissions.requestPermission(permission).then((res){print("permission "+permission.toString()+ " request result is " + res.toString());});
//    print("permission request result is " + res.toString());
    //}
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    File filePath = File('$path/MetroTrans/transacciones.txt');

    final myDir = new Directory('$path/MetroTrans');
    myDir.exists().then((isThere) {
      if (isThere) {
        filePath = File('$path/MetroTrans/transacciones.txt');
      }
      else {
        new Directory('$path/MetroTrans').create(recursive: true);
        filePath = File('$path/MetroTrans/transacciones.txt');
      }
    });

    return filePath;
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> writeTransactions() async {
    await requestPermission(Permission.WriteExternalStorage);
    final file = await _localFile;
    // Write the file

    String content = 'fecha;id_Transaccion;credito;debito;moneda;operacion;servicio;saldo\n';

    _transactions.sort((a, b) => a.fecha.compareTo(b.fecha));

    _transactions.forEach((t){
      content += t.fecha.year.toString()+'/'+t.fecha.month.toString()+'/'+t.fecha.day.toString()+';';
      content += t.noTransaccion.toString()+';';
      if(t.operacion==TIPO_TRANSACCION.DEBITO)
        content+=';';
      content += t.monto.toStringAsFixed(2)+';';
      if(t.operacion==TIPO_TRANSACCION.CREDITO)
        content+=';';
      content += t.moneda.toString()+';';
      content += t.operacion.toString()+';';
      content += t.servicio.toString()+';';
      content += t.saldo.toStringAsFixed(2)+'\n';
    });

    return file.writeAsString(content);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('MetroTrans'),
        actions: [
          new IconButton(icon: new Icon(Icons.help_outline),
              tooltip: 'Acerca de',
              onPressed: () {
                _aboutDialog(context);
              }),
          new IconButton(
              icon: new Icon(Icons.save), tooltip: 'Exportar transacciones', onPressed: () {
            writeTransactions();

          }),
        ],
      ),
      body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child:

          _getTtransactViewWidgets()),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.account_balance),
        onPressed: () {
          //launch("tel:*444*48*1%23");
          _initCall("*444*48%23");
        },
        label: const Text("Ultimas Operaciones"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        hasNotch: false,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: _isConnected ? Icon(Icons.link) : Icon(Icons.link_off),
              onPressed: _changeConnectionStatus,
              tooltip: "Autenticarse",),
            new Stack(children: <Widget>[
              IconButton(icon: Icon(Icons.sd_card),
                  onPressed: _changeSimNumber,
                  tooltip: _simNumber.toString()),
              Container(
                margin: const EdgeInsets.only(left: 20.0, top: 20.0), child:
              Text(_simNumber.toString(),
                style: TextStyle(fontSize: 13.0, color: Colors.white),),
              )
            ],)
          ],
        ),
      ),
    );
  }

  Widget _getTtransactViewWidgets() {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new FadeTransition(
        opacity: opacityController,
        child: new ListView.builder(
            padding: kMaterialListPadding,
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              return new TransactItem(_transactions[index]);
            }),
      );
    }
  }
}

