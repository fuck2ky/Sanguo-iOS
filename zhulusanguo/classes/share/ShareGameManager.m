//
//  ShareGameManager.m
//  sanguo
//
//  Created by lai qing on 15/1/27.
//  Copyright (c) 2015年 qing lai. All rights reserved.
//

#import "ShareGameManager.h"

NSString* const skillnames[] = {@"冶炼",@"土豪",@"伐木",@"伏兵",@"箭术",@"刺杀",@"强攻",@"砲术",@"沉着",@"冲锋",@"水神",@"助火",@"反制",@"残酷",@"驱散",@"医师",@"爆击",@"激怒",@"反馈",@"火计",@"火箭",@"治疗",@"威压",@"恐惧",@"铁壁",@"合击",@"诏书",@"雷击",@"机甲",@"仁义",@"迷魂",@"误导",@"解毒",@"毒术",@"雨天",@"援兵",@"反计",@"复仇",@"谣言",@"疾行",@"地道",@"治安",@"晴天",@"雷神",@"陷阱",@"群射",@"治水",@"水计"};

NSString* const trooptypes[] = {@"",@"步兵",@"弓兵",@"骑兵",@"策士",@"弩车"};
NSString* const armytypes[] = {@"",@"步",@"弓",@"骑"};

NSString* const citynames[] = {@"",@"酒泉",@"张掖",@"武威",@"西海",@"天水",@"陇西",@"汉中",@"巴西",@"梓潼",@"巴郡",@"广汉",@"成都",@"江阳",@"永安",@"江州",@"建宁",@"云南",@"交趾",@"郁林",@"扶风",@"京兆",@"长安",@"上庸",@"武陵",@"零陵",@"桂阳",@"苍梧",@"合浦",@"晋阳",@"平阳",@"弘农",@"襄阳",@"雁门",@"常山",@"洛阳",@"宛城",@"新野",@"江陵",@"长沙",@"南海",@"朱崖",@"上谷",@"范阳",@"代郡",@"邺城",@"巨鹿",@"河内",@"濮阳",@"颖川",@"许昌",@"陈留",@"汝南",@"寿春",@"江夏",@"庐江",@"柴桑",@"鄱阳",@"豫章",@"建安",@"庐陵",@"蓟城",@"渔阳",@"清河",@"泰山",@"平原",@"北平",@"辽西",@"襄平",@"乐浪",@"南皮",@"东莱",@"北海",@"小沛",@"琅邪",@"东海",@"徐州",@"下邳",@"广陵",@"建业",@"毗陵",@"吴郡",@"会稽",@"临海",@"夷州"};

NSString* const articleForCitys[] = {@"10,11,12,14,15",@"13,14,15,16,17",@"16,17,18,19,20",@"19,20,21,22,23",@"22,23,24,26,27",@"25,26,27,28,29",@"28,29,30,31,15",@"31,101,102,12,18",@"103,104,105,22,24",@"106,107,108,28,29",@"201,202,203,31,14",@"204,205,206,16,19",@"301,302,303,101,102",@"304,305,306,30,18"};

int const goldToWoodRate[] = {100,80,60,40,20,10};
int const goldToIronRate[] = {100,80,60,40,20,10};
int const woodToGoldRate[] = {15,10,8,6,4,3};  //10 wood <-> 1 gold
int const woodToIronRate[] = {15,10,8,6,4,3};
int const ironToGoldRate[] = {15,10,8,6,4,3};
int const ironToWoodRate[] = {15,10,8,6,4,3};

@implementation ShareGameManager

@synthesize gameDifficulty = _gameDifficulty;
@synthesize selectedCityID = _selectedCityID;
@synthesize kingID = _kingID;
@synthesize gold = _gold;
@synthesize wood = _wood;
@synthesize iron = _iron;
@synthesize year = _year;
@synthesize month = _month;
@synthesize day = _day;

static id instance = nil;


+(ShareGameManager*)shareGameManager {
    @synchronized([ShareGameManager class]) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+(id)alloc {
    @synchronized([ShareGameManager class]) {
        NSAssert(instance==nil, @"ShareGameObjectManager singleton already exists...");
        instance = [super alloc];
        return instance;
    }
    return nil;
}

-(id) init
{
    if ((self = [super init])) {
        hasAudioBeenInitialized = NO;
        _gameDifficulty = 1;
        _kingID = -1;
        _selectedCityID = -1;
    }
    return self;
}

-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing;
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised)
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil ||
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed;
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        //soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
        //[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.2f];
        
    }
}

-(void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation =
        [[NSInvocationOperation alloc] initWithTarget:self
                                             selector:@selector(initAudioAsync)
                                               object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}

-(void)playCurrentBackgroundTrack
{
    
}

-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) &&
        (managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) ||
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerReady) {
        if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        }
        //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:trackFileName];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:trackFileName loop:YES];
    }
}

-(void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [[SimpleAudioEngine sharedEngine] stopEffect:soundEffectID];
    }
}

-(ALuint)playSoundEffect:(NSString*)soundEffectName {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        soundID = [[SimpleAudioEngine sharedEngine] playEffect:soundEffectName];
    }
    else {
        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectName);
    }
    return soundID;
}

-(void) initDefaultAllAnimationInScene
{
    NSString *fn_noext = [NSString stringWithFormat:@"animate_all"];
    NSString *fn = [NSString stringWithFormat:@"animate_all.plist"];
    
    //从documents目录下进行查找plist
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistpath = [rootpath stringByAppendingPathComponent:fn];
    //如果未找到，则从bundle里查找
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistpath]) {
        plistpath = [[NSBundle mainBundle] pathForResource:fn_noext ofType:@"plist"];
    }
    NSDictionary *animationSettings = [NSDictionary dictionaryWithContentsOfFile:plistpath];
    //
    //NSString *key = [NSString stringWithFormat:@"%d",sceneID];
    NSString *key = @"10";
    NSArray *animationList = [animationSettings objectForKey:key];
    for (NSDictionary *ani in animationList) {
        NSString *animate_name = [ani objectForKey:@"animate_name"];
        NSString *filename = [ani objectForKey:@"filename"];
        NSString *fileext = [ani objectForKey:@"fileext"];
        float delay = [[ani objectForKey:@"delay"] floatValue];
        CCAnimation *an = [CCAnimation animation];
        NSString *animateFrames = [ani objectForKey:@"frames"];
        NSArray *animateArray = [animateFrames componentsSeparatedByString:@","];
        for (NSString *frameNumber in animateArray) {
            NSString *animateFileName = [NSString stringWithFormat:@"%@%@%@.png",filename,frameNumber,fileext];
            [an addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animateFileName]];
        }
        [an setDelayPerUnit:delay];
        [[CCAnimationCache sharedAnimationCache] addAnimation:an name:animate_name];
        CCLOG(@"animation %@ add to cache",animate_name);
        //add to loading animate list
        //[loadingAnimateList addObject:[animate_name retain]];
    }
    
}

