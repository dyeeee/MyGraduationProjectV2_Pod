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
            
            Section(header:Text("云同步设置")){
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
                
                VStack(alignment:.leading){
                    HStack{
                        Text("学习中的课本: \(UD_learningBook)")
                        Spacer()
                        Text("共\(UD_allWordNum)词")
                    }
                    HStack{
                        Text("学习中: \(UD_learningWordNum); ")
                        Text("已掌握: \(UD_knownWordNum); ")
                        Text("未学习: \(UD_unlearnedWordNum); ")
                    }
                    HStack{
                        Text("生词本单词数量: 261")
                    }
                    HStack{
                        Text("待办事件数量: 8")
                    }
                }.font(.subheadline)
                .foregroundColor(Color(.systemGray))
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
