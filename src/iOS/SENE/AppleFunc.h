//
//  AppleFunc.h
//  SEVPN
//
//  Created by Shuyi Dong on 2018-10-07.
//

#ifndef AppleFunc_h
#define AppleFunc_h
#include "CedarType.h"
// AppleFunc

void CNSLog(char* pipe, char* msg);
void SCC_SHA1(const void *data, unsigned int len, unsigned char *md);
void SCC_MD5(const void *data, unsigned int len, unsigned char *md);
void InitVars();
void ReceiveIOS(CONNECTION *c, CANCEL *c1, CANCEL *c2);


#endif /* AppleFunc_h */
