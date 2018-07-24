//
//  ClientDummy.c
//  Cedar Strip
//
//  Created by System Administrator on 2018/7/23.
//

#include "CedarPch.h"

void* unimplemented(){ return 0x1; }

bool CheckMaxLoggedPacketsPerMinute(SESSION *s, UINT max_packets, UINT64 now)
{ return unimplemented(); }

void IncrementHubTraffic(HUB *h)
{ unimplemented(); }

void SiWriteSysLog(SERVER *s, char *typestr, char *hubname, wchar_t *message)
{ unimplemented(); }

UINT VirtualGetNextPacket(VH *v, void **data)
{ return unimplemented(); }
void NatSetHubOption(VH *v, HUB_OPTION *o)
{ unimplemented(); }

UINT AdminReconnect(RPC *rpc)
{ return unimplemented(); }

UINT L3GetNextPacket(L3IF *f, void **data)
{ return unimplemented(); }
void L3FreeAllSw(CEDAR *c)
{ unimplemented(); }

UINT EthGetPacket(ETH *e, void **data)
{ return unimplemented(); }
CANCEL *EthGetCancel(ETH *e)
{ return unimplemented(); }
bool EthSetMtu(ETH *e, UINT mtu)
{ return unimplemented(); }
void EthPutPackets(ETH *e, UINT num, void **datas, UINT *sizes)
{ unimplemented(); }

UINT GetEthDeviceHash()
{ return unimplemented(); }


void UnixVLanFree()
{ unimplemented(); }
void UnixVLanDelete(char *name)
{ unimplemented(); }


//PACKET_ADAPTER *NullGetPacketAdapter()
//{ return unimplemented(); }


void InRpcInternetSetting(INTERNET_SETTING *t, PACK *p)
{ unimplemented(); }

