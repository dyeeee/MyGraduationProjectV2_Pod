//
//  WordExampleSentencesView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI

struct WordExampleSentencesView: View {
    @State var wordContent:String = "AA"
    @State var wordExampleSentences:String = "After the encirclement of the German 9th Flak Division at Stalingrad it was the only Axis AA defence unit in the area.<br>在德国第9高炮师陷入斯大林格勒的包围圈后，罗马尼亚防空部队成为轴心国在该地区唯一的防空部队了。<br>Oh, and I should also mention that this mouse is said to last around nine months on two AA batteries.<br>噢，我应该还告诉你，这个鼠标用两节AA电池可以利用差不多九个月。<br>Hammering on this topic reminds me how I once sent a patient to AA who told me that those meetings ruined him as an alcoholic.<br>谈这个话题时，我想起了我送一个病人去匿名戒酒者协会时，他说这个聚会差点把他当酗酒者给毁了。"
    var maxLine = 3
    @State var showCH:Bool = true
    
    
    
    func countSentences(str:String) -> Int {
        let sentenceList = str.components(separatedBy: "<br>")
        //sentenceList.removeLast()
        if sentenceList.count/2 < self.maxLine {
            return sentenceList.count/2
        }else
        {
            return self.maxLine
        }
        //return sentenceList.count/2
    }
    
    //    func dealExampleSentences_EN(str:String,currentWord:String) -> [[String]] {
    //        var sentenceList = str.components(separatedBy: "<br>")
    //        sentenceList.removeLast()
    //        var i = 0
    //        var sentenceList_EN:[String] = []
    //
    //        while i<sentenceList.count {
    //            if (i % 2 == 0) {
    //                sentenceList_EN.append(sentenceList[i])
    //            }
    //            i = i + 1
    //        }
    //
    //        var sentenceListList_EN:[[String]] = []
    //        for sentence in sentenceList_EN {
    //            sentenceListList_EN.append(sentence.components(separatedBy: currentWord))
    //        }
    //
    //        return sentenceListList_EN
    //    }
    
    func dealExampleSentences_EN(str:String) -> [String] {
        let sentenceList = str.components(separatedBy: "<br>")
        var i = 0
        var sentenceList_EN:[String] = []
        
        while i<sentenceList.count {
            if (i % 2 == 0) {
                sentenceList_EN.append(sentenceList[i])
            }
            i = i + 1
        }
        return sentenceList_EN
    }
    
    func dealExampleSentences_CH(str:String) -> [String] {
        let sentenceList = str.components(separatedBy: "<br>")
        var i = 0
        var sentenceList_CH:[String] = []
        
        while i<sentenceList.count {
            if (i % 2 != 0) {
                sentenceList_CH.append(sentenceList[i])
            }
            i = i + 1
        }
        return sentenceList_CH
    }
    
    
    var body: some View {
        VStack(alignment:.leading) {
            ForEach(0..<self.countSentences(str: self.wordExampleSentences)){
                        num in
                        VStack(alignment:.leading,spacing:5) {
                                HStack(alignment:.top) {
                                    VStack {
                                        Text("\(num+1).")
                                            .fontWeight(.semibold)
                                            .padding(3)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2.0)
                                                    .stroke())
                                    }.foregroundColor(Color("WordSentencesColor"))
                                    .offset(x: 0, y: 5)
                                    HighlightPartlyView(fullString: self.dealExampleSentences_EN(str: self.wordExampleSentences)[num], wordContent: self.wordContent)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
//                            ZStack {
//                                TextEditor(text:.constant("\(self.dealExampleSentences_CH(str: self.wordExampleSentences)[num])"))
//                                        .font(.callout)
//                                        .padding(.leading,30)
//                                    .foregroundColor(Color("WordSentencesColor"))
                                    //.fixedSize(horizontal: false, vertical: true)
                            if showCH {
                                Text("\(self.dealExampleSentences_CH(str: self.wordExampleSentences)[num])")
                                    //.opacity(0)
                                    .font(.callout)
                                    .padding(.leading,30)
                                .foregroundColor(Color("WordSentencesColor"))
//                            }
                            }
                                Divider()
                            }
                        
                    }.font(.callout)
        }
//        .onTapGesture(perform: {
//            self.hideKeyboard()
//        })

    }
}


struct WordExampleSentencesView_Previews: PreviewProvider {
    static var previews: some View {
        WordExampleSentencesView()
    }
}
