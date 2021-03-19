//
//  GridStack.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/11/19.
//  Copyright © 2019 KesDev. All rights reserved.
/*  Credit: Paul Hudson, https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid
 */
import SwiftUI

//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
struct GridStack<Content: View>: View {

    let rows: Int
    let cols: Int
    let content: (Int, Int) -> Content
    
    //@State var orientation = UIDevice.current.orientation
    @State var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {

        VStack(spacing:5) {
            ForEach(0..<self.rows) { row in
                HStack(spacing:5) {
                    ForEach(0..<self.cols) { col in
                        //Spacer()
                        //GeometryReader { geometry in
                        self.content(row, col)
                            //.frame(width: geometry.size.width * 0.5)
//                            .frame(width: (screenWidth-80)/CGFloat((cols)))

//                        .frame(width: (screenWidth-80)/CGFloat((cols)), height: 22)
                        
                        //}
                    }
                }

            }
        }.onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 5){
                self.screenWidth = UIScreen.main.bounds.width
            }
          }
    }


    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.cols = columns
        self.content = content
    }

}

//@available(OSX 10.15, *)
//@available(iOS 13.0, *)
struct GridStack_Previews: PreviewProvider {

    static var previews: some View {
        List{
            HStack {
                Spacer()
                GridStack(rows: 5, columns: 7) { row, col in
                Text("1")
                    .frame(width: (UIScreen.main.bounds.width)/CGFloat((7))-15, height: 22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5.0)
                            .stroke())

                }
                Spacer()
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
