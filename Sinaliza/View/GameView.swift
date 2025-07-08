//
//  GameView.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 30/06/25.
//

import SwiftUI
import CoreML

struct GameView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCamera = false
    @State private var feedback: FeedbackType?
    @State private var showStarAnimation = false
    private let model = try! svm_pipeline(configuration: MLModelConfiguration())
    
    enum FeedbackType: Identifiable {
        case success, failure, unclear
        
        var id: Int {
            switch self {
            case .success: return 1
            case .failure: return 2
            case .unclear: return 3
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Letra")
                    .font(.title)
                
                Text(viewModel.currentLetter)
                    .font(.largeTitle)
                    .bold()
                
                Button("Fazer sinal") {
                    showCamera = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.startCountdown()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                if viewModel.canSortLetter() {
                    Button("Pular") {
                        viewModel.restoreLetter()
                        viewModel.sortLetter()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ZStack {
                    CameraView { image in
                        self.viewModel.capturedImage = image
                        
                        // Processar e classificar
                        let processor = HandFeatureProcessor()
                        if let input = processor.extractAttributes(from: image) {
                            do {
                                let output = try model.prediction(input: input)
                                let label = output.classLabel
//                                let probs = output.classProbability
//                                print("Resultado: \(label), confianças: \(probs)")
                                
                                if label == viewModel.currentLetter {
                                    let previousStars = viewModel.score / 7
                                    feedback = .success
                                    viewModel.incrementScore()
                                    let currentStars = viewModel.score / 7
                                    if currentStars > previousStars {
                                        showStarAnimation = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            showStarAnimation = false
                                        }
                                    }
                                    viewModel.restartTimer()
                                } else {
                                    feedback = .failure
                                    viewModel.restartTimer()
                                }
                            } catch {
                                feedback = .unclear
                                print("Erro ao usar modelo: \(error)")
                            }
                        } else {
                            feedback = .unclear
                            print("Não foi possível extrair atributos da mão.")
                        }
                    }
                    
                    // Contador
                    Text(viewModel.countdown.formatted())
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    
                    if let feedback = feedback {
                        FeedbackOverlayView(feedback: feedback, score: viewModel.score) {
                            if feedback == .unclear {
                                viewModel.restartTimer()
                                viewModel.startCountdown()
                            } else {
                                viewModel.sortLetter()
                                self.showCamera = false
                            }
                            
                            self.feedback = nil
                        }
                    }
                    
                    if showStarAnimation {
                        Image(systemName: "star.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.yellow)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .offset(y: showStarAnimation ? -300 : 0)
                            .animation(.easeOut(duration: 1), value: showStarAnimation)
                    }
                }
            }
            .onAppear {
                viewModel.resetGame()
            }
            .onChange(of: viewModel.takePhoto) {
                if viewModel.takePhoto {
                    NotificationCenter.default.post(name: .takePhotoNotification, object: nil)
                }
            }
            .onChange(of: viewModel.gameFinished) {
                if viewModel.gameFinished {
                    dismiss()
                }
            }
        }
        //        .navigationBarBackButtonHidden(true)
    }
}

struct FeedbackOverlayView: View {
    let feedback: GameView.FeedbackType
    let score: Int
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(titulo)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Text(mensagem)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("Pontuação: \(score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button(action: onContinue) {
                    Text(botao)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(32)
        }
    }
    
    private var titulo: String {
        switch feedback {
        case .success: return "✅ Acertou!"
        case .failure: return "❌ Errou!"
        case .unclear: return "🤔 Não foi possível identificar"
        }
    }
    
    private var mensagem: String {
        switch feedback {
        case .success: return "Você acertou o sinal. Parabéns!"
        case .failure: return "Esse não era o sinal correto."
        case .unclear: return "Tente novamente o sinal para essa letra."
        }
    }
    
    private var botao: String {
        switch feedback {
        case .unclear: return "Tentar novamente"
        default: return "Continuar"
        }
    }
}
