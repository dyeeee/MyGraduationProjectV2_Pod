//
//  naviColorTest.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/7.
//

import SwiftUI
struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor?

    init(backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

struct TabBarModifier: ViewModifier {
    var backgroundColor: UIColor?

    init(backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.bottom)
                        .edgesIgnoringSafeArea(.bottom)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
    
    func tabBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(TabBarModifier(backgroundColor: backgroundColor))
    }
}


struct MyContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    Text("One")
                        
                    Text("Two")
                        
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle("Summary", displayMode: .large)
            .navigationBarColor(.systemGroupedBackground)
        }
    }
}
struct naviColorTest_Previews: PreviewProvider {
    static var previews: some View {
        MyContentView()
    }
}
