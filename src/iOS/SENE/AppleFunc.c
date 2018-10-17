//
//  AppleFunc.c
//  Cedar Strip
//
//  Created by System Administrator on 2018/7/24.
//

#include "CedarPch.h"
UINT StrCpy(char *dst, UINT size, char *src);

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

void PrintHex(void* data, UINT size){
    char buffer[size*2];
    char* ptr = data;
    for (int i=0; i<size; i++) {
        sprintf(&buffer[i], "%02x",ptr[i]);
    }
    Debug("Packet: %s",buffer);
}

// Virtual
void GenMacAddress(UCHAR *mac)
{
    UCHAR rand_data[32];
    UINT64 now;
    BUF *b;
    UCHAR hash[SHA1_SIZE];
    // Validate arguments
    if (mac == NULL)
    {
        return;
    }
    
    // Get the current time
    now = SystemTime64();
    
    // Generate a random number
    Rand(rand_data, sizeof(rand_data));
    
    // Add to the buffer
    b = NewBuf();
    WriteBuf(b, &now, sizeof(now));
    WriteBuf(b, rand_data, sizeof(rand_data));
    
    // Hash
    Hash(hash, b->Buf, b->Size, true);
    
    // Generate a MAC address
    mac[0] = 0x5E;
    mac[1] = hash[0];
    mac[2] = hash[1];
    mac[3] = hash[2];
    mac[4] = hash[3];
    mac[5] = hash[4];
    
    FreeBuf(b);
}
