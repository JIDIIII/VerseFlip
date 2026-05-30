//
//  ContentView.swift
//  VerseFlip
//
//  Created by John David Velos on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userNickname") private var userNickname = ""

    @State private var isEnteringNickname = false

    var body: some View {
        if hasCompletedOnboarding && userNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            MainTabView()
        } else if isEnteringNickname {
            NicknameView {
                hasCompletedOnboarding = true
                isEnteringNickname = false
            }
        } else {
            SplashView {
                isEnteringNickname = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
