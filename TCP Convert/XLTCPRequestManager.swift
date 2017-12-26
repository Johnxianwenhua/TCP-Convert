//
//  XLTCPRequestManager.swift
//  XLXC_BB
//
//  Created by holdtime on 2017/11/28.
//  Copyright © 2017年 holdtime. All rights reserved.
//

import UIKit


struct XLTCPRequestProtocol {
    
    var currenInfo:XLTCPTheoryModel!
    
    //包头
    let HEADER:[u_char] = [0x00,0x00] //2 bit
    //命令字
    let MLZ:u_char = 0x11 //1bit
    //包尾
    let TAIL:u_char = 0xDD //1bit

    /** 需要计算 **/
    
    //数据长度 2bit
    var DATALENGTH:[u_char]{
        get{
            let count = STUDYCONTENT.count + TOKEN.count + 43
            
            var data:[u_char] = [0x00,0x00]
            
            if count >= 0xff {
                let hex1 = String(count/0xff,radix:16)
                let hex2 = String(count%0xff,radix:16)
                data[0] = UInt8(hex1,radix:16)!
                data[1] = UInt8(hex2,radix:16)!
            }else{
                let hex1 = String(count,radix:16)
                data[1] = UInt8(hex1,radix:16)!
            }
        
            return data
        }
    }

    /** 需要设置 **/

    var PHONE:[u_char] {
        get{
            return XLTCPConvert.DEC2BCD(u_long((currenInfo.PHONE as NSString).doubleValue), byteCount: 8)
        }
    }
    var IDE:[u_char] {
        get{
            let IDEArray = currenInfo.IDE.map {String(UnicodeScalar(String($0))!.value, radix: 16)}
            return IDEArray.map({UInt8($0,radix:16)!})
        }
    }
    var THEORYNUMBER:[u_char] {
        get{
            return XLTCPConvert.LONG2DWORD(u_long((currenInfo.THEORYNUMBER as NSString).doubleValue),byteCount: 4)
        }
    }
    var TIME:[u_char] {
        get{
            return XLTCPConvert.TIME2BCD(currenInfo.TIME as NSString)
        }
    }
    var TRAINCLASS:[u_char] {
        get{
            return XLTCPConvert.DEC2BCD(u_long((currenInfo.TRAINCLASS as NSString).doubleValue), byteCount: 5)
        }
    }
    var STUDYLENGTH:u_char {
        get{
            return UInt8(String(STUDYCONTENT.count,radix:16),radix:16)!
        }
    }
    var STUDYCONTENT:[u_char] {
        get{
            let gbkData = currenInfo.STUDYCONTENT.data(using: .utf8)!
            return [u_char](gbkData)
        }
    }
    var TOKEN:[u_char] {
        get{
            let tokenData = currenInfo.TOKEN.data(using: .utf8)
            let tokenDataBytes = [u_char](tokenData!)
            return tokenDataBytes
        }
    }
    
    var XOR:u_char {
        get{
            var r_xor:u_char = 0x00
            for x in XORBEFOR { r_xor ^= x }
            return u_char(r_xor)
        }
    }
    var XORBEFOR:[u_char] {
        get{
            var data:[u_char] = []
            data += HEADER
            data.append(MLZ)
            data += DATALENGTH
            data += PHONE
            data += IDE
            data += THEORYNUMBER
            data += TIME
            data += TRAINCLASS
            data.append(STUDYLENGTH)
            data += STUDYCONTENT
            data += TOKEN
            return data
        }
    }
    var XORAFTER:[u_char] {
        get{
            var data:[u_char] = []
            data += XORBEFOR
            data.append(XOR)
            data.append(TAIL)
            return data
        }
    }
    
    init(_ postInfo:XLTCPTheoryModel) {
        currenInfo = postInfo
    }
}


