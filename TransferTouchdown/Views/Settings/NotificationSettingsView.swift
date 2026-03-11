import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [NotificationHistoryItem] = []
    @State private var showDeleteAllAlert = false
    var onDismiss: (() -> Void)?

    private let buttonCornerRadius: CGFloat = 12
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ZStack {
            MainBackgroundView()
            VStack(spacing: 24) {

                if history.isEmpty {
                    Text("No messages :)")
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(history) { item in
                                notificationRow(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            history = NotificationManager.shared.getHistory()
        }
        .alert("Delete all notifications?", isPresented: $showDeleteAllAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                NotificationManager.shared.clearHistory()
                history = []
            }
        } message: {
            Text("This will remove all notifications from the list.")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onDismiss?()
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image("backButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !history.isEmpty {
                    Button {
                        showDeleteAllAlert = true
                    } label: {
                        Image("deleteAll")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 50)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image("deleteAllB")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 50)
                }

            }
        }
    }

    private func notificationRow(item: NotificationHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.body)
                .font(.body)
                .foregroundColor(.white)
            Text(dateFormatter.string(from: item.date))
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.darkGreen))
        .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
    }
}
