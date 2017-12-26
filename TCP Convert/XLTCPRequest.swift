//
//  XLTCPRequest.swift
//  XLXC_BB
//
//  Created by holdtime on 2017/11/28.
//  Copyright © 2017年 holdtime. All rights reserved.
//

import UIKit

//host address
private let kAsyncSocketHost:String = ""

//host port
private let kAsyncSocketPort:UInt16 = 1900

//host reconnect count
private let kAsyncSocketReconnectTime:UInt16 = 5
private let kAsyncSocketWriteTimeout:TimeInterval = TimeInterval(-1)
private let kAsyncSocketReadTimeout:TimeInterval = TimeInterval(-1)
private let kAsyncSocketReadMaxLength:UInt = 1024

private let kAsyncSocketReceiveTag:Int = 10001


public enum XLTCPRequestType {
    
    case disconnect  //服务器连接失败
    case reconnect   //重连
    case connect     //链接成功
    case timeout     //链接超时
    case unreachable //无网络链接
    case none        //链接错误
    
    case error_0      //数据溢出
    case error_1      //数据处理异常，请联系小鹿管家
    case error_2      //账号已在其他设备登录
    case error_3      //已经太晚了，您该休息一会儿
    case error_4      //登录超时，请重新进入理论学习
    case error_5      //数据传输异常，请联系小鹿管家

}

class XLTCPRequest: NSObject {

    var tSockerConnectComplete:((_ error:XLTCPRequestType)->())? = nil
    var tSockerDisConnectComplete:(()->())? = nil

    public static let shared = XLTCPRequest()
    
    private override init (){
        super.init()
    }
    
    var tSocket:GCDAsyncSocket? = nil
    
    var tSockerState:Bool = false
    
    var tSockerReConnectTime:UInt16 = 0
    var tSockerReConnectTimer:Timer!

    public func tConnectToServer(_ connectComplete:((_ error:XLTCPRequestType)->())?){
        
        tSockerConnectComplete = nil;

        guard tSocket == nil else{return}
        
        tSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        tReConnectToServer()
    
        tSockerConnectComplete = { err in
            if connectComplete != nil {
                connectComplete!(err)
            }
        }  
    }
    
    @objc public func tReConnectToServer(){
        do {
            try tSocket?.connect(toHost: kAsyncSocketHost, onPort: kAsyncSocketPort)
        }catch{
            if tSockerConnectComplete != nil {
                tSockerConnectComplete!(.disconnect)
            }
        }
    }
    
    public func tWriteData(){
        
//        let TCP = XLTCPRequestProtocol(model)
        
//        if let socket = tSocket {
//            socket.write(Data(bytes:TCP.XORAFTER), withTimeout: kAsyncSocketWriteTimeout, tag: kAsyncSocketReceiveTag)
//            var model = theory
//            model["code"] = "\(TCP.XOR)"
//            XLUserDefaultManager.updateTheoryInfo(model)
//        }
        
    }

    public func tDisConnectToServer(){
        
        guard tSocket != nil else{
           return
        }
        
        tSocket?.delegate = nil
        
        tSockerState = false
        
        tSockerReConnectTime = 0
        
        if tSockerReConnectTimer != nil {
            tSockerReConnectTimer.invalidate()
            tSockerReConnectTimer = nil
        }
        
        tSocket?.disconnect()
    }
    
}

extension XLTCPRequest:GCDAsyncSocketDelegate {
    
//    connect
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("服务器连接成功")
        tSockerReConnectTime = 0
        tSockerState = true
        
        sock.readData(withTimeout: kAsyncSocketReadTimeout, tag: kAsyncSocketReceiveTag)

        if tSockerConnectComplete != nil {
            tSockerConnectComplete!(.connect)
        }
    }
//    disconnect
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        tSockerState = false

        if tSockerConnectComplete != nil {
            tSockerConnectComplete!(.reconnect)
        }
        
        if tSockerReConnectTimer != nil {
            tSockerReConnectTimer.invalidate()
            tSockerReConnectTimer = nil
        }
        
        if let error:NSError = err as NSError? {
            // Try to reconnect to sever

            guard tSockerReConnectTime >= 0 && tSockerReConnectTime <= kAsyncSocketReconnectTime else{
                tSockerReConnectTime = 0
                
                if tSockerConnectComplete != nil {
                    if error.code == 51 {
                        tSockerConnectComplete!(.unreachable)
                    }else{
                        tSockerConnectComplete!(.timeout)
                    }
                }
                return
            }
            
            let time = pow(2, Double(tSockerReConnectTime))
            
            tSockerReConnectTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(tReConnectToServer), userInfo: nil, repeats: false)
            tSockerReConnectTimer.fire()
            
            tSockerReConnectTime += 1
            
        }else{
            tSockerReConnectTime = 0
            
            if tSockerConnectComplete != nil {
                tSockerConnectComplete!(.none)
            }
        }
        
    }
//    write
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        sock.readData(withTimeout: kAsyncSocketReadTimeout, tag: kAsyncSocketReceiveTag)

    }
//    read
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        var revice = [u_char](data)
        
        if data.count == 11 {
            
            switch (revice[8]) {
            case 0:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_0)
                }
            case 1:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_1)
                }
            case 2:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_2)
                }
            case 3:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_3)
                }
            case 4:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_4)
                }
            default:
                if tSockerConnectComplete != nil {
                    tSockerConnectComplete!(.error_5)
                }
            }
            
        }
    }

}
