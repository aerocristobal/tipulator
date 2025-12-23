import SwiftUI

struct PaymentOptionsView: View {
    @Environment(\.dismiss) var dismiss
    let amount: Double
    let paymentRequestText: String

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)

                    Text("Request Payment")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Request \(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00") per person")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                Divider()

                // Payment apps section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Open Payment App")
                        .font(.headline)
                        .padding(.horizontal)

                    let installedApps = PaymentService.installedApps()

                    if installedApps.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "apps.iphone")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No payment apps detected")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Install Venmo, Cash App, Zelle, or PayPal to request payments directly")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(installedApps, id: \.self) { app in
                                PaymentAppButton(app: app, amount: amount) {
                                    PaymentService.openPaymentApp(app, amount: amount, note: "Split bill payment")
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Divider()

                // Share via Messages
                VStack(alignment: .leading, spacing: 12) {
                    Text("Or Share Request")
                        .font(.headline)
                        .padding(.horizontal)

                    ShareLink(item: paymentRequestText) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.system(size: 20))
                            Text("Share via Messages")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .accessibilityLabel("Share payment request via Messages")
                    .accessibilityHint("Opens share sheet to send payment request to contacts")
                }

                Spacer()
            }
            .navigationTitle("Payment Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PaymentAppButton: View {
    let app: PaymentService.PaymentApp
    let amount: Double
    let action: () -> Void

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: app.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(.green)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.rawValue)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Request \(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .accessibilityLabel("Request payment via \(app.rawValue)")
        .accessibilityHint("Opens \(app.rawValue) to request \(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00")")
    }
}

#Preview {
    PaymentOptionsView(
        amount: 29.50,
        paymentRequestText: "Please send me $29.50 for the dinner bill"
    )
}
