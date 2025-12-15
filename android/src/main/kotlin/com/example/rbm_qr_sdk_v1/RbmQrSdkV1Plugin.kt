package com.example.rbm_qr_sdk_v1

import android.app.Activity
import android.content.Context
import android.net.ConnectivityManager
import android.util.Log
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

        // Verificar conectividad de red
        val connectivityManager = currentActivity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkInfo = connectivityManager.activeNetworkInfo
        val isConnected = networkInfo?.isConnected == true
        
        Log.d("RbmQrSdkV1", "Estado de red - Conectado: $isConnected, Tipo: ${networkInfo?.typeName}")
        
        if (!isConnected) {
            Log.w("RbmQrSdkV1", "No hay conexión a internet disponible")
        }

        val url = "https://rgw.1647-63a93ef4.us-south.apiconnect.appdomain.cloud/rbmcalidad/calidad/api/v1/prx-licenses/validate"
        val publicKey = "a3c7002d989e83a163a2648fcf8631bf:ec9008b76dea494ebc623c0dda976d30"
        val license = "763cd5d7b76152c82162692a59aa362dcc616e72173239ff14e34e649459516e"

        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d("RbmQrSdkV1", "Iniciando validación de licencia...")
                Log.d("RbmQrSdkV1", "URL: $url")
                Log.d("RbmQrSdkV1", "PublicKey: ${publicKey.take(10)}...")
                Log.d("RbmQrSdkV1", "License: ${license.take(10)}...")
                
                val resp = QrManager.initializeLibrary(currentActivity, url, publicKey, license)
                
                Log.d("RbmQrSdkV1", "Respuesta recibida: $resp")
                Log.d("RbmQrSdkV1", "Tipo de respuesta: ${resp::class.java.simpleName}")
                
                val isValid = resp.isRight()
                Log.d("RbmQrSdkV1", "¿Es válida la respuesta? $isValid")
                
                // Logging adicional para debug
                if (!isValid) {
                    Log.w("RbmQrSdkV1", "Respuesta no válida. Contenido: $resp")
                    // Si resp es Either, podemos obtener el error
                    try {
                        val errorMsg = resp.fold(
                            { error -> 
                                Log.e("RbmQrSdkV1", "Error de serialización detectado: $error")
                                if (error.toString().contains("Serializer for class")) {
                                    "ERROR DE SERIALIZACIÓN: Las clases del SDK fueron obfuscadas por ProGuard/R8. Se necesitan reglas de ProGuard."
                                } else {
                                    error.toString()
                                }
                            }, 
                            { success -> 
                                Log.w("RbmQrSdkV1", "Éxito pero isRight() devolvió false: $success")
                                "Response is right but isRight() returned false: $success"
                            }
                        )
                        Log.w("RbmQrSdkV1", "Error details: $errorMsg")
                    } catch (e: Exception) {
                        Log.w("RbmQrSdkV1", "No se pudo obtener detalles del error: ${e.message}")
                    }
                }

                withContext(Dispatchers.Main) {
                    if (isValid) {
                        Log.i("RbmQrSdkV1", "SDK RBM inicializado correctamente")
                        result.success(true)
                    } else {
                        Log.w("RbmQrSdkV1", "Error al inicializar SDK RBM - La licencia no es válida o hay problemas de conectividad")
                        result.success(false)
                    }
                }
            } catch (e: Exception) {
                Log.e("RbmQrSdkV1", "Excepción durante la inicialización del SDK", e)
                Log.e("RbmQrSdkV1", "Stack trace completo:", e)
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
        Log.v("RbmQrSdkV1", "Transformando QR: $qrString")
        if (qrString.isNullOrEmpty()) {
            result.error("INVALID_INPUT", "QR string cannot be null or empty", null)
            return
        }

        try {
            QrManager.transformData(
                input = qrString,
                scannedQrEntity = { qrEntity ->
                    Log.v("RbmQrSdkV1", "QR transformado: ${qrEntity.emvcoList}")

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
                    Log.v("RbmQrSdkV1", "Valor de QrTxId (tag 90): $qrTxIdValue")

                    val qrData = mapOf(
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
                        "transactionCurrency" to qrEntity.transactionAmount,
                        "rrn" to qrEntity.rrn,
                        "approvalNumber" to qrEntity.approvalNumber,
                        "idAcquirer" to qrEntity.merchantAccountInformation?.idAcquirer,
                        "QrTxId" to qrTxIdValue
                    )

                    activity?.runOnUiThread {
                        result.success(qrData)
                    }
                },
                scanError = { error ->
                    activity?.runOnUiThread {
                        Log.e("RbmQrSdkV1", "Error al transformar QR: $error")
                        result.error("TRANSFORM_ERROR", error.toString(), null)
                    }
                }
            )
        } catch (e: Exception) {
            Log.e("RbmQrSdkV1", "Excepción al transformar QR", e)
            result.error("TRANSFORM_EXCEPTION", e.message, null)
        }
    }

}
