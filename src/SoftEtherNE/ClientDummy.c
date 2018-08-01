//
//  ClientDummy.c
//  Cedar Strip
//
//  Created by System Administrator on 2018/7/23.
//

#define SWIFT_BRIDGE

#include "CedarPch.h"

void* unimplemented(){ return 0x1; }
void* ignored(){ return 0x1; }


bool g_debug;
bool g_little_endian = true;
UINT64 kernel_status[NUM_KERNEL_STATUS];        // Kernel state
UINT64 kernel_status_max[NUM_KERNEL_STATUS];    // Kernel state (maximum value)
BOOL kernel_status_inited = false;
LOCK *openssl_lock = NULL;



//size_t iconv (iconv_t cd, char* * __restrict inbuf, size_t * __restrict inbytesleft, char* * __restrict outbuf, size_t * __restrict outbytesleft)
//{ return unimplemented(); }
//iconv_t iconv_open (const char* tocode, const char* fromcode)
//{ return unimplemented(); }
//int iconv_close (iconv_t cd)
//{ return unimplemented(); }


void HashPassword(void *dst, char *username, char *password)
{ unimplemented(); }
void AcUnlock(HUB *h)
{ unimplemented(); }
USER *AcGetUser(HUB *h, char *name)
{ return unimplemented(); }
void ReleaseUser(USER *u)
{ unimplemented(); }
void AcLock(HUB *h)
{ unimplemented(); }
void OutRpcNodeInfo(PACK *p, NODE_INFO *t)
{ unimplemented(); }
void OutRpcWinVer(PACK *p, RPC_WINVER *t)
{ unimplemented(); }
UINT GetEthDeviceHash()
{ return unimplemented(); }
void InitLocalBridgeList(CEDAR *c)
{ unimplemented(); }
void FreeLocalBridgeList(CEDAR *c)
{ unimplemented(); }
CANCEL *EthGetCancel(ETH *e)
{ return unimplemented(); }
bool EthIsChangeMtuSupported(ETH *e)
{ return unimplemented(); }
void EthPutPackets(ETH *e, UINT num, void **datas, UINT *sizes)
{ unimplemented(); }
UINT EthGetMtu(ETH *e)
{ return unimplemented(); }
bool EthSetMtu(ETH *e, UINT mtu)
{ return unimplemented(); }
void CloseEth(ETH *e)
{ unimplemented(); }
ETH *OpenEth(char *name, bool local, bool tapmode, char *tapaddr)
{ return unimplemented(); }
UINT EthGetPacket(ETH *e, void **data)
{ return unimplemented(); }
void CiIncrementNumActiveSessions()
{ unimplemented(); }
void CiDecrementNumActiveSessions()
{ unimplemented(); }
void CiNotify(CLIENT *c)
{ unimplemented(); }
SOCK *CncMsgDlg(UI_MSG_DLG *dlg)
{ return unimplemented(); }
SOCK *CncNicInfo(UI_NICINFO *info)
{ return unimplemented(); }
void CiSaveConfigurationFile(CLIENT *c)
{ unimplemented(); }
void CncNicInfoFree(SOCK *s)
{ unimplemented(); }
void CndMsgDlgFree(SOCK *s)
{ unimplemented(); }
bool ParseHostPort(char *src, char **host, UINT *port, UINT default_port)
{ return unimplemented(); }
void AddSession(HUB *h, SESSION *s)
{ unimplemented(); }
void AddTrafficDiff(HUB *h, char *name, UINT type, TRAFFIC *traffic)
{ unimplemented(); }
HUB *GetHub(CEDAR *cedar, char *name)
{ return unimplemented(); }
UINT GetHubAdminOption(HUB *h, char *name)
{ return unimplemented(); }
bool IsHub(CEDAR *cedar, char *name)
{ return unimplemented(); }
void DelSession(HUB *h, SESSION *s)
{ unimplemented(); }
void StopHub(HUB *h)
{ unimplemented(); }
void ReleaseHub(HUB *h)
{ unimplemented(); }
int CompareHub(void *p1, void *p2)
{ return unimplemented(); }
void UnlockHubList(CEDAR *cedar)
{ unimplemented(); }
void IncrementHubTraffic(HUB *h)
{ unimplemented(); }
void LockHubList(CEDAR *cedar)
{ unimplemented(); }
PACKET_ADAPTER *GetHubPacketAdapter()
{ return unimplemented(); }
int CompareCert(void *p1, void *p2)
{ return unimplemented(); }
bool OvsGetNoOpenVpnTcp()
{ return unimplemented(); }
bool OvsPerformTcpServer(CEDAR *cedar, SOCK *sock)
{ return unimplemented(); }
bool OvsCheckTcpRecvBufIfOpenVPNProtocol(UCHAR *buf, UINT size)
{ return unimplemented(); }
bool GetNoSstp()
{ return unimplemented(); }
bool AcceptSstp(CONNECTION *c)
{ return unimplemented(); }
void GenerateNtPasswordHash(UCHAR *dst, char *password)
{ unimplemented(); }
void L3PutPacket(L3IF *f, void *data, UINT size)
{ unimplemented(); }
void InitCedarLayer3(CEDAR *c)
{ unimplemented(); }
void FreeCedarLayer3(CEDAR *c)
{ unimplemented(); }
UINT L3GetNextPacket(L3IF *f, void **data)
{ return unimplemented(); }
void L3FreeAllSw(CEDAR *c)
{ unimplemented(); }
void StopListener(LISTENER *r)
{ unimplemented(); }
void AddUDPEntry(CEDAR *cedar, SESSION *session)
{ unimplemented(); }
void DelUDPEntry(CEDAR *cedar, SESSION *session)
{ unimplemented(); }
int CompareListener(void *p1, void *p2)
{ return unimplemented(); }
int CompareUDPEntry(void *p1, void *p2)
{ return unimplemented(); }
void ReleaseListener(LISTENER *r)
{ unimplemented(); }
void CLog(CLIENT *c, char *name, ...)
{ unimplemented(); }
void SLog(CEDAR *c, char *name, ...)
{ unimplemented(); }
void HLog(HUB *h, char *name, ...)
{ unimplemented(); }
LOG *NewLog(char *dir, char *prefix, UINT switch_type)
{ return unimplemented(); }
void FreeLog(LOG *g)
{ unimplemented(); }
X *GetIssuerFromList(LIST *cert_list, X *cert)
{ return unimplemented(); }
UINT GetGlobalServerFlag(UINT index)
{ return unimplemented(); }
void GetServerProductName(SERVER *s, char *name, UINT size)
{ unimplemented(); }
bool IsAdminPackSupportedServerProduct(char *name)
{ return unimplemented(); }
bool GetServerCapsBool(SERVER *s, char *name)
{ return unimplemented(); }
void FreeUdpAccel(UDP_ACCEL *a)
{ unimplemented(); }
void UdpAccelPoll(UDP_ACCEL *a)
{ unimplemented(); }
void UdpAccelSendBlock(UDP_ACCEL *a, BLOCK *b)
{ unimplemented(); }
UDP_ACCEL *NewUdpAccel(CEDAR *cedar, IP *ip, bool client_mode, bool random_port, bool no_nat_t)
{ return unimplemented(); }
bool VirtualPutPacket(VH *v, void *data, UINT size)
{ return unimplemented(); }
UINT VirtualGetNextPacket(VH *v, void **data)
{ return unimplemented(); }
void NatSetHubOption(VH *v, HUB_OPTION *o)
{ unimplemented(); }
bool WuFreeWebUI(WEBUI *wu)
{ return unimplemented(); }
WEBUI *WuNewWebUI(CEDAR *cedar)
{ return unimplemented(); }
WU_WEBPAGE *WuGetPage(char *target, WEBUI *wu)
{ return unimplemented(); }
void WuFreeWebPage(WU_WEBPAGE *page)
{ unimplemented(); }
bool ParseUrl(URL_DATA *data, char *str, bool is_post, char *referrer)
{ return unimplemented(); }
BUF *HttpRequestEx(URL_DATA *data, INTERNET_SETTING *setting,
                   UINT timeout_connect, UINT timeout_comm,
                   UINT *error_code, bool check_ssl_trust, char *post_data,
                   WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash,
                   bool *cancel, UINT max_recv_size)
{ return unimplemented(); }
SOCK *WpcSockConnect2(char *hostname, UINT port, INTERNET_SETTING *t, UINT *error_code, UINT timeout)
{ return unimplemented(); }
BUF *HttpRequestEx3(URL_DATA *data, INTERNET_SETTING *setting,
                    UINT timeout_connect, UINT timeout_comm,
                    UINT *error_code, bool check_ssl_trust, char *post_data,
                    WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash, UINT num_hashes,
                    bool *cancel, UINT max_recv_size, char *header_name, char *header_value)
{ return unimplemented(); }
bool FileCopyW(wchar_t *src, wchar_t *dst)
{ return unimplemented(); }
char *CfgReadNextLine(BUF *b)
{ return unimplemented(); }
CRYPT *NewCrypt(void *key, UINT size)
{ return unimplemented(); }
bool IsBase64(BUF *b)
{ return unimplemented(); }
USHORT Rand16()
{ return unimplemented(); }
void HMacSha1(void *dst, void *key, UINT key_size, void *data, UINT data_size)
{ unimplemented(); }
void FreeCrypt(CRYPT *c)
{ unimplemented(); }
void GetAllNameFromName(wchar_t *str, UINT size, NAME *name)
{ unimplemented(); }
bool CheckXDateNow(X *x)
{ return unimplemented(); }
bool CompareName(NAME *n1, NAME *n2)
{ return unimplemented(); }
K *GetKFromX(X *x)
{ return unimplemented(); }
void FreeK(K *k)
{ unimplemented(); }
bool RsaSignEx(void *dst, void *src, UINT size, K *k, UINT bits)
{ return unimplemented(); }
BUF *KToBuf(K *k, bool text, char *password)
{ return unimplemented(); }
K *CloneK(K *k)
{ return unimplemented(); }
X *BufToX(BUF *b, bool text)
{ return unimplemented(); }
K *BufToK(BUF *b, bool private_key, bool text, char *password)
{ return unimplemented(); }
void GetXDigest(X *x, UCHAR *buf, bool sha1)
{ unimplemented(); }
UINT64 Rand64()
{ return unimplemented(); }
X *FileToXW(wchar_t *filename)
{ return unimplemented(); }
bool CompareX(X *x1, X *x2)
{ return unimplemented(); }
void DhFree(DH_CTX *dh)
{ unimplemented(); }
int GetSslClientCertIndex()
{ return unimplemented(); }
void Hash(void *dst, void *src, UINT size, bool sha)
{ unimplemented(); }
bool CheckXEx(X *x, X *x_issuer, bool check_name, bool check_date)
{ return unimplemented(); }
X *X509ToX(X509 *x509)
{ return unimplemented(); }
bool CheckSignature(X *x, K *k)
{ return unimplemented(); }
void HashSha1(void *dst, void *src, UINT size)
{ unimplemented(); }
UINT HashPtrToUINT(void *p)
{ return unimplemented(); }
bool CheckXandK(X *x, K *k)
{ return unimplemented(); }
UCHAR Rand8()
{ return unimplemented(); }
void FreeX(X *x)
{ unimplemented(); }
X *CloneX(X *x)
{ return unimplemented(); }
BUF *XToBuf(X *x, bool text)
{ return unimplemented(); }
void Encrypt(CRYPT *c, void *dst, void *src, UINT size)
{ unimplemented(); }
bool FileRead(IO *o, void *buf, UINT size)
{ return unimplemented(); }
bool FileDeleteW(wchar_t *name)
{ return unimplemented(); }
IO *FileOpenExW(wchar_t *name, bool write_mode, bool read_lock)
{ return unimplemented(); }
IO *FileCreateW(wchar_t *name)
{ return unimplemented(); }
bool MakeDir(char *name)
{ return unimplemented(); }
IO *FileOpen(char *name, bool write_mode)
{ return unimplemented(); }
void CombinePathW(wchar_t *dst, UINT size, wchar_t *dirname, wchar_t *filename)
{ unimplemented(); }
void GetExeDirW(wchar_t *name, UINT size)
{ unimplemented(); }
void ConvertSafeFileName(char *dst, UINT size, char *src)
{ unimplemented(); }
UINT FileSize(IO *o)
{ return unimplemented(); }
IO *FileCreate(char *name)
{ return unimplemented(); }
bool FileWrite(IO *o, void *buf, UINT size)
{ return unimplemented(); }
void FileFlush(IO *o)
{ unimplemented(); }
bool IsFileExistsW(wchar_t *name)
{ return unimplemented(); }
DIRLIST *EnumDirW(wchar_t *dirname)
{ return unimplemented(); }
void GetExeNameW(wchar_t *name, UINT size)
{ unimplemented(); }
void FreeDir(DIRLIST *d)
{ unimplemented(); }
void FileClose(IO *o)
{ unimplemented(); }
bool MakeDirExW(wchar_t *name)
{ return unimplemented(); }
void ReleaseThread(THREAD *t)
{ unimplemented(); }
bool GetEnv(char *name, char *data, UINT size)
{ return unimplemented(); }
void AbortExitEx(char *msg)
{ unimplemented(); }
void YieldCpu()
{ unimplemented(); }
UINT64 LocalTime64()
{ return unimplemented(); }
void LocalTime(SYSTEMTIME *st)
{ unimplemented(); }
void GetDateTimeStrMilli64(char *str, UINT size, UINT64 sec64)
{ unimplemented(); }
UINT64 SystemTime64()
{ return unimplemented(); }
void NoticeThreadInit(THREAD *t)
{ unimplemented(); }
UINT DoNothing()
{ return unimplemented(); }
void SleepThread(UINT time)
{ unimplemented(); }
bool WaitThread(THREAD *t, UINT timeout)
{ return unimplemented(); }
UINT64 SystemToUINT64(SYSTEMTIME *st)
{ return unimplemented(); }
void UINT64ToSystem(SYSTEMTIME *st, UINT64 sec64)
{ unimplemented(); }
void WaitThreadInit(THREAD *t)
{ unimplemented(); }
THREAD *NewThreadNamed(THREAD_PROC *thread_proc, void *param, char *name)
{ return unimplemented(); }
void UnlockKernelStatus(UINT id)
{ unimplemented(); }
OS_INFO *GetOsInfo()
{ return unimplemented(); }
void LockKernelStatus(UINT id)
{ unimplemented(); }
void Alert(char *msg, char *caption)
{ unimplemented(); }
UINT Release(REF *ref)
{ return unimplemented(); }
REF *NewRef()
{ return unimplemented(); }
EVENT *NewEvent()
{ return unimplemented(); }
bool WaitEx(EVENT *e, UINT timeout, volatile bool *cancel)
{ return unimplemented(); }
void DeleteLock(LOCK *lock)
{ unimplemented(); }
void UnlockInner(LOCK *lock)
{ unimplemented(); }
LOCK *NewLock()
{ return unimplemented(); }
bool Wait(EVENT *e, UINT timeout)
{ return unimplemented(); }
LOCK *NewLockMain()
{ return unimplemented(); }
void ReleaseEvent(EVENT *e)
{ unimplemented(); }
void Set(EVENT *e)
{ unimplemented(); }
bool LockInner(LOCK *lock)
{ return unimplemented(); }
UINT AddRef(REF *ref)
{ return unimplemented(); }
char* OSGetProductId()
{ return unimplemented(); }
void OSMemoryFree(void *addr)
{ unimplemented(); }
void *OSMemoryAlloc(UINT size)
{ return unimplemented(); }
void OSSleep(UINT time)
{ unimplemented(); }
void *OSMemoryReAlloc(void *addr, UINT size)
{ return unimplemented(); }
bool WriteSecCert(SECURE *sec, bool private_obj, char *name, X *x)
{ return unimplemented(); }
bool WriteSecKey(SECURE *sec, bool private_obj, char *name, K *k)
{ return unimplemented(); }
bool LoginSec(SECURE *sec, char *pin)
{ return unimplemented(); }
bool DeleteSecCert(SECURE *sec, char *name)
{ return unimplemented(); }
void LogoutSec(SECURE *sec)
{ unimplemented(); }
void CloseSec(SECURE *sec)
{ unimplemented(); }
void CloseSecSession(SECURE *sec)
{ unimplemented(); }
bool OpenSecSession(SECURE *sec, UINT slot_number)
{ return unimplemented(); }
bool SignSec(SECURE *sec, char *name, void *dst, void *src, UINT size)
{ return unimplemented(); }
void FreeEnumSecObject(LIST *o)
{ unimplemented(); }
LIST *EnumSecObject(SECURE *sec)
{ return unimplemented(); }
bool DeleteSecKey(SECURE *sec, char *name)
{ return unimplemented(); }
SECURE *OpenSec(UINT id)
{ return unimplemented(); }
X *ReadSecCert(SECURE *sec, char *name)
{ return unimplemented(); }
wchar_t *GetUniErrorStr(UINT err)
{ return unimplemented(); }
wchar_t *GetTableUniStr(char *name){
    unimplemented();
    return L"";
}
char *GetTableStr(char *name)
{ return unimplemented(); }
UINT GetTableInt(char *name)
{ return unimplemented(); }
void FreePacket(PKT *p)
{ unimplemented(); }
bool IsDhcpPacketForSpecificMac(UCHAR *data, UINT size, UCHAR *mac_address)
{ return unimplemented(); }
UINT GetIpHeaderSize(UCHAR *src, UINT src_size)
{ return unimplemented(); }
USHORT IpChecksum(void *buf, UINT size)
{ return unimplemented(); }
UINT64 TickHighres64()
{ return unimplemented(); }
UINT64 Tick64()
{ return unimplemented(); }
void TrackNewObj(UINT64 addr, char *name, UINT size)
{ unimplemented(); }
void TrackDeleteObj(UINT64 addr)
{ unimplemented(); }
void TrackChangeObjSize(UINT64 addr, UINT size, UINT64 new_addr)
{ unimplemented(); }


// Override

//void UniFormat(wchar_t *buf, UINT size, wchar_t *fmt, ...)
//{ unimplemented(); }

bool StartSSLEx(SOCK *sock, X *x, K *priv, bool client_tls, UINT ssl_timeout, char *sni_hostname)
{ return unimplemented(); }
