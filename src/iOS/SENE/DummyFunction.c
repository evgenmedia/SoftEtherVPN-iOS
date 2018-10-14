#define SWIFT_BRIDGE

#include "CedarPch.h"

void* unimplemented(){ return 0x1; }
void* ignored(){ return 0x1; }

bool g_debug = true;                                    // Debug mode
UINT64 kernel_status[NUM_KERNEL_STATUS];        // Kernel state
UINT64 kernel_status_max[NUM_KERNEL_STATUS];    // Kernel state (maximum value)
BOOL kernel_status_inited = false;                // Kernel state initialization flag
bool g_little_endian = true;

LOCK *openssl_lock = NULL;

void AddSession(HUB *h, SESSION *s)
{ unimplemented(); }

void CiIncrementNumActiveSessions()
{ unimplemented(); }

void CiDecrementNumActiveSessions()
{ unimplemented(); }

void AddTrafficDiff(HUB *h, char *name, UINT type, TRAFFIC *traffic)
{ unimplemented(); }

void CiNotify(CLIENT *c)
{ unimplemented(); }

SOCK *CncMsgDlg(UI_MSG_DLG *dlg)
{ return unimplemented(); }

SOCK *CncNicInfo(UI_NICINFO *info)
{ return unimplemented(); }

void CndMsgDlgFree(SOCK *s)
{ unimplemented(); }

void DelSession(HUB *h, SESSION *s)
{ unimplemented(); }

void OutRpcNodeInfo(PACK *p, NODE_INFO *t)
{ unimplemented(); }

bool IsAdminPackSupportedServerProduct(char *name)
{ return unimplemented(); }

bool UnixVLanSetState(char* name, bool state_up)
{ return unimplemented(); }

void CLog(CLIENT *c, char *name, ...)
{ unimplemented(); }

X *ReadSecCert(SECURE *sec, char *name)
{ return unimplemented(); }

LIST *EnumSecObject(SECURE *sec)
{ return unimplemented(); }

void FreeEnumSecObject(LIST *o)
{ unimplemented(); }

SECURE *OpenSec(UINT id)
{ return unimplemented(); }

bool LoginSec(SECURE *sec, char *pin)
{ return unimplemented(); }

void CiSaveConfigurationFile(CLIENT *c)
{ unimplemented(); }

bool DeleteSecCert(SECURE *sec, char *name)
{ return unimplemented(); }

void LogoutSec(SECURE *sec)
{ unimplemented(); }

bool AcceptSstp(CONNECTION *c)
{ return unimplemented(); }

WU_WEBPAGE *WuGetPage(char *target, WEBUI *wu)
{ return unimplemented(); }

void WuFreeWebPage(WU_WEBPAGE *page)
{ unimplemented(); }

bool SiTooManyUserObjectsInServer(SERVER *s, bool oneMore)
{ return unimplemented(); }

void InRpcWinVer(RPC_WINVER *t, PACK *p)
{ unimplemented(); }

bool WriteSecKey(SECURE *sec, bool private_obj,
                 char *name, K *k)
{ return unimplemented(); }

bool IsIpDeniedByAcList(IP *ip, LIST *o)
{ return unimplemented(); }

bool GetNoSstp()
{ return unimplemented(); }

bool SamAuthUserByAnonymous(HUB *h, char *username)
{ return unimplemented(); }

void GenerateNtPasswordHashHash(UCHAR *dst_hash, UCHAR *src_hash)
{ unimplemented(); }

bool SamAuthUserByPlainPassword(CONNECTION *c, HUB *hub, char *username, char *password, bool ast, UCHAR *mschap_v2_server_response_20, RADIUS_LOGIN_OPTION *opt)
{ return unimplemented(); }

bool RsaVerifyEx(void *data, UINT data_size, void *sign, K *k, UINT bits)
{ return unimplemented(); }

FARM_MEMBER *SiGetHubHostingMember(SERVER *s, HUB *h, bool admin_mode, CONNECTION *c)
{ return unimplemented(); }

K *GetKFromX(X *x)
{ return unimplemented(); }

void SiCallCreateTicket(SERVER *s, FARM_MEMBER *f, char *hubname, char *username, char *realusername, POLICY *policy, UCHAR *ticket, UINT counter, char *groupname)
{ unimplemented(); }

