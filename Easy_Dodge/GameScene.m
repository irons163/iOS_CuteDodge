//
//  GameScene.m
//  Easy_Dodge
//
//  Created by irons on 2015/7/2.
//  Copyright (c) 2015年 irons. All rights reserved.
//

#import "GameScene.h"
#import "TextureHelper.h"
#import "CommonUtil.h"
#import "GameViewController.h"
#import "GameCenterUtil.h"

#define DEFAULT_HP  20

const int stay = 0;
const int left = 1;
const int right = 2;

const int moveDestance = 15;

const static int PLAYER_STAY_LEFT_INDEX = 0;
const static int PLAYER_STAY_RIGHT_INDEX = 1;
const static int PLAYER_LEFT_WALK01_INDEX = 2;
const static int PLAYER_LEFT_WALK02_INDEX = 3;
const static int PLAYER_LEFT_WALK03_INDEX = 4;
const static int PLAYER_RIGHT_WALK01_INDEX = 5;
const static int PLAYER_RIGHT_WALK02_INDEX = 6;
const static int PLAYER_RIGHT_WALK03_INDEX = 7 ;
const static int PLAYER_LEFT_INJURE_INDEX = 8;
const static int PLAYER_RIGHT_INJURE_INDEX = 9;

const int backgroundLayerZPosition = -3;

@implementation GameScene {
    int walkCount;
    int gameTime;
    float fireballInterval;
    bool isGameRun;
    bool isPressLeftMoveBtn;
    bool isPressRightMoveBtn;
    int key;
    bool isMoving;
    
    NSTimer *theGameTimer;
    
    SKSpriteNode *backgroundNode;
    SKLabelNode *clearedMonsterLabel;
    SKSpriteNode *player;
    SKSpriteNode *leftKey;
    SKSpriteNode *rightKey;
    SKSpriteNode *rankBtn;
    SKSpriteNode *pauseBtnNode;
    
    NSMutableArray *fireballs;
    NSMutableArray *footbardsByLines;
    
    NSArray *hamsterDefaultArray;
    NSArray *rightNsArray;
    NSArray *leftNsArray;
}

- (void)initTextures {
    hamsterDefaultArray = [TextureHelper getTexturesWithSpriteSheetNamed:@"hamster" withinNode:nil sourceRect:CGRectMake(0, 0, 192, 200) andRowNumberOfSprites:2 andColNumberOfSprites:7
                                                                sequence:@[@7]];
    
    rightNsArray = [TextureHelper getTexturesWithSpriteSheetNamed:@"hamster" withinNode:nil sourceRect:CGRectMake(0, 0, 192, 200) andRowNumberOfSprites:2 andColNumberOfSprites:7
                                                         sequence:@[@5,@6]];
    
    leftNsArray = [TextureHelper getTexturesWithSpriteSheetNamed:@"hamster" withinNode:nil sourceRect:CGRectMake(0, 0, 192, 200) andRowNumberOfSprites:2 andColNumberOfSprites:7
                                                        sequence:@[@5,@6]];
}

- (void)initGameTimeTextLabel {
    clearedMonsterLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    clearedMonsterLabel.text = @"00:00:00";
    clearedMonsterLabel.fontSize = 20;
    clearedMonsterLabel.color = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    clearedMonsterLabel.position = CGPointMake(clearedMonsterLabel.frame.size.width/2, self.frame.size.height - 100 - clearedMonsterLabel.frame.size.height);
    
    [self addChild:clearedMonsterLabel];
}

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    fireballInterval = 0.7;
    isGameRun = true;
    isMoving = false;
    
    [self initTextures];
    
    [self initGameTimeTextLabel];
    
    fireballs = [NSMutableArray array];
    footbardsByLines = [NSMutableArray array];
    
    backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"bgMainMenu"];
    backgroundNode.size = self.frame.size;
    backgroundNode.anchorPoint = CGPointMake(0, 0);
    backgroundNode.zPosition = backgroundLayerZPosition;
    [self addChild:backgroundNode];
    
    leftKey = [SKSpriteNode spriteNodeWithImageNamed:@"left_keyboard_btn"];
    leftKey.size = CGSizeMake(80, 80);
    leftKey.position = CGPointMake(0, 0);
    leftKey.anchorPoint = CGPointMake(0, 0);
    
    rightKey = [SKSpriteNode spriteNodeWithImageNamed:@"right_keyboard_btn"];
    rightKey.size = CGSizeMake(80, 80);
    rightKey.position = CGPointMake(self.frame.size.width - rightKey.size.width, 0);
    rightKey.anchorPoint = CGPointMake(0, 0);
    
    player = [SKSpriteNode spriteNodeWithTexture:hamsterDefaultArray[PLAYER_STAY_LEFT_INDEX]];
    player.size = CGSizeMake(60, 60);
    player.position = CGPointMake(self.frame.size.width/2, player.size.height/2);
    
    [self addChild:leftKey];
    [self addChild:rightKey];
    [self addChild:player];
    
    rankBtn = [SKSpriteNode spriteNodeWithImageNamed:@"leader_board_btn"];
    rankBtn.size = CGSizeMake(42,42);
    rankBtn.anchorPoint = CGPointMake(0, 0);
    rankBtn.position = CGPointMake(self.frame.size.width - rankBtn.size.width, self.frame.size.height/2);
    rankBtn.zPosition = backgroundLayerZPosition;
    [self addChild:rankBtn];
    
    pauseBtnNode = [SKSpriteNode spriteNodeWithImageNamed:@"game_resume_btn"];
    pauseBtnNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 100);
    pauseBtnNode.size = CGSizeMake(50, 50);
    pauseBtnNode.hidden = true;
    [self addChild:pauseBtnNode];
    
    [self initGameTimer];
}