void AddSession(HUB *h, SESSION *s)
{ unimplemented(); }
void UdpAccelSendBlock(UDP_ACCEL *a, BLOCK *b)
{ unimplemented(); }
void OutRpcInternetSetting(PACK *p, INTERNET_SETTING *t)
{ unimplemented(); }
void UdpAccelPoll(UDP_ACCEL *a)
{ unimplemented(); }
void GenMacAddress(UCHAR *mac)
{ unimplemented(); }
int CompareHub(void *p1, void *p2)
{ return unimplemented(); }
void InitLocalBridgeList(CEDAR *c)
{ unimplemented(); }
void UnixVLanInit()
{ unimplemented(); }
void UnlockHubList(CEDAR *cedar)
{ unimplemented(); }
WEBUI *WuNewWebUI(CEDAR *cedar)
{ return unimplemented(); }
bool WuFreeWebUI(WEBUI *wu)
{ return unimplemented(); }
void StopHub(HUB *h)
{ unimplemented(); }
UINT EthGetMtu(ETH *e)
{ return unimplemented(); }
bool IsHub(CEDAR *cedar, char *name)
{ return unimplemented(); }
void WuFreeWebPage(WU_WEBPAGE *page)
{ unimplemented(); }
X *GetIssuerFromList(LIST *cert_list, X *cert)
{ return unimplemented(); }
bool GetServerCapsBool(SERVER *s, char *name)
{ return unimplemented(); }
WU_WEBPAGE *WuGetPage(char *target, WEBUI *wu)
{ return unimplemented(); }
void AddTrafficDiff(HUB *h, char *name, UINT type, TRAFFIC *traffic)
{ unimplemented(); }
BUF *HttpRequestEx(URL_DATA *data, INTERNET_SETTING *setting,
                   UINT timeout_connect, UINT timeout_comm,
                   UINT *error_code, bool check_ssl_trust, char *post_data,
                   WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash,
                   bool *cancel, UINT max_recv_size)
{ return unimplemented(); }
void OutRpcNodeInfo(PACK *p, NODE_INFO *t)
{ unimplemented(); }
UINT GetGlobalServerFlag(UINT index)
{ return unimplemented(); }
void FreeCedarLayer3(CEDAR *c)
{ unimplemented(); }
SOCK *WpcSockConnect2(char *hostname, UINT port, INTERNET_SETTING *t, UINT *error_code, UINT timeout)
{ return unimplemented(); }
SERVER *SiNewServerEx(bool bridge, bool in_client_inner_server, bool relay_server)
{ return unimplemented(); }
void ReleaseHub(HUB *h)
{ unimplemented(); }
void HashPassword(void *dst, char *username, char *password)
{ unimplemented(); }
void GenerateNtPasswordHash(UCHAR *dst, char *password)
{ unimplemented(); }
void CloseEth(ETH *e)
{ unimplemented(); }
bool EthIsChangeMtuSupported(ETH *e)
{ return unimplemented(); }
void OutRpcWinVer(PACK *p, RPC_WINVER *t)
{ unimplemented(); }
void DelSession(HUB *h, SESSION *s)
{ unimplemented(); }
UDP_ACCEL *NewUdpAccel(CEDAR *cedar, IP *ip, bool client_mode, bool random_port, bool no_nat_t)
{ return unimplemented(); }
ETH *OpenEth(char *name, bool local, bool tapmode, char *tapaddr)
{ return unimplemented(); }
bool VirtualPutPacket(VH *v, void *data, UINT size)
{ return unimplemented(); }
int CompareCert(void *p1, void *p2)
{ return unimplemented(); }
void L3PutPacket(L3IF *f, void *data, UINT size)
{ unimplemented(); }
void LockHubList(CEDAR *cedar)
{ unimplemented(); }
PACKET_ADAPTER *GetHubPacketAdapter()
{ return unimplemented(); }
void FreeUdpAccel(UDP_ACCEL *a)
{ unimplemented(); }
UINT SiGetSysLogSaveStatus(SERVER *s)
{ return unimplemented(); }
bool GetNoSstp()
{ return unimplemented(); }
HUB *GetHub(CEDAR *cedar, char *name)
{ return unimplemented(); }
void FreeLocalBridgeList(CEDAR *c)
{ unimplemented(); }
bool ParseUrl(URL_DATA *data, char *str, bool is_post, char *referrer)
{ return unimplemented(); }
bool OvsPerformTcpServer(CEDAR *cedar, SOCK *sock)
{ return unimplemented(); }
UINT GetHubAdminOption(HUB *h, char *name)
{ return unimplemented(); }
bool UnixVLanCreate(char *name, UCHAR *mac_address)
{ return unimplemented(); }
bool OvsCheckTcpRecvBufIfOpenVPNProtocol(UCHAR *buf, UINT size)
{ return unimplemented(); }
bool OvsGetNoOpenVpnTcp()
{ return unimplemented(); }
void SiReleaseServer(SERVER *s)
{ unimplemented(); }
bool IsAdminPackSupportedServerProduct(char *name)
{ return unimplemented(); }
//void SecurePassword(void *secure_password, void *password, void *random)
//{ unimplemented(); }
USER *AcGetUser(HUB *h, char *name)
{ return unimplemented(); }
void AcUnlock(HUB *h)
{ unimplemented(); }
bool AcceptSstp(CONNECTION *c)
{ return unimplemented(); }
void AcLock(HUB *h)
{ unimplemented(); }
BUF *HttpRequestEx3(URL_DATA *data, INTERNET_SETTING *setting,
                    UINT timeout_connect, UINT timeout_comm,
                    UINT *error_code, bool check_ssl_trust, char *post_data,
                    WPC_RECV_CALLBACK *recv_callback, void *recv_callback_param, void *sha1_cert_hash, UINT num_hashes,
                    bool *cancel, UINT max_recv_size, char *header_name, char *header_value)
{ return unimplemented(); }
void InitCedarLayer3(CEDAR *c)
{ unimplemented(); }
void ReleaseUser(USER *u)
{ unimplemented(); }

void GetServerProductName(SERVER *s, char *name, UINT size)
{ unimplemented(); }

void GetServerProductNameInternal(SERVER *s, char *name, UINT size)
{ unimplemented(); }

bool ParseHostPort(char *src, char **host, UINT *port, UINT default_port)
{ return unimplemented(); }