UINT GetServerCapsInt(SERVER *s, char *name)
{ return unimplemented(); }

bool ParseAndExtractMsChapV2InfoFromPassword(IPC_MSCHAP_V2_AUTHINFO *d, char *password)
{ return unimplemented(); }

bool UdpAccelInitServer(UDP_ACCEL *a, UCHAR *client_key, IP *client_ip, UINT client_port, IP *client_ip_2)
{ return unimplemented(); }

bool IsURLMsg(wchar_t *str, char *url, UINT url_size)
{ return unimplemented(); }

UINT SiGetPoint(SERVER *s)
{ return unimplemented(); }

void FreeUdpAccel(UDP_ACCEL *a)
{ unimplemented(); }

UINT L3GetNextPacket(L3IF *f, void **data)
{ return unimplemented(); }

POLICY *SamGetUserPolicy(HUB *h, char *username)
{ return unimplemented(); }

void DeleteAllUserListCache(LIST *o)
{ unimplemented(); }

void CloseSecSession(SECURE *sec)
{ unimplemented(); }

void SiFarmServ(SERVER *server, SOCK *sock, X *cert, UINT ip, UINT num_port, UINT *ports, char *hostname, UINT point, UINT weight, UINT max_sessions)
{ unimplemented(); }

void ReleaseEapClient(EAP_CLIENT *e)
{ unimplemented(); }

void HashPassword(void *dst, char *username, char *password)
{ unimplemented(); }

void AbortExitEx(char *msg)
{ unimplemented(); }

bool FileRead(IO *o, void *buf, UINT size)
{ return unimplemented(); }

void ElStopListener(EL *e)
{ unimplemented(); }

UINT GetHubAdminOption(HUB *h, char *name)
{ return unimplemented(); }

void AcUnlock(HUB *h)
{ unimplemented(); }

bool AcIsUser(HUB *h, char *name)
{ return unimplemented(); }

CRYPT *NewCrypt(void *key, UINT size)
{ return unimplemented(); }

bool ParseUrl(URL_DATA *data, char *str, bool is_post, char *referrer)
{ return unimplemented(); }

void FreeRpcEnumSession(RPC_ENUM_SESSION *t)
{ unimplemented(); }

BUF *HttpRequestEx(URL_DATA *data, INTERNET_SETTING *setting,
				   UINT timeout_connect, UINT timeout_comm,
				   UINT *error_code, bool check_ssl_trust, char *post_data,
				   WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash,
				   bool *cancel, UINT max_recv_size)
{ return unimplemented(); }

bool IsBase64(BUF *b)
{ return unimplemented(); }

bool FileDeleteW(wchar_t *name)
{ return unimplemented(); }

void GetServerProductName(SERVER *s, char *name, UINT size)
{ unimplemented(); }

UINT GetEthDeviceHash()
{ return unimplemented(); }

bool OvsGetNoOpenVpnTcp()
{ return unimplemented(); }

bool OvsPerformTcpServer(CEDAR *cedar, SOCK *sock)
{ return unimplemented(); }

bool OpenSecSession(SECURE *sec, UINT slot_number)
{ return unimplemented(); }

void SLog(CEDAR *c, char *name, ...)
{ unimplemented(); }

void AddUDPEntry(CEDAR *cedar, SESSION *session)
{ unimplemented(); }

void DelUDPEntry(CEDAR *cedar, SESSION *session)
{ unimplemented(); }

void UdpAccelPoll(UDP_ACCEL *a)
{ unimplemented(); }

void YieldCpu()
{ unimplemented(); }

USHORT Rand16()
{ return unimplemented(); }

CANCEL *EthGetCancel(ETH *e)
{ return unimplemented(); }

bool EthIsChangeMtuSupported(ETH *e)
{ return unimplemented(); }

bool VirtualPutPacket(VH *v, void *data, UINT size)
{ return unimplemented(); }

USER *AcGetUser(HUB *h, char *name)
{ return unimplemented(); }

void FreePacket(PKT *p)
{ unimplemented(); }

IO *FileOpenExW(wchar_t *name, bool write_mode, bool read_lock)
{ return unimplemented(); }

