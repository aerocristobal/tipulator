# Tipulator

A modern iOS tip calculator app built with SwiftUI, inspired by the classic Tipulator app.

## Features

- **Bill Amount Entry**: Easy-to-use currency input with large, readable text
- **Customizable Preset Percentages**: Four quick-select buttons with default values (10%, 18%, 20%, 22%)
  - Long-press any preset button to customize it
  - Your custom presets are saved automatically
- **Custom Tip Percentage**: Slider control for any tip amount from 0% to 50%
- **Palindrome Rounding**: Unique feature that rounds up the tip to make the total a palindrome number (e.g., $57.75, $63.36, $120.21)
- **Dollar Rounding**: Round the total up or down to the nearest whole dollar
  - Options: None, Round Up, Round Down
  - Perfect for cash payments
- **Bill Splitting**: Split the bill between multiple people with easy increment/decrement controls
- **Real-time Calculations**: Instant updates showing:
  - Tip amount
  - Total bill amount
  - Amount per person (when splitting)
  - Palindrome adjustment amount (when enabled)
  - Dollar rounding adjustment (when enabled)
- **Customizable Settings**:
  - **Appearance Mode**: Choose Light, Dark, or System (follows device setting)
  - Settings persist across app launches
- **Liquid Glass Design**: Modern glassmorphism UI with:
  - Translucent glass-effect cards using `.ultraThinMaterial`
  - Multi-layered gradient backgrounds (green, blue, purple)
  - Luminous white gradient overlays
  - Soft gradient borders for depth
  - Dual shadow system (depth + glow)
  - Smooth 20px corner radius throughout
- **Modern iOS Design**: Clean interface using iOS 18+ design patterns
- **Accessibility**: Full VoiceOver support and Dynamic Type compatibility

## Requirements

- iOS 18.0 or later
- Xcode 16.0 or later
- Swift 5.9 or later

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/tipulator.git
   cd tipulator
   ```

2. Open the project in Xcode:
   ```bash
   open Tipulator.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the project (Cmd + R)

## Usage

1. **Enter Bill Amount**: Tap the bill amount field and enter the total
2. **Select Tip Percentage**:
   - Tap a preset button (10%, 18%, 20%, or 22% by default)
   - Or use the custom slider for any percentage from 0% to 50%
3. **Customize Presets** (Optional): Long-press any preset button to change its value
   - Your custom presets are saved automatically
   - Perfect for your favorite tipping percentages
4. **Enable Palindrome Rounding** (Optional): Toggle on to automatically adjust the tip so the total becomes a palindrome number
5. **Enable Dollar Rounding** (Optional): Choose to round the total up or down to the nearest whole dollar
   - Perfect for cash payments or even totals
6. **Split the Bill**: Use the +/- buttons to adjust the number of people
7. **Access Settings** (Optional): Tap the gear icon to customize:
   - **Appearance**: Switch between Light, Dark, or System mode
8. **View Results**: The app automatically calculates and displays:
   - Tip amount (including palindrome adjustment if enabled)
   - Total amount (with checkmark seal when it's a palindrome)
   - Amount per person

### What is Palindrome Rounding?

A palindrome number reads the same forwards and backwards. When palindrome rounding is enabled, the app finds the nearest palindrome total amount (in cents) and adjusts your tip accordingly.

**Examples:**
- Bill: $50.00, 15% tip = $57.50 → Rounds to $57.75 (5775 cents)
- Bill: $100.00, 20% tip = $120.00 → Rounds to $120.21 (12021 cents)
- Bill: $45.67, 18% tip = $53.89 → Rounds to $54.45 (5445 cents)

The app displays how much extra was added to achieve the palindrome total.

### What is Dollar Rounding?

Dollar rounding adjusts the tip so the final total is a whole dollar amount. This is especially useful for cash payments or when you prefer even numbers.

**Options:**
- **None**: No rounding applied (default)
- **Round Up**: Rounds total up to next whole dollar (e.g., $57.50 → $58.00)
- **Round Down**: Rounds total down to previous whole dollar (e.g., $57.50 → $57.00)

**Examples:**
- Bill: $50.00, 15% tip = $57.50
  - Round Up → $58.00 (tip adjusted from $7.50 to $8.00)
  - Round Down → $57.00 (tip adjusted from $7.50 to $7.00)
- Bill: $45.67, 18% tip = $53.89
  - Round Up → $54.00 (tip adjusted +$0.11)
  - Round Down → $53.00 (tip adjusted -$0.89)

The app shows exactly how much the tip was adjusted for rounding.

**Note:** Palindrome rounding and dollar rounding can be used together. The app applies palindrome rounding first, then dollar rounding if both are enabled.

## Project Structure

```
Tipulator/
├── Tipulator.xcodeproj/      # Xcode project file
└── Tipulator/
    ├── TipulatorApp.swift     # App entry point
    ├── ContentView.swift      # Main UI view with Liquid Glass design
    ├── TipCalculator.swift    # Business logic and calculations
    ├── Settings.swift         # Settings model (appearance mode)
    ├── SettingsView.swift     # Settings screen UI
    └── Assets.xcassets/       # App icons and assets
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Model**: `TipCalculator` - Observable object handling all calculation logic
- **View**: `ContentView` - SwiftUI views with declarative UI
- **State Management**: Combine framework with `@Published` properties for reactive updates

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **UserDefaults**: Persistent storage for preset percentages and settings
- **Swift**: Latest language features and best practices
- **Glassmorphism Design**: Modern UI/UX with translucent materials and layered effects

## Customizing Preset Percentages

The app includes four customizable preset buttons that you can personalize:

### In-App Customization (Recommended)
1. Long-press any preset button
2. Enter your desired percentage (0-50)
3. Tap "Save"
4. Your custom presets are saved automatically and persist across app launches

### Changing Default Presets (Code Level)

Edit `TipCalculator.swift:6` to change the factory defaults:
```swift
private static let defaultPresets = [10, 18, 20, 22]  // Change these values
```

### Other Code Customizations

**Default selected percentage** - Edit `TipCalculator.swift:20`:
```swift
@Published var selectedTipPercentage: Int = 18  // Change to your preferred default
```

**Custom slider range** - Edit `ContentView.swift` (slider section):
```swift
Slider(value: $calculator.customTipPercentage, in: 0...50, step: 1)  // Modify range
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MPL 2.0 License - see the LICENSE file for details.

## Acknowledgments

Inspired by the classic Tipulator app that helped countless people calculate tips quickly and easily.
