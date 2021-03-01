//
//  FrqDetailIntroView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/10.
//

import SwiftUI

struct FrqDetailIntroView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment:.leading,spacing:10) {
                    Text("______________")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .overlay(
                            Text("OXFORD 牛津3000核心词汇")
                                .font(.headline)
                                .offset(x: 0, y: 5.0))
                    Text("牛津3000核心词汇是一份从包含20亿词的牛津英语语料库（Oxford English Corpus）中精选而出的英语学习者必备常用 3000+词汇。\n")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                VStack(alignment:.leading,spacing:10) {
                    Text("________________")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .overlay(
                            Text("COLLINS-X 柯林斯词典五级词汇")
                                .font(.headline)
                                .offset(x: 0, y: 5.0))
                    Text("柯林斯高阶英汉词典（Collins Cobuild Advanced Learner's English-Chinese Dictionary）将部分常用单词分为1-5级，级别5为最常使用，级别1为较少使用。")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                    Text("COLLINS-1: Used rarely, it's in the lower 50% of commonly used words in the Collins Dictionary.\nCOLLINS-2: Used occasionally, it's one of the 30000 most commonly used words in the Collins Dictionary.\nCOLLINS-3: In Common Usage, it's one of the 10000 most commonly used words in the Collins Dictionary.\nCOLLINS-4: Very Common, it's one of the 4000 most commonly used words in the Collins Dictionary.\nCOLLINS-5: Extremely Common, it's one of the 1000 most commonly used words in the Collins Dictionary.\n")
                        .font(.footnote)
                        .foregroundColor(Color(.systemGray))
                }
                
                VStack(alignment:.leading,spacing:10) {
                    Text("________________")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .overlay(
                            Text("BNC-X 英国国家语料库词频顺序")
                                .font(.headline)
                                .offset(x: 0, y: 5.0))
                    Text("英国国家语料库词频顺序是基于英国国家语料库（British National Corpus），收录近几百年的各类英文资料统计出的词汇使用频率，其中1为使用频率最高的单词(the)。\n")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                
                VStack(alignment:.leading,spacing:10) {
                    Text("___________________")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .overlay(
                            Text("COCA-X 当代美国英语语料库词频顺序")
                                .font(.headline)
                                .offset(x: 0, y: 5.0))
                    Text("当代美国英语语料库词频顺序是基于当代美国英语语料库（Corpus of Contemporary American English），收录近二十年的英文资料统计出的词汇使用频率，其中1为使用频率最高的单词(the)。\n")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                
                VStack(alignment:.leading,spacing:10) {
                    Text("___________________")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .overlay(
                            Text("英国国家语料库与当代美国英语语料库的区别")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .offset(x: 0, y: 6.0))
                    Text("BNC 词频统计的是最近几百年的历史各类英文资料，而COCA只统计了最近 20 年的，为什么两者都要提供呢？\n举个例子来说，quay（码头）这个词在COCA里排两万以外，你可能觉得是个没必要掌握的生僻词，而 BNC 里面却排在第 8906 名，基本算是一个高频词，为啥呢？可以想象过去航海还是一个重要的交通工具，所以以往的各类文字资料对这个词提的比较多，你要看懂 19 世纪即以前的各类名著，你会发现 BNC 的词频很管用。而你要阅读各类现代杂志，COCA的作用就体现出来了，比如 Taliban（塔利班），在 BNC 词频里基本就没收录（没进前 20 万词汇），而在COCA里，它已经冒到 6089 号了，高频中的高频。\nBNC 较为全面和传统，针对性学习能帮助你阅读各类国外帝王将相的文学名著，COCA较为现代和实时，以和科技紧密相关。所以两者搭配，干活不累。\n")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                    Text("参考：\nhttps://github.com/skywind3000/ECDICT\nhttps://github.com/dyeeee/English-Chinese-Dictionary")
                        .font(.footnote)
                        .foregroundColor(Color(.systemGray2))
                }
                
            }.padding(20)
            .navigationTitle("单词标签介绍")
            
            
        }
    }
    
}

struct FrqDetailIntroView_Previews: PreviewProvider {
    static var previews: some View {
        FrqDetailIntroView()
    }
}