-(id) addLabelWithString:(NSString*)text dimension:(CGRect)rect normalColor:(UIColor*)nc highColor:(UIColor*)hc nrange:(NSString*)nr hrange:(NSString*)hr
{
    //get a smaller rect
    //CGRect labelRect = CGRectMake(rect.origin.x + rect.size.width*0.1 , rect.origin.y + rect.size.height*0.1, rect.size.width*1.8, rect.size.height*1.8);
    CGRect labelRect = CGRectMake(20, -30, rect.size.width, rect.size.height);
    CCLOG(@"addlabel in rect: %f,%f,%f,%f",labelRect.origin.x,labelRect.origin.y,labelRect.size.width,labelRect.size.height);
    
    //add a uilabel
    UILabel *label = [[[UILabel alloc] initWithFrame:labelRect] autorelease];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    //label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    
    NSMutableAttributedString *ntxt = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    
    //generate normal range
    NSArray *narray = [nr componentsSeparatedByString:@","];
    int nlen = (int)[narray count];
    for (int i=0; i<nlen; i+=2) {
        NSString* s1 = [narray objectAtIndex:i];
        NSString* s2 = [narray objectAtIndex:i+1];
        int st1 = [s1 intValue];
        int st2 = [s2 intValue];
        NSRange nr = NSMakeRange(st1, st2);
        [ntxt addAttribute:NSForegroundColorAttributeName value:nc range:nr];
    }
    
    NSArray *harray = [hr componentsSeparatedByString:@","];
    nlen = (int)[harray count];
    for (int i=0; i<nlen; i+=2) {
        NSString* s1 = [harray objectAtIndex:i];
        NSString* s2 = [harray objectAtIndex:i+1];
        int st1 = [s1 intValue];
        int st2 = [s2 intValue];
        NSRange hr = NSMakeRange(st1, st2);
        [ntxt addAttribute:NSForegroundColorAttributeName value:hc range:hr];
    }
    
    label.attributedText = ntxt;
    return label;
    
}

-(void) initNewGameDBWithKingID:(int)king_id
{
    //copy the sanguo.db from bundle to the document dir
    
    //copy the db to a new temp dbfile for save
    NSString* sfile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sanguo.db"];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    CCLOG(@"current db path:%@",curdb);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:curdb isDirectory:NO]) {
        CCLOG(@"current db is exist, now remove it....");
        [[NSFileManager defaultManager] removeItemAtPath:curdb error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:curdb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:curdb];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:sfile];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
    
    
    sqlite3* _database;
    if (sqlite3_open([curdb UTF8String], &_database) != SQLITE_OK) {
        CCLOG(@"Failed to open database!");
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"发生错误"
                                  message:@"手机空间不足，无法创建游戏档案！"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    int initCityCount;
    
    NSTimeInterval nt = [[NSDate date] timeIntervalSince1970];
    NSString* savetime = [NSString stringWithFormat:@"%lf",nt];
    
    NSString* query = [NSString stringWithFormat:@"select gold,lumber,iron,cityCount from kingInit where kingid=%d",king_id];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        _gold = (int) sqlite3_column_int(statement, 0);
        _wood = (int) sqlite3_column_int(statement, 1);
        _iron = (int) sqlite3_column_int(statement, 2);
        initCityCount = (int) sqlite3_column_int(statement, 3);
        
    }
    sqlite3_finalize(statement);
    
    //insert into table playerInfo (kingID, year, month, day , savedate, gold, lumber, iron , inBattle 0, difficulty , cityCount)
    query = [NSString stringWithFormat:@"insert into playerInfo values(%d,189,1,1,'%@',%d,%d,%d,0,%d,%d",king_id,savetime,_gold,_wood,_iron,_gameDifficulty,initCityCount];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    //query = [NSString stringWithFormat:@"update city set tower1=1,tower2=1,tower3=1,tower4=1 where flag<>%d and flag<>99",king_id];
    //now set all city tower the same , so no need to build tower again
    //query = [NSString stringWithFormat:@"update city set tower1=1,tower2=1,tower3=1,tower4=1"];
    //sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    sqlite3_close(_database);

    
}

-(NSArray*) selectAllHero:(int)king_id
{
    return nil;
    
}


-(int) getTheCapitalCityWithKingID:(int)king_id
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    int result = 1;
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select id from city where flag=%d and capital=1",king_id];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        result = (int) sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    return result;
}

-(int) getCityHeroCount:(int)cityID withKingID:(int)kingid
{
    int result = 0;
    if (kingid==99) return result;
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select count(*) from hero where owner=%d and city=%d",kingid,cityID];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        result = (int) sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    return result;
}

-(int) getCityKingID:(int)cityID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    int result = 0;
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select flag from city where id=%d",cityID];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        result = (int) sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    return result;
}

