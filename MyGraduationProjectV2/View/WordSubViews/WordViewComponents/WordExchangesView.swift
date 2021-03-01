//
//  WordExchangesView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/11.
//

import SwiftUI

struct WordExchangesView: View {
    @State var wordExchanges:String = "d:alleviated/i:alleviating/3:alleviates/p:alleviated"
    
    func dealExchanges(str:String) -> [[String]] {
        var exString = str
        //        exString = exString.replacingOccurrences(of: "/", with: "\n")
        exString = exString.replacingOccurrences(of: "p:", with: "过去式(did):")
        exString = exString.replacingOccurrences(of: "d:", with: "过去分词(done):")
        exString = exString.replacingOccurrences(of: "i:", with: "现在分词(doing):")
        exString = exString.replacingOccurrences(of: "3:", with: "第三人称单数(does):")
        exString = exString.replacingOccurrences(of: "r:", with: "形容词比较级(-er):")
        exString = exString.replacingOccurrences(of: "t:", with: "形容词最高级(-est):")
        exString =  exString.replacingOccurrences(of: "0:", with: "词缀(lemma):")
        exString = exString.replacingOccurrences(of: "1:", with: "词缀的复数形式(lemma):")
        
        exString =  exString.replacingOccurrences(of: "s:", with: "复数:")
        
        let exList = exString.components(separatedBy: "/")
        var exListList:[[String]] = []//[exList[0].components(separatedBy: ":")]
        for ex in exList[0...exList.count-1] {
            exListList.append(ex.components(separatedBy: ":"))
        }
        return exListList
    }
    var body: some View {
        VStack(alignment:.leading) {
            if(self.wordExchanges != "nullTag"){
                ForEach(self.dealExchanges(str: self.wordExchanges),id:\.self){
                    exList in
                    HStack {
                        HStack {
                            Text(exList[0])
                                .font(.caption2)
                                .padding(1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2.0)
                                    .stroke())
                        }.foregroundColor(Color("WordExchangesColor"))
                        Text(exList[1])
                            .font(.callout)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = exList[1]
                                }) {
                                    Text("Copy to clipboard")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    }
                }
            }
        }        .padding(.bottom, 5)
        .padding(.top, 5)
    }
}

struct WordExchangesView_Previews: PreviewProvider {
    static var previews: some View {
        WordExchangesView()
    }
}
