package com.example.sangam_pro.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.example.sangam_pro.channels.UpiNotificationStreamHandler
import com.example.sangam_pro.models.UpiPayment

class UpiNotificationListener : NotificationListenerService() {

    private val upiPackages = setOf(
        "com.google.android.apps.nbu.paisa.user",
        "net.one97.paytm",
        "com.phonepe.app",
        "in.org.npci.upiapp",
        "com.amazon.mShop.android.shopping"
    )

    private val amountRegex = Regex("""(?:Rs\\.?|₹)\\s*([\\d,]+(?:\\.\\d{1,2})?)""", RegexOption.IGNORE_CASE)

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in upiPackages) return

        val extras = sbn.notification.extras
        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""
        val fullText = "$title $text $bigText".trim()

        if (!isPaymentReceived(fullText)) return

        val amount = extractAmount(fullText) ?: return
        val sender = extractSender(fullText)
        val payment = UpiPayment(
            amount = amount,
            sender = sender,
            appSource = sbn.packageName,
            timestamp = sbn.postTime,
            rawText = fullText,
        )

        Log.d("UpiListener", "Payment captured: $payment")
        UpiNotificationStreamHandler.emit(payment)
    }

    private fun isPaymentReceived(text: String): Boolean {
        val t = text.lowercase()
        val keywords = listOf("received", "credited", "you got", "payment received", "paid you", "sent you")
        return keywords.any { t.contains(it) }
    }

    private fun extractAmount(text: String): Double? {
        return amountRegex.find(text)
            ?.groupValues
            ?.getOrNull(1)
            ?.replace(",", "")
            ?.toDoubleOrNull()
    }

    private fun extractSender(text: String): String {
        val fromRegex = Regex("""^(.+?)\\s+(?:paid|sent)\\s+you""", RegexOption.IGNORE_CASE)
        return fromRegex.find(text)?.groupValues?.getOrNull(1)?.trim().orEmpty().ifEmpty { "Unknown" }
    }
}
