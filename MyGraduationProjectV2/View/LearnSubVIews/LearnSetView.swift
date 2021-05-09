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
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    @AppStorage("UD_allWordNum") var UD_allWordNum = 1 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量
    
    @State var notiTime:String = ""
    
    func createNotification(time:Int) -> UNNotificationRequest{
        let content = UNMutableNotificationContent()
        content.title = "开始今天的学习！"
        //content.subtitle = "子标题"
        content.body = "正在学习《\(UD_learningBook)》，已掌握\(UD_knownWordNum)个单词。\n还有\(UD_unlearnedWordNum)个单词未学习。"
        content.badge = 0

        let dateComponents = DateComponents(hour: 19) // 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) // 2
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
        
        //用即时通知测试
        let trigger_test = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request_test = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger_test)

        return request_test
    }
    
    var newWordNumSelection:[Int] {
        var list:[Int] = [2,5]
        for i in stride(from: 10, to: 110, by: 10) {
            list.append(i)
        }
        return list
    }
    
    var testWordNumSelection:[Int] {
        var list:[Int] = [1,3,5]
        for i in stride(from: 10, to: 30, by: 5) {
            list.append(i)
        }
        return list
    }
    
//    @State var selectednewWordNumIndex: Int = 0
    @AppStorage("UD_selectednewWordNumIndex") var UD_selectednewWordNumIndex = 0
    @AppStorage("UD_newWordNum") var UD_newWordNum = 10 //用户设定每日新词数量，存在UD里
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 1
    
    //单词测试的数量
    @AppStorage("UD_selectedtestWordNumIndex") var UD_selectedtestWordNumIndex = 0
    @AppStorage("UD_testWordNum") var UD_testWordNum = 1
    
    
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
            
            Section{
                HStack {
                    Text("每次单词测试数量")
                    Spacer()
                    Button(action: {
                        UD_testWordNum = self.testWordNumSelection[UD_selectedtestWordNumIndex]
                    }, label: {
                        Text("保存")
                    }).buttonStyle(PlainButtonStyle())
                    .foregroundColor(UD_testWordNum != self.testWordNumSelection[UD_selectedtestWordNumIndex] ? Color(.systemBlue) : Color(.systemGray3))
                    .disabled(UD_testWordNum != self.testWordNumSelection[UD_selectedtestWordNumIndex] ? false : true)
                }
                HStack {
                    Picker("单词测试数量", selection: $UD_selectedtestWordNumIndex){
                            ForEach(0..<testWordNumSelection.count){
                                i in
                                HStack {
                                    Text("\(self.testWordNumSelection[i])")
                                        .padding([.leading],20)
                                    
                                }
                            }}
                        .pickerStyle(WheelPickerStyle())
                }.offset(x: -5, y: 0)
            }
            
            Section{
                HStack {
                    Text("开启学习通知")
                    Spacer()
                    Button(action: {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (status, err) in
                            if !status {
                                    print("用户不同意授权通知权限")
                                return
                            }
                        }
                        
                        let request = self.createNotification(time: 11)
                        UNUserNotificationCenter.current().add(request) { err in
                            err != nil ? print("添加本地通知错误", err!.localizedDescription) : print("添加本地通知成功")
                        }
                    }, label: {
                        Text("保存")
                            .foregroundColor(Color(.systemBlue))
                    }).buttonStyle(PlainButtonStyle())

                }
                HStack {
//                    Picker("单词测试数量", selection: $UD_selectedtestWordNumIndex){
//                            ForEach(0..<testWordNumSelection.count){
//                                i in
//                                HStack {
//                                    Text("\(self.testWordNumSelection[i])")
//                                        .padding([.leading],20)
//
//                                }
//                            }}
//                        .pickerStyle(WheelPickerStyle())
                    Text("每日通知时间")
                    TextField("输入每日通知时间（HH）", text: $notiTime)
                        .keyboardType(.numberPad)
                }
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
