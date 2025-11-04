//
//  CalendarView.swift
//  SwiftUICalendar
//
//  Created by Roo on 2025-11-04.
//

import Foundation
import SwiftUI

/// The current view mode of the calendar
public enum ViewMode: String, CaseIterable {
    case day, week, month, year
}

/// Weekday enumeration for calendar calculations
public enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

/// A highly customizable and reusable SwiftUI calendar library supporting multiple views: day, week, month, and year.
/// Designed for iOS developers to integrate an elegant and flexible calendar into their apps.
/// Features Apple-inspired liquid glass effect where possible.
@available(iOS 17.0, macOS 14.0, *)
@MainActor
public struct CalendarView {

    /// Configuration for the calendar appearance and behavior
    public struct Configuration {
        public var accentColor: Color
        public var backgroundColor: Color
        public var textColor: Color
        public var todayColor: Color
        public var selectedColor: Color
        public var disabledColor: Color
        public var useLiquidGlassEffect: Bool
        public var showWeekNumbers: Bool
        public var startOfWeek: Weekday
        public var locale: Locale

        public init(
            accentColor: Color = Color.blue,
            backgroundColor: Color = Color.white,
            textColor: Color = Color.black,
            todayColor: Color = Color.blue,
            selectedColor: Color = Color.blue.opacity(0.2),
            disabledColor: Color = Color.gray.opacity(0.3),
            useLiquidGlassEffect: Bool = true,
            showWeekNumbers: Bool = false,
            startOfWeek: Weekday = .monday,
            locale: Locale = Locale.current
        ) {
            self.accentColor = accentColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.todayColor = todayColor
            self.selectedColor = selectedColor
            self.disabledColor = disabledColor
            self.useLiquidGlassEffect = useLiquidGlassEffect
            self.showWeekNumbers = showWeekNumbers
            self.startOfWeek = startOfWeek
            self.locale = locale
        }
    }

    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date?
    @State private var viewMode: ViewMode = .month

    public let configuration: Configuration
    public let onDateSelected: ((Date) -> Void)?

