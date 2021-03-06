//
//  SettingView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import SwiftUI

struct SettingView: View {
    @StateObject var appearanceVM:AppearanceViewModel
    @StateObject var userVM:UserViewModel
    @StateObject var wordVM:WordViewModel
    
    @AppStorage("UD_isLogged") var UD_isLogged = true
    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    @AppStorage("UD_searchHistoryCount") var UD_searchHistoryCount = 0
    
    @State var ECOn = false
    
    @State var deleteNoteAlert = false
    @State var deleteHistoryAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("账号及同步")){
                    
                    NavigationLink(
                        destination: PersonalView(userVM: self.userVM, wordVM: self.wordVM).hiddenTabBar(),
                        label: {
                            VStack {
                                if (UD_isLogged && self.userVM.isLocalSessionVertified) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                            .font(.largeTitle)
                                            .padding([.top,.bottom],15)
                                        Text("\(userVM.currentUserInfo())")
                                    }
                                }else{
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill.badge.questionmark")
                                            .font(.largeTitle)
                                            .padding([.top,.bottom],15)
                                        Text("登录账号")
                                    }
                                }
                            }
                        })
                    
                    
                    
                }
                .onAppear(perform: {
                    self.userVM.vertifyLocalSession()
                })
                
                Section(header:Text("词典设置")){
                    HStack {
                        Image(systemName: "c.square")
                            .font(.title2)
                       Toggle("启动汉英查询", isOn: $ECOn)
                    }
                    NavigationLink(
                        destination: Text("test"),
                        label: {
                            HStack {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                Text("自动展开内容")
                            }
                        })
                }
                
                Section(header: Text("外观设置")){
                    NavigationLink(
                        destination: DarkModeSettingView(appearanceVM:self.appearanceVM),
                        label: {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                Text("深色模式设置")
                            }
                        })
                }
                
                Section(header: Text("本地记录设置")){
                    Button(action: {
                        self.deleteNoteAlert = true
                    }, label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除生词本内容")
                        }
                    }).foregroundColor(Color(.systemRed))
                    .alert(isPresented: $deleteNoteAlert, content: {
                        Alert(title: Text("确定要删除本地生词本内容吗？"), message: Text("已保存到云端的内容不受影响"), primaryButton: .default(Text("确定"), action: {
                            self.wordVM.deleteAllNotebook()
                        }), secondaryButton: .destructive(Text("取消"), action: {self.deleteNoteAlert = false}))
                    })
                    
                    Button(action: {
                        self.deleteHistoryAlert = true
                        UD_searchHistoryCount = 0
                    }, label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除本地查询记录")
                        }
                    }).foregroundColor(Color(.systemRed))
                    .alert(isPresented: $deleteHistoryAlert, content: {
                        Alert(title: Text("确定要删除本地查询记录吗？"), message: Text("云端查询记录不受影响"), primaryButton: .default(Text("确定"), action: {
                            self.wordVM.deleteAllHistory()
                        }), secondaryButton: .destructive(Text("取消"), action: {self.deleteHistoryAlert = false}))
                    })
                }
                
                
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("设置")
            .showTabBar()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(appearanceVM: AppearanceViewModel(), userVM: UserViewModel(), wordVM: WordViewModel())
    }
}
