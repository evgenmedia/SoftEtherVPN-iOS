//
//  AppleFunc.c
//  Cedar Strip
//
//  Created by System Administrator on 2018/7/24.
//

#include "CedarPch.h"


// Sam.c
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


// iOS
void AppleStatusPrinter(SESSION *s, wchar_t *status)
{
    UniPrint(L"Status: %s\n", status);
}

// Table.c
// Get an error string in Unicode
wchar_t *GetUniErrorStr(UINT err)
{
    wchar_t *ret;
    char name[MAX_SIZE];
    Format(name, sizeof(name), "ERR_%u", err);
    
    ret = GetTableUniStr(name);
    if (UniStrLen(ret) != 0)
    {
        return ret;
    }
    else
    {
        return _UU("ERR_UNKNOWN");
    }
}

// Encrypt.c
void Hash(void *dst, void *src, UINT size,bool sha){
    if (dst == NULL || (src == NULL && size != 0))
    {
        return;
    }
    
    if (sha == false)
    {
        // MD5 hash
        SCC_MD5(src,size,dst);
    }
    else
    {
        // SHA hash
        SCC_SHA1(src,size,dst);
    }
    
}

void HashSha1(void *dst, void *src, UINT size)
{ Hash(dst, src, size, true); }

THREAD_PROC* getThreadProc(void* func){
    return (THREAD_PROC*)func;
}
