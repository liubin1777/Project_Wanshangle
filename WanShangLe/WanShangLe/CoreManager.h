//
//  CoreManager.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-4.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "ABLogger.h"
#import "LocationManager.h"
#import "ReachabilityManager.h"

#import "common.h"
#import "SysConfig.h"
#import "SysInfo.h"

//数据库
#import "CoreData+MagicalRecord.h"
#import "DataBaseManager.h"
#import "CacheManager.h"

//电影数据
#define UpdatingMoviesList @"UpdatingMoviesList" //正在抓取数据
#define IsUpdatedMoviesList @"IsUpdatedMoviesList" //正在抓取数据

//数据升级
#import "SystemDataUpdater.h"
#import "SystemDataUpdater1_0.h"  // updator for version 1.0

//网络API
#import "ApiNotify.h"
#import "ApiConfig.h"
#import "ApiFault.h"
#import "ApiClient.h"
#import "ApiCmd.h"

//用户选择的城市
#define UserState @"administrativeArea"

//时间戳
#define MMovieTimeStamp @"MMovieTimeStamp"
#define MCinemaTimeStamp @"MCinemaTimeStamp"

//判断设备ios版本
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//判断设备是否支持retina
#ifndef ImageShowcase_Utility_h
#define ImageShowcase_Utility_h
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

//适配iphone5的屏幕
//adaptive iphone5 macro
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,1136), [[UIScreen mainScreen] currentMode].size) : NO)
//CGRect ( 0, 20, 320, 548)
#define iPhoneAppFrame [[UIScreen mainScreen] applicationFrame]
#define iPhoneScreenBounds [[UIScreen mainScreen] bounds]