- (void)setGameTimeNodeText {
    NSString *s = [CommonUtil timeFormatted:gameTime];
    
    clearedMonsterLabel.text = s;
    clearedMonsterLabel.position = CGPointMake(clearedMonsterLabel.frame.size.width / 2, self.frame.size.height - 100 - clearedMonsterLabel.frame.size.height);
}

- (void)initGameTimer {
    theGameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(countGameTime)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)countGameTime {
    
    if (!isGameRun) {
        return;
    }
    
    gameTime++;
    
    if (gameTime == 60) {
        fireballInterval = 0.6;
    } else if (gameTime == 120) {
        fireballInterval = 0.5;
    } else if (gameTime == 180) {
        fireballInterval = 0.4;
    } else if (gameTime == 240) {
        fireballInterval = 0.3;
    }
    
    [self setGameTimeNodeText];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (pauseBtnNode.hidden == false) {
            if(CGRectContainsPoint(pauseBtnNode.calculateAccumulatedFrame, location)) {
                [self setGameRun:YES];
                [self setPaused:false];
            }
        } else if (CGRectContainsPoint(leftKey.calculateAccumulatedFrame, location)) {
            
            isPressLeftMoveBtn = true;
            key = left;
            
        } else if (CGRectContainsPoint(rightKey.calculateAccumulatedFrame, location)) {
            
            isPressRightMoveBtn = true;
            key = right;
        } else if (CGRectContainsPoint(rankBtn.calculateAccumulatedFrame, location)) {
            [self.gameDelegate showRankView];
        }
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if(isPressLeftMoveBtn && isPressRightMoveBtn){
            
            if(CGRectContainsPoint(leftKey.calculateAccumulatedFrame, location)){
                isPressLeftMoveBtn = false;
                key = right;
            }else if(CGRectContainsPoint(rightKey.calculateAccumulatedFrame, location)){
                isPressRightMoveBtn = false;
                key = left;
            }
            
        }else if(isPressLeftMoveBtn || isPressRightMoveBtn) {
            if(CGRectContainsPoint(leftKey.calculateAccumulatedFrame, location) || CGRectContainsPoint(rightKey.calculateAccumulatedFrame, location)){
                
                if (isPressLeftMoveBtn) {
                    isPressLeftMoveBtn = !isPressLeftMoveBtn;
                } else if (isPressRightMoveBtn) {
                    isPressRightMoveBtn = !isPressRightMoveBtn;
                }
                
                [player removeAllActions];
                
                if(key == left){
                    player.texture = hamsterDefaultArray[PLAYER_STAY_LEFT_INDEX];
                }else if(key == right){
                    player.texture = hamsterDefaultArray[PLAYER_STAY_LEFT_INDEX];
                }
                
                key = stay;
                isMoving = false;
                player.xScale = 1;
            }
        }
    }
}

- (void)setGameRun:(bool)isrun {
    [self setViewRun:isrun];
    [self setPauseBtnHidden:isrun];
}

- (void)setPauseBtnHidden:(bool)isrun {
    pauseBtnNode.hidden = isrun;
}

