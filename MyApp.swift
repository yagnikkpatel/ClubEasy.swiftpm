import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasCompletedIntro") private var hasCompletedIntro = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedIntro {
                    ContentView()
                        .transition(.opacity)
                } else {
                    IntroView(onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedIntro = true
                        }
                    })
                    .transition(.opacity)
                    .preferredColorScheme(.light)
                }
            }
            .tint(.appTheme)
        }
    }
}
