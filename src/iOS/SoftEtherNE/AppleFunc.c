//
//  AppleFunc.c
//  Cedar Strip
//
//  Created by System Administrator on 2018/7/24.
//

#include "CedarPch.h"

void SecurePassword(void *secure_password, void *password, void *random)
{
    BUF *b;
    // Validate arguments
    if (secure_password == NULL || password == NULL || random == NULL)
    {
        return;
    }
    
    b = NewBuf();
    WriteBuf(b, password, SHA1_SIZE);
    WriteBuf(b, random, SHA1_SIZE);
    Hash(secure_password, b->Buf, b->Size, true);
    
    FreeBuf(b);
}
