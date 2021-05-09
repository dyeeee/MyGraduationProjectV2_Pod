//
//  DealString.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/22.
//

import Foundation

//a. 抽象的, 深奥的\nn. 摘要, 抽象概念\nvt. 摘要, 提炼, 使抽象化\n[计] 摘录; 摘要; 抽象

public func dealTrans(_ rawTrans:String) -> String {
    let pattern1 = "^(vt|n|a|adj|adv|v|pron|prep|num|art|conj|vi|interj|r)(\\.| )"
    let regex1 = try! Regex(pattern1)
    
    //只替换第1个匹配项
    let out1 = regex1.replacingMatches(in: rawTrans, with: "[$1.] ", count: 1)
    
    
    
    let pattern2 = "n(vt|n|a|adj|adv|v|pron|prep|num|art|conj|vi|interj|r)(\\.| )"
    let regex2 = try! Regex(pattern2)
    //替换所有匹配项
    let out2 = regex2.replacingMatches(in: out1, with: "n[$1.] ")
    
    //        //输出结果
    //        print("原始的字符串：", rawTrans)
    //        print("替换第1个匹配项：", out1)
    //        print("替换所有匹配项：", out2)
    
    let result = out2.replacingOccurrences(of: "\\n", with: "\n")
    return result
}

func bookName2Tag(book:String) -> String{
    switch book {
    case "中考英语":
        return "zk"
    case "高考英语":
        return "gk"
    case "大学英语四级":
        return "cet4"
    case "大学英语六级":
        return "cet6"
    case "考研英语":
        return "ky"
    case "雅思词汇":
        return "ielts"
    case "托福词汇":
        return "toelf"
    case "GRE词汇":
        return "gre"
    default:
        return "gk"
    }
}
