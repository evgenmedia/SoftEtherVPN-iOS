//
//  AppleSock.c
//  Cedar
//
//  Created by System Administrator on 2018/7/23.
//

#include "AppleSock.h"
#include "CedarPch.h"

void* net_unimplemented(){ return 0x1; }

// Server.c
UINT vpn_global_parameters[NUM_GLOBAL_PARAMS] = {0};

UINT UdpAccelCalcMss(UDP_ACCEL *a)
{ return net_unimplemented(); }

void UdpAccelSetTick(UDP_ACCEL *a, UINT64 tick64)
{ net_unimplemented(); }

bool UdpAccelIsSendReady(UDP_ACCEL *a, bool check_keepalive)
{ return net_unimplemented(); }

bool UdpAccelInitClient(UDP_ACCEL *a, UCHAR *server_key, IP *server_ip, UINT server_port, UINT server_cookie, UINT client_cookie, IP *server_ip_2)
{ return net_unimplemented(); }
