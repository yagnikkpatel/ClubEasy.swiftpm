import SwiftUI

struct IntroView: View {
    @State private var currentPage = 0
    var onGetStarted: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    IntroPage(
                        icon: "person.2.fill",
                        title: "Lead Your Club",
                        subtitle: "The all-in-one professional dashboard to manage your club's members and growth."
                    )
                    .tag(0)
                    
                    IntroPage(
                        icon: "calendar.badge.checkmark",
                        title: "Attendance Insight",
                        subtitle: "Monitor student consistency and engagement with simple yet powerful attendance tracking."
                    )
                    .tag(1)
                    
                    IntroPage(
                        icon: "folder.fill.badge.gearshape",
                        title: "Project Progress",
                        subtitle: "Keep every student on the right path by tracking their coding projects and milestones."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Enhanced Page Indicator
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.appTheme : Color.appTheme.opacity(0.2))
                            .frame(width: currentPage == index ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                bottomSection
            }
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            Button(action: { 
                if currentPage < 2 {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentPage += 1
                    }
                } else {
                    onGetStarted?()
                }
            }) {
                Text(currentPage == 2 ? "Get Started" : "Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appTheme)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct IntroPage: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 90))
                .foregroundStyle(Color.appTheme)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
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