-(void) upgradeCityBuilding:(int)buildID withNewLevel:(int)lev withCityID:(int)cid withNewCityLevel:(int)nlev
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    switch (buildID) {
        case 1:
            query = [NSString stringWithFormat:@"update city set hall=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 2:
            query = [NSString stringWithFormat:@"update city set barrack=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 3:
            query = [NSString stringWithFormat:@"update city set archer=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 4:
            query = [NSString stringWithFormat:@"update city set cavalry=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 5:
            query = [NSString stringWithFormat:@"update city set wizard=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 6:
            query = [NSString stringWithFormat:@"update city set blacksmith=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 7:
            query = [NSString stringWithFormat:@"update city set lumbermill=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 8:
            query = [NSString stringWithFormat:@"update city set steelmill=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 9:
            query = [NSString stringWithFormat:@"update city set market=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 10:
            query = [NSString stringWithFormat:@"update city set magictower=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        case 11:
            query = [NSString stringWithFormat:@"update city set tavern=%d,level=%d where id=%d",lev,nlev,cid];
            break;
        default:
            query = [NSString stringWithFormat:@"update city set hall=%d,level=%d where id=%d",lev,nlev,cid];
            break;
    }
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);

}

-(CityInfoObject*) getCityInfoObjectFromID:(int)cityID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    CityInfoObject* cio = [[[CityInfoObject alloc] init] autorelease];
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select cname,level,warriorCount,archerCount,cavalryCount,wizardCount,ballistaCount from city  where id=%d",cityID];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        char *cname = (char *) sqlite3_column_text(statement, 0);
        NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
        int level = (int) sqlite3_column_int(statement, 1);
        int wc = (int) sqlite3_column_int(statement, 2);
        int ac = (int) sqlite3_column_int(statement, 3);
        int cc = (int) sqlite3_column_int(statement, 4);
        int wic = (int) sqlite3_column_int(statement, 5);
        int bc = (int) sqlite3_column_int(statement, 6);
        
        cio.cnName = cname2;
        cio.level = level;
        cio.warriorCount = wc;
        cio.archerCount = ac;
        cio.cavalryCount = cc;
        cio.wizardCount = wic;
        cio.ballistaCount = bc;
        
        CCLOG(@"GET city info from db: %d,%d,%d,%d,%d",wc,ac,cc,wic,bc);
        
    }
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    return cio;
}

-(CityInfoObject*) getCityInfoForCityScene:(int)cityID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    CityInfoObject* cio = [[[CityInfoObject alloc] init] autorelease];
    //insert into db , player select king id , and difficulty
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select cname,hall,barrack,archer,cavalry,wizard,blacksmith,tavern,market,lumbermill,steelmill,magictower,tower1,tower2,tower3,tower4,level from city  where id=%d",cityID];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        char *cname = (char *) sqlite3_column_text(statement, 0);
        NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
        cio.cnName = cname2;
        cio.hall =  sqlite3_column_int(statement, 1);
        cio.barrack = sqlite3_column_int(statement, 2);
        cio.archer =  sqlite3_column_int(statement, 3);
        cio.cavalry =  sqlite3_column_int(statement, 4);
        cio.wizard =  sqlite3_column_int(statement, 5);
        cio.blacksmith =  sqlite3_column_int(statement, 6);
        cio.tavern =  sqlite3_column_int(statement, 7);
        cio.market =  sqlite3_column_int(statement, 8);
        cio.lumbermill =  sqlite3_column_int(statement, 9);
        cio.steelmill =  sqlite3_column_int(statement, 10);
        cio.magictower =  sqlite3_column_int(statement, 11);
        cio.tower1 =  sqlite3_column_int(statement, 12);
        cio.tower2 =  sqlite3_column_int(statement, 13);
        cio.tower3 =  sqlite3_column_int(statement, 14);
        cio.tower4 =  sqlite3_column_int(statement, 15);
        cio.level = sqlite3_column_int(statement, 16);
    }
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    
    return cio;
}

-(TipObject*) getRandomTip
{
    //2 is the max tips for test table
    int ran = arc4random()%37;
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    TipObject* to = [[[TipObject alloc] init] autorelease];

    sqlite3_stmt *statement;
    NSString* query = [NSString stringWithFormat:@"select ctip,nrange,hrange from tips where id=%d",ran];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
        char *ctip = (char *) sqlite3_column_text(statement, 0);
        NSString *strctip = [[NSString alloc] initWithUTF8String:ctip];
        to.ctip = strctip;
        
        char *nr = (char *) sqlite3_column_text(statement, 1);
        NSString *strnr = [[NSString alloc] initWithUTF8String:nr];
        to.nrange = strnr;
        
        char *hr = (char *) sqlite3_column_text(statement, 2);
        NSString *strhr = [[NSString alloc] initWithUTF8String:hr];
        to.hrange = strhr;
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    return to;
}


-(NSArray*) selectHeroForDiaoDong:(int)king_id targetCityID:(int)cid
{
    NSMutableArray* herolist = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);

    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select id,cname,city,headImage,strength,intelligence,level,skill1,skill2,skill3,skill4,skill5,troopAttack,troopMental,troopType,troopCount from hero  where owner=%d and city<>%d",king_id,cid];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int hid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            int currentCity = (int) sqlite3_column_int(statement, 2);
            int headImageID = (int) sqlite3_column_int(statement, 3);
            int strength = (int) sqlite3_column_int(statement, 4);
            int intelligence = (int) sqlite3_column_int(statement, 5);
            int level = (int) sqlite3_column_int(statement, 6);
            int skill1 = (int) sqlite3_column_int(statement, 7);
            int skill2 = (int) sqlite3_column_int(statement, 8);
            int skill3 = (int) sqlite3_column_int(statement, 9);
            int skill4 = (int) sqlite3_column_int(statement, 10);
            int skill5 = (int) sqlite3_column_int(statement, 11);
            int tatt = (int) sqlite3_column_int(statement, 12);
            int tmental = (int) sqlite3_column_int(statement, 13);
            int ttype = (int) sqlite3_column_int(statement, 14);
            int tcount = (int) sqlite3_column_int(statement, 15);
            
            HeroObject* ho = [[HeroObject alloc] init];
            ho.cname = cname2;
            ho.heroID = hid;
            ho.cityID = currentCity;
            ho.headImageID = headImageID;
            ho.strength = strength;
            ho.intelligence = intelligence;
            ho.level = level;
            ho.skill1 = skill1;
            ho.skill2 = skill2;
            ho.skill3 = skill3;
            ho.skill4 = skill4;
            ho.skill5 = skill5;
            ho.troopAttack = tatt;
            ho.troopMental = tmental;
            ho.troopType = ttype;
            ho.troopCount = tcount;
            
            [herolist addObject:ho];
            
            
            
            [cname2 release];
        }
        
    }
    
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    return herolist;
}

-(NSArray*) selectAllHeroForAttack:(int)king_id targetCityID:(int)cid
{
    NSMutableArray* herolist = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select id,cname,city,headImage,strength,intelligence,level,skill1,skill2,skill3,skill4,skill5,troopAttack,troopMental,troopType,troopCount from hero  where owner=%d",king_id];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int hid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            int currentCity = (int) sqlite3_column_int(statement, 2);
            int headImageID = (int) sqlite3_column_int(statement, 3);
            int strength = (int) sqlite3_column_int(statement, 4);
            int intelligence = (int) sqlite3_column_int(statement, 5);
            int level = (int) sqlite3_column_int(statement, 6);
            int skill1 = (int) sqlite3_column_int(statement, 7);
            int skill2 = (int) sqlite3_column_int(statement, 8);
            int skill3 = (int) sqlite3_column_int(statement, 9);
            int skill4 = (int) sqlite3_column_int(statement, 10);
            int skill5 = (int) sqlite3_column_int(statement, 11);
            int tatt = (int) sqlite3_column_int(statement, 12);
            int tmental = (int) sqlite3_column_int(statement, 13);
            int ttype = (int) sqlite3_column_int(statement, 14);
            int tcount = (int) sqlite3_column_int(statement, 15);
            
            HeroObject* ho = [[HeroObject alloc] init];
            ho.cname = cname2;
            ho.heroID = hid;
            ho.cityID = currentCity;
            ho.headImageID = headImageID;
            ho.strength = strength;
            ho.intelligence = intelligence;
            ho.level = level;
            ho.skill1 = skill1;
            ho.skill2 = skill2;
            ho.skill3 = skill3;
            ho.skill4 = skill4;
            ho.skill5 = skill5;
            ho.troopAttack = tatt;
            ho.troopMental = tmental;
            ho.troopType = ttype;
            ho.troopCount = tcount;
            
            [herolist addObject:ho];
            
            
            
            [cname2 release];
        }
        
    }
    
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    return herolist;
}

-(int) calcHeroDiaoDongFeet:(int)heroID targetCityID:(int)tcid
{
    int result = 0;
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    sqlite3_stmt *statement;
    int hcid = 0;
    NSString* query = [NSString stringWithFormat:@"select city from hero where id=%d",heroID];
    sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) ;
    sqlite3_step(statement);
    hcid = (int)sqlite3_column_int(statement,0);
    sqlite3_finalize(statement);
    
    query = [NSString stringWithFormat:@"select xpos,ypos from city where id=%d",hcid];
    sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) ;
    sqlite3_step(statement);
    float xpos1 = (float)sqlite3_column_int(statement, 0);
    float ypos1 = (float)sqlite3_column_int(statement, 1);
    sqlite3_finalize(statement);
    
    query = [NSString stringWithFormat:@"select xpos,ypos from city where id=%d",tcid];
    sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) ;
    sqlite3_step(statement);
    float xpos2 = (float)sqlite3_column_int(statement, 0);
    float ypos2 = (float)sqlite3_column_int(statement, 1);
    sqlite3_finalize(statement);
    
    result = (int) sqrtf((xpos1-xpos2)*(xpos1-xpos2) + (ypos1-ypos2)*(ypos1-ypos2));
    sqlite3_close(_database);
    return result;
}

