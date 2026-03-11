import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var showDeleteDataAlert = false
    @State private var showOpenSettingsAlert = false
    @State private var showRestorePurchaseAlert = false
    @State private var showHowToUse = false
    @State private var showRemoveAds = false
    @State private var showProfile = false
    @State private var showNotificationSettings = false
    @ObservedObject var progressStore: PlayerProgressStore
    @ObservedObject var careerStore: CareerStore
    private let buttonCornerRadius: CGFloat = 12

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MainBackgroundView()
                ZStack(alignment: .top) {
                    NavigationLink(destination: HowToUseView(onDismiss: { showHowToUse = false }), isActive: $showHowToUse) {
                        EmptyView()
                    }
                    .hidden()
                    .frame(width: 0, height: 0)
                    .zIndex(-1)
                    NavigationLink(destination: RemoveAdsView(onDismiss: { showRemoveAds = false }), isActive: $showRemoveAds) {
                        EmptyView()
                    }
                    .hidden()
                    .frame(width: 0, height: 0)
                    .zIndex(-1)
                    NavigationLink(destination: ProfileView(onDismiss: { showProfile = false }, progressStore: progressStore, careerStore: careerStore), isActive: $showProfile) {
                        EmptyView()
                    }
                    .hidden()
                    .frame(width: 0, height: 0)
                    .zIndex(-1)
                    NavigationLink(destination: NotificationSettingsView(onDismiss: { showNotificationSettings = false }), isActive: $showNotificationSettings) {
                        EmptyView()
                    }
                    .hidden()
                    .frame(width: 0, height: 0)
                    .zIndex(-1)

                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 100)
                        ScrollView {
                            VStack(spacing: 16) {
                                Text("Settings")
                                    .font(.title).bold()
                                    .foregroundStyle(.white)
                                notificationRow
                                Button {
                                    showHowToUse = true
                                } label: {
                                    settingsRow(title: "How to use")
                                }
                                .buttonStyle(.plain)
                                Button {
                                    showRemoveAds = true
                                } label: {
                                    settingsRow(title: "Remove ads")
                                }
                                .buttonStyle(.plain)
                                settingsButton(title: "Restore purchase", showChevron: false, action: { showRestorePurchaseAlert = true })
                                settingsButtonDelete(title: "Delete data", destructive: true, showChevron: false, action: { showDeleteDataAlert = true })
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            Rectangle()
                                .frame(height: 200)
                                .foregroundStyle(Color.clear)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showNotificationSettings = true
                        } label: {
                            Image("notification")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showProfile = true
                        } label: {
                            Image("profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .alert("Delete all data?", isPresented: $showDeleteDataAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        appState.resetAllDataAndRestart()
                    }
                } message: {
                    Text("This will delete all stored data and the app will start from the beginning. Are you sure?")
                }
                .alert("Restore purchase?", isPresented: $showRestorePurchaseAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Restore") {
                        restorePurchase()
                    }
                } message: {
                    Text("Are you sure you want to restore your purchase?")
                }
                .alert("Notifications disabled", isPresented: $showOpenSettingsAlert) {
                    Button("Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Notifications are off for this app. Open Settings to enable them.")
                }
            }
            .preferredColorScheme(.dark)
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }

    private var notificationRow: some View {
        HStack {
            Text("Notifications")
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
        }
        .padding()
        .background(Color(.orange))
        .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        .onChange(of: notificationsEnabled) { newValue in
            if newValue {
                NotificationManager.shared.getAuthorizationStatus { status in
                    switch status {
                    case .denied:
                        notificationsEnabled = false
                        showOpenSettingsAlert = true
                    case .notDetermined:
                        NotificationManager.shared.requestAuthorization { granted in
                            if !granted {
                                notificationsEnabled = false
                                showOpenSettingsAlert = true
                            }
                        }
                    case .authorized, .provisional, .ephemeral:
                        break
                    @unknown default:
                        break
                    }
                }
            } else {
                NotificationManager.shared.cancel24HourReminder()
            }
        }
    }

    private func settingsRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(.orange))
        .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
    }

    private func settingsButton(title: String, destructive: Bool = false, showChevron: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(destructive ? .white : .white)
                Spacer()
                Image(systemName: "arrow.uturn.backward")
                    .font(.body)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.orange))
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
        .buttonStyle(.plain)
    }
    
    private func settingsButtonDelete(title: String, destructive: Bool = false, showChevron: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "trash.fill")
                    .font(.body)
                    .foregroundColor(.white)

            }
            .padding()
            .background(Color(.darkGreen))
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
        .buttonStyle(.plain)
    }

    private func restorePurchase() {
    }
}
