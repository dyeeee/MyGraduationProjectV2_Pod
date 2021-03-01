//
//  wordContentView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/10.
//

import SwiftUI

struct WordContentView: View {
    @State var wordContent:String = "allow"
    @State var fontSize = 18
    
    var body: some View {
        VStack {
            Text(self.wordContent )
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.clear)
                .overlay(Rectangle().frame(height:4)
                            .foregroundColor(Color(.systemBlue))
                            .offset(x:0,y:10))
        }.overlay(
            Text(self.wordContent )
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("WordContentColor"))
        )
        
    }
}

struct wordContentView_Previews: PreviewProvider {
    static var previews: some View {
        WordContentView()
    }
}
