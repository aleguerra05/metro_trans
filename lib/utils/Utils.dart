import 'Transaccion.dart';
import 'package:sms/sms.dart';
import 'dart:async';

class Utils {

  List<Transaccion> transaccionesCUP;
  List<Transaccion> transaccionesCUC;

  static List<Transaccion> MessageToTransaction(SmsMessage message) {
    Transaccion transaccion = new Transaccion();

    TIPO_OPERACIONES tipo_operaciones = identificarOperacion(message);

    List<Transaccion> list = new List<Transaccion>();

    if (tipo_operaciones == TIPO_OPERACIONES.ULTIMAS_OPERACIONES) {
      var lines = message.body.split("\n");

      for (int i = 2; i < lines.length - 1; i++) {
        if (lines[i].contains("INFO:"))
          continue;

        transaccion = new Transaccion();
        var items = lines[i].split(";");
        String dateStr = items[0].trim();

        var parts = dateStr.split('/');

        DateTime date = new DateTime(
            int.parse(parts.elementAt(2)), int.parse(parts.elementAt(1)),
            int.parse(parts.elementAt(0)));


        transaccion.fecha = date;
        transaccion.servicio = identificarServicio(items[1].trim());
        transaccion.operacion = identificarTransaccion(items[2].trim());
        transaccion.monto = double.parse(items[3].trim());
        transaccion.moneda = identificarTipoMoneda(items[4].trim());
        transaccion.noTransaccion = (items[5].trim()).split(" ")[0].trim();

        list.add(transaccion);
      }
    }
    else if (tipo_operaciones == TIPO_OPERACIONES.FACTURA_PAGADA) {
      var lines = message.body.split("\n");

      transaccion = new Transaccion();
      transaccion.fecha = message.date;
      transaccion.servicio = identificarServicio(lines[0]);
      transaccion.operacion =
          TIPO_TRANSACCION.DEBITO; //TIPO_TRANSACCION.Identificar(lines[4]);
      transaccion.monto = double.parse(lines[2].trim().split(" ")[2].trim());
      transaccion.moneda =
          identificarTipoMoneda(lines[2].trim().split(" ")[3].trim());
      transaccion.noTransaccion = lines[3].trim().split(" ")[2].trim();
      list.add(transaccion);
    }
    else if (tipo_operaciones == TIPO_OPERACIONES.TRANSFERENCIA_RX_SALDO) {
      var lines = message.body.split("\n");

      transaccion = new Transaccion();
      transaccion.fecha = message.date;
      transaccion.servicio =
          TIPO_SERVICIO.TRANSFERENCIA; //TIPO_SERVICIO.Identificar(lines[0]);
      transaccion.operacion = TIPO_TRANSACCION.CREDITO;
      transaccion.monto = double.parse(lines[0].trim().split(" ")[10].trim());
      transaccion.moneda =
          identificarTipoMoneda(lines[0].trim().split(" ")[11].trim());
      transaccion.noTransaccion = lines[0].trim().split(" ")[14].trim();

      list.add(transaccion);
    } else if (tipo_operaciones == TIPO_OPERACIONES.TRANSFERENCIA_TX_SALDO) {
      var lines = message.body.split("\n");

      transaccion = new Transaccion();
      transaccion.fecha = message.date;
      transaccion.servicio =
          TIPO_SERVICIO.TRANSFERENCIA; //TIPO_SERVICIO.Identificar(lines[0]);
      transaccion.operacion = TIPO_TRANSACCION.DEBITO;
      transaccion.monto = double.parse(lines[3].trim().split(" ")[1].trim());
      transaccion.moneda =
          identificarTipoMoneda(lines[3].trim().split(" ")[2].trim());
      transaccion.noTransaccion = lines[5].trim().split(" ")[2].trim();
      list.add(transaccion);
    }
    return list;
  }

  Future<List<Transaccion>> readTransCup() async {
    List<Transaccion> transCUP = new List<Transaccion>();
    List<Saldo> saldosCUP = new List<Saldo>();
    SmsQuery query = new SmsQuery();
    final smsCollection = await query.querySms(address: "PAGOxMOVIL");
    smsCollection.forEach((SmsMessage sms) {
      List<Transaccion> trans = MessageToTransaction(sms);
      List<Transaccion> transactionsCUP = new List<Transaccion>();
      if(trans.length>0) {
        if (trans[0].moneda == TIPO_MONEDA.CUP)
          transactionsCUP = trans;
      }
      Saldo saldo = MessageToSaldos(sms);
      if (saldo.monto != 0.0) {
        if (saldo.moneda == TIPO_MONEDA.CUP)
          saldosCUP.add(saldo);
      }
      for (int i = 0; i < transactionsCUP.length; i++) {
        if (!transCUP.contains(transactionsCUP[i])) transCUP.add(
            transactionsCUP[i]);
      }
    });

    List<Transaccion> transFinal;

    if (saldosCUP.length != 0) {
      transFinal = AgregarSaldoATransacciones(transCUP, saldosCUP);
    }
    else
      transFinal = transCUP;

    //Calcular Saldos de todas las transacciones

    return transFinal;
  }

