//
//  GameViewController.h
//  Easy_Dodge
//

//  Copyright (c) 2015年 irons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameOverViewController.h"
#import "GameScene.h"

//@class GameScene;

@import iAd;

@protocol gameDelegate <NSObject>

-(void)showGameOver;
-(void)showRankView;
-(void)restartGame;

@end

@protocol pauseGameDelegate <NSObject>
- (void)pauseGame;
@end

@interface GameViewController : UIViewController<gameDelegate, pauseGameDelegate,ADBannerViewDelegate>

+(GameScene*)GameScene;

@end
