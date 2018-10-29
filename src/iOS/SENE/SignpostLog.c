//
//  SignpostLog.c
//  SENE
//
//  Created by Shuyi Dong on 2018-10-29.
//

#include <stdio.h>
#include <os/signpost.h>

static os_log_t log = NULL;

//void signpost_log(char* pipe, char* msg){
//    if (log == NULL){
//        log =  os_log_create("tech.nsyd.se.SENE","Log");
//    }
//    os_signpost_event_emit(log,OS_SIGNPOST_ID_EXCLUSIVE,pipe,"%s",msg);
//}

//void Debug(char *fmt, ...){
//    va_list args;
//    
//    if (log == NULL){
//        log =  os_log_create("tech.nsyd.se.SENE","Log");
//    }
//    
//    va_start(args, fmt);
//    os_signpost_event_emit(log, OS_SIGNPOST_ID_EXCLUSIVE, "Debug", fmt, args);
//    va_end(args);
//}