    public init(
        configuration: Configuration = Configuration(),
        initialDate: Date = Date(),
        initialViewMode: ViewMode = .month,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self.configuration = configuration
        self._currentDate = State(initialValue: initialDate)
        self._viewMode = State(initialValue: initialViewMode)
        self.onDateSelected = onDateSelected
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension CalendarView: View {

    public var body: some View {
        ZStack {
            if configuration.useLiquidGlassEffect {
                LiquidGlassBackground()
            }

            VStack(spacing: 0) {
                headerView
                calendarContent
            }
        }
        .background(configuration.backgroundColor)
    }

    private var headerView: some View {
        HStack {
            Button(action: previousPeriod) {
                Image(systemName: "chevron.left")
                    .foregroundColor(configuration.accentColor)
            }

            Spacer()

            Text(headerTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(configuration.textColor)

            Spacer()

            Button(action: nextPeriod) {
                Image(systemName: "chevron.right")
                    .foregroundColor(configuration.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.locale = configuration.locale

        switch viewMode {
        case .day:
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
        case .week:
            let calendar = Foundation.Calendar(identifier: .gregorian)
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!.adding(days: configuration.startOfWeek.rawValue - 1)
            let endOfWeek = startOfWeek.adding(days: 6)
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startOfWeek)
            let end = formatter.string(from: endOfWeek)
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: startOfWeek)
            return "\(start) - \(end), \(year)"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }

        return formatter.string(from: currentDate)
    }

    private var calendarContent: some View {
        Group {
            switch viewMode {
            case .day:
                DayView(
                    date: currentDate,
                    configuration: configuration,
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected
                )
            case .week:
                WeekView(
                    date: currentDate,
                    configuration: configuration,
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected
                )
            case .month:
                MonthView(
                    date: currentDate,
                    configuration: configuration,
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected
                )
            case .year:
                YearView(
                    date: currentDate,
                    configuration: configuration,
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected
                )
            }
        }
        .task { }
    }

    private func previousPeriod() {
        switch viewMode {
        case .day:
            currentDate = currentDate.adding(days: -1)
        case .week:
            currentDate = currentDate.adding(days: -7)
        case .month:
            currentDate = currentDate.adding(months: -1)
        case .year:
            currentDate = currentDate.adding(years: -1)
        }
    }

    private func nextPeriod() {
        switch viewMode {
        case .day:
            currentDate = currentDate.adding(days: 1)
        case .week:
            currentDate = currentDate.adding(days: 7)
        case .month:
            currentDate = currentDate.adding(months: 1)
        case .year:
            currentDate = currentDate.adding(years: 1)
        }
    }
}

/// Liquid glass effect background view
/// Based on Apple's Liquid Glass design principles
private struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // Primary material layer
            Color.clear
                .background(.ultraThinMaterial)

            // Subtle highlight layer
            Color.white.opacity(0.08)
                .blur(radius: 24)
                .blendMode(.plusLighter)

            // Inner glow effect
            Color.white.opacity(0.05)
                .blur(radius: 12)
                .blendMode(.plusLighter)

            // Vignette effect for depth
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.08)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .blendMode(.multiply)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 20,
            x: 0,
            y: 8
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Supporting Views

private struct DayView: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        VStack {
            Text(date.formatted(.dateTime.day().month().year()))
                .font(.largeTitle)
                .foregroundColor(configuration.textColor)

            Spacer()

            // Day details would go here - events, tasks, etc.
            Text("Day View - Full details implementation needed")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(height: 400)
    }
}

private struct WeekView: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Week header
            HStack(spacing: 0) {
                if configuration.showWeekNumbers {
                    Text("WK")
                        .font(.caption)
                        .foregroundColor(configuration.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
                ForEach(0..<7) { index in
                    let weekday = configuration.startOfWeek.advanced(by: index)
                    Text(weekday.shortName(for: configuration.locale))
                        .font(.caption)
                        .foregroundColor(configuration.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)

            // Week days
            HStack(spacing: 0) {
                if configuration.showWeekNumbers {
                    Text("\(date.weekNumber)")
                        .font(.caption2)
                        .foregroundColor(configuration.textColor.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
                ForEach(0..<7) { index in
                    DayCell(
                        date: date.startOfWeek(weekday: configuration.startOfWeek).adding(days: index),
                        configuration: configuration,
                        selectedDate: $selectedDate,
                        onDateSelected: onDateSelected
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct MonthView: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Month header
            HStack(spacing: 0) {
                if configuration.showWeekNumbers {
                    Text("WK")
                        .font(.caption)
                        .foregroundColor(configuration.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
                ForEach(0..<7) { index in
                    let weekday = configuration.startOfWeek.advanced(by: index)
                    Text(weekday.shortName(for: configuration.locale))
                        .font(.caption)
                        .foregroundColor(configuration.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)

            // Month grid
            ForEach(0..<6) { weekIndex in
                HStack(spacing: 0) {
                    if configuration.showWeekNumbers {
                        let weekDate = date.startOfMonth.startOfWeek(weekday: configuration.startOfWeek).adding(days: weekIndex * 7)
                        Text("\(weekDate.weekNumber)")
                            .font(.caption2)
                            .foregroundColor(configuration.textColor.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(0..<7) { dayIndex in
                        let dayDate = date.startOfMonth.startOfWeek(weekday: configuration.startOfWeek).adding(days: weekIndex * 7 + dayIndex)
                        DayCell(
                            date: dayDate,
                            configuration: configuration,
                            selectedDate: $selectedDate,
                            onDateSelected: onDateSelected
                        )
                        .opacity(dayDate.isSameMonth(as: date) ? 1.0 : 0.3)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct YearView: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(0..<12) { monthIndex in
                    let monthDate = date.startOfYear.adding(months: monthIndex)
                    MonthCell(
                        date: monthDate,
                        configuration: configuration,
                        selectedDate: $selectedDate,
                        onDateSelected: onDateSelected
                    )
                }
            }
            .padding()
        }
    }
}

private struct MonthCell: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(date.formatted(.dateTime.month(.abbreviated)))
                .font(.caption)
                .foregroundColor(configuration.textColor)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(0..<42) { index in
                    let calendar = Foundation.Calendar(identifier: .gregorian)
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!.adding(days: configuration.startOfWeek.rawValue - 1)
                    let dayDate = startOfWeek.adding(days: index)
                    Text(dayDate.isSameMonth(as: date) ? "\(dayDate.day)" : "")
                        .font(.system(size: 8))
                        .foregroundColor(dayDate.isSameDay(as: Date()) ? configuration.todayColor : configuration.textColor.opacity(dayDate.isSameMonth(as: date) ? 1.0 : 0.3))
                        .frame(width: 12, height: 12)
                        .background(
                            selectedDate?.isSameDay(as: dayDate) == true ?
                                configuration.selectedColor : Color.clear
                        )
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDate = dayDate
                            onDateSelected?(dayDate)
                        }
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DayCell: View {
    let date: Date
    let configuration: CalendarView.Configuration
    @Binding var selectedDate: Date?
    let onDateSelected: ((Date) -> Void)?

    var body: some View {
        Text("\(date.day)")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                selectedDate?.isSameDay(as: date) == true ?
                    configuration.selectedColor : Color.clear
            )
            .clipShape(Circle())
            .onTapGesture {
                selectedDate = date
                onDateSelected?(date)
            }
    }

    private var foregroundColor: Color {
        if date.isSameDay(as: Date()) {
            return configuration.todayColor
        } else if selectedDate?.isSameDay(as: date) == true {
            return configuration.accentColor
        } else {
            return configuration.textColor
        }
    }
}

// MARK: - Extensions

extension Date {
    var day: Int {
        Foundation.Calendar(identifier: .gregorian).component(.day, from: self)
    }

    var weekNumber: Int {
        Foundation.Calendar(identifier: .gregorian).component(.weekOfYear, from: self)
    }

    var startOfWeek: Date {
        startOfWeek(weekday: Weekday.monday)
    }

    func startOfWeek(weekday: Weekday) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!.adding(days: weekday.rawValue - 1)
    }

    var startOfMonth: Date {
        Foundation.Calendar(identifier: .gregorian).date(from: Foundation.Calendar(identifier: .gregorian).dateComponents([.year, .month], from: self))!
    }

    var startOfYear: Date {
        Foundation.Calendar(identifier: .gregorian).date(from: Foundation.Calendar(identifier: .gregorian).dateComponents([.year], from: self))!
    }

    func adding(days: Int) -> Date {
        Foundation.Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(months: Int) -> Date {
        Foundation.Calendar(identifier: .gregorian).date(byAdding: .month, value: months, to: self)!
    }

    func adding(years: Int) -> Date {
        Foundation.Calendar(identifier: .gregorian).date(byAdding: .year, value: years, to: self)!
    }

    func isSameDay(as other: Date) -> Bool {
        Foundation.Calendar(identifier: .gregorian).isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        Foundation.Calendar(identifier: .gregorian).isDate(self, equalTo: other, toGranularity: .month)
    }
}

// MARK: - Weekday Extensions

// MARK: - Weekday Extensions

extension Weekday {
    public var rawValue: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }

    func advanced(by days: Int) -> Weekday {
        let newRawValue = (rawValue - 1 + days) % 7 + 1
        switch newRawValue {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }

    func shortName(for locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        let weekdaySymbols = formatter.weekdaySymbols
        return weekdaySymbols?[rawValue - 1] ?? ""
    }
}

#Preview {
    Group {
        CalendarView()
            .previewDisplayName("Default Month View")

        CalendarView(initialViewMode: .week)
            .previewDisplayName("Week View")

        CalendarView(initialViewMode: .day)
            .previewDisplayName("Day View")

        CalendarView(initialViewMode: .year)
            .previewDisplayName("Year View")
    }
    .padding()
}