bool IsHub(CEDAR *cedar, char *name)
{ return unimplemented(); }

void L3PutPacket(L3IF *f, void *data, UINT size) 
{ unimplemented(); }

void EthPutPackets(ETH *e, UINT num, void **datas, UINT *sizes)
{ unimplemented(); }

int CompareListener(void *p1, void *p2)
{ return unimplemented(); }


void HMacSha1(void *dst, void *key, UINT key_size, void *data, UINT data_size)
{ unimplemented(); }

int CompareUDPEntry(void *p1, void *p2)
{ return unimplemented(); }

UINT64 SystemToUINT64(SYSTEMTIME *st)
{ return unimplemented(); }


void MsChapV2Server_GenerateResponse(UCHAR *dst, UCHAR *nt_password_hash_hash, UCHAR *client_response, UCHAR *challenge8)
{ unimplemented(); }

void InitLocalBridgeList(CEDAR *c)
{ unimplemented(); }

void InitCedarLayer3(CEDAR *c)
{ unimplemented(); }

SOCK *WpcSockConnect2(char *hostname, UINT port, INTERNET_SETTING *t, UINT *error_code, UINT timeout)
{ return unimplemented(); }

bool WuFreeWebUI(WEBUI *wu)
{ return unimplemented(); }

void ReleaseUser(USER *u)
{ unimplemented(); }

void FreeCedarLayer3(CEDAR *c)
{ unimplemented(); }

void FreeLocalBridgeList(CEDAR *c)
{ unimplemented(); }

bool SignSec(SECURE *sec, char *name, void *dst, void *src, UINT size)
{ return unimplemented(); }

void L3FreeAllSw(CEDAR *c)
{ unimplemented(); }

void OutRpcWinVer(PACK *p, RPC_WINVER *t)
{ unimplemented(); }

void HLog(HUB *h, char *name, ...)
{ unimplemented(); }

bool SamAuthUserByCert(HUB *h, char *username, X *x)
{ return unimplemented(); }

void ReleaseListener(LISTENER *r)
{ unimplemented(); }

WEBUI *WuNewWebUI(CEDAR *cedar)
{ return unimplemented(); }

void StopHub(HUB *h)
{ unimplemented(); }

UINT VirtualGetNextPacket(VH *v, void **data)
{ return unimplemented(); }

void FreeCrypt(CRYPT *c)
{ unimplemented(); }

UINT EthGetMtu(ETH *e)
{ return unimplemented(); }

void ReleaseHub(HUB *h)
{ unimplemented(); }

void GetAllNameFromName(wchar_t *str, UINT size, NAME *name)
{ unimplemented(); }

bool CheckXDateNow(X *x)
{ return unimplemented(); }

LOG *NewLog(char *dir, char *prefix, UINT switch_type)
{ return unimplemented(); }

bool IsDhcpPacketForSpecificMac(UCHAR *data, UINT size, UCHAR *mac_address)
{ return unimplemented(); }

UINT64 LocalTime64()
{ return unimplemented(); }

bool CompareName(NAME *n1, NAME *n2)
{ return unimplemented(); }

void FreeK(K *k)
{ unimplemented(); }

void FreeLog(LOG *g)
{ unimplemented(); }

void UdpAccelSendBlock(UDP_ACCEL *a, BLOCK *b)
{ unimplemented(); }

int CompareHub(void *p1, void *p2)
{ return unimplemented(); }


void GetDateTimeStrMilli64(char *str, UINT size, UINT64 sec64)
{ unimplemented(); }

void UnlockHubList(CEDAR *cedar)
{ unimplemented(); }

bool MakeDir(char *name)
{ return unimplemented(); }

bool ParseHostPort(char *src, char **host, UINT *port, UINT default_port)
{ return unimplemented(); }

void CombinePathW(wchar_t *dst, UINT size, wchar_t *dirname, wchar_t *filename)
{ unimplemented(); }

void GetExeDirW(wchar_t *name, UINT size)
{ unimplemented(); }

BUF *KToBuf(K *k, bool text, char *password)
{ return unimplemented(); }

bool GetServerCapsBool(SERVER *s, char *name)
{ return unimplemented(); }

K *CloneK(K *k)
{ return unimplemented(); }

