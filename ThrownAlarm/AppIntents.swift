//
//  AppIntents.swift
//  AlarmKitTest
//
//  Created by Luca Maria Incarnato on 26/09/25.
//

import AlarmKit
import AppIntents

public struct OpenInApp: LiveActivityIntent {
    public func perform() async throws -> some IntentResult { .result() }
    
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
