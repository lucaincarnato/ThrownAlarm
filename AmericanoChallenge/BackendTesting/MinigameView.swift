//
//  MinigameView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI

struct MinigameView: View {
    @Binding var alarmOff: Bool
    @State var hasNotPlayed: Bool = false
    @State var isMinigameOn: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                if(!isMinigameOn){
                    Button(){
                        alarmOff.toggle()
                        isMinigameOn.toggle()
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    } label: {
                        Text("Start minigame")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .destructive){
                        hasNotPlayed.toggle()
                    }
                    .alert(Text("Don't give up"),
                           isPresented: $hasNotPlayed,
                           actions: {
                        Button("Retry", role: .cancel) {
                            hasNotPlayed.toggle()
                        }
                        Button("Stop", role: .destructive) {
                            alarmOff.toggle()
                            hasNotPlayed.toggle()
                        }
                    }, message: {
                        Text("You will lose your streak")
                    })
                }
            }
        }
    }
}
