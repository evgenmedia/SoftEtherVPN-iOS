//
//  AppleOverride.h
//  SoftEtherNE
//
//  Created by xy on 2018/8/1.
//

#ifndef AppleOverride_h
#define AppleOverride_h
#ifndef SWIFT_BRIDGE


#pragma weak Copy
#pragma weak Zero
#pragma weak Free
#pragma weak ZeroMalloc
#pragma weak Malloc


#pragma weak UniFormat


// Network
#pragma weak ConnectEx4
#pragma weak StartSSLEx
#pragma weak Send
#pragma weak Recv
#endif
#endif /* AppleOverride_h */
