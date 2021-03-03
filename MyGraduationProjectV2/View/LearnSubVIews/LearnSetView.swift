//
//  LearnSetView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/8.
//

import SwiftUI

struct LearnSetView: View {
    @StateObject var wordVM: WordViewModel// = WordViewModel()
    @StateObject var learnWordVM: LearnWordViewModel// = LearnWordViewModel()
    
    var newWordNumSelection:[Int] {
        var list:[Int] = [5]
        for i in stride(from: 10, to: 110, by: 10) {
            list.append(i)
        }
        return list
    }
    
//    @State var selectednewWordNumIndex: Int = 0
    @AppStorage("UD_selectednewWordNumIndex") var UD_selectednewWordNumIndex = 0
    @AppStorage("UD_newWordNum") var UD_newWordNum = 10 //用户设定每日新词数量，存在UD里
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 1
    
    //@AppStorage("UD_newWordNum") var newWordNum = 0
    
    var body: some View {
        List {
            HStack {
                Text("每日新词数量")
                Spacer()
                Button(action: {
                    learnWordVM.UD_newWordNum = self.newWordNumSelection[UD_selectednewWordNumIndex]
                    //更改后重新获取今日列表
                    learnWordVM.getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
                }, label: {
                    Text("保存")
                }).buttonStyle(PlainButtonStyle())
                .foregroundColor(learnWordVM.UD_newWordNum != self.newWordNumSelection[UD_selectednewWordNumIndex] ? Color(.systemBlue) : Color(.systemGray3))
                .disabled(learnWordVM.UD_newWordNum != self.newWordNumSelection[UD_selectednewWordNumIndex] ? false : true)
            }
            HStack {
                Picker("每日新词数量", selection: $UD_selectednewWordNumIndex){
                        ForEach(0..<newWordNumSelection.count){
                            i in
                            HStack {
                                Text("\(self.newWordNumSelection[i])")
                                    .padding([.leading],20)
                                
                            }
                        }}
                    .pickerStyle(WheelPickerStyle())
            }.offset(x: -5, y: 0)
            HStack {
                Text("预计完成学习时间:")
                Text(doneDateCount(unlearnedWordNum: self.learnWordVM.UD_unlearnedWordNum, newWordNum: self.newWordNumSelection[UD_selectednewWordNumIndex]))
            }
            
        }.listStyle(InsetGroupedListStyle())
    }
    
    func doneDateCount(unlearnedWordNum:Int,newWordNum:Int) -> String {
        let dayCount = unlearnedWordNum/newWordNum + 29
        var component = Calendar.current.dateComponents([.year,.month,.day], from: Date())
//        component.day = component.day! + 29 + dayCount
        component.day = component.day!  + dayCount
        let date = Calendar.current.date(from: component)
        return date?.dateToString(format: "yyyy-MM-dd") ?? "unkonw"
    }
}

struct LearnSetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
        LearnSetView(wordVM: WordViewModel(), learnWordVM: LearnWordViewModel())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
