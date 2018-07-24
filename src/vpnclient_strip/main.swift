//
//  main.swift
//  vpnclient_strip
//
//  Created by System Administrator on 2018/7/24.
//

import Foundation

print("Hello, World!")

var exec = [strdup("vpnclient")]

MayaquaMinimalMode();
InitMayaqua(0, 1, 1, &exec);
InitCedar();

CtStartClient()
var c = CtGetClient()
c?.pointee.Config.AllowRemoteConfig = 1

while (wait(nil) != 0){
    sleep(10000);
    //print("Wait!")
}
print("Done!")