-(void) diaoDongHerolistToCity:(NSArray*)heroIDList targetCityID:(int)tcid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    NSMutableArray* clists = [[NSMutableArray alloc] init];
    [clists addObject:[NSNumber numberWithInt:tcid]];
    sqlite3_stmt *statement;
    
    for (NSNumber* heid in heroIDList) {
        int hid = (int)[heid integerValue];
        query = [NSString stringWithFormat:@"select city from hero where id=%d",hid];
        sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) ;
        sqlite3_step(statement);
        int ccid = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
        [clists addObject:[NSNumber numberWithInt:ccid]];
        
        query = [NSString stringWithFormat:@"update hero set city=%d where id=%d",tcid,hid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
        /*
        if (hid<=11) {
            //capital move
            query = [NSString stringWithFormat:@"update city set capital=0 where id=%d",ccid];
            sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
            query = [NSString stringWithFormat:@"update city set capital=1 where id=%d",tcid];
            sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        }
         */
    }
    //-------------------------------------------
    //now re calculate the owner city army count
    //-------------------------------------------
    int wsum = 0;
    int asum = 0;
    int csum = 0;
    int wisum = 0;
    int bsum = 0;
    for (NSNumber* c  in clists) {
        int cid = (int)[c integerValue];
        query = [NSString stringWithFormat:@"select troopType,troopCount,skill1,skill2,skill3,skill4,skill5,id from hero where city=%d and owner=%d",cid,[ShareGameManager shareGameManager].kingID];
        sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) ;
        while (sqlite3_step(statement)==SQLITE_ROW) {
            int tt = sqlite3_column_int(statement, 0);
            int tc = sqlite3_column_int(statement, 1);
            switch (tt) {
                case 1:
                    wsum += tc;
                    break;
                case 2:
                    asum += tc;
                    break;
                case 3:
                    csum += tc;
                    break;
                case 4:
                    wisum += tc;
                    break;
                case 5:
                    bsum += tc;
                    break;
                default:
                    break;
            
            }
            int skill1 = sqlite3_column_int(statement, 2);
            int skill2 = sqlite3_column_int(statement, 3);
            int skill3 = sqlite3_column_int(statement, 4);
            int skill4 = sqlite3_column_int(statement, 5);
            int skill5 = sqlite3_column_int(statement, 6);
            int hid = sqlite3_column_int(statement, 7);
            if ((skill1==41)||(skill2==41)||(skill3==41)||(skill4==41)||(skill5==41)) {
                //治安
                query = [NSString stringWithFormat:@"update cityWithSpecialHero set cityID=%d where heroID=%d and skillID=41",cid,hid];
                sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
            }
            else if ((skill1==15)||(skill2==15)||(skill3==15)||(skill4==15)||(skill5==15)) {
                //doctor
                query = [NSString stringWithFormat:@"update cityWithSpecialHero set cityID=%d where heroID=%d and skillID=15",cid,hid];
                sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
            }
            else if ((skill1==46)||(skill2==46)||(skill3==46)||(skill4==46)||(skill5==46)) {
                //治水
                query = [NSString stringWithFormat:@"update cityWithSpecialHero set cityID=%d where heroID=%d and skillID=46",cid,hid];
                sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
            }
            
        }
        sqlite3_finalize(statement);
        //update the city table set the new troop count
        query = [NSString stringWithFormat:@"update city set warriorCount=%d,archerCount=%d,cavalryCount=%d,wizardCount=%d,ballistaCount=%d where id=%d",wsum,asum,csum,wisum,bsum,cid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
    }
    
    [clists release];
    sqlite3_close(_database);
}

-(NSArray*) getUnemploymentHeroListFromCity:(int)cid
{
    NSMutableArray* herolist = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select id,cname,city,headImage,strength,intelligence,level,skill1,skill2,skill3,skill4,skill5,troopAttack,troopMental,troopType,troopCount,armyType,article1,article2 from hero  where owner=99 and city=%d",cid];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int hid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            int currentCity = (int) sqlite3_column_int(statement, 2);
            int headImageID = (int) sqlite3_column_int(statement, 3);
            int strength = (int) sqlite3_column_int(statement, 4);
            int intelligence = (int) sqlite3_column_int(statement, 5);
            int level = (int) sqlite3_column_int(statement, 6);
            int skill1 = (int) sqlite3_column_int(statement, 7);
            int skill2 = (int) sqlite3_column_int(statement, 8);
            int skill3 = (int) sqlite3_column_int(statement, 9);
            int skill4 = (int) sqlite3_column_int(statement, 10);
            int skill5 = (int) sqlite3_column_int(statement, 11);
            int tatt = (int) sqlite3_column_int(statement, 12);
            int tmental = (int) sqlite3_column_int(statement, 13);
            int ttype = (int) sqlite3_column_int(statement, 14);
            int tcount = (int) sqlite3_column_int(statement, 15);
            int atype = (int) sqlite3_column_int(statement, 16);
            int a1 = (int) sqlite3_column_int(statement, 17);
            int a2 = (int) sqlite3_column_int(statement, 18);
            
            HeroObject* ho = [[HeroObject alloc] init];
            ho.cname = cname2;
            ho.heroID = hid;
            ho.cityID = currentCity;
            ho.headImageID = headImageID;
            ho.strength = strength;
            ho.intelligence = intelligence;
            ho.level = level;
            ho.skill1 = skill1;
            ho.skill2 = skill2;
            ho.skill3 = skill3;
            ho.skill4 = skill4;
            ho.skill5 = skill5;
            ho.troopAttack = tatt;
            ho.troopMental = tmental;
            ho.troopType = ttype;
            ho.troopCount = tcount;
            ho.armyType = atype;
            ho.article1 = a1;
            ho.article2 = a2;
            
            [herolist addObject:ho];
            
            
            
            [cname2 release];
        }
        
    }
    
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    return herolist;
}

-(void) hireHeroWithID:(int)hid forKing:(int)kid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"update hero set owner=%d where id=%d",kid,hid];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
    
}

-(NSArray*) getHeroListFromCity:(int)cid kingID:(int)kid
{
    NSMutableArray* herolist = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    
    sqlite3_stmt *statement;
    
    NSString* query = [NSString stringWithFormat:@"select id,cname,city,headImage,strength,intelligence,level,skill1,skill2,skill3,skill4,skill5,troopAttack,troopMental,troopType,troopCount,armyType,article1,article2 from hero  where owner=%d and city=%d",kid,cid];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int hid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            int currentCity = (int) sqlite3_column_int(statement, 2);
            int headImageID = (int) sqlite3_column_int(statement, 3);
            int strength = (int) sqlite3_column_int(statement, 4);
            int intelligence = (int) sqlite3_column_int(statement, 5);
            int level = (int) sqlite3_column_int(statement, 6);
            int skill1 = (int) sqlite3_column_int(statement, 7);
            int skill2 = (int) sqlite3_column_int(statement, 8);
            int skill3 = (int) sqlite3_column_int(statement, 9);
            int skill4 = (int) sqlite3_column_int(statement, 10);
            int skill5 = (int) sqlite3_column_int(statement, 11);
            int tatt = (int) sqlite3_column_int(statement, 12);
            int tmental = (int) sqlite3_column_int(statement, 13);
            int ttype = (int) sqlite3_column_int(statement, 14);
            int tcount = (int) sqlite3_column_int(statement, 15);
            int atype = (int) sqlite3_column_int(statement, 16);
            int a1 = (int) sqlite3_column_int(statement, 17);
            int a2 = (int) sqlite3_column_int(statement, 18);
            
            HeroObject* ho = [[HeroObject alloc] init];
            ho.cname = cname2;
            ho.heroID = hid;
            ho.cityID = currentCity;
            ho.headImageID = headImageID;
            ho.strength = strength;
            ho.intelligence = intelligence;
            ho.level = level;
            ho.skill1 = skill1;
            ho.skill2 = skill2;
            ho.skill3 = skill3;
            ho.skill4 = skill4;
            ho.skill5 = skill5;
            ho.troopAttack = tatt;
            ho.troopMental = tmental;
            ho.troopType = ttype;
            ho.troopCount = tcount;
            ho.armyType = atype;
            ho.article1 = a1;
            ho.article2 = a2;
            
            [herolist addObject:ho];
            
            
            
            [cname2 release];
        }
        
    }
    
    sqlite3_finalize(statement);
    
    sqlite3_close(_database);
    return herolist;
}

