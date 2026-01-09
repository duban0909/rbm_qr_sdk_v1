package com.example.rbm_qr_sdk_v1

import android.app.Activity
import android.content.Context
import android.net.ConnectivityManager
import com.redeban.sdkqrcore.domain.QrManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** RbmQrSdkV1Plugin */
class RbmQrSdkV1Plugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rbm_qr_sdk_v1")
        channel.setMethodCallHandler(this)
    }

    // ---- Métodos de ActivityAware ----
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
    // ----------------------------------

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initializeLibrary" -> initializeLibrary(call, result)
            "transformData" -> transformData(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initializeLibrary(call: MethodCall, result: MethodChannel.Result) {
        val currentActivity = activity ?: run {
            result.error("NO_ACTIVITY", "Activity not attached", null)
            return
        }

        val url = "https://rgw.1647-63a93ef4.us-south.apiconnect.appdomain.cloud/rbmcalidad/calidad/api/v1/prx-licenses/validate"
        val publicKey = "a3c7002d989e83a163a2648fcf8631bf:ec9008b76dea494ebc623c0dda976d30"
        val license = "763cd5d7b76152c82162692a59aa362dcc616e72173239ff14e34e649459516e"

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val resp = QrManager.initializeLibrary(currentActivity, url, publicKey, license)
                val isValid = resp.isRight()
                withContext(Dispatchers.Main) {
                    if (isValid) {
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("INIT_ERROR", "Error inicializando SDK: ${e.message}", mapOf(
                        "exception_type" to e::class.java.simpleName,
                        "stack_trace" to e.stackTraceToString()
                    ))
                }
            }
        }
    }

    private fun transformData(call: MethodCall, result: MethodChannel.Result) {
        val currentActivity = activity ?: run {
            result.error("NO_ACTIVITY", "Activity not attached", null)
            return
        }

        val qrString = call.argument<String>("qrString")
        if (qrString.isNullOrEmpty()) {
            result.error("INVALID_INPUT", "QR string cannot be null or empty", null)
            return
        }

        try {
            QrManager.transformData(
                input = qrString,
                scannedQrEntity = { qrEntity ->
                    // Extraer el tag 90 considerando ambos patrones (legacy y nuevo)
                    val qrTxIdValue = qrEntity.emvcoList
                        ?.filter { it.tag == "90" }
                        ?.mapNotNull { emvco90 ->
                            val data = emvco90.data
                            // Patrón legacy: inicia con 01 + longitud (2) + valor, luego 00 + longitud (2) + valor
                            if (data.startsWith("01") && data.length >= 4) {
                                val len1 = data.substring(2, 4).toIntOrNull() ?: return@mapNotNull null
                                val start1 = 4
                                val end1 = start1 + len1
                                if (end1 > data.length) return@mapNotNull null
                                val txId = data.substring(start1, end1)
                                // Buscar si hay otro subtag después (ej: 00 + longitud + valor)
                                if (end1 + 4 <= data.length) {
                                    val subTag2 = data.substring(end1, end1 + 2)
                                    val len2 = data.substring(end1 + 2, end1 + 4).toIntOrNull() ?: 0
                                    val start2 = end1 + 4
                                    val end2 = start2 + len2
                                    if (subTag2 == "00" && end2 <= data.length) {
                                        val value2 = data.substring(start2, end2)
                                        // Concatenar primero el valor largo (entidad) y luego el valor corto (TxId)
                                        return@mapNotNull value2 + txId
                                    }
                                }
                                // Si solo hay un subtag, devolver ese valor
                                return@mapNotNull txId
                            }
                            // Patrón nuevo: 00 + longitud + valor, 01 + longitud + valor, etc.
                            val subtags = mutableListOf<String>()
                            var idx = 0
                            while (idx + 4 <= data.length) {
                                val subTag = data.substring(idx, idx + 2)
                                val len = data.substring(idx + 2, idx + 4).toIntOrNull() ?: break
                                val valueStart = idx + 4
                                val valueEnd = valueStart + len
                                if (valueEnd > data.length) break
                                val value = data.substring(valueStart, valueEnd)
                                subtags.add(value)
                                idx = valueEnd
                            }
                            if (subtags.isNotEmpty()) subtags.joinToString("") else null
                        }
                        ?.joinToString("")

                    val qrData: Map<String, Any?> = mapOf(
                        "channel" to qrEntity.merchantUnreservedTemplamples?.channel,
                        "merchantCity" to qrEntity.merchantCity,
                        "ivaTaxIndicator" to "01",
                        "purposeOfTransaction" to qrEntity.merchantAdditionalData?.purposeOfTransaction,
                        "QRType" to if(qrEntity.pointOfInitiationMethod == "12") "DNI" else "STA",
                        "terminalLabel" to qrEntity.merchantAdditionalData?.terminalLabel,
                        "tipOrConvenienceIndicator" to qrEntity.tipOrConvenienceIndicator,
                        "valueOfConvenienceFeeFixed" to qrEntity.valueOfConvenienceFeeFixed,
                        "TransactionAmount" to qrEntity.transactionAmount,
                        "QRTransactionID" to qrEntity.merchantUnreservedTemplamples?.consecutiveTransaction,
                        "MerchantID" to qrEntity.merchantAccountInformation?.uniqueCodeMerchant,
                        "multikeyPayment" to qrEntity.merchantAccountInformation?.multikeyPayment,
                        "SecurityCode" to qrEntity.merchantUnreservedTemplamples?.securityField,
                        "merchantName" to qrEntity.merchantName,
                        "storeLabel" to qrEntity.merchantAdditionalData?.storeLabel,
                        "transactionCurrency" to qrEntity.transactionCurrency,
                        "rrn" to qrEntity.rrn,
                        "approvalNumber" to qrEntity.approvalNumber,
                        "idAcquirer" to qrEntity.merchantAccountInformation?.idAcquirer,
                        "QrTxId" to qrTxIdValue
                    )

                    result.success(qrData)
                },
                scanError = { error ->
                    result.error("TRANSFORM_ERROR", error.toString(), null)
                }
            )
        } catch (e: Exception) {
            result.error("TRANSFORM_EXCEPTION", e.message, null)
        }
    }

}
