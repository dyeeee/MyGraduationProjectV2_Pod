//
//  WidgetWordView_Medium.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/12.
//

import WidgetKit
import SwiftUI

struct WidgetWordView_Medium: View {
    let widgetWord: WidgetWord
    let color = [Color(.systemPurple),Color(.systemBlue)
                 ,Color(.systemTeal),Color(.systemIndigo),
                 Color(.systemOrange),Color(.systemPink)].randomElement()
    
    var body: some View {
        VStack(spacing:0) {
            HStack {
                VStack {
                    Text(widgetWord.wordContent)
                        .font(widgetWord.wordContent.count < 14 ? .title3 :.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.clear)
                        .overlay(Rectangle().frame(height:4)
                                    .foregroundColor(color)
                                    .offset(x:0,y:widgetWord.wordContent.count < 14 ? 7 : 6))
                }.overlay(
                    Text(widgetWord.wordContent)
                        .font(widgetWord.wordContent.count < 14 ? .title3 :.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("systemBlack"))
            )
            
                HStack(spacing:0) {
                    Image("EN")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 25, alignment: .trailing)
                    Text("\(dealEN_Widget(widgetWord.phonetic_EN))")
                        .font(.custom("Baskerville", size: 16,relativeTo: .body))
                    Spacer()
                }//.padding([.leading,.trailing],10)
                .foregroundColor(Color(.systemGray))
                
                Spacer()
                
   
            }//.padding([.leading,.trailing],10)
            

            if widgetWord.wordTags != "nullTag" {
            HStack(spacing:3){
                ForEach(getTagsList_Widget(str: widgetWord.wordTags,limit: 10), id:\.self){
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
                Spacer()
            }.padding([.trailing],0)
            .padding(.top,5)
            }
            
            HStack(alignment:.top) {
                VStack {
                    Text("\(dealTrans_Widget(widgetWord.translation))")
                        .font(.custom("Baskerville", size: 14,relativeTo: .body))
                        //Spacer()
                }.padding([.trailing],5)
                Spacer(minLength: 0)
                Divider()
                HStack {
                    Text("\(dealTrans_Widget(widgetWord.definition))")
                        .font(.custom("Baskerville", size: 14,relativeTo: .body))
                        //Spacer()
                }//.padding([.leading],10)

                

                
            }.padding(.top,7)
            
            Spacer(minLength: 0)
            
            HStack {
                Spacer(minLength: 0)
                Text("E-Word")
            }.font(.custom("", size: 8,relativeTo: .caption2))
            .foregroundColor(Color(.systemGray2))
            //.padding([.trailing],15)
            .padding(.bottom,3)
            

        }.padding([.top],10)
        .padding([.leading,.trailing],15)
        
    }
}

struct WidgetWordView_Medium_Previews: PreviewProvider {
    static var previews: some View {
        let demo = WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "v. consider a concept without thinking of a specific example; consider abstractly or theoretically\nv. consider apart from a particular case or instance\nv. give an abstract (of)\na. existing only in the mind; separated from embodiment", translation: "a. 抽象的, 深奥的\nn. 摘要, 抽象概念\nvt. 摘要, 提炼, 使抽象化\n[计] 摘录; 摘要; 抽象", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works. . .<br>曾有人告诉我一个明晰而无聊的可视物能帮助人们理解抽象的理论，让我们来看看当它工作时……<br>Abstract: traditional chinese medicine, known as an ancient medical science is marked by its obscurity and difficulty in terms of theory.")
        
        return Group{
        WidgetWordView_Medium(widgetWord: demo)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
        }
    }
}