-(ArticleObject*) getArticleDetailFromID:(int)aid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    query = [NSString stringWithFormat:@"select id,cname,ename,cdesc,edesc,attack,hp,mp,attackRange,moveRange,multiAttack,doubleAttack,gold,wood,iron,requireArmyType,effectTypeID,articleType from articleList where id=%d",aid];
    
    sqlite3_stmt *statement;
    ArticleObject *ao = nil;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            ao = [[[ArticleObject alloc] init] autorelease];
            int aid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            char *ename = (char *) sqlite3_column_text(statement, 2);
            NSString *ename2 = [[NSString alloc] initWithUTF8String:ename];
            char *cdesc = (char *) sqlite3_column_text(statement, 3);
            NSString *cdesc2 = [[NSString alloc] initWithUTF8String:cdesc];
            char *edesc = (char *) sqlite3_column_text(statement, 4);
            NSString *edesc2 = [[NSString alloc] initWithUTF8String:edesc];
            
            ao.aid = aid;
            ao.cname = cname2;
            ao.ename = ename2;
            ao.cdesc = cdesc2;
            ao.edesc = edesc2;
            ao.attack = (int) sqlite3_column_int(statement, 5);
            ao.hp = (int) sqlite3_column_int(statement, 6);
            ao.mp = (int) sqlite3_column_int(statement, 7);
            ao.attackRange = (int) sqlite3_column_int(statement, 8);
            ao.moveRange = (int) sqlite3_column_int(statement, 9);
            ao.multiAttack = (int) sqlite3_column_int(statement, 10);
            ao.doubleAttack = (int) sqlite3_column_int(statement, 11);
            ao.gold = (int) sqlite3_column_int(statement, 12);
            ao.wood = (int) sqlite3_column_int(statement, 13);
            ao.iron = (int) sqlite3_column_int(statement, 14);
            ao.requireArmyType = (int) sqlite3_column_int(statement, 15);
            ao.effectTypeID = (int) sqlite3_column_int(statement, 16);
            ao.articleType = (int) sqlite3_column_int(statement, 17);
            
            [cname2 release];
            [ename2 release];
            [cdesc2 release];
            [edesc2 release];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    return ao;
}

-(NSArray*) getArticleListFromCity:(int)cid
{
    //select aid from articles where cityid = cid
    //for every item in the result set, select * from articlelist where id= aid
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    NSMutableArray* clists = [[NSMutableArray alloc] init];
    //query = [NSString stringWithFormat:@"select id,cname,ename,cdesc,edesc,attack,hp,mp,attackRange,moveRange,multiAttack,doubleAttack,gold,wood,iron,requireArmyType,effectTypeID,articleType from articleList where id in (select aid from articles where cityid=%d)",cid];
    
    sqlite3_stmt *statement;
    query = [NSString stringWithFormat:@"select aid from articles where cityid=%d",cid];
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber* tempaid = [NSNumber numberWithInt:sqlite3_column_int(statement,0)];
            [temp addObject:tempaid];
        }
    }
    sqlite3_finalize(statement);
    
    for (NSNumber* temp_id in temp) {
        int tid = (int)[temp_id integerValue];
        query = [NSString stringWithFormat:@"select id,cname,ename,cdesc,edesc,attack,hp,mp,attackRange,moveRange,multiAttack,doubleAttack,gold,wood,iron,requireArmyType,effectTypeID,articleType from articleList where id=%d",tid];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                ArticleObject* ao = [[ArticleObject alloc] init];
                
                int aid = (int) sqlite3_column_int(statement, 0);
                CCLOG(@"select one article : %d",aid);
                char *cname = (char *) sqlite3_column_text(statement, 1);
                NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
                char *ename = (char *) sqlite3_column_text(statement, 2);
                NSString *ename2 = [[NSString alloc] initWithUTF8String:ename];
                char *cdesc = (char *) sqlite3_column_text(statement, 3);
                NSString *cdesc2 = [[NSString alloc] initWithUTF8String:cdesc];
                char *edesc = (char *) sqlite3_column_text(statement, 4);
                NSString *edesc2 = [[NSString alloc] initWithUTF8String:edesc];
                
                ao.aid = aid;
                ao.cname = cname2;
                ao.ename = ename2;
                ao.cdesc = cdesc2;
                ao.edesc = edesc2;
                ao.attack = (int) sqlite3_column_int(statement, 5);
                ao.hp = (int) sqlite3_column_int(statement, 6);
                ao.mp = (int) sqlite3_column_int(statement, 7);
                ao.attackRange = (int) sqlite3_column_int(statement, 8);
                ao.moveRange = (int) sqlite3_column_int(statement, 9);
                ao.multiAttack = (int) sqlite3_column_int(statement, 10);
                ao.doubleAttack = (int) sqlite3_column_int(statement, 11);
                ao.gold = (int) sqlite3_column_int(statement, 12);
                ao.wood = (int) sqlite3_column_int(statement, 13);
                ao.iron = (int) sqlite3_column_int(statement, 14);
                ao.requireArmyType = (int) sqlite3_column_int(statement, 15);
                ao.effectTypeID = (int) sqlite3_column_int(statement, 16);
                ao.articleType = (int) sqlite3_column_int(statement, 17);
                
                [clists addObject:ao];
                
                [cname2 release];
                [ename2 release];
                [cdesc2 release];
                [edesc2 release];
            }
            
        }
        sqlite3_finalize(statement);
    }
    [temp removeAllObjects];
    [temp release];
    
    /*
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            ArticleObject* ao = [[ArticleObject alloc] init];
            
            int aid = (int) sqlite3_column_int(statement, 0);
            CCLOG(@"select one article : %d",aid);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            char *ename = (char *) sqlite3_column_text(statement, 2);
            NSString *ename2 = [[NSString alloc] initWithUTF8String:ename];
            char *cdesc = (char *) sqlite3_column_text(statement, 3);
            NSString *cdesc2 = [[NSString alloc] initWithUTF8String:cdesc];
            char *edesc = (char *) sqlite3_column_text(statement, 4);
            NSString *edesc2 = [[NSString alloc] initWithUTF8String:edesc];
            
            ao.aid = aid;
            ao.cname = cname2;
            ao.ename = ename2;
            ao.cdesc = cdesc2;
            ao.edesc = edesc2;
            ao.attack = (int) sqlite3_column_int(statement, 5);
            ao.hp = (int) sqlite3_column_int(statement, 6);
            ao.mp = (int) sqlite3_column_int(statement, 7);
            ao.attackRange = (int) sqlite3_column_int(statement, 8);
            ao.moveRange = (int) sqlite3_column_int(statement, 9);
            ao.multiAttack = (int) sqlite3_column_int(statement, 10);
            ao.doubleAttack = (int) sqlite3_column_int(statement, 11);
            ao.gold = (int) sqlite3_column_int(statement, 12);
            ao.wood = (int) sqlite3_column_int(statement, 13);
            ao.iron = (int) sqlite3_column_int(statement, 14);
            ao.requireArmyType = (int) sqlite3_column_int(statement, 15);
            ao.effectTypeID = (int) sqlite3_column_int(statement, 16);
            ao.articleType = (int) sqlite3_column_int(statement, 17);
            
            [clists addObject:ao];
            
            [cname2 release];
            [ename2 release];
            [cdesc2 release];
            [edesc2 release];
        }
        
    }
     */
    //sqlite3_finalize(statement);
    sqlite3_close(_database);
    
    return clists;
}

-(void) addArticleForID:(int)aid cityID:(int)cid
{
    CCLOG(@"add article to sqlite , arid : %d,  cityid : %d",aid,cid);
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    query = [NSString stringWithFormat:@"insert into articles values(null,%d,%d)",aid,cid];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
    
}

-(void) removeArticleForID:(int)aid cityID:(int)cid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    query = [NSString stringWithFormat:@"delete from articles where rowid = (select rowid from articles where aid=%d and cityid=%d limit 1) ",aid,cid];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
}

