import SwiftUI

struct ContentView: View {
    @StateObject private var calculator = TipCalculator()
    @StateObject private var settings = Settings()
    @FocusState private var billAmountIsFocused: Bool
    @FocusState private var customPeopleIsFocused: Bool
    @State private var showingPresetEditor = false
    @State private var editingPresetIndex: Int?
    @State private var editingPresetValue: String = ""
    @State private var showingSettings = false
    @State private var customPeopleText: String = ""

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.15),
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: geometry.size.height * 0.015) {
                        billAmountSection
                        tipPercentageSection

                        HStack(spacing: geometry.size.width * 0.03) {
                            palindromeToggleSection
                            dollarRoundingSection
                        }

                        numberOfPeopleSection
                        resultsSection
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Tipulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.green)
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        billAmountIsFocused = false
                        customPeopleIsFocused = false
                    }
                }
            }
            .preferredColorScheme(settings.appearanceMode.colorScheme)
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
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
        }
    }

    private var billAmountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bill Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("$")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                TextField("0.00", text: $calculator.billAmountText)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .focused($billAmountIsFocused)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassCard()
        }
    }

    private var tipPercentageSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tip Percentage")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(Array(calculator.presetPercentages.enumerated()), id: \.offset) { index, percentage in
                        tipPercentageButton(percentage, index: index)
                    }
                }

                VStack(spacing: 4) {
                    HStack {
                        Text("Custom: \(Int(calculator.customTipPercentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    Slider(value: $calculator.customTipPercentage, in: 0...50, step: 1)
                        .tint(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .glassCard()
        }
    }

    private func tipPercentageButton(_ percentage: Int, index: Int) -> some View {
        Button(action: {
            calculator.selectedTipPercentage = percentage
            billAmountIsFocused = false
        }) {
            Text("\(percentage)%")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(calculator.selectedTipPercentage == percentage ? Color.green : Color(.systemBackground))
                .foregroundColor(calculator.selectedTipPercentage == percentage ? .white : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
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
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Palindrome")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle("", isOn: $calculator.usePalindromeRounding)
                    .labelsHidden()
                    .tint(.green)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
    }

    private var dollarRoundingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Dollar Rounding")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("", selection: $calculator.dollarRoundingMode) {
                    ForEach(TipCalculator.DollarRoundingMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .tint(.green)
                .disabled(calculator.usePalindromeRounding)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
            .opacity(calculator.usePalindromeRounding ? 0.4 : 1.0)
        }
    }

    private var numberOfPeopleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Split Between")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                // Preset buttons for 1, 2, and 4
                ForEach([1, 2, 4], id: \.self) { count in
                    Button(action: {
                        calculator.numberOfPeople = count
                        customPeopleText = ""
                        billAmountIsFocused = false
                        customPeopleIsFocused = false
                    }) {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(calculator.numberOfPeople == count && customPeopleText.isEmpty ? Color.green : Color(.systemBackground))
                            .foregroundColor(calculator.numberOfPeople == count && customPeopleText.isEmpty ? .white : .primary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: calculator.numberOfPeople == count && customPeopleText.isEmpty ? 0 : 1)
                            )
                    }
                }

                // Custom text field
                TextField("___", text: $customPeopleText)
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($customPeopleIsFocused)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(!customPeopleText.isEmpty ? Color.green : Color(.systemBackground))
                    .foregroundColor(!customPeopleText.isEmpty ? .white : .primary)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.3), lineWidth: !customPeopleText.isEmpty ? 0 : 1)
                    )
                    .onChange(of: customPeopleText) { oldValue, newValue in
                        // Limit to 3 digits
                        let filtered = newValue.filter { $0.isNumber }
                        let limited = String(filtered.prefix(3))
                        customPeopleText = limited

                        // Update calculator
                        if let value = Int(limited), value > 0 {
                            calculator.numberOfPeople = value
                        }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .glassCard()
        }
    }

    private var resultsSection: some View {
        VStack(spacing: 8) {
            resultRow(title: "Tip", amount: calculator.tipAmount)

            HStack {
                Text("Total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if calculator.isPalindrome {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.caption2)
                }

                Spacer()

                Text(currencyFormatter.string(from: NSNumber(value: calculator.totalAmount)) ?? "$0.00")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }

            Divider()
                .padding(.vertical, 2)

            VStack(spacing: 4) {
                Text("Per Person")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(currencyFormatter.string(from: NSNumber(value: calculator.amountPerPerson)) ?? "$0.00")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glassCard()
    }

    private func resultRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
    }

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .shadow(color: Color.green.opacity(0.1), radius: 15, x: 0, y: 5)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}

#Preview {
    ContentView()
}
