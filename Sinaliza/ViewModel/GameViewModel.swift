//
//  GameViewModel.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 27/06/25.
//


import Foundation
import SwiftUI

@Observable class GameViewModel {
    var score: Int = 0
    
    var countdown: Int = 3
    var isCounting: Bool = false
    var takePhoto: Bool = false
    var capturedImage: UIImage?
    
    var gameFinished: Bool = false
    
    var currentLetter: String = ""
    @ObservationIgnored let allLetters = Array("ABCDEFGILMNOPQRSTUVWY").map { String($0) }
    @ObservationIgnored var usedLetters: Set<String> = []

    @ObservationIgnored var timer: Timer?
    
    init() {
        score = UserDefaults.standard.integer(forKey: "score")
    }
    
    func sortLetter() {
        let availableLetters = allLetters.filter { !usedLetters.contains($0) }
        guard let letter = availableLetters.randomElement() else {
            gameFinished = true
            return
        }
        currentLetter = letter
        usedLetters.insert(letter)
    }
    
    func canSortLetter() -> Bool {
        return usedLetters.count + 1 != allLetters.count
    }
    
    func restoreLetter() {
        usedLetters.remove(currentLetter)
    }

    func startCountdown(seconds: Int = 3) {
        countdown = seconds
        isCounting = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.countdown -= 1
            if self.countdown <= 0 {
                timer.invalidate()
                self.isCounting = false
                self.takePhoto = true
            }
        }
    }

    func restartTimer() {
        isCounting = false
        countdown = 3
        takePhoto = false
        timer?.invalidate()
    }
    
    func incrementScore() {
        score += 1
        UserDefaults.standard.set(score, forKey: "score")
    }

    func restart() {
        if usedLetters.count == allLetters.count {
            usedLetters.removeAll()
        }
        score = 0
        UserDefaults.standard.set(score, forKey: "score")
    }
}
