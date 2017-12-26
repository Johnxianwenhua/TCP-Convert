//
//  XLTCPConvert.swift
//  XLXC_BB
//
//  Created by holdtime on 2017/12/12.
//  Copyright © 2017年 holdtime. All rights reserved.
//

import UIKit

class XLTCPConvert: NSObject {
    
    public class func BCD2DEC(_ data:[u_char])->u_long{
        
        var tmp:u_long = 0
        var dec:u_long = 0
        
        for i in 0..<data.count{
            
            let parm1 = (u_int(data[i])>>4)&0x0F
            let parm2 = u_int(data[i])&0x0F
            tmp = u_long(parm1 * 10 + parm2)
            let powParm = pow(100,data.count-1-i)
            dec += (tmp * u_long(truncating: NSDecimalNumber(decimal: powParm)))
        }
        return dec
    }
    
    public class func DEC2BCD(_ params:u_long,byteCount:Int)->[u_char]{
        
        var value = params
        var temp:u_long
        var data:[u_char] = Array(repeating: 0, count: byteCount)
        
        for i in (0..<byteCount).reversed(){
            temp = value%100
            let parm1 = (temp/10)<<4
            let parm2 = (temp%10)&0x0F
            data[i] = u_char(parm1 + parm2)
            value /= 100
        }
        return data
    }
    
    public class func LONG2DWORD(_ params:u_long, byteCount:Int)->[u_char]{
        
        var data:[u_char] = Array(repeating: 0, count: byteCount)
        
        for i in 0..<byteCount {
            
            let powParm = 4*i*2
            let temp = (params >> powParm) & 0xFF
            data[byteCount-i-1] = u_char(temp)
        }
        return data
    }
    
    public class func TIME2BCD(_ time:NSString)->[u_char]{
        
        let timeSta:TimeInterval = time.doubleValue/1000
        
        let date = Date(timeIntervalSince1970: timeSta)
        let calendar = Calendar.current
        
        let timeArray:[Calendar.Component] = [.year,.month,.day,.hour,.minute,.second]
        
        var data:[u_char] = []
        
        for component in timeArray {
            let temp = calendar.component(component, from: date)
            data.append(DEC2BCD(u_long(temp),byteCount:1).first!)
        }
        
        return data
    }

}
