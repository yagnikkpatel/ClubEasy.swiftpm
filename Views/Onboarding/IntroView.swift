import SwiftUI

struct IntroView: View {
    @State private var selection = 0
    var onGetStarted: (() -> Void)?
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            VStack(spacing: 0) {
                onboardingPages
                pageIndicator
                actionButton
            }
        }
    }
    
    // MARK: - Components
    
    private var onboardingPages: some View {
        TabView(selection: $selection) {
            HeroPage()
                .tag(0)
            
            FeaturePage(
                icon: "doc.append.fill",
                title: "Professional Reports",
                description: "Generate industry-standard PDF and Excel attendance reports for university records."
            )
            .tag(1)
            
            FeaturePage(
                icon: "person.3.sequence.fill",
                title: "Student Success",
                description: "Track student projects, attendance risk, and top performers all in one place."
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(selection == index ? Color.appTheme : Color.appTheme.opacity(0.3))
                    .frame(width: selection == index ? 24 : 8, height: 8)
            }
        }
        .animation(.spring(), value: selection)
        .padding(.vertical, 24)
    }
    
    private var actionButton: some View {
        Button {
            moveToNextPage()
        } label: {
            Text(selection == 2 ? "Get Started" : "Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appTheme)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
    
    // MARK: - Logic
    
    private func moveToNextPage() {
        if selection < 2 {
            withAnimation { selection += 1 }
        } else {
            onGetStarted?()
        }
    }
}

// MARK: - Subviews

private struct ThemeBackground: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            glowEffect(at: CGPoint(x: -100, y: -200), opacity: 0.1)
            glowEffect(at: CGPoint(x: 100, y: 200), opacity: 0.15)
        }
    }
    
    private func glowEffect(at position: CGPoint, opacity: Double) -> some View {
        Circle()
            .fill(Color.appTheme.opacity(opacity))
            .blur(radius: 100)
            .offset(x: position.x, y: position.y)
            .ignoresSafeArea()
    }
}

private struct HeroPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "swift")
                .font(.system(size: 100))
                .foregroundStyle(Color.appTheme)
                .symbolRenderingMode(.hierarchical)
                .shadow(color: Color.appTheme.opacity(0.3), radius: 20, y: 10)
                .offset(x: -15) // Offset to correct visual weight of asymmetrical logo
            
            VStack(spacing: 16) {
                Text("Swift Coding Club")
                    .font(.largeTitle.bold())
                
                Text("The professional management dashboard for your university's developer community.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

private struct FeaturePage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 90))
                .foregroundStyle(Color.appTheme)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    IntroView()
}
