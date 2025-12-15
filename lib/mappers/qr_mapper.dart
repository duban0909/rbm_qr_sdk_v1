import 'package:rbm_qr_sdk_v1/models/qr_model.dart';

class QrMapper {
  static QrModel fromJson(Map<String, dynamic> json) {
    print('Mapping JSON to QrModel: ${json['channel']}');
    return QrModel(
      channel: json['channel'] ?? 'No channel',
      incAmount: json['incAmount'] ?? 0.0,
      incTaxIndicator: json['incTaxIndicator'] ?? 'No incTaxIndacaor',
      ivaAmount: json['ivaAmount'] ?? 0.0,
      ivaAmountBase: json['ivaAmountBase'] ?? 0.0,
      ivaTaxIndicator: json['ivaTaxIndicator'] ?? 'No ivaTaxIndicator',
      purposeOfTransaction:
          json['purposeOfTransaction'] ?? 'No purposeOfTransaction',
      qrType: json['QRType'] ?? 'No QRType',
      terminalLabel: json['terminalLabel'] ?? 'No terminal',
      tipOrConvenienceIndicator:
          json['tipOrConvenienceIndicator'] ?? 'No tipOrConvenienceIndicator',
      transactionAmount: _parseDouble(json['TransactionAmount']),
      qrTransactionId: json['QRTransactionID'] ?? 'No QRTransactionID',
      merchantId: json['MerchantID'] ?? 'NA',
      securityCode: json['SecurityCode'] ?? 'No securityCode',
      merchantName: json['merchantName'] ?? '',
      storeLabel: json['storeLabel'] ?? '',
      transactionCurrency: json['transactionCurrency'] ?? '',
      rrn: json['RRN'] ?? 0,
      approvalNumber: json['approvalNumber'] ?? 0,
      multikeyPayment: json['multikeyPayment'] ?? 'NA',
      idAcquirer: json['idAcquirer'],
      qrTxId: json['qrTxId'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }
}
