import SwiftUI

struct ContentView: View {
    @StateObject private var calculator = TipCalculator()
    @FocusState private var billAmountIsFocused: Bool
    @State private var showingPresetEditor = false
    @State private var editingPresetIndex: Int?
    @State private var editingPresetValue: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        billAmountSection
                        tipPercentageSection
                        palindromeToggleSection
                        numberOfPeopleSection
                        resultsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Tipulator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        billAmountIsFocused = false
                    }
                }
            }
            .alert("Edit Preset Percentage", isPresented: $showingPresetEditor) {
                TextField("Percentage (0-50)", text: $editingPresetValue)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {
                    editingPresetIndex = nil
                    editingPresetValue = ""
                }
                Button("Save") {
                    if let index = editingPresetIndex,
                       let newValue = Int(editingPresetValue),
                       newValue >= 0 && newValue <= 50 {
                        calculator.updatePreset(at: index, to: newValue)
                    }
                    editingPresetIndex = nil
                    editingPresetValue = ""
                }
            } message: {
                Text("Enter a percentage between 0 and 50")
            }
        }
    }

    private var billAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bill Amount")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text("$")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                TextField("0.00", text: $calculator.billAmountText)
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .focused($billAmountIsFocused)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private var tipPercentageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tip Percentage")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(Array(calculator.presetPercentages.enumerated()), id: \.offset) { index, percentage in
                        tipPercentageButton(percentage, index: index)
                    }
                }

                VStack(spacing: 8) {
                    HStack {
                        Text("Custom: \(Int(calculator.customTipPercentage))%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    Slider(value: $calculator.customTipPercentage, in: 0...50, step: 1)
                        .tint(.green)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private func tipPercentageButton(_ percentage: Int, index: Int) -> some View {
        Button(action: {
            calculator.selectedTipPercentage = percentage
            billAmountIsFocused = false
        }) {
            Text("\(percentage)%")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(calculator.selectedTipPercentage == percentage ? Color.green : Color(.systemBackground))
                .foregroundColor(calculator.selectedTipPercentage == percentage ? .white : .primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: calculator.selectedTipPercentage == percentage ? 0 : 1)
                )
        }
        .contextMenu {
            Button(action: {
                editingPresetIndex = index
                editingPresetValue = String(percentage)
                showingPresetEditor = true
            }) {
                Label("Edit Preset", systemImage: "pencil")
            }
        }
    }

    private var palindromeToggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Palindrome Rounding")
                        .font(.headline)
                    Text("Round total to nearest palindrome")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $calculator.usePalindromeRounding)
                    .labelsHidden()
                    .tint(.green)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

            if calculator.usePalindromeRounding && calculator.palindromeAdjustment > 0 {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.green)
                    Text("Tip adjusted by \(currencyFormatter.string(from: NSNumber(value: calculator.palindromeAdjustment)) ?? "$0.00") for palindrome total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var numberOfPeopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Split Between")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button(action: {
                    if calculator.numberOfPeople > 1 {
                        calculator.numberOfPeople -= 1
                    }
                    billAmountIsFocused = false
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(calculator.numberOfPeople > 1 ? Color.green : Color.gray.opacity(0.3))
                }
                .disabled(calculator.numberOfPeople <= 1)

                VStack(spacing: 4) {
                    Text("\(calculator.numberOfPeople)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text(calculator.numberOfPeople == 1 ? "Person" : "People")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Button(action: {
                    calculator.numberOfPeople += 1
                    billAmountIsFocused = false
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private var resultsSection: some View {
        VStack(spacing: 16) {
            resultRow(title: "Tip Amount", amount: calculator.tipAmount)

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if calculator.isPalindrome {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }

                Spacer()

                Text(currencyFormatter.string(from: NSNumber(value: calculator.totalAmount)) ?? "$0.00")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
            }

            Divider()
                .padding(.vertical, 8)

            VStack(spacing: 8) {
                Text("Per Person")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(currencyFormatter.string(from: NSNumber(value: calculator.amountPerPerson)) ?? "$0.00")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
    }

    private func resultRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
        }
    }

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }
}

#Preview {
    ContentView()
}
