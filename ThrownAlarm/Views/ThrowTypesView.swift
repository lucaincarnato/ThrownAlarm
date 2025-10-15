//
//  ThrowTypesView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 15/10/25.
//

import SwiftUI

struct ThrowTypesView: View {
    @AppStorage("ThrowType") var throwType: String = "Basket"
    @State private var currentIndex: Int = 0
    let typesAvailable: [String] = [
        "Basket",
        "Target",
        "Paper",
        "Pool",
        "Biscuits",
        "Rock",
        "Golf",
        "Note",
        "Cake",
        "Frisbee",
        "Pasta",
        "Cards"
        // "Pen",
        // "Trash",
        // "Popcorn",
        // "Airplane",
        // "Christmas",
        // "Halloween"
    ]
    
    var body: some View {
        ZStack {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                TabView(selection: $currentIndex) {
                    ForEach(0..<typesAvailable.count,id: \.self){ index in
                        Text(typesAvailable[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 156, maxHeight: 250)
            VStack{
                Spacer()
                Button() {
                    throwType = typesAvailable[currentIndex]
                    UIApplication.shared.setAlternateIconName("ThrownAlarmAppIcon", completionHandler: {error in})
                } label: {
                    Text(typesAvailable[currentIndex] == throwType ? "Selected" : "Select")
                        .font(.title3)
                        .bold()
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 40)
                .buttonStyle(.glassProminent)
                .disabled(typesAvailable[currentIndex] == throwType)
            }
        }
    }
}

#Preview {
    ThrowTypesView()
}


// selected = typesAvailable[currentIndex]
