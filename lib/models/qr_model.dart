class QrModel {
  final String? channel;
  final dynamic incAmount;
  final String? incTaxIndicator;
  final dynamic ivaAmount;
  final dynamic ivaAmountBase;
  final String? ivaTaxIndicator;
  final String? purposeOfTransaction;
  final String? qrType;
  final String? terminalLabel;
  final String? tipOrConvenienceIndicator;
  final double? transactionAmount;
  final String? qrTransactionId;
  final String? merchantId;
  final String? multikeyPayment;
  final String? securityCode;
  final String? merchantName;
  final String? storeLabel;
  final String? transactionCurrency;
  final int? rrn;
  final int? approvalNumber;
  final String? idAcquirer;
  final String? qrTxId;

  QrModel({
    this.channel,
    this.incAmount,
    this.incTaxIndicator,
    this.ivaAmount,
    this.ivaAmountBase,
    this.ivaTaxIndicator,
    this.purposeOfTransaction,
    this.qrType,
    this.terminalLabel,
    this.tipOrConvenienceIndicator,
    this.transactionAmount,
    this.qrTransactionId,
    this.merchantId,
    this.multikeyPayment,
    this.securityCode,
    this.merchantName,
    this.storeLabel,
    this.transactionCurrency,
    this.rrn,
    this.approvalNumber,
    this.idAcquirer,
    this.qrTxId,
  });

  @override
  String toString() {
    return '{"channel": $channel, "incAmount": $incAmount, "incTaxIndicator": $incTaxIndicator, "ivaAmount": $ivaAmount, "ivaAmountBase": $ivaAmountBase, "ivaTaxIndicator": $ivaTaxIndicator, "purposeOfTransaction": $purposeOfTransaction, "qrType": $qrType, "terminalLabel": $terminalLabel, "tipOrConvenienceIndicator": $tipOrConvenienceIndicator, "transactionAmount": $transactionAmount, "qrTransactionId": $qrTransactionId, "merchantId": $merchantId, "multikeyPayment": $multikeyPayment, "securityCode": $securityCode, "merchantName": $merchantName, "storeLabel": $storeLabel, "transactionCurrency": $transactionCurrency, "rrn": $rrn, "approvalNumber": $approvalNumber, "idAcquirer": $idAcquirer}';
  }

  Map<String, dynamic> toJson() {
    return {
      "channel": channel,
      "incAmount": incAmount,
      "incTaxIndicator": incTaxIndicator,
      "ivaAmount": ivaAmount,
      "ivaAmountBase": ivaAmountBase,
      "ivaTaxIndicator": ivaTaxIndicator,
      "purposeOfTransaction": purposeOfTransaction,
      "qrType": qrType,
      "terminalLabel": terminalLabel,
      "tipOrConvenienceIndicator": tipOrConvenienceIndicator,
      "transactionAmount": transactionAmount,
      "qrTransactionId": qrTransactionId,
      "merchantId": merchantId,
      "multikeyPayment": multikeyPayment,
      "securityCode": securityCode,
      "merchantName": merchantName,
      "storeLabel": storeLabel,
      "transactionCurrency": transactionCurrency,
      "rrn": rrn,
      "approvalNumber": approvalNumber,
      "idAcquirer": idAcquirer,
      "qrTxId": qrTxId,
    };
  }
}
