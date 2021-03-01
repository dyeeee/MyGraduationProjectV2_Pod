//
//  WordPhoneticView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI

struct WordPhoneticView: View {
    @State var phonetic_EN:String = "nullTag"
    @State var phonetic_US:String = "nullTag"
    @State var fontSize = 18
    
    func dealEN(_ en:String) -> String {
        var enString = "/"
        enString.append(en)
        enString.append("/")
        return enString
    }
    
    func dealUS(_ us:String) -> String {
        var usString = us
        usString = usString.replacingOccurrences(of: "[", with: "/")
        usString = usString.replacingOccurrences(of: "]", with: "/")
        return usString
    }
    
    var body: some View {
        HStack(alignment:.center,spacing:CGFloat(self.fontSize)-10) {
            if(phonetic_EN != "nullTag"){
                HStack(spacing:1) {
                    Image("EN")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat(self.fontSize), height: 25, alignment: .trailing)
                    Text(dealEN(self.phonetic_EN))
                        .font(.custom("Baskerville", size: CGFloat(self.fontSize),relativeTo: .body))
                }
                
            }
            if(phonetic_US != "nullTag"){
                HStack(spacing:1) {
                    Image("US")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat(self.fontSize), height: 25, alignment: .trailing)
                    Text(dealUS(self.phonetic_US))
                        .font(.custom("Baskerville", size: CGFloat(self.fontSize),relativeTo: .body))
                }
            }
        }.foregroundColor(Color("WordPhoneticColor"))
    }
}

struct WordPhoneticView_Previews: PreviewProvider {
    static var previews: some View {
        WordPhoneticView()
    }
}
