//
//  WidgetWordView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/11.
//

import SwiftUI

struct WidgetWordView: View {
    let widgetWord: WidgetWord
    
    var body: some View {
        Text(widgetWord.wordContent)
            .font(.title2)
            .padding()
            .background(Color(.systemFill))
        
    }
}

struct WidgetWordView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetWordView(widgetWord: WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "v. consider a concept without thinking of a specific example; consider abstractly or theoretically\nv. consider apart from a particular case or instance\nv. give an abstract (of)\na. existing only in the mind; separated from embodiment", translation: "a. 抽象的, 深奥的\nn. 摘要, 抽象概念\nvt. 摘要, 提炼, 使抽象化\n[计] 摘录; 摘要; 抽象", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works. . .<br>曾有人告诉我一个明晰而无聊的可视物能帮助人们理解抽象的理论，让我们来看看当它工作时……<br>Abstract: traditional chinese medicine, known as an ancient medical science is marked by its obscurity and difficulty in terms of theory."))
        
    }
}