  Future<List<Transaccion>> readTransCuc() async {
    List<Transaccion> transCUC = new List<Transaccion>();
    List<Saldo> saldosCUC = new List<Saldo>();
    SmsQuery query = new SmsQuery();
    final smsCollection = await query.querySms(address: "PAGOxMOVIL");
    smsCollection.forEach((SmsMessage sms) {
      List<Transaccion> trans = MessageToTransaction(sms);
      List<Transaccion> transactionsCUC = new List<Transaccion>();
      if(trans.length>0) {
        if (trans[0].moneda == TIPO_MONEDA.CUC)
          transCUC = trans;
      }
      Saldo saldo = MessageToSaldos(sms);
      if (saldo.monto != 0.0) {
        if (saldo.moneda == TIPO_MONEDA.CUC)
          saldosCUC.add(saldo);
      }
      for (int i = 0; i < transactionsCUC.length; i++) {
        if (!transCUC.contains(transactionsCUC[i])) transCUC.add(
            transactionsCUC[i]);
      }
    });

    List<Transaccion> transFinal;

    if (saldosCUC.length != 0) {
      transFinal = AgregarSaldoATransacciones(transCUC, saldosCUC);
    }
    else
      transFinal = transCUC;

    //Calcular Saldos de todas las transacciones

    return transFinal;
  }

  List<Transaccion> AgregarSaldoATransacciones(List<Transaccion> transacciones,
      List<Saldo> saldos) {
    for (int i = saldos.length - 1; i > -1; i--) {
      double saldo = saldos[i].monto;
      for (int j = transacciones.length - 1; j > -1; j--) {
        Transaccion trans = transacciones[j];
        Saldo sal = saldos[i];
        if (trans.fecha.isAfter(sal.fecha)) {
          if (trans.operacion == TIPO_TRANSACCION.DEBITO)
            saldo -= trans.monto;
          else if (trans.operacion == TIPO_TRANSACCION.CREDITO)
            saldo += trans.monto;

          trans.saldo = saldo;
          transacciones[j] = trans;
        }
      }
    }

    for (int i = 0; i < transacciones.length; i++) {
      if (transacciones[i].saldo == 0) {
        if (transacciones[i].operacion == TIPO_TRANSACCION.DEBITO) {
          transacciones[i].saldo =
              transacciones[i - 1].saldo + transacciones[i].monto;
        }
        else {
          transacciones[i].saldo =
              transacciones[i - 1].saldo - transacciones[i].monto;
        }
      }
    }
    return transacciones;
  }

  smsLoaded(List<Transaccion> list) {
    transaccionesCUP = list;
  }

