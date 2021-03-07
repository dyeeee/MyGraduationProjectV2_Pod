//
//  HighlightPartly.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI

struct HighlightPartlyView: View {
    @State var fullString: String = "She was also taken aback by his intense jealousy and the imbalance between his tight penny-pinching and extravagant spending aback aback， 'Aback."
    @State var wordContent:String = "aback"
    var color = Color(.systemBlue)
    
    var body: some View{
        //let testo : String = "There is a thunderstorm in the area"
        let stringArray = self.fullString.components(separatedBy: " ")
        let stringToTextView = stringArray.reduce(Text(""), {
            if $1.lowercased() == self.wordContent.lowercased() {
                return $0 + Text($1)
                    .bold()
                    .foregroundColor(color)
                    .underline(color:Color(.systemBlue))
                    
                    + Text(" ")
            }else if $1.lowercased().dropLast() == self.wordContent.lowercased(){
                return $0 + Text($1.dropLast())
                    .bold()
                    .foregroundColor(color)
                    .underline(color:Color(.systemBlue))
                    + Text($1.suffix(1)) +  Text(" ")
            }else if $1.lowercased().dropFirst() == self.wordContent.lowercased(){
                return $0 + Text($1.dropFirst())
                    .bold()
                    .foregroundColor(color)
                    .underline(color:Color(.systemBlue))
                    + Text($1.suffix(1)) +  Text(" ")
            }else if $1.lowercased().dropFirst().dropLast() == self.wordContent.lowercased(){
                return $0 + Text($1.dropFirst().dropLast())
                    .bold()
                    .foregroundColor(color)
                    .underline(color:Color(.systemBlue))
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
        HighlightPartlyView(color:Color(.systemBlue))
    }
}
