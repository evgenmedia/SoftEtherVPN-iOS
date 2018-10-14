//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#define SWIFT_BRIDGE

#import <Mayaqua/Mayaqua.h>
#import <Cedar/Cedar.h>
#import <CommonCrypto/CommonCrypto.h>

#import "AppleFunc.h"


// Swift export
void AppleStatusPrinter(SESSION *s, wchar_t *status);
THREAD_PROC* getThreadProc(void* func);
//UINT SPAInit(SESSION *s);
//CANCEL *SPAGetCancel(SESSION *s);
//UINT SPAGetNextPacket(SESSION *s, void **data);
//UINT SPAPutPacket(SESSION *s, void *data, UINT size);
//void SPAFree(SESSION *s);
