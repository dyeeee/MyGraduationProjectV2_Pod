//
//  ToDoListView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/20.
//

import SwiftUI

struct ToDoListView: View {
    @StateObject var todoVM:ToDoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showCreate = true
    @State var showUndoneOnly = false
    @State var text = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                
                
                
                List {
                    Section(header:ToDoSearchHeader(toggle:$showCreate)){
                        VStack {
                            HStack {
                                TextField(showCreate ? "待办事项" : "查询", text: ($text))
                                    .onChange(of: text, perform: { text in
                                        if text == "" {
                                            todoVM.getAllToDoItems()
                                        }else if !showCreate && text != "" {
                                            todoVM.searchToDoItems(contain:text)
                                        }
                                    })
                                Button(action:{
                                    if showCreate && text != ""{
                                        todoVM.createToDoItem(content:text)
                                        text = ""
                                    }else if !showCreate && text != "" {
                                        todoVM.searchToDoItems(contain:text)
                                        text = ""
                                    }
                                },label:{
                                    Image(systemName: showCreate ? "plus.circle" : "magnifyingglass.circle")
                                        .font(.title)
                                }).onChange(of:showCreate,perform:{
                                    _ in
                                    text = ""
                                })
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(Color(.systemBlue))
                            }
                            //.padding(10)
                            //                        .background(Color(.systemGray6))
                            //                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            //                        .shadow(color: Color(.systemGray6), radius: 2)
                        }}
                    
                    Section(header:ToDoListHeader(toggle:$showUndoneOnly)){
                        ForEach(self.todoVM.ToDoItemList, id:\.self){
                            item in
                            if (!showUndoneOnly || item.done == false){
                                HStack{
                                    //Text(item.todoContent)
                                    Button(action:{
                                        item.done.toggle()
                                        todoVM.saveToPersistentStore()
                                    },label:{
                                        ZStack {
                                            
                                            Image(systemName:"checkmark.circle.fill")
                                                .opacity(item.done ? 1 : 0)
                                                .foregroundColor(Color(.systemGreen))
                                            Image(systemName:"circle")
                                                .foregroundColor(Color(.systemGray))
                                        }.font(.title3)
                                    }).buttonStyle(PlainButtonStyle())
                                    
                                    Text("\(item.todoContent ?? "noContent")")
                                        .foregroundColor(item.done ? Color(.systemGray3) : Color("systemBlack"))
                                        
                                        .strikethrough(item.done ? true:false, color: Color(.systemGray))
                                        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                                    
                                    Spacer()
                                    
                                    Text("\(item.createDate?.dateToString(format: "yyyy-MM-dd") ?? "noContent")")
                                        .foregroundColor(Color(.systemGray))
                                        
                                        .strikethrough(item.done ? true:false, color: Color(.systemGray))
                                        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                                    
                                }
                            }
                        }.onDelete(perform: self.todoVM.deleteToDoItem)
                        
                    }
                    
                    Image("thingsImg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .listRowBackground(Color(.systemGroupedBackground))

                    
                }
                .listStyle(InsetGroupedListStyle())
                
                
                

                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("待办事项")

            .toolbar { // <2>
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button(action: {
                            self.todoVM.deleteAllDoneItem()
                        }) {
                            Label("删除已完成", systemImage: "trash.fill")
                        }
                        Button(action: {
                            self.todoVM.deleteAllToDoItem()
                        }) {
                            Label("删除全部", systemImage: "trash.fill")
                        }
                        Button(action: {
                            self.todoVM.uploadToCloud()
                            
                            let tmpUSerVM = UserViewModel()
                            tmpUSerVM.vertifyLocalSession()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
                                tmpUSerVM.uploadUserInfoCheck()
                            }
                            
                        }) {
                            Label("上传本地数据", systemImage: "icloud.and.arrow.up")
                        }
                        Button(action: {
                            self.todoVM.downloadFromCloud()
                        }) {
                            Label("下载云端数据", systemImage: "icloud.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName:"xmark.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(todoVM: ToDoViewModel())
    }
}

struct ToDoSearchHeader: View {
    //var img:String = "scroll.fill"
    //var text:String = "近期学习状况"
    @Binding var toggle:Bool
    
    var body: some View {
        HStack {
            Text(self.toggle ? "新建待办事项" : "查询待办事项").offset(x: -5, y: 0)
            Spacer()
            //Text("show")
            
            HStack(spacing:5) {
                Text(self.toggle ? "切换至查询" : "切换至新建")
                Image(systemName: self.toggle ? "magnifyingglass.circle" :"plus.circle")
                
            }.padding(.trailing,5)
            .onTapGesture {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1){
                toggle.toggle()
                }
            }
        }
        .foregroundColor(Color("ListHeaderColor"))
        .padding([.leading],5)
    }
}


struct ToDoListHeader: View {
    @Binding var toggle:Bool
    
    var body: some View {
        HStack {
            Text("待办事项列表").offset(x: -5, y: 0)
            Spacer()
            //Text("show")
            
            HStack(spacing:5) {
                Text(self.toggle ? "显示已完成" : "隐藏已完成")
                Image(systemName: self.toggle ? "text.badge.checkmark" :"square.fill.text.grid.1x2")
                
            }.padding(.trailing,5)
            .onTapGesture {
                withAnimation{
                    toggle.toggle()}
            }
        }
        .foregroundColor(Color("ListHeaderColor"))
        .padding([.leading],5)
    }
}
