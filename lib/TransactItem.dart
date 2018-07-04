import 'utils/Transaccion.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'item_details.dart';

class TransactItem extends StatelessWidget {
  final Transaccion transaccion;

  TransactItem(Transaccion transaccion)
      : transaccion = transaccion,
        super(key: new ObjectKey(transaccion));

  Icon getTypeServiceIcon(Transaccion transaccion) {
    return new Icon(
      transaccion.servicio == TIPO_SERVICIO.ATM ? Icons.local_atm :
      transaccion.servicio == TIPO_SERVICIO.TELEFONO ? Icons.phone :
      transaccion.servicio == TIPO_SERVICIO.ELECTRICIDAD ? Icons.power :
      transaccion.servicio == TIPO_SERVICIO.INTERES ? Icons.attach_money :
      transaccion.servicio == TIPO_SERVICIO.TRANSFERENCIA ? Icons.cached :
      transaccion.servicio == TIPO_SERVICIO.POS ? Icons.credit_card :
      transaccion.servicio == TIPO_SERVICIO.SALARIO ? Icons.work :
      Icons.help_outline,
      color: transaccion.operacion == TIPO_TRANSACCION.DEBITO ?
      Colors.red :
      Colors.green,
      size: 50.0,);
  }

  String getTypeServiceText(Transaccion transaccion) {
    switch (transaccion.servicio) {
      case TIPO_SERVICIO.ATM:
        return "Cajero Automatico";
      case TIPO_SERVICIO.SALARIO:
        return "Salario";
      case TIPO_SERVICIO.POS:
        return "POS";
      case TIPO_SERVICIO.TRANSFERENCIA:
        return "Transferencia";
      case TIPO_SERVICIO.INTERES:
        return "Intereses";
      case TIPO_SERVICIO.ELECTRICIDAD:
        return "Factura Electrica";
      case TIPO_SERVICIO.TELEFONO:
        return "Factura Telefonica";
      case TIPO_SERVICIO.DEFAULT:
        return "Desconocido";
    }
    return "Error";
  }

  @override
  Widget build(BuildContext context) {
    return
      new Card(child: new ListTile(
        dense: true,
        leading: getTypeServiceIcon(transaccion),
        title: new Row(children: <Widget>[
          new Expanded(
              child: new Text(
                  transaccion.monto.toStringAsFixed(2) + " " + "CUP")),
          new Icon(Icons.account_balance, size: 10.0,),
          new Text(transaccion.saldo.toStringAsFixed(2) + " CUP"),
        ]),
        subtitle:
        new Row(children: <Widget>[
          new Expanded(child: new Text(getTypeServiceText(transaccion))),
          new Icon(Icons.calendar_today, size: 10.0),
          new Text(transaccion.fecha.day.toString() + "/" +
              transaccion.fecha.month.toString() + "/" +
              transaccion.fecha.year.toString()),

        ]),
        //trailing: new Badge(thread.messages),
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (_) => new ItemDetails(item: transaccion),
            ),
          );
        },
      ));
  }
}