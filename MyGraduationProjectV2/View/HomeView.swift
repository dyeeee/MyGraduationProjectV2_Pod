//
//  HomeView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/7.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject var userVM:UserViewModel
    @StateObject var wordVM:WordViewModel
    @StateObject var learnVM:LearnWordViewModel
    @StateObject var dayContentVM:DayContentViewModel
    @StateObject var todoVM:ToDoViewModel
    @StateObject var appearanceVM:AppearanceViewModel
    
    @Binding var selectedTab:TabSelection
    @AppStorage("UD_isLastLearnDone") var UD_isLastLearnDone = false
    @AppStorage("UD_learningBook") var UD_learningBook = "测试"
    @State var showCalendar = true
    
    @State var showAllToDo = false
    @State var screenWidth = UIScreen.main.bounds.width
    
    @AppStorage("UD_newData") var UD_newData = false
    @AppStorage("UD_autoSync") var UD_autoSync = false

    
    var body: some View {
        NavigationView {
            List{
                Section(header: Text("今日学习").foregroundColor(Color("ListHeaderColor"))){
                    VStack(alignment:.leading) {
                        HStack {
                            Text("\(Date().dateToString(format: "yyyy-MM-dd"))")
                            Spacer()
//                            Button(action: {
//                                isLastLearnDone.toggle()
//                            }, label: {
//                                Text("Test")
//                            })
                        }.font(.subheadline)
                        .foregroundColor(Color(.systemGray))//.padding([.top],5)
                        
                        HStack {
                            HStack(spacing:5) {
                                Image(systemName: UD_isLastLearnDone ? "checkmark.square.fill" : "xmark.octagon.fill")
                                Text(UD_isLastLearnDone ? "今日学习已完成" : "今日学习未完成")
                            }.font(.headline)
                            
                            Spacer()
                            Button(action: {
                                self.selectedTab = .page2
                            }, label: {
                                HStack(spacing:0) {
                                    Text(UD_isLastLearnDone ? "":"前往学习")
                                    Image(systemName: UD_isLastLearnDone ? "":"chevron.right.square")
                                }.foregroundColor(UD_isLastLearnDone ? Color(.systemGray) : Color(.systemBlue))
                            }).font(.subheadline)
                            .buttonStyle(PlainButtonStyle())
                        }.padding([.top],5)
                    }}.padding([.top,.bottom],5)
                
                Section(header:CalendarListHeader(showContent: $showCalendar)){
                    
                    if showCalendar {
                        VStack{
                            HStack {
                                Spacer()
                                MonthView(dayContentVM:self.dayContentVM,isCurrentMonth:true, screenWidth: $screenWidth, month: Month(startDate:Date()))
                                Spacer()
                            }

                        }.buttonStyle(PlainButtonStyle())
                        
//                        .sheet(isPresented: $showHistoryCalendar, content: {
//                            HistoryCalendarView(dayContentVM:self.dayContentVM,isLoading:self.$isLoading)
//                        })
                    }
                    else{
                        VStack{
                            HStack {
                                HStack(spacing:0) {
                                    Text("学习中的单词书: ")
                                    Text(NSLocalizedString("\(UD_learningBook)", comment: ""))
                                }
                                Spacer()
                            }.font(.subheadline)
                            LineView(data: [0,0.4,1.5,2.0,3.7], title: "Line chart", legend: "Full screen")
                        }.buttonStyle(PlainButtonStyle())
                    }
                    
                }.padding([.top,.bottom],5)
                
                Section(header:ToDoPartHeader(showContent:$showAllToDo)){
                    ForEach(self.todoVM.UndoneToDoItemList, id:\.self){
                        item in
                        HStack{
                            //Text(item.todoContent)
                            Button(action:{
                                item.done.toggle()
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15){
                                    todoVM.saveToPersistentStore()}
                            },label:{
                                ZStack {
                                    
                                    Image(systemName:"checkmark.circle.fill")
                                        .opacity(item.done ? 1 : 0)
                                        .foregroundColor(Color(.systemGreen))
                                    Image(systemName:"circle")
                                        .foregroundColor(Color(.systemGray))
                                }
                            }).buttonStyle(PlainButtonStyle())
                            
                            
                            Text("\(item.todoContent ?? "noContent")")
                                .foregroundColor(item.done ? Color(.systemGray3) : Color("systemBlack"))
                                
                                .strikethrough(item.done ? true:false, color: Color(.systemGray))
                                .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                            
                        }
                    }.onDelete(perform: self.todoVM.deleteToDoItem)
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("摘要")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        self.userVM.downloadFromCloud()
                        self.wordVM.downloadFromCloud()
                        self.learnVM.downloadFromCloud()
                        self.todoVM.downloadFromCloud()
                        self.dayContentVM.createTestItem()
                    },label:{
                        Image(systemName:UD_newData ? "bolt.horizontal.icloud" : "checkmark.icloud")
                    }).opacity(UD_newData ? 1:0)
                    .disabled(UD_newData ? false:true)
                }
            })
            .onAppear(perform: {
                userVM.vertifyLocalSession()
                userVM.checkNewDataFromCloud()
                
                if UD_newData && UD_autoSync{
                    print("自动下载中")
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3){
                        self.userVM.downloadFromCloud()
                        self.todoVM.downloadFromCloud()
//                        self.learnVM.downloadFromCloud()
                        self.wordVM.downloadFromCloud()
                    }
                    
                    UD_newData = false
                }
            })
//            .onChange(of:UD_newData,perform:{
//                _ in
//                userVM.vertifyLocalSession()
//                userVM.checkNewDataFromCloud()
//            })
            .sheet(isPresented: $showAllToDo, content: {
                ToDoListView(todoVM:self.todoVM)
                    .ifIs(Device.deviceType == .iPad && (self.appearanceVM.UD_storedColorScheme != "")){
                        $0.preferredColorScheme(self.appearanceVM.colorScheme)
                    }
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userVM: UserViewModel(), wordVM: WordViewModel(), learnVM: LearnWordViewModel(),dayContentVM:DayContentViewModel(),todoVM: ToDoViewModel(), appearanceVM: AppearanceViewModel(), selectedTab: .constant(.page2))
    }
}

struct CalendarListHeader: View {
    var img:String = "scroll.fill"
    //var text:String = "近期学习状况"
    @Binding var showContent:Bool
    
    var body: some View {
        HStack {
            Text("近期学习状况").offset(x: -5, y: 0)
            Spacer()
                //Text("show")
                HStack(spacing:5) {
                    Text(self.showContent ? "切换至进度" : "切换至日历")
                    Image(systemName: self.showContent ? "chart.bar.xaxis" :"calendar")
                    
                }.padding(.trailing,5)
                .onTapGesture {
                    showContent.toggle()
                }
                
                
            
        }
        .foregroundColor(Color("ListHeaderColor"))
        .padding([.leading],5)
    }
}

struct ToDoPartHeader: View {
    @Binding var showContent:Bool
    //var text:String = "待办事项"
    
    var body: some View {
        HStack {
            Text("待办事项").offset(x: -5, y: 0)
            Spacer()
            Button(action: {
                showContent.toggle()
            }, label: {
                Text("显示所有待办")
                Image(systemName: "tray.full.fill")
            }).padding(.trailing,5)
            
//                //Text("show")
//                HStack(spacing:5) {
//                    Text("显示所有待办")
//                    Image(systemName: "tray.full.fill")
//
//                }.padding(.trailing,5)
//                .onTapGesture {
//                    showContent.toggle()
//                }
                
                
            
        }
        .foregroundColor(Color("ListHeaderColor"))
        .padding([.leading],5)
    }
}
