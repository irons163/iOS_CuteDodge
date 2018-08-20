//
//  GameScene.h
//  Easy_Dodge
//

//  Copyright (c) 2015年 irons. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
//#import "GameViewController.h"

//@class GameViewController;
@protocol gameDelegate;

@interface GameScene : SKScene
//extern NORMAL_MODE;

@property (weak) id<gameDelegate> gameDelegate;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnMoveTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnCreateFootboardTimeInterval;

-(void)setGameRun:(bool)isrun;
-(int)gameTime;
-(void)restartGame;

@end