void InRpcNodeInfo(NODE_INFO *t, PACK *p)
{ unimplemented(); }

X *BufToX(BUF *b, bool text)
{ return unimplemented(); }

K *BufToK(BUF *b, bool private_key, bool text, char *password)
{ return unimplemented(); }

void IncrementHubTraffic(HUB *h)
{ unimplemented(); }

void GetXDigest(X *x, UCHAR *buf, bool sha1)
{ unimplemented(); }

UINT64 Rand64()
{ return unimplemented(); }

void OSMemoryFree(void *addr)
{ unimplemented(); }

void ConvertSafeFileName(char *dst, UINT size, char *src)
{ unimplemented(); }

void *OSMemoryAlloc(UINT size)
{ return unimplemented(); }

void OSSleep(UINT time)
{ unimplemented(); }

bool RsaSignEx(void *dst, void *src, UINT size, K *k, UINT bits)
{ return unimplemented(); }

IO *FileCreateW(wchar_t *name)
{ return unimplemented(); }

UINT FileSize(IO *o)
{ return unimplemented(); }

void MsChapV2_GenerateChallenge8(UCHAR *dst, UCHAR *client_challenge, UCHAR *server_challenge, char *username)
{ unimplemented(); }

USHORT IpChecksum(void *buf, UINT size)
{ return unimplemented(); }

UINT StGetHubMsg(ADMIN *a, RPC_MSG *t)
{ return unimplemented(); }

void CncNicInfoFree(SOCK *s)
{ unimplemented(); }

REF *NewRef()
{ return unimplemented(); }

void UnlockKernelStatus(UINT id)
{ unimplemented(); }

bool WaitThread(THREAD *t, UINT timeout)
{ return unimplemented(); }

BUF *XToBuf(X *x, bool text)
{ return unimplemented(); }

bool IsFileExistsW(wchar_t *name)
{ return unimplemented(); }

void InitTick64()
{ unimplemented(); }

void TrackChangeObjSize(UINT64 addr, UINT size, UINT64 new_addr)
{ unimplemented(); }

void FileClose(IO *o)
{ unimplemented(); }

X *GetIssuerFromList(LIST *cert_list, X *cert)
{ return unimplemented(); }

POLICY *GetDefaultPolicy()
{ return unimplemented(); }

void LockHubList(CEDAR *cedar)
{ unimplemented(); }

bool SiCheckTicket(HUB *h, UCHAR *ticket, char *username, UINT username_size, char *usernamereal, UINT usernamereal_size, POLICY *policy, char *sessionname, UINT sessionname_size, char *groupname, UINT groupname_size)
{ return unimplemented(); }

void SiEnumSessionMain(SERVER *s, RPC_ENUM_SESSION *t)
{ unimplemented(); }

void AcLock(HUB *h)
{ unimplemented(); }

bool EthSetMtu(ETH *e, UINT mtu)
{ return unimplemented(); }

void NatSetHubOption(VH *v, HUB_OPTION *o)
{ unimplemented(); }

X *FileToXW(wchar_t *filename)
{ return unimplemented(); }

void FileFlush(IO *o)
{ unimplemented(); }

bool GetEnv(char *name, char *data, UINT size)
{ return unimplemented(); }

bool FileWrite(IO *o, void *buf, UINT size)
{ return unimplemented(); }

UDP_ACCEL *NewUdpAccel(CEDAR *cedar, IP *ip, bool client_mode, bool random_port, bool no_nat_t)
{ return unimplemented(); }

PACKET_ADAPTER *GetHubPacketAdapter()
{ return unimplemented(); }

void DhFree(DH_CTX *dh)
{ unimplemented(); }

char *MsChapV2DoBruteForce(IPC_MSCHAP_V2_AUTHINFO *d, LIST *password_list)
{ return unimplemented(); }

int GetSslClientCertIndex()
{ return unimplemented(); }

UINT GetTableInt(char *name)
{ return unimplemented(); }

void TrackDeleteObj(UINT64 addr)
{ unimplemented(); }

bool OvsCheckTcpRecvBufIfOpenVPNProtocol(UCHAR *buf, UINT size)
{ return unimplemented(); }

bool FileCopyW(wchar_t *src, wchar_t *dst)
{ return unimplemented(); }

