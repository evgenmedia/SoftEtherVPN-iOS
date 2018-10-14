//
//  AppleOverride.h
//  SENE
//
//  Created by Shuyi Dong on 2018-10-04.
//

#ifndef AppleOverride_h
#define AppleOverride_h
#ifndef SWIFT_BRIDGE


#pragma weak Copy
#pragma weak Zero
#pragma weak InternalFree
#pragma weak InternalMalloc
#pragma weak InternalReAlloc


#pragma weak UniFormat

// Protocol
#pragma weak GenerateMachineUniqueHash

// Network
#pragma weak ConnectEx4
#pragma weak StartSSLEx
#pragma weak Send
#pragma weak Recv
#pragma weak Select
#pragma weak Disconnect
#pragma weak NewCancel
#pragma weak ReleaseCancel
#pragma weak Cancel

#include "AppleFunc.h"

#define fputs(msg,pipe) CNSLog((#pipe), msg) 
//#define PROBE_STR(str) CNSLog("PROBE_STR", str)

#endif
#endif /* AppleOverride_h */
