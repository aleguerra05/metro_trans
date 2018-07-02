//import 'package:adaptive_master_detail_layouts/item.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'utils/Transaccion.dart';

class ItemDetails extends StatelessWidget {
  ItemDetails({@required this.item});
  final Transaccion item;

  Icon getTypeServiceIcon (Transaccion transaccion)
  {
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

  String getTypeServiceText(Transaccion transaccion)
  {
    switch(transaccion.servicio) {
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
    final Widget content = new Card(child: new ListTile(
      leading: getTypeServiceIcon(item),
        title: new Text(getTypeServiceText(item)),
        subtitle:
        new Row(children: <Widget>[
            new Expanded(child: new Text(item.monto.toStringAsFixed(2)+" CUP")),
            new Icon(Icons.calendar_today, size: 10.0),
            new Text(item.fecha.day.toString() + "/" +
            item.fecha.month.toString() + "/" +
            item.fecha.year.toString())]),
        //trailing: new Text(item.monto.toStringAsFixed(2)+" CUP",),
        )
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(item.noTransaccion.toString()),
      ),
      body: content,
    );
  }
}