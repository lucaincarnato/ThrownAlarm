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
    
    
    var body: some View {
        NavigationStack{
            Button(){
                alarmOff.toggle()
            } label: {
                Text("Stop alarm")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive){
                        hasNotPlayed.toggle()
                    } label: {
                        Text("Cancel")
                    }
                    .alert(Text("Don't give "),
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
                            }
                        )
                    
                }
            }
        }
    }
}

#Preview {
    MinigameView(alarmOff: .constant(true))
}
