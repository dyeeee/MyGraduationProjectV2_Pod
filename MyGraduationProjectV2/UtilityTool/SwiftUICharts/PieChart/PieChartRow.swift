//
//  PieChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartRow : View {
    var data: [Double]
    var backgroundColor: Color
    var accentColor: Color
    var accentColorList: [Color] = [Color("WordLevelsColor"),Color("CalendarOnColor"),Color("loginColor")]
    // 从最右侧逆时针
    
    var slices: [PieSlice] {
        var tempSlices:[PieSlice] = []
        var lastEndDeg:Double = 0
        
        var tmpData: [Double] = []
        
        for i in 0..<data.count {
            if data[i] == 0 {
                tmpData.append(0.1)
            }else{
                tmpData.append(data[i])
            }
        }
        
        let maxValue = tmpData.reduce(0, +)
        
        for slice in tmpData {
            let normalized:Double = Double(slice)/Double(maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice, normalizedValue: normalized))
        }
        return tempSlices
    }
    
    
    
    @Binding var showValue: Bool
    @Binding var currentValue: Double
    @State private var currentTouchedIndex = -1 {
        didSet {
            if oldValue != currentTouchedIndex {
                showValue = currentTouchedIndex != -1
                currentValue = showValue ? slices[currentTouchedIndex].value : 0
            }
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack{
                ForEach(0..<self.slices.count){ i in
                    PieChartCell(rect: geometry.frame(in: .local), startDeg: self.slices[i].startDeg, endDeg: self.slices[i].endDeg, index: i, backgroundColor: self.backgroundColor,accentColor: i < self.accentColorList.count ? self.accentColorList[i] : self.accentColor,data:self.data,legendIndex:i)
                        .scaleEffect(self.currentTouchedIndex == i ? 1.1 : 1)
                        .animation(Animation.spring(blendDuration:3))
                }
            }
            .gesture(DragGesture()
                        .onChanged({ value in
                            let rect = geometry.frame(in: .local)
                            let isTouchInPie = isPointInCircle(point: value.location, circleRect: rect)
                            if isTouchInPie {
                                let touchDegree = degree(for: value.location, inCircleRect: rect)
                                self.currentTouchedIndex = self.slices.firstIndex(where: { $0.startDeg < touchDegree && $0.endDeg > touchDegree }) ?? -1
                            } else {
                                self.currentTouchedIndex = -1
                            }
                        })
                        .onEnded({ value in
                            self.currentTouchedIndex = -1
                            //print("PieChartRow的数据: \(data)")
                        })
            )
//            .onTapGesture(perform: {
//                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
//            })
        }
    }
}

#if DEBUG
struct PieChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
//            PieChartRow(data:[8,23,54,32,12,37,7,23,43], backgroundColor: Color(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0), accentColor: Color(red: 225.0/255.0, green: 97.0/255.0, blue: 76.0/255.0), showValue: Binding.constant(false), currentValue: Binding.constant(0))
//                .frame(width: 100, height: 100)
            PieChartRow(data:[100,100,200], backgroundColor: Color(red: 252.0/255.0, green: 236.0/255.0, blue: 234.0/255.0), accentColor: Color(red: 0/255.0, green: 97.0/255.0, blue: 76.0/255.0), showValue: Binding.constant(false), currentValue: Binding.constant(0))
                .frame(width: 200, height: 200)
        }
    }
}
#endif