-(void) updateHeroaddArticle:(int)heroID newArticle:(int)aid articlePos:(int)posID
{
    //if hero has already a item in the pos , remove it from hero and add article to articles table
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    query = [NSString stringWithFormat:@"select city,article1,article2 from hero where id=%d",heroID];
    sqlite3_stmt *statement;
    int oldcityID = 0;
    int a1 = 0;
    int a2 = 0;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            oldcityID = (int) sqlite3_column_int(statement, 0);
            a1 = (int) sqlite3_column_int(statement, 1);
            a2 = (int) sqlite3_column_int(statement, 2);
        }
    }
    sqlite3_finalize(statement);
    if (posID == 1) {
        //check a1 != 0 , then add a new article to the articles table
        if (a1 != 0) {
            query = [NSString stringWithFormat:@"insert into articles values(null,%d,%d)",a1,oldcityID];
            sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        }
        //update the hero table set article1 = new id
        query = [NSString stringWithFormat:@"update hero set article1=%d where id=%d",aid,heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (posID == 2) {
        //check a2
        if (a2 != 0) {
            query = [NSString stringWithFormat:@"insert into articles values(null,%d,%d)",a2,oldcityID];
            sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        }
        query = [NSString stringWithFormat:@"update hero set article2=%d where id=%d",aid,heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    
    //finally remove the new article from the articles table
    query = [NSString stringWithFormat:@"delete from articles where rowid = (select rowid from articles where aid=%d and cityid=%d limit 1) ",aid,oldcityID];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    sqlite3_close(_database);
}

-(void) removeArticleFromHero:(int)heroID cityID:(int)cid article:(int)aid articlePos:(int)posID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    if (posID == 1) {
        //check a1 != 0 , then add a new article to the articles table
        query = [NSString stringWithFormat:@"insert into articles values(null,%d,%d)",aid,cid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);

        //update the hero table set article1 = new id
        query = [NSString stringWithFormat:@"update hero set article1=0 where id=%d",heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (posID == 2) {
        
        query = [NSString stringWithFormat:@"insert into articles values(null,%d,%d)",aid,cid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
        query = [NSString stringWithFormat:@"update hero set article2=0 where id=%d",heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    sqlite3_close(_database);
}

-(HeroObject*) getHeroInfoFromID:(int)hid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"select id,cname,city,headImage,strength,intelligence,level,skill1,skill2,skill3,skill4,skill5,troopAttack,troopMental,troopType,troopCount,armyType,article1,article2,experience,attackImage,defendImage from hero  where id=%d",hid];
    sqlite3_stmt *statement;
    HeroObject* ho = [[[HeroObject alloc] init] autorelease];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int hid = (int) sqlite3_column_int(statement, 0);
            char *cname = (char *) sqlite3_column_text(statement, 1);
            NSString *cname2 = [[NSString alloc] initWithUTF8String:cname];
            int currentCity = (int) sqlite3_column_int(statement, 2);
            int headImageID = (int) sqlite3_column_int(statement, 3);
            int strength = (int) sqlite3_column_int(statement, 4);
            int intelligence = (int) sqlite3_column_int(statement, 5);
            int level = (int) sqlite3_column_int(statement, 6);
            int skill1 = (int) sqlite3_column_int(statement, 7);
            int skill2 = (int) sqlite3_column_int(statement, 8);
            int skill3 = (int) sqlite3_column_int(statement, 9);
            int skill4 = (int) sqlite3_column_int(statement, 10);
            int skill5 = (int) sqlite3_column_int(statement, 11);
            int tatt = (int) sqlite3_column_int(statement, 12);
            int tmental = (int) sqlite3_column_int(statement, 13);
            int ttype = (int) sqlite3_column_int(statement, 14);
            int tcount = (int) sqlite3_column_int(statement, 15);
            int atype = (int) sqlite3_column_int(statement, 16);
            int a1 = (int) sqlite3_column_int(statement, 17);
            int a2 = (int) sqlite3_column_int(statement, 18);
            int exp = (int) sqlite3_column_int(statement, 19);
            ho.armyAttackImageID = sqlite3_column_int(statement, 20);
            ho.armyDefendImageID = sqlite3_column_int(statement, 21);
            
            ho.cname = cname2;
            ho.heroID = hid;
            ho.cityID = currentCity;
            ho.headImageID = headImageID;
            ho.strength = strength;
            ho.intelligence = intelligence;
            ho.level = level;
            ho.skill1 = skill1;
            ho.skill2 = skill2;
            ho.skill3 = skill3;
            ho.skill4 = skill4;
            ho.skill5 = skill5;
            ho.troopAttack = tatt;
            ho.troopMental = tmental;
            ho.troopType = ttype;
            ho.troopCount = tcount;
            ho.armyType = atype;
            ho.article1 = a1;
            ho.article2 = a2;
            ho.experience = exp;
            
            [cname2 release];
        }
    }
    
    
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    
    return ho;
}

-(SkillDBObject*) getSkillInfoFromID:(int)skID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"select skillID,skillLevel,cname,passive,strengthRequire,intelligenceRequire,requireWeather,cost from skillList where skillID=%d",skID];
    sqlite3_stmt *statement;
    SkillDBObject *sdo = [[[SkillDBObject alloc] init] autorelease];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            sdo.skillID = sqlite3_column_int(statement, 0);
            sdo.skillLevel = sqlite3_column_int(statement, 1);
            char *cname = (char *) sqlite3_column_text(statement, 2);
            sdo.cname = [[NSString alloc] initWithUTF8String:cname];
            sdo.passive = sqlite3_column_int(statement, 3);
            sdo.strengthRequire = sqlite3_column_int(statement, 4);
            sdo.intelligenceRequire = sqlite3_column_int(statement, 5);
            sdo.requireWeather = sqlite3_column_int(statement, 6);
            sdo.cost = sqlite3_column_int(statement, 7);
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    
    return sdo;
}

-(NSArray*) getSkillListFromCity:(int)cityID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"select skillID,skillLevel from citySkills where cityID=%d",cityID];
    sqlite3_stmt *statement;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            SkillDBObject *sdo = [[[SkillDBObject alloc] init] autorelease];
            sdo.skillID = sqlite3_column_int(statement, 0);
            sdo.skillLevel = sqlite3_column_int(statement, 1);
            [result addObject:sdo];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    return result;
}

-(void) updateCityTroopCount:(int)tcount withTroopType:(int)ttype withCityID:(int)cid
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query;
    switch (ttype) {
        case 1:
            query = [NSString stringWithFormat:@"select warriorCount from city where id=%d",cid];
            break;
        case 2:
            query = [NSString stringWithFormat:@"select archerCount from city where id=%d",cid];
            break;
        case 3:
            query = [NSString stringWithFormat:@"select cavalryCount from city where id=%d",cid];
            break;
        case 4:
            query = [NSString stringWithFormat:@"select wizardCount from city where id=%d",cid];
            break;
        case 5:
            query = [NSString stringWithFormat:@"select ballistaCount from city where id=%d",cid];
            break;
        default:
            query = [NSString stringWithFormat:@"select warriorCount from city where id=%d",cid];
            break;
    }
    sqlite3_stmt *statement;
    int count=0;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    
    int ncount = count + tcount;
    switch (ttype) {
        case 1:
            query = [NSString stringWithFormat:@"update city set warriorCount=%d where id=%d",ncount,cid];
            break;
        case 2:
            query = [NSString stringWithFormat:@"update city set archerCount=%d where id=%d",ncount,cid];
            break;
        case 3:
            query = [NSString stringWithFormat:@"update city set cavalryCount=%d where id=%d",ncount,cid];
            break;
        case 4:
            query = [NSString stringWithFormat:@"update city set wizardCount=%d where id=%d",ncount,cid];
            break;
        case 5:
            query = [NSString stringWithFormat:@"update city set ballistaCount=%d where id=%d",ncount,cid];
            break;
        default:
            query = [NSString stringWithFormat:@"update city set warriorCount=%d where id=%d",ncount,cid];
            break;
    }
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
    
}

