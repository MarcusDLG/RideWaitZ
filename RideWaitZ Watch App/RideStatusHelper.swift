import Foundation

struct RideStatusHelper {
    static func rideStatus(for ride: Ride) -> String {
        if let waitTime = ride.queue?.STANDBY?.waitTime {
            return "\(waitTime) min"
        } else if ride.status == "DOWN" {
            return "Down"
        } else if ride.status == "OPERATING" {
            return "Open"
        } else if ride.status == "REFURBISHMENT" {
            return "Refurb."
        } else if ride.status == "CLOSED" {
            return "Closed"
        } else {
            return "N/A"
        }
    }

    static func showStatus(for show: Ride, withinParkHours: Bool) -> String {
        if !withinParkHours {
            return "Closed"
        } else if let nextShowtime = getNextShowtime(for: show) {
            return nextShowtime
        } else if let waitTime = show.queue?.STANDBY?.waitTime {
            return "\(waitTime) min"
        } else if show.status == "OPERATING" {
            return "Open"
        } else {
            return "N/A"
        }
    }

    static func getNextShowtime(for show: Ride) -> String? {
        let now = Date()
        return show.showtimes?
            .compactMap { ISO8601DateFormatter().date(from: $0.startTime) }
            .first { $0 > now }
            .map { DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .short) }
    }
}
