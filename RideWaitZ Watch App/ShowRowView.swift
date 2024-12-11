import SwiftUI

struct ShowRowView: View {
    let show: Ride

    var body: some View {
        HStack {
            Text(show.name)
            Spacer()
            Text(RideStatusHelper.showStatus(for: show, withinParkHours: true)) 
                .foregroundColor(.gray)
        }
    }
}
