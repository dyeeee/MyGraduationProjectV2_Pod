//
//  HighlightPartly.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI

struct HighlightPartlyView: View {
    @State var fullString: String = "She was also taken aback by his intense jealousy and the imbalance between his tight penny-pinching and extravagant spending aback aback， Aback."
    @State var wordContent:String = "aback"
    
    var body: some View{
        //let testo : String = "There is a thunderstorm in the area"
        let stringArray = self.fullString.components(separatedBy: " ")
        let stringToTextView = stringArray.reduce(Text(""), {
            if $1 == self.wordContent {
                return $0 + Text($1)
                                .bold()
                    .foregroundColor(Color(.systemBlue))
                        + Text(" ")
            }else if $1.dropLast() == self.wordContent{
                return $0 + Text($1.dropLast())
                                .bold()
                    .foregroundColor(Color(.systemBlue))
                     + Text($1.suffix(1)) +  Text(" ")
            }
            else {
                return $0 + Text($1) + Text(" ")
            }
            
        })
        return stringToTextView
    }
}





struct HighlightPartly_Previews: PreviewProvider {
    static var previews: some View {
        HighlightPartlyView()
    }
}