  static TIPO_OPERACIONES identificarOperacion(SmsMessage message) {
    if (message.body.contains("La consulta de saldo"))
      return TIPO_OPERACIONES.CONSULTAR_SALDO;
    else if (message.body.contains("Fallo la consulta de saldo"))
      return TIPO_OPERACIONES.CONSULTAR_SALDO_ERROR;
    else if (message.body.contains("La Transferencia"))
      return TIPO_OPERACIONES.TRANSFERENCIA_TX_SALDO;
    else if (message.body.contains("Se ha realizado una transferencia"))
      return TIPO_OPERACIONES.TRANSFERENCIA_RX_SALDO;
    else if (message.body.contains("Fallo la transferencia"))
      return TIPO_OPERACIONES.TRANSFERENCIA_FALLIDA;
    else if (message.body.contains("Consulta de Servicio Error"))
      return TIPO_OPERACIONES.ERROR_FACTURA;
    else if (message.body.contains("  Factura: "))
      return TIPO_OPERACIONES.FACTURA;
    else if (message.body.contains("El pago de la factura"))
      return TIPO_OPERACIONES.FACTURA_PAGADA;
    else if (message.body.contains("Usted se ha autenticado en la plataforma"))
      return TIPO_OPERACIONES.AUTENTICAR;
    else if (message.body.contains("El código de activación"))
      return TIPO_OPERACIONES.INFO_CODIGO_ACTIVACION;
    else if (message.body.contains("Para obtener el codigo de activacion"))
      return TIPO_OPERACIONES.ERROR_CODIGO_ACTIVACION;
    else if (message.body.contains("La operacion de registro fue completada"))
      return TIPO_OPERACIONES.REGISTRAR_SUCESS;
    else if (message.body.contains("Error "))
      return TIPO_OPERACIONES.ERROR;
    else if (message.body.contains("Error "))
      return TIPO_OPERACIONES.ERROR_AUTENTICACION;
    else if (message.body.contains(
        "Fallo la consulta de servicio. Para realizar esta operacion"))
      return TIPO_OPERACIONES.ERROR_SERVICIO_SIN_AUTENTICACION;
    else
    if (message.body.contains("Fallo la consulta de las ultimas operaciones"))
      return TIPO_OPERACIONES.ERROR_ULTIMAS_OPERACIONES;
    else if (message.body.contains("Banco Metropolitano Ultimas operaciones"))
      return TIPO_OPERACIONES.ULTIMAS_OPERACIONES;

    else
      return TIPO_OPERACIONES.DEFAULT;
  }

  static TIPO_SERVICIO identificarServicio(String cadena) {
    TIPO_SERVICIO tipo_servicio = TIPO_SERVICIO.DEFAULT;
    if (cadena != null) {
      if (cadena.contains("AY"))
        tipo_servicio = TIPO_SERVICIO.ATM;
      else if (cadena.contains("TELF"))
        tipo_servicio = TIPO_SERVICIO.TELEFONO;
      else if (cadena.contains("TELF") || cadena.contains("telef"))
        tipo_servicio = TIPO_SERVICIO.TELEFONO;
      else if (cadena.contains("ELEC") || cadena.contains("electricidad"))
        tipo_servicio = TIPO_SERVICIO.ELECTRICIDAD;
      else if (cadena.contains("TRAN"))
        tipo_servicio = TIPO_SERVICIO.TRANSFERENCIA;
      else if (cadena.contains("EV"))
        tipo_servicio = TIPO_SERVICIO.SALARIO;
      else if (cadena.contains("IO"))
        tipo_servicio = TIPO_SERVICIO.INTERES;
      else if (cadena.contains("AP"))
        tipo_servicio = TIPO_SERVICIO.POS;
    }
    return tipo_servicio;
  }

  static TIPO_TRANSACCION identificarTransaccion(String cadena) {
    TIPO_TRANSACCION tipo_transaccion = TIPO_TRANSACCION.DEFAULT;
    if (cadena != null) {
      if (cadena.contains("DB"))
        tipo_transaccion = TIPO_TRANSACCION.DEBITO;
      else if (cadena.contains("CR"))
        tipo_transaccion = TIPO_TRANSACCION.CREDITO;
    }
    return tipo_transaccion;
  }

  static TIPO_MONEDA identificarTipoMoneda(String cadena) {
    TIPO_MONEDA tipo_moneda = TIPO_MONEDA.DEFAULT;
    if (cadena != null) {
      if (cadena.contains("CUC"))
        tipo_moneda = TIPO_MONEDA.CUC;
      else if (cadena.contains("CUP"))
        tipo_moneda = TIPO_MONEDA.CUP;
    }
    return tipo_moneda;
  }

  Saldo MessageToSaldos(SmsMessage message) {
    TIPO_OPERACIONES tipo_operaciones = identificarOperacion(message);

    Saldo saldo = new Saldo();

    if (tipo_operaciones == TIPO_OPERACIONES.CONSULTAR_SALDO) {
      var lines = message.body.split("\n");
      saldo.fecha = message.date;
      saldo.monto = double.parse(lines[1].trim().split(" ")[3].trim());
      saldo.moneda =
          identificarTipoMoneda(lines[1].trim().split(" ")[4].trim());
      saldo.isAutoGenerated = false;
    } else if (tipo_operaciones == TIPO_OPERACIONES.FACTURA_PAGADA) {
      var lines = message.body.split("\n");
      saldo.fecha = message.date;
      saldo.monto = double.parse(lines[4].trim().split(" ")[3].trim());
      saldo.moneda =
          identificarTipoMoneda(lines[4].trim().split(" ")[4].trim());
      saldo.isAutoGenerated = false;
    }


    return saldo;
  }
}