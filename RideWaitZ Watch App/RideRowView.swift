import SwiftUI

struct RideRowView: View {
    let ride: Ride

    var body: some View {
        HStack {
            Text(ride.name)
            Spacer()
            Text(RideStatusHelper.rideStatus(for: ride))
                .foregroundColor(.gray)
        }
    }
}
