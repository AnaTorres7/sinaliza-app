//
//  ContentView.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Sinaliza")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    let filledStars = viewModel.score / 7
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < filledStars ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title)
                    }
                }
                
                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(GameViewModel())
}
