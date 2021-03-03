//
//  User InfoView.swift
//  LeanCloudTest
//
//  Created by YES on 2021/1/30.
//

import SwiftUI

struct UserInfoView: View {
    @StateObject var userVM:UserViewModel
    @AppStorage("UD_isUsingBioID") var UD_isUsingBioID = false
    
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    @AppStorage("UD_allWordNum") var UD_allWordNum = 0 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量，存在UD里
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量，存在UD里
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量，存在UD里
    
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
                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Text("同步模式设置")
                        })
                }
                
                HStack {
                    Text("上传当前学习进度")
                    Spacer()
                    Button(action: {
                        self.userVM.uploadUserInfo(learningBook: UD_learningBook, wordStatusList: [UD_allWordNum,UD_knownWordNum,UD_learningWordNum,UD_unlearnedWordNum])
                    }, label: {
                        Image(systemName: "link.icloud.fill")
                        
                    }).buttonStyle(PlainButtonStyle())
                    .font(.title2)
                    .foregroundColor(Color(.systemBlue))
                }
                
                HStack {
                    
                    VStack {
                        
                        Image(systemName: "house.fill")
                    }
                    Spacer()
                    Divider()
                    VStack(alignment:.leading){
                        HStack {

                            VStack {
                                Text("课本")
    //                            Text("《\(UD_learningBook)》")
                                Text("大学英语六级")
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
                                Text("261")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("待办事件")
                                Text("8")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("查询历史")
                                Text("43")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                    }.font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    Divider()
                }
                
                
                HStack {
                    
                    VStack {
                        
                        Image(systemName: "icloud.fill")
                    }
                    Spacer()
                    Divider()
                    VStack(alignment:.leading){
                        
                        HStack {

                            VStack {
                                Text("课本")
    //                            Text("《\(UD_learningBook)》")
                                Text("大学英语六级")
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
                                Text("261")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("待办事件")
                                Text("8")
                            }.frame(width: UIScreen.main.bounds.width*0.2)
                            Divider()
                            VStack {
                                Text("查询历史")
                                Text("43")
                            }.frame(width: UIScreen.main.bounds.width*0.2)

                        }
                        
                    }.font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    Divider()
                }
                

                
//                Picker(selection: self.$tabIndex, label: Text("Picker"), content:
//                        {
//                            Text("星级").tag(0)
//                            Text("字母").tag(1)
//                            Text("笔记").tag(2)
//                        })
//                    .pickerStyle(SegmentedPickerStyle())
//                    .background(Color(.systemBackground))
                
//                TabView{
//
//                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
            }
            
            Section{
            VStack{
                Toggle("是否启用生物识别登录", isOn: $UD_isUsingBioID)
            }
            }
            Section{
                VStack(alignment:.center) {
                    Button(action: {
                        self.userVM.userLogOut()
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
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserInfoView(userVM: UserViewModel())
        }
    }
}
