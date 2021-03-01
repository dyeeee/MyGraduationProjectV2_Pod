//
//  WordTagsView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/10.
//

import SwiftUI

struct WordTagsView: View {
    @State var wordTags:String = "gk cet4 cet6 ky toefl gre"
    @State var bncLevel:Int = 123
    @State var frqLevel:Int = 123
    @State var oxfordLevel:Int = 0
    @State var collinsLevel:Int = 2
    
    @State var showHelp:Bool = false
    
    func getTagsList(str:String) -> [String] {
        var tagsString = str
        tagsString = tagsString.replacingOccurrences(of: "zk", with: "中")
        tagsString = tagsString.replacingOccurrences(of: "gk", with: "高")
        tagsString = tagsString.replacingOccurrences(of: "cet4", with: "四")
        tagsString = tagsString.replacingOccurrences(of: "cet6", with: "六")
        tagsString = tagsString.replacingOccurrences(of: "ky", with: "研")
        tagsString = tagsString.uppercased()
        let tagsList:[String] = tagsString.components(separatedBy: " ")
        return tagsList
    }
    
    func isFrqsEmpty(bnc:Int,frq:Int,ox:Int,co:Int) -> Bool {
        if (bnc != 0 || frq != 0 || ox != 0 || co != 0) {
            return false
        }
        else{
            return true
        }
    }
    
    func getFrqsList(bnc:Int,frq:Int,ox:Int,co:Int) -> [String] {
        var frqString = ""
        
        
        if ox == 1 {
            frqString.append("OXFORD ")
        }
        if co != 0 {
            frqString.append("COLLINS-\(String(co)) ")
        }
        if bnc != 0 {
            frqString.append("BNC-\(String(bnc)) ")
        }
        if frq != 0 {
            frqString.append("COCA-\(String(frq)) ")
        }
        frqString.removeLast()
        let frqsList = frqString.components(separatedBy: " ")
        return frqsList
    }
    
    var body: some View {
        
        VStack(alignment:.leading,spacing:5){
            if (wordTags != "nullTag") {
                Menu{
                    VStack{
                        Text("高: 高考词汇")
                        Text("四: CET四级词汇")
                        Text("六: CET六级词汇")
                        Text("研: 考研词汇")
                        Text("TOEFL: 托福词汇")
                        Text("IELTS: 雅思词汇")
                        Text("GRE: GRE词汇")
                    }
                }label: {
                    HStack(spacing:3){
                        ForEach(self.getTagsList(str: wordTags), id:\.self){
                            tag in
                            VStack {
                                Text(tag)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2.0)
                                            .stroke())
                            }.foregroundColor(Color("WordTagsColor"))
                        }
                    }
                }
                
            }
            if (!isFrqsEmpty(bnc: self.bncLevel, frq: self.frqLevel, ox: self.oxfordLevel, co: self.collinsLevel)) {
                
                Menu{
                    VStack{
                        Text("OXFORD:牛津核心词汇")
                        Text("COLLINS-X:柯林斯X级词汇")
                        Text("BNC-X:BNC词频排序X位")
                        Text("COCA-X:COCA词频排序X位")
                        
                        Button(action: {
                            self.showHelp.toggle()
                        }, label: {
                            Text("更多介绍")
                        })
                        
                    }
                }label: {
                    HStack(spacing:3){
                        ForEach(self.getFrqsList(bnc: self.bncLevel, frq: self.frqLevel, ox: self.oxfordLevel, co: self.collinsLevel), id:\.self){
                            level in
                            VStack {
                                Text(level)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2.0)
                                            .stroke())
                            }.foregroundColor(Color("WordLevelsColor"))
                        }
                    }
                }.foregroundColor(Color("WordTagsColor"))
                
            }
            
        }.sheet(isPresented: $showHelp, content: {
            FrqDetailIntroView()
        })
        .padding([.top,.bottom],5)
        
    }
}

struct WordTagsView_Previews: PreviewProvider {
    static var previews: some View {
        WordTagsView()
    }
}
