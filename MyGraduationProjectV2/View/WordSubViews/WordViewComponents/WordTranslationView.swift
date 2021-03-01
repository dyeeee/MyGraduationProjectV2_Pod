//
//  WordTranslationView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI


struct WordTranslationView: View {
    @State var wordTranslastion:String = "vt. 减轻, 使缓和"
    @State var wordDefinition:String = "v provide physical relief, as from pain\nv make easier"
    
    var body: some View {
        VStack(alignment:.leading,spacing:15) {
            if(self.wordTranslastion != "nullTag" ){
            VStack(alignment:.leading,spacing:3) {
                VStack {
                    Text("英汉释义")
                        .font(.caption2)
                        .padding(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.0)
                                .stroke())
                }.foregroundColor(Color("WordTransColor"))
                Text("\(dealTrans(self.wordTranslastion))")
                    .padding([.leading],5)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = dealTrans(self.wordTranslastion)
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                    //.foregroundColor(Color())
            }}
            if(self.wordDefinition != "nullTag" ){
            VStack(alignment:.leading,spacing:3) {
                VStack {
                    Text("英英释义")
                        .font(.caption2)
                        .padding(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.0)
                                .stroke())
                }.foregroundColor(Color("WordTransColor"))
                Text("\(dealTrans(self.wordDefinition))")
                    .padding([.leading],5)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = dealTrans(self.wordDefinition)
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }}
        }.font(.callout)
        .padding(.bottom, 10)
        .padding(.top, 5)
    }
}

struct WordTranslationView_Previews: PreviewProvider {
    static var previews: some View {
        WordTranslationView()
    }
}
