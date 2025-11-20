import SwiftUI

struct ScanRecordCard: View {
    let record: SupabaseScanRecord

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(Image(systemName: "eyeglasses").foregroundStyle(.purple))
                .cornerRadius(12)
            VStack(alignment: .leading) {
                Text(record.prediction)
                    .font(.headline)
                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(record.confidence * 100))%")
                .font(.headline)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}
