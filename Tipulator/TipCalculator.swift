import Foundation
import Combine

class TipCalculator: ObservableObject {
    private static let presetPercentagesKey = "PresetTipPercentages"
    private static let defaultPresets = [10, 18, 20, 22]

    @Published var presetPercentages: [Int] {
        didSet {
            savePresets()
        }
    }

    @Published var billAmountText: String = "" {
        didSet {
            calculateTip()
        }
    }

    @Published var selectedTipPercentage: Int = 18 {
        didSet {
            if selectedTipPercentage > 0 {
                isUpdatingFromButton = true
                customTipPercentage = Double(selectedTipPercentage)
                isUpdatingFromButton = false
            }
            calculateTip()
        }
    }

    @Published var customTipPercentage: Double = 18.0 {
        didSet {
            if !isUpdatingFromButton && selectedTipPercentage != Int(customTipPercentage) {
                selectedTipPercentage = 0
            }
            calculateTip()
        }
    }

    private var isUpdatingFromButton: Bool = false

    init() {
        self.presetPercentages = Self.loadPresets()
    }

    @Published var numberOfPeople: Int = 1 {
        didSet {
            calculateTip()
        }
    }

    @Published var usePalindromeRounding: Bool = false {
        didSet {
            calculateTip()
        }
    }

    @Published var dollarRoundingMode: DollarRoundingMode = .none {
        didSet {
            calculateTip()
        }
    }

    @Published private(set) var tipAmount: Double = 0.0
    @Published private(set) var totalAmount: Double = 0.0
    @Published private(set) var amountPerPerson: Double = 0.0
    @Published private(set) var palindromeAdjustment: Double = 0.0
    @Published private(set) var dollarRoundingAdjustment: Double = 0.0
    @Published private(set) var isPalindrome: Bool = false

    enum DollarRoundingMode: String, CaseIterable {
        case none = "None"
        case up = "Round Up"
        case down = "Round Down"
    }

    private var billAmount: Double {
        let cleanedText = billAmountText.replacingOccurrences(of: ",", with: "")
        return Double(cleanedText) ?? 0.0
    }

    private var effectiveTipPercentage: Double {
        selectedTipPercentage > 0 ? Double(selectedTipPercentage) : customTipPercentage
    }

    private func calculateTip() {
        let bill = billAmount
        let tipPercentage = effectiveTipPercentage / 100.0

        var calculatedTip = bill * tipPercentage
        var calculatedTotal = bill + calculatedTip

        var totalPalindromeAdjustment = 0.0
        var totalDollarRoundingAdjustment = 0.0

        if usePalindromeRounding && bill > 0 {
            let palindromeTotal = findNextPalindrome(from: calculatedTotal)
            totalPalindromeAdjustment = palindromeTotal - calculatedTotal
            calculatedTip += totalPalindromeAdjustment
            calculatedTotal = palindromeTotal
            isPalindrome = true
        } else {
            isPalindrome = false
        }

        if dollarRoundingMode != .none && bill > 0 {
            let roundedTotal = applyDollarRounding(to: calculatedTotal, mode: dollarRoundingMode)
            totalDollarRoundingAdjustment = roundedTotal - calculatedTotal
            calculatedTip += totalDollarRoundingAdjustment
            calculatedTotal = roundedTotal
        }

        palindromeAdjustment = totalPalindromeAdjustment
        dollarRoundingAdjustment = totalDollarRoundingAdjustment
        tipAmount = calculatedTip
        totalAmount = calculatedTotal
        amountPerPerson = numberOfPeople > 0 ? totalAmount / Double(numberOfPeople) : 0.0
    }

    private func applyDollarRounding(to amount: Double, mode: DollarRoundingMode) -> Double {
        switch mode {
        case .none:
            return amount
        case .up:
            return ceil(amount)
        case .down:
            return floor(amount)
        }
    }

    private func isPalindromeNumber(_ value: Double) -> Bool {
        let cents = Int(round(value * 100))
        let str = String(cents)
        return str == String(str.reversed())
    }

    private func findNextPalindrome(from value: Double) -> Double {
        let startCents = Int(ceil(value * 100))

        for cents in startCents...Int(value * 100) + 100000 {
            let str = String(cents)
            if str == String(str.reversed()) {
                return Double(cents) / 100.0
            }
        }

        return value
    }

    private static func loadPresets() -> [Int] {
        if let saved = UserDefaults.standard.array(forKey: presetPercentagesKey) as? [Int], saved.count == 4 {
            return saved
        }
        return defaultPresets
    }

    private func savePresets() {
        UserDefaults.standard.set(presetPercentages, forKey: Self.presetPercentagesKey)
    }

    func updatePreset(at index: Int, to newValue: Int) {
        guard index >= 0 && index < presetPercentages.count else { return }
        guard newValue >= 0 && newValue <= 50 else { return }
        presetPercentages[index] = newValue
    }
}
