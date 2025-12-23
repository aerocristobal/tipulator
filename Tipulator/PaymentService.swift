import Foundation
import UIKit

/// Service for generating payment request deep links to popular payment apps
class PaymentService {

    enum PaymentApp: String, CaseIterable {
        case venmo = "Venmo"
        case cashApp = "Cash App"
        case zelle = "Zelle"
        case payPal = "PayPal"

        var iconName: String {
            switch self {
            case .venmo: return "v.circle.fill"
            case .cashApp: return "dollarsign.circle.fill"
            case .zelle: return "z.circle.fill"
            case .payPal: return "p.circle.fill"
            }
        }

        var urlScheme: String {
            switch self {
            case .venmo: return "venmo://"
            case .cashApp: return "cashapp://"
            case .zelle: return "zelle://"
            case .payPal: return "paypal://"
            }
        }
    }

    /// Check if a payment app is installed on the device
    static func isAppInstalled(_ app: PaymentApp) -> Bool {
        guard let url = URL(string: app.urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    /// Get list of installed payment apps
    static func installedApps() -> [PaymentApp] {
        PaymentApp.allCases.filter { isAppInstalled($0) }
    }

    /// Generate deep link URL for payment request
    static func generatePaymentLink(app: PaymentApp, amount: Double, note: String) -> URL? {
        switch app {
        case .venmo:
            return generateVenmoLink(amount: amount, note: note)
        case .cashApp:
            return generateCashAppLink(amount: amount, note: note)
        case .zelle:
            // Zelle doesn't support deep link parameters, use SMS fallback
            return nil
        case .payPal:
            return generatePayPalLink(amount: amount, note: note)
        }
    }

    /// Generate Venmo payment request link
    /// Format: venmo://paycharge?txn=pay&recipients=USERNAME&amount=AMOUNT&note=NOTE
    private static func generateVenmoLink(amount: Double, note: String) -> URL? {
        let encodedNote = note.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let amountString = String(format: "%.2f", amount)

        // Note: Venmo requires username, which we don't have. Open app to request screen.
        let urlString = "venmo://paycharge?txn=pay&amount=\(amountString)&note=\(encodedNote)"
        return URL(string: urlString)
    }

    /// Generate Cash App payment request link
    /// Format: cashapp://qr/USERNAME?amount=AMOUNT&note=NOTE
    private static func generateCashAppLink(amount: Double, note: String) -> URL? {
        let encodedNote = note.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let amountString = String(format: "%.2f", amount)

        // Cash App requires cashtag, which we don't have. Open app to request screen.
        let urlString = "cashapp://cash.app?amount=\(amountString)&note=\(encodedNote)"
        return URL(string: urlString)
    }

    /// Generate PayPal payment request link
    /// Format: paypal://paypalme/USERNAME?amount=AMOUNT
    private static func generatePayPalLink(amount: Double, note: String) -> URL? {
        let amountString = String(format: "%.2f", amount)

        // PayPal.me requires username, which we don't have. Open app to send money screen.
        let urlString = "paypal://sendmoney?amount=\(amountString)"
        return URL(string: urlString)
    }

    /// Open payment app with pre-filled request
    static func openPaymentApp(_ app: PaymentApp, amount: Double, note: String) {
        // Try deep link first
        if let deepLink = generatePaymentLink(app: app, amount: amount, note: note) {
            UIApplication.shared.open(deepLink)
        } else if let appURL = URL(string: app.urlScheme) {
            // Fallback: Just open the app
            UIApplication.shared.open(appURL)
        }
    }

    /// Generate SMS payment request message
    static func generateSMSPaymentRequest(amount: Double, tipPercent: Int, totalBill: Double, numberOfPeople: Int) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current

        let amountStr = currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
        let totalStr = currencyFormatter.string(from: NSNumber(value: totalBill)) ?? "$\(String(format: "%.2f", totalBill))"

        var message = "💸 Payment Request\n\n"
        message += "Please send me \(amountStr)\n\n"
        message += "Bill Details:\n"
        message += "• Total: \(totalStr)\n"
        message += "• Tip: \(tipPercent)%\n"

        if numberOfPeople > 1 {
            message += "• Split \(numberOfPeople) ways\n"
        }

        message += "\nYou can pay via:\n"

        let installedApps = installedApps()
        if !installedApps.isEmpty {
            for app in installedApps {
                message += "• \(app.rawValue)\n"
            }
        } else {
            message += "• Venmo\n• Cash App\n• Zelle\n• PayPal\n"
        }

        message += "\n📱 Sent from Tipulator"

        return message
    }
}