-(void) updateCityTroopCountWithCityID:(int)cid withKingID:(int)kid
{
    //first select all hero from this city.
    int wcount = 0;
    int acount = 0;
    int ccount = 0;
    int wicount = 0;
    int bcount = 0;
    NSArray* heroes = [self getHeroListFromCity:cid kingID:kid];
    for (HeroObject* ho in heroes) {
        switch (ho.troopType) {
            case 1:
                wcount += ho.troopCount;
                break;
            case 2:
                acount += ho.troopCount;
                break;
            case 3:
                ccount += ho.troopCount;
                break;
            case 4:
                wicount += ho.troopCount;
                break;
            case 5:
                bcount += ho.troopCount;
                break;
            default:
                break;
        }
        
    }
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"update city set warriorCount=%d,archerCount=%d,cavalryCount=%d,wizardCount=%d,ballistaCount=%d where id=%d",wcount,acount,ccount,wicount,bcount,cid];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
    
}

-(void) generateRandomMagicTower:(int)cityID towerLevel:(int)tlev
{
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"select skillID,skillLevel from skillList where canLearn=1 and skillLevel=%d",tlev];
    sqlite3_stmt *statement;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            SkillDBObject *sdo = [[[SkillDBObject alloc] init] autorelease];
            sdo.skillID = sqlite3_column_int(statement, 0);
            sdo.skillLevel = sqlite3_column_int(statement, 1);
            [result addObject:sdo];
        }
    }
    sqlite3_finalize(statement);
    
    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
    int tcount = 9;
    if (tlev == 2) {
        tcount = 5;
    }
    else if (tlev == 3) {
        tcount = 3;
    }
    
    int tlen = (int)[result count];
    
    while ([randomSet count] < tcount) {
        int rid = arc4random()%tlen;
        SkillDBObject *sdo = [result objectAtIndex:rid];
        [randomSet addObject:sdo];
    }
    
    for (SkillDBObject* sdo in randomSet) {
        query = [NSString stringWithFormat:@"insert into citySkills values(null,%d,%d,%d)",sdo.skillID,sdo.skillLevel,cityID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    
    [randomSet release];
    [result release];
    sqlite3_close(_database) ;
    
}

-(void) heroLearnSkill:(int)heroID skill:(int)skillID skillPos:(int)skillPosID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"update hero set skill1=%d where id=%d",skillID,heroID]; ;
    
    if (skillPosID == 2) {
        query = [NSString stringWithFormat:@"update hero set skill2=%d where id=%d",skillID,heroID];
    }
    else if (skillPosID == 3) {
        query = [NSString stringWithFormat:@"update hero set skill3=%d where id=%d",skillID,heroID];
    }
    else if (skillPosID == 4) {
        query = [NSString stringWithFormat:@"update hero set skill4=%d where id=%d",skillID,heroID];
    }
    else if (skillPosID == 5) {
        query = [NSString stringWithFormat:@"update hero set skill5=%d where id=%d",skillID,heroID];
    }
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    sqlite3_stmt *statement;
    
    //if skill is 冶炼0、土豪1、伐木2、医师15、治水46、治安41中的一种，需要update autoIncResource或者cityWithSpecialHero表
    if (skillID==0) {
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",_kingID];
        int oldinc = 0;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 2);
            }
        }
        sqlite3_finalize(statement);
        oldinc += 10;
        query = [NSString stringWithFormat:@"update autoIncResource set incIron=%d where kingID=%d",oldinc,_kingID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
    }
    else if (skillID==1) {
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",_kingID];
        int oldinc = 0;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        oldinc += 100;
        query = [NSString stringWithFormat:@"update autoIncResource set incGold=%d where kingID=%d",oldinc,_kingID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (skillID==2) {
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",_kingID];
        int oldinc = 0;
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 1);
            }
        }
        sqlite3_finalize(statement);
        oldinc += 10;
        query = [NSString stringWithFormat:@"update autoIncResource set incWood=%d where kingID=%d",oldinc,_kingID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (skillID==15) {
        int cio = 1;
        query = [NSString stringWithFormat:@"select city from hero where id=%d",heroID];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                cio = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        query = [NSString stringWithFormat:@"insert into cityWithSpecialHero values(%d,%d,15)",cio,heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (skillID==41) {
        int cio = 1;
        query = [NSString stringWithFormat:@"select city from hero where id=%d",heroID];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                cio = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        query = [NSString stringWithFormat:@"insert into cityWithSpecialHero values(%d,%d,41)",cio,heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if (skillID==46) {
        int cio = 1;
        query = [NSString stringWithFormat:@"select city from hero where id=%d",heroID];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                cio = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        query = [NSString stringWithFormat:@"insert into cityWithSpecialHero values(%d,%d,46)",cio,heroID];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    
    
    sqlite3_close(_database);
}

-(void) lostHero:(int)hid withOwnerID:(int)oid
{

    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"select city,skill1,skill2,skill3,skill4,skill5 from hero where id=%d",hid];
    sqlite3_stmt *statement;
    int cio =1;
    int skill1=99;
    int skill2=99;
    int skill3=99;
    int skill4=99;
    int skill5=99;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            cio = sqlite3_column_int(statement, 0);
            skill1 = sqlite3_column_int(statement, 1);
            skill2 = sqlite3_column_int(statement, 2);
            skill3 = sqlite3_column_int(statement, 3);
            skill4 = sqlite3_column_int(statement, 4);
            skill5 = sqlite3_column_int(statement, 5);
        }
    }
    sqlite3_finalize(statement);
    int ncio = arc4random()%84 + 1;
    //hero set owner to 99
    
    //hero set city to a random city(1-84)
    query = [NSString stringWithFormat:@"update hero set city=%d,owner=99 where id=%d",ncio,hid];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    //if hero has the skill , update the autoIncResource table or cityWithSpecialHero table.
    if ((skill1==15)||(skill2==15)||(skill3==15)||(skill4==15)||(skill5==15)) {
        //doctor
        query = [NSString stringWithFormat:@"delete from cityWithSpecialHero where heroID=%d and skillID=15",hid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if ((skill1==41)||(skill2==41)||(skill3==41)||(skill4==41)||(skill5==41)) {
        //security
        query = [NSString stringWithFormat:@"delete from cityWithSpecialHero where heroID=%d and skillID=41",hid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if ((skill1==46)||(skill2==46)||(skill3==46)||(skill4==46)||(skill5==46)) {
        //water wheel
        query = [NSString stringWithFormat:@"delete from cityWithSpecialHero where heroID=%d and skillID=46",hid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    else if ((skill1==0)||(skill2==0)||(skill3==0)||(skill4==0)||(skill5==0)) {
        //iron - 10 autoIncResource
        int oldinc = 0;
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",oid];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 2);
            }
        }
        oldinc -= 10;
        query = [NSString stringWithFormat:@"update autoIncResource set incIron=%d where kingID=%d",oldinc,oid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
    }
    else if ((skill1==1)||(skill2==1)||(skill3==1)||(skill4==1)||(skill5==1)) {
        //gold - 100
        int oldinc = 0;
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",oid];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 0);
            }
        }
        oldinc -= 100;
        query = [NSString stringWithFormat:@"update autoIncResource set incGold=%d where kingID=%d",oldinc,oid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
        
    }
    else if ((skill1==2)||(skill2==2)||(skill3==2)||(skill4==2)||(skill5==2)) {
        //wood - 10
        int oldinc = 0;
        query = [NSString stringWithFormat:@"select incGold,incWood,incIron from autoIncResource where kingID=%d",oid];
        if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                oldinc = sqlite3_column_int(statement, 1);
            }
        }
        oldinc -= 10;
        query = [NSString stringWithFormat:@"update autoIncResource set incWood=%d where kingID=%d",oldinc,oid];
        sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    }
    
}

-(NSArray*) getBotCityBestSixHero:(int)cityID
{
    return nil;
}

-(void) addSkillToBotCityHero:(int)cityID forKing:(int)kid
{
    //先判断第一个技能是不是被动，是则不要再增加被动技能了。每个武将要有攻击性两种，辅助性两种，被动一种，如果被动只能有冶铁等，则换为主动的攻击性技能。
    
    
    
    
}

-(void) heroRecruitTroop:(int)heroID newTroopCount:(int)nc
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = [NSString stringWithFormat:@"update hero set troopCount=%d where id=%d",nc,heroID];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    sqlite3_close(_database);
}

-(void) updateHeroTroopCount:(int)hid1 withCount1:(int)c1 hero2:(int)hid2 withCount2:(int)c2 withTroopType:(int)tt
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query ;
    if (c1 == 0) {
        query =[NSString stringWithFormat:@"update hero set troopType=0,troopCount=%d where id=%d",c1,hid1];
    }
    else {
        query = [NSString stringWithFormat:@"update hero set troopType=%d,troopCount=%d where id=%d",tt,c1,hid1];
    }
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    if (c2 == 0) {
        query = [NSString stringWithFormat:@"update hero set troopType=0,troopCount=%d where id=%d",c2,hid2];
    }
    else {
        query = [NSString stringWithFormat:@"update hero set troopType=%d,troopCount=%d where id=%d",tt,c2,hid2];
    }
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    sqlite3_close(_database);
}



-(void) saveGameToRecord:(int)recID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    CCLOG(@"current db path:%@",curdb);
    
    NSString *f = [NSString stringWithFormat:@"save%d.db",recID];
    NSString *savefile = [rootpath stringByAppendingPathComponent:f];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savefile isDirectory:NO]) {
        CCLOG(@"remove old save file....");
        [[NSFileManager defaultManager] removeItemAtPath:savefile error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:curdb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:savefile];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:curdb];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
}


