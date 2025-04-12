//
//  AmericanoChallengeApp.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftUI
import FreemiumKit
import UserNotifications
import UIKit

@main
struct ThrownAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // App delegate
    @StateObject private var deepLinkManager = DeepLinkManager()
    
    var body: some Scene {
        WindowGroup {
            TabView{
                DashboardView()
                    .tabItem {
                        Label("Schedule", systemImage: "alarm.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Streak", systemImage: "flame.fill")
                    }
            }
            .preferredColorScheme(.dark) // Forces the app to run in dark mode
            .environmentObject(deepLinkManager) // Push the manager into the environment so that DashboardView can get from it
            .environmentObject(FreemiumKit.shared) // Needed to implement freemium paywall call from FreemiumKit
            // Once the url is received, it is managed
            .onOpenURL { url in
                deepLinkManager.handleDeepLink(url)
            }
        }
        .modelContainer(for: [Alarm.self, Night.self])
    }
}

// Manage the target when a deep link is received
class DeepLinkManager: ObservableObject {
    @Published var showModal: Bool = false
    @Published var targetView: TargetView?
    
    // Toggles boolean for modality and direct the view to show
    func handleDeepLink(_ url: URL) {
        if url.host == "alarm" {
            targetView = .alarmView
            showModal = true
        }
    }
}

// Enumeration of the different possibilities for the deep link
enum TargetView {
    case alarmView
}

// App delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self // Sets up the delegate for notifications
        return true
    }
    
    // Get the deep link and create the url
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let deepLink = response.notification.request.content.userInfo["deepLink"] as? String,
           let url = URL(string: deepLink) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
        completionHandler()
    }
}
