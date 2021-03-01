//
//  AnimationTestView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/9.
//

import SwiftUI

struct AnimationTestView: View {
    @State var animate = false
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.triangle.2.circlepath.circle")
                .rotationEffect(.init(degrees: animate ? 360 : 0))
        }.onAppear(perform: {
            withAnimation(Animation.linear.speed(0.2).repeatForever(autoreverses: false)){
                animate.toggle()
            }
        })
    }
}

struct AnimationTestView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationTestView()
    }
}