//---------------------------
//  the save file must exist, not check if it's exist here
//---------------------------
-(void) loadGameFromRecord:(int)recID
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    
    NSString *f = [NSString stringWithFormat:@"save%d.db",recID];
    NSString *savefile = [rootpath stringByAppendingPathComponent:f];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savefile isDirectory:NO] == NO) {
        CCLOG(@"save file not exist....");
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:curdb isDirectory:NO]) {
        CCLOG(@"remove curdb file....");
        [[NSFileManager defaultManager] removeItemAtPath:curdb error:nil];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:curdb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:curdb];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:savefile];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
}

-(void) autoSaveCurrentDB
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    
    NSString *savefile = [rootpath stringByAppendingPathComponent:@"autosave.db"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savefile isDirectory:NO]) {
        CCLOG(@"save file removing....");
        [[NSFileManager defaultManager] removeItemAtPath:savefile error:nil];
        return;
    }
    
    [[NSFileManager defaultManager] createFileAtPath:curdb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:savefile];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:curdb];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
}

//map progress
-(void) saveProgress
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = @"delete from playerInfo";  //delete all record
    
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    //now insert into playerinfo
    query = [NSString stringWithFormat:@"insert into playerInfo values(%d,%d,%d,%d,%d,%d,%d,0,%d",_kingID,_year,_month,_day,_gold,_wood,_iron,_gameDifficulty];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    sqlite3_close(_database);
    
    //now copy the file to auto.db
    NSString *autodb = [rootpath stringByAppendingPathComponent:@"auto.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:autodb isDirectory:NO]) {
        CCLOG(@"remove old auto save file....");
        [[NSFileManager defaultManager] removeItemAtPath:autodb error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:autodb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:autodb];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:curdb];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
    
}

-(void) saveBattleProgress
{
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = @"delete from playerInfo";  //delete all record
    
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    //now insert into playerinfo
    query = [NSString stringWithFormat:@"insert into playerInfo values(%d,%d,%d,%d,%d,%d,%d,1,%d",_kingID,_year,_month,_day,_gold,_wood,_iron,_gameDifficulty];
    sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    
    
    //now update the battleInfo and battleHeroInfo table......
    //****************************************
    
    sqlite3_close(_database);
    
    //now copy the file to auto.db
    NSString *autodb = [rootpath stringByAppendingPathComponent:@"auto.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:autodb isDirectory:NO]) {
        CCLOG(@"remove old auto save file....");
        [[NSFileManager defaultManager] removeItemAtPath:autodb error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:autodb contents:nil attributes:nil];
    NSFileHandle *outFileHandle = [NSFileHandle fileHandleForWritingAtPath:autodb];//写管道
    NSFileHandle *inFileHandle = [NSFileHandle fileHandleForReadingAtPath:curdb];//读管道
    NSData *data =[inFileHandle readDataToEndOfFile];
    [outFileHandle writeData:data];
    [outFileHandle closeFile];
    [inFileHandle closeFile];
}


-(CGPoint) getPositionTransform:(CGPoint)heroPos
{
    CGPoint p;
    int w = heroPos.x / 80;
    int h = heroPos.y / 80;
    p = ccp(w, h);
    return p;
    //if p.h == 0 or == 11 is not available for move grid
}

//判断转换后的坐标是否可以行走
-(BOOL) isValidPosition:(CGPoint)pos
{
    BOOL res = NO;
    if ((pos.x >=0)&&(pos.x<=GRID_MAX_WIDTH)) {
        if ((pos.y>0)&&(pos.y <GRID_MAX_HEIGHT)) {
            res = YES;
        }
    }
    return res;
}

//获得依据该strength和intelligence值
-(NSArray*) getSkillAvailableForStrength:(int)strength forIntelligence:(int)intelligence
{
    NSMutableArray* skills = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = @"select skillID,strengthRequire,intelligenceRequire from skillList where passive==0 and canLearn=1";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int skillid = sqlite3_column_int(statement, 0);
            int recstr = sqlite3_column_int(statement, 1);
            int recint = sqlite3_column_int(statement, 2);
            if ((strength>= recstr)&&(intelligence >= recint)) {
                //不需要祈雨和晴天
                if ((skillid != 34)&&(skillid != 42)) {
                    NSNumber* skid = [NSNumber numberWithInt:skillid];
                    [skills addObject:skid];
                }
                
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    
    return skills;
}

-(NSArray*) getPassiveSkillAvailableForStrength:(int)strength forIntelligence:(int)intelligence
{
    NSMutableArray* skills = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *rootpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *curdb = [rootpath stringByAppendingPathComponent:@"current.db"];
    sqlite3* _database;
    sqlite3_open([curdb UTF8String], &_database);
    NSString* query = @"select skillID,strengthRequire,intelligenceRequire from skillList where passive==1 and canLearn=1";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int skillid = sqlite3_column_int(statement, 0);
            int recstr = sqlite3_column_int(statement, 1);
            int recint = sqlite3_column_int(statement, 2);
            if ((strength>= recstr)&&(intelligence >= recint)) {
                //不需要土豪 冶炼 伐木 治水 治安 医生
                if ((skillid != 0)&&(skillid != 1)&&(skillid!=2)&&(skillid!=15)&&(skillid!=41)&&(skillid!=46)) {
                    NSNumber* skid = [NSNumber numberWithInt:skillid];
                    [skills addObject:skid];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(_database);
    
    return skills;
}

-(void) generateHeroSkill:(int)hid
{
    //first get hero , get skill1 ,
    //if skill1 is passive , then get the non passive skill list
    //arcrandom() 4 skill , update the hero skill table
    
    //if skill1 is non passive, then get one passive skill , and get arcrandom() 3 skill, update the hero skill table
    //must remove the skill1 from the arraylist at first
    
}


@end
