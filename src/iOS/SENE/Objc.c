//
//  Objc.c
//  SENE
//
//  Created by Shuyi Dong on 2018-10-07.
//

#include <stdio.h>

#import <CommonCrypto/CommonCrypto.h>


void SCC_SHA1(const void *data, unsigned int len, unsigned char *md){
    CC_SHA1(data,len,md);
}

void SCC_MD5(const void *data, unsigned int len, unsigned char *md){
    CC_MD5(data,len,md);
}

