import Foundation

public enum ReadoutFormat {
    private static let posix = Locale(identifier: "en_US_POSIX")

    public static func speedKmh(_ value: Double) -> String {
        String(Int(value.rounded()))
    }

    public static func bar(_ value: Double) -> String {
        String(format: "%.1f", locale: posix, value)
    }

    public static func percent(_ value: Double) -> String {
        "\(Int(value.rounded()))%"
    }

    public static func kilometers(_ value: Double) -> String {
        "\(Int(value.rounded())) km"
    }

    public static func kilometersDetail(_ value: Double) -> String {
        String(format: "%.1f km", locale: posix, value)
    }

    public static func kilowattHours(_ value: Double) -> String {
        String(format: "%.2f kWh", locale: posix, value)
    }

    public static func kilowatts(_ value: Double) -> String {
        let rounded = Int(value.rounded())
        if rounded > 0 { return "+\(rounded)" }
        return "\(rounded)"
    }

    public static func celsius(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    public static func clock(_ date: Date, calendar: Calendar) -> String {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return String(format: "%02d:%02d", locale: posix, hour, minute)
    }

    public static func duration(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours) 小时 \(minutes) 分"
        }
        return "\(minutes) 分钟"
    }

    public static func meters(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1f 公里", locale: posix, Double(value) / 1000)
        }
        return "\(value) 米"
    }

    public static func seconds(_ value: TimeInterval) -> String {
        "\(max(0, Int(value.rounded()))) 秒"
    }
}
