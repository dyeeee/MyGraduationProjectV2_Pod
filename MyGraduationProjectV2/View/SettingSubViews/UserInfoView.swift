//
//  User InfoView.swift
//  LeanCloudTest
//
//  Created by YES on 2021/1/30.
//

import SwiftUI

struct UserInfoView: View {
    @StateObject var userVM:UserViewModel
    
    @StateObject var wordVM:WordViewModel
    @StateObject var learnVM:LearnWordViewModel
    
    @StateObject var todoVM:ToDoViewModel
    
    
    
    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    @AppStorage("UD_allWordNum") var UD_allWordNum = 0 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量，存在UD里
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量，存在UD里
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量，存在UD里
    
    @AppStorage("UD_noteWordNum") var UD_noteWordNum = 0
    @AppStorage("UD_todoNum") var UD_todoNum = 0
    @AppStorage("UD_searchHistoryCount") var UD_searchHistoryCount = 0
    
    @AppStorage("UD_autoSync") var UD_autoSync = false
    
    @State var uploadAlert = false
    
    @State var tabIndex = 0
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Image("avatar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80, alignment: .center)
                    VStack(alignment: .leading) {
                        Text("账号")
                            .font(.subheadline)
                        Text("\(userVM.currentUserInfo())")
                    }
                }
            }
            
            Section(header:Text("云同步")){
                HStack{
                    Image(systemName: "link.icloud")
                        .font(.title2)
                   Toggle("启用自动同步", isOn: $UD_autoSync)
                }
                
                HStack {
                    HStack {
                        

                        Button(action: {
                            self.userVM.downloadFromCloud()
                            
                            self.wordVM.downloadFromCloud()
                            self.learnVM.downloadFromCloud()
                            self.todoVM.downloadFromCloud()
                            
                        }, label: {
                            Text("下载云端数据")
                                .font(.headline)
                            Image(systemName: "icloud.and.arrow.down")
                            
                            
                        }).buttonStyle(PlainButtonStyle())
                        .font(.title2)
                        .foregroundColor(Color(.systemBlue))
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    HStack {
                        Button(action: {
                            userVM.uploadUserInfo()
                            
                            todoVM.uploadToCloud()
                            wordVM.uploadToCloud()
                            learnVM.uploadToCloud()
                            
                        }, label: {
                            Text("上传本地数据")
                                .font(.headline)
                            Image(systemName: "icloud.and.arrow.up")
                            
                        }).buttonStyle(PlainButtonStyle())
                        .font(.title2)
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                
                HStack {
                    
                    VStack {
                        
                        if Device.deviceType == .iPhone {
                            Image(systemName: "house.fill")
                        }else{
                            HStack {
                                Spacer()
                                Image(systemName: "house.fill")
                                Text("本地数据情况")
                                Spacer()
                            }
                        }

                    }
                    Spacer()
                    Divider()
                    VStack(alignment:.leading){
                        HStack {

                            VStack {
                                Text("课本")
    //                            Text("《\(UD_learningBook)》")
                                Text("\(NSLocalizedString("\(UD_learningBook)", comment: ""))")
                            }.frame(width: UIScreen.main.bounds.width*0.32)
                            Divider()
                            VStack {
                                Text("单词数量")
    //                            Text("《\(UD_learningBook)》")
                                Text("\(UD_allWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.32)

                        }
                        HStack{
                            VStack {
                                Text("学习中")
                                Text("\(UD_learningWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("已掌握")
                                Text("\(UD_knownWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("未学习")
                                Text("\(UD_unlearnedWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                        HStack{
                            VStack {
                                Text("生词本")
                                Text("\(UD_noteWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("待办事项")
                                Text("\(UD_todoNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("查询历史")
                                Text("\(UD_searchHistoryCount)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                    }.font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    Divider()
                }
                
                
                HStack {
                    
                    VStack {
                        
                        
                        if Device.deviceType == .iPhone {
                            Image(systemName: "icloud.fill")
                        }else{
                            HStack {
                                Spacer()
                                Image(systemName: "icloud.fill")
                                Text("云端数据情况")
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                    Divider()
                    VStack(alignment:.leading){
                        
                        HStack {

                            VStack {
                                Text("课本")
    //                            Text("《\(UD_learningBook)》")
                                Text("\(NSLocalizedString("\(userVM.Cloud_learningBook)", comment: ""))")
                            }.frame(width: UIScreen.main.bounds.width*0.32)
                            Divider()
                            VStack {
                                Text("单词数量")
    //                            Text("《\(UD_learningBook)》")
                                Text("\(userVM.Cloud_allWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.32)

                        }
                        HStack{
                            VStack {
                                Text("学习中")
                                Text("\(userVM.Cloud_learningWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("已掌握")
                                Text("\(userVM.Cloud_knownWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("未学习")
                                Text("\(userVM.Cloud_unlearnedWordNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                        HStack{
                            VStack {
                                Text("生词本")
                                Text("\(userVM.Cloud_noteBookNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("待办事项")
                                Text("\(userVM.Cloud_todoNum)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("查询历史")
                                Text("\(userVM.Cloud_searchHistoryCount)")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                    }.font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    Divider()
                }
                

                
                
                
            }
            
            Section{
            VStack{
                Toggle("是否启用生物识别登录", isOn: $UD_isUsingBioID)
            }
            .onChange(of: UD_isUsingBioID, perform: { value in
                print("生物识别状态: \(UD_isUsingBioID)")
            })
                
            }
            Section{
                VStack(alignment:.center) {
                    Button(action: {
                        self.userVM.userLogOut()
//                        print(UD_isUsingBioID)
                    }, label: {
                        Text("退出当前账号")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemRed))
                    })
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("账号")
        .navigationBarHidden(false)
        .hiddenTabBar()
        .onAppear(perform: {
            userVM.showCurrentUserInfo()
        })
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserInfoView(userVM: UserViewModel(), wordVM: WordViewModel(), learnVM: LearnWordViewModel(), todoVM: ToDoViewModel())
        }
    }
}