ETH *OpenEth(char *name, bool local, bool tapmode, char *tapaddr)
{ return unimplemented(); }

UCHAR Rand8()
{ return unimplemented(); }

int CompareCert(void *p1, void *p2)
{ return unimplemented(); }

void UnixGetExeNameW(wchar_t *name, UINT size, wchar_t *arg)
{ unimplemented(); }

bool DeleteSecKey(SECURE *sec, char *name)
{ return unimplemented(); }

void OSDeleteLock(LOCK *lock)
{ unimplemented(); }

bool CheckXEx(X *x, X *x_issuer, bool check_name, bool check_date)
{ return unimplemented(); }

X *X509ToX(X509 *x509)
{ return unimplemented(); }

void FreeDir(DIRLIST *d)
{ unimplemented(); }

bool CheckSignature(X *x, K *k)
{ return unimplemented(); }

void ReleaseGroup(USERGROUP *g)
{ unimplemented(); }

UINT HashPtrToUINT(void *p)
{ return unimplemented(); }

void CloseEth(ETH *e)
{ unimplemented(); }

bool CheckXandK(X *x, K *k)
{ return unimplemented(); }

UINT GetIpHeaderSize(UCHAR *src, UINT src_size)
{ return unimplemented(); }

BUF *HttpRequestEx3(URL_DATA *data, INTERNET_SETTING *setting,
					UINT timeout_connect, UINT timeout_comm,
					UINT *error_code, bool check_ssl_trust, char *post_data,
					WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash, UINT num_hashes,
					bool *cancel, UINT max_recv_size, char *header_name, char *header_value)
{ return unimplemented(); }


void *OSMemoryReAlloc(void *addr, UINT size)
{ return unimplemented(); }

void FreeX(X *x)
{ unimplemented(); }

X *CloneX(X *x)
{ return unimplemented(); }

bool CompareX(X *x1, X *x2)
{ return unimplemented(); }

DIRLIST *EnumDirW(wchar_t *dirname)
{ return unimplemented(); }

void SleepThread(UINT time)
{ unimplemented(); }

UINT AdminAccept(CONNECTION *c, PACK *p)
{ return unimplemented(); }

void LockKernelStatus(UINT id)
{ unimplemented(); }

void Encrypt(CRYPT *c, void *dst, void *src, UINT size)
{ unimplemented(); }

void EnableSecureNATEx(HUB *h, bool enable, bool no_change)
{ unimplemented(); }

bool MakeDirExW(wchar_t *name)
{ return unimplemented(); }

UINT AddRef(REF *ref)
{ return unimplemented(); }

bool WriteSecCert(SECURE *sec, bool private_obj, char *name, X *x)
{ return unimplemented(); }

bool SamAuthUserByPassword(HUB *h, char *username, void *random, void *secure_password, char *mschap_v2_password, UCHAR *mschap_v2_server_response_20, UINT *err)
{ return unimplemented(); }

UINT EthGetPacket(ETH *e, void **data)
{ return unimplemented(); }


char *CfgReadNextLine(BUF *b)
{ return unimplemented(); }

POLICY *ClonePolicy(POLICY *policy)
{ return unimplemented(); }

void TrackNewObj(UINT64 addr, char *name, UINT size)
{ unimplemented(); }

void CloseSec(SECURE *sec)
{ unimplemented(); }

UINT StGetHub(ADMIN *a, RPC_CREATE_HUB *t)
{ return unimplemented(); }

HUB *GetHub(CEDAR *cedar, char *name)
{ return unimplemented(); }

void Alert(char *msg, char *caption)
{ unimplemented(); }

wchar_t *GetHubMsg(HUB *h)
{ return unimplemented(); }

void StopListener(LISTENER *r)
{ unimplemented(); }

void LocalTime(SYSTEMTIME *st)
{ unimplemented(); }

IO *FileOpen(char *name, bool write_mode)
{ return unimplemented(); }

void GetExeNameW(wchar_t *name, UINT size)
{ unimplemented(); }

void GenerateNtPasswordHash(UCHAR *dst, char *password)
{ unimplemented(); }

IO *FileCreate(char *name)
{ return unimplemented(); }

UINT Release(REF *ref)
{ return unimplemented(); }

