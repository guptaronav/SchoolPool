import SwiftUI

struct RideCard: View {
    let ride: Ride

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ride.departureTime.dateValue(), format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.spPrimary)
                Spacer()
                priceBadge
            }

            routeRow(icon: "circle.fill", color: .spAccent, text: ride.origin.title)
            routeRow(icon: "mappin.circle.fill", color: .spPrimary, text: ride.destination.title)

            HStack {
                Label(ride.driverName, systemImage: "person.fill")
                Spacer()
                Label("\(ride.seatsAvailable) of \(ride.totalSeats) seats", systemImage: "chair.lounge.fill")
            }
            .font(.caption)
            .foregroundStyle(Color.spTextSecondary)
        }
        .padding(16)
        .background(Color.spSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var priceBadge: some View {
        Text(ride.pricePerSeat > 0
             ? ride.pricePerSeat.formatted(.currency(code: "USD"))
             : "Free")
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.spDroplet.opacity(0.12))
            .foregroundStyle(Color.spDroplet)
            .clipShape(Capsule())
    }

    private func routeRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
                .frame(width: 14)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.spTextPrimary)
                .lineLimit(1)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        RideCard(ride: .stub())
        RideCard(ride: .stub(seatsAvailable: 1, pricePerSeat: 4.5))
    }
    .padding()
    .background(Color.spBackground)
}
#endif
