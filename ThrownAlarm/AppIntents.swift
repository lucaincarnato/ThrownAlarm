//
//  AppIntents.swift
//  AlarmKitTest
//
//  Created by Luca Maria Incarnato on 26/09/25.
//

import AlarmKit
import AppIntents
import SwiftUI

public struct OpenInApp: LiveActivityIntent {
    @AppStorage("AlarmGame") private var alarmGame: Bool = false

    public func perform() async throws -> some IntentResult {
        alarmGame = true
        return .result()
    }
    
    public static var title: LocalizedStringResource = "Open App"
    public static var description = IntentDescription("Opens the Sample app")
    public static var openAppWhenRun = true
    
    @Parameter(title: "alarmID")
    public var alarmID: String
    
    public init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    public init() {
        self.alarmID = ""
    }
}
