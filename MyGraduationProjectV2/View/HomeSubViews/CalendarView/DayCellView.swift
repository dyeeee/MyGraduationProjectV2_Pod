//
//  CellView.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/13/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import SwiftUI


struct DayCellView: View {
    @ObservedObject var day: Day
    @State var done:Bool = false
    @Binding var screenWidth:CGFloat
    
    var angleList:[Double]{
        var list:[Double] = []
        for i in stride(from: -60.0, to: 60.0, by: 5) {
            list.append(i)
        }
        return list
    }
    
    var offsetList:[CGFloat] = [0,1,2,3]
    
    var animate = false
    @State var doneShow = false
    
    var body: some View {
        ZStack {
            if self.done{
//                Text("DONE")
//                    .font(.headline)
//                Image("StudyDone3")
                Image(systemName: "checkmark")
                    .font(.largeTitle)
//                    .renderingMode(.template)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .scaleEffect(1.5)
                    .opacity(doneShow ? 1:0)
                    .foregroundColor(doneShow ? Color(.systemGreen):Color(.clear))
                //                .rotationEffect(.degrees(angleList.randomElement()!))
                //                .offset(x: offsetList.randomElement()!, y: offsetList.randomElement()!)
                    .onAppear(perform: {
                        if animate{
                            withAnimation(Animation.easeIn(duration: 1.5)){
                                doneShow = true
                            }
                        }else{}
                    })
                    .onDisappear(perform: {
                        if animate{
                                doneShow = false
                        }else{}
                    })
            }
            Text(day.dayName)
                .padding(1)
            

        }
//        .frame(width: UIScreen.main.bounds.width/7-20, height: 22)
        .frame(width: (screenWidth)/CGFloat((7))-15, height: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 5.0)
                .stroke())
        .foregroundColor(day.textColor)
        .background(day.backgroundColor)
        //.foregroundColor(Color(.systemGray))
        
        //            .onTapGesture {
        //                if self.day.disabled == false && self.day.selectableDays {
        //                    self.day.isSelected.toggle()
        //                }
        //
        //            }
    }
}


struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        DayCellView(day: Day(date: Date()),done: true, screenWidth: .constant(1125),animate:true)
    }
}
