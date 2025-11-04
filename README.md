# SwiftUICalendar 📆

A highly customizable and reusable SwiftUI calendar library supporting multiple views: day, week, month, and year. Designed for iOS developers to integrate an elegant and flexible calendar into their apps with Apple-inspired liquid glass effects.

## Features

- **Multiple View Modes**: Day, Week, Month, and Year views
- **Highly Customizable**: Configure colors, fonts, and behavior through a comprehensive configuration struct
- **Liquid Glass Effect**: Apple-inspired visual effects using SwiftUI's material backgrounds
- **Localization Support**: Automatic localization for weekdays and months
- **Swift Package Manager**: Easy integration into any SwiftUI project
- **iOS 17+ Support**: Takes advantage of the latest SwiftUI features

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/gchimera/SwiftUICalendar.git", from: "1.0.0")
]
```

Or in Xcode:
1. Go to File > Add Packages...
2. Enter the repository URL: `https://github.com/gchimera/SwiftUICalendar.git`
3. Choose the version you want to use

## Usage

### Basic Usage

```swift
import SwiftUI
import SwiftUICalendar

struct ContentView: View {
    var body: some View {
        CalendarView()
    }
}
```

### Advanced Configuration

```swift
import SwiftUI
import SwiftUICalendar

struct ContentView: View {
    @State private var selectedDate: Date?

    var body: some View {
        CalendarView(
            configuration: CalendarView.Configuration(
                accentColor: .purple,
                backgroundColor: Color(.systemBackground),
                textColor: Color(.label),
                todayColor: .purple,
                selectedColor: .purple.opacity(0.2),
                disabledColor: .gray.opacity(0.3),
                useLiquidGlassEffect: true,
                showWeekNumbers: true,
                startOfWeek: .monday,
                locale: .current
            ),
            initialDate: Date(),
            initialViewMode: .month
        ) { date in
            selectedDate = date
            print("Selected date: \(date)")
        }
    }
}
```

### Configuration Options

The `CalendarView.Configuration` struct allows you to customize:

- `accentColor`: Main accent color for buttons and highlights
- `backgroundColor`: Background color of the calendar
- `textColor`: Color for text elements
- `todayColor`: Color for today's date
- `selectedColor`: Background color for selected dates
- `disabledColor`: Color for disabled dates
- `useLiquidGlassEffect`: Whether to apply the liquid glass effect
- `showWeekNumbers`: Whether to display week numbers
- `startOfWeek`: First day of the week (Sunday or Monday)
- `locale`: Locale for date formatting and localization

## View Modes

### Day View
Shows detailed information for a single day. Perfect for day planners and detailed schedules.

### Week View
Displays a 7-day week with optional week numbers. Great for weekly overviews.

### Month View
Traditional calendar month view with 6 weeks displayed. Most common calendar layout.

### Year View
Shows all 12 months in a grid layout. Ideal for year planning and date selection.

## Architecture

The library is built with modularity in mind:

- `CalendarView`: Main view that orchestrates the different view modes
- `DayView`, `WeekView`, `MonthView`, `YearView`: Individual view implementations
- `Configuration`: Struct for customizing appearance and behavior
- Extensions: Date and weekday utilities

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