- (void)setViewRun:(bool)isrun {
    isGameRun = isrun;
    
    for (int i = 0; i < [self children].count; i++) {
        SKNode *n = [self children][i];
        n.paused = !isrun;
    }
}

- (void)beHited {
    [self setViewRun:false];
    GameCenterUtil *gameCenterUtil = [GameCenterUtil sharedInstance];
    [gameCenterUtil reportScore:gameTime forCategory:@"QuteDodgeLeaderBoard"];
    [self.gameDelegate showGameOver];
}

- (void)checkPlayerMoved {
    if (key == left) {
        player.xScale = 1;
        player.position = CGPointMake(player.position.x - moveDestance - player.size.width / 2 < 0 ? player.size.width / 2 : player.position.x - moveDestance, player.position.y);
        
        if(!isMoving){
            isMoving = true;
            SKAction* move = [SKAction animateWithTextures:leftNsArray timePerFrame:0.2];
            [player runAction:[SKAction repeatActionForever:move]];
        }
    } else if (key == right) {
        player.position = CGPointMake(player.position.x + moveDestance + player.size.width / 2 > self.frame.size.width ? self.frame.size.width - player.size.width / 2 : player.position.x + moveDestance, player.position.y);
        
        player.xScale = -1;
        if (!isMoving) {
            isMoving = true;
            SKAction *move = [SKAction animateWithTextures:rightNsArray timePerFrame:0.2];
            [player runAction:[SKAction repeatActionForever:move]];
        }
    }
}

- (void)clearFireballAfterHitFootboard:(NSMutableArray *)fireballWillClear {
    for (SKSpriteNode *fireball in fireballWillClear) {
        [fireball removeFromParent];
        [fireballs removeObject:fireball];
    }
    [fireballWillClear removeAllObjects];
}

- (void)clearFireball {
    for (SKSpriteNode *fireball in fireballs) {
        [fireball removeFromParent];
        [fireballs removeObject:fireball];
    }
}

- (int)gameTime {
    return gameTime;
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    self.lastSpawnMoveTimeInterval += timeSinceLast;
    self.lastSpawnCreateFootboardTimeInterval += timeSinceLast;
    
    for(int i = 0; i < fireballs.count; i++){
        SKSpriteNode * fireballForCheck = fireballs[i];
        CGRect playerFreme = player.calculateAccumulatedFrame;
        CGRect fireballFreme = fireballForCheck.calculateAccumulatedFrame;
        float collisionWdith = fireballFreme.size.width/3;
        float collisionHeight = fireballFreme.size.height/2;
        CGRect fireballCollisionFrame = CGRectMake(fireballFreme.origin.x + fireballFreme.size.width/2 - collisionWdith/2, fireballFreme.origin.y + collisionHeight/3*2, collisionWdith, collisionHeight);
        
        if (CGRectIntersectsRect(fireballCollisionFrame, playerFreme)) {
            [self beHited];
        }
    }
    
    if (self.lastSpawnTimeInterval > fireballInterval) {
        self.lastSpawnTimeInterval = 0;
        
        SKSpriteNode *fireball = [SKSpriteNode spriteNodeWithImageNamed:@"fireball"];
        fireball.size = CGSizeMake(50, 70);
        int x = arc4random_uniform(self.frame.size.width - fireball.size.width);
        fireball.anchorPoint = CGPointMake(0, 0);
        fireball.position = CGPointMake(x, self.frame.size.height);
        
        [self addChild:fireball];
        [fireballs addObject:fireball];
        
        SKAction *move = [SKAction moveToY:0 duration:1.5];
        SKAction *end = [SKAction runBlock:^{
            [fireball removeFromParent];
            [fireballs removeObject:fireball];
        }];
        
        [fireball runAction:[SKAction sequence:@[move, end]]];
    }
    
    if (self.lastSpawnMoveTimeInterval > 0.1) {
        self.lastSpawnMoveTimeInterval = 0;
        
        [self checkPlayerMoved];
    }
    
    if (self.lastSpawnCreateFootboardTimeInterval > 3.0) {
        self.lastSpawnCreateFootboardTimeInterval = 0;
    }
}

- (void)update:(CFTimeInterval)currentTime {

    if(!isGameRun){
        [self setViewRun:false];
        return;
    }
    
    /* Called before each frame is rendered */
    // 获取时间增量
    // 如果我们运行的每秒帧数低于60，我们依然希望一切和每秒60帧移动的位移相同
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // 如果上次更新后得时间增量大于1秒
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

@end
