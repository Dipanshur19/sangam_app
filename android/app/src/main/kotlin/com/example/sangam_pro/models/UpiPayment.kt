package com.example.sangam_pro.models

data class UpiPayment(
    val amount: Double,
    val sender: String,
    val appSource: String,
    val timestamp: Long,
    val rawText: String
) {
    fun toMap(): Map<String, Any> = mapOf(
        "amount" to amount,
        "sender" to sender,
        "appSource" to appSource,
        "timestamp" to timestamp,
        "rawText" to rawText,
    )
}
