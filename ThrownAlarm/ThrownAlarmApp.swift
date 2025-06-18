//
//  ThrownAlarmApp.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftUI
import FreemiumKit
import UserNotifications
import UIKit

@main
struct ThrownAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var deepLinkManager = DeepLinkManager()
    
    var body: some Scene {
        WindowGroup {
            TabView{
                DashboardView()
                    .tabItem {
                        Label("Alarms", systemImage: "alarm.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Streak", systemImage: "flame.fill")
                    }
            }
            .preferredColorScheme(.dark)
            .environmentObject(deepLinkManager)
            .environmentObject(FreemiumKit.shared)
            .onOpenURL { url in
                deepLinkManager.handleDeepLink(url)
            }
        }
        .modelContainer(for: [Alarm.self, Night.self], isUndoEnabled: true)
    }
}

class DeepLinkManager: ObservableObject {
    @Published var targetView: TargetView?
    @Published var id: String?
    
    func handleDeepLink(_ url: URL) {
        if url.lastPathComponent == "alarm" {
            targetView = .alarmView
            id = url.host()
        }
    }
}

enum TargetView {
    case alarmView
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
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
