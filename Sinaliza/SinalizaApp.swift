//
//  SinalizaApp.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 30/05/25.
//

import SwiftUI

@main
struct SinalizaApp: App {
    @State private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameViewModel)
        }
    }
}
