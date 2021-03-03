//
//  LoadingView.swift
//  LeanCloudTest
//
//  Created by YES on 2021/1/30.
//

import SwiftUI

struct LoadingView: View {
    @State var animate = false
    var body: some View {
        ZStack{
            Color(.systemGray5).opacity(0.5)
                .ignoresSafeArea(.all, edges: .all)
            
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(Color("loginColor"),lineWidth: 10)
                .frame(width: 80, height: 80)
                .rotationEffect(.init(degrees: animate ? 360 : 0))
                .padding(30)
                .background(Color.white).opacity(0.8)
                .cornerRadius(15)
            
            Text("loading...")
                .font(.caption2)
        }
        .onAppear(perform: {
            withAnimation(Animation.linear.speed(0.3).repeatForever(autoreverses: false)){
                animate.toggle()
            }
        })
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
