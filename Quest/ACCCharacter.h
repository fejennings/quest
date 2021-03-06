//
//  ACCCharacter.h
//  Quest
//
//  Created by Frank Jennings on 11/17/13.
//  Copyright (c) 2013 Acceltius. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface ACCCharacter : SKNode

@property (nonatomic, assign) int idealX;
@property (nonatomic, assign) int idealY;
@property (nonatomic, assign) BOOL theLeader;
@property (nonatomic, assign) BOOL followingEnabled;
@property (nonatomic, assign) float currentHealth;
@property (nonatomic, assign) float maxHealth;
@property (nonatomic, assign) BOOL  hasOwnHealth;
@property (nonatomic, assign) int charState;
@property (nonatomic, assign) float charSpeed;
@property (nonatomic, assign) BOOL isDying;


-(void)createWithDictionary: (NSDictionary*) charData;
-(void)update;
-(void)moveLeftWithPlace:(NSNumber*) place;
-(void)moveRightWithPlace:(NSNumber*) place;
-(void)moveUpWithPlace:(NSNumber*) place;
-(void)moveDownWithPlace:(NSNumber*) place;
-(void)makeLeader;
-(int)returnDirection;
-(void)stopMoving;
-(void)stopMovingFromWallHit;
-(void)stopInFormation:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;
-(void)followIntoPositionWithDirection:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;
-(void)attack;
-(void)rest:(int) direction;
-(void) doDamageWithAmount:(float)amount;
-(void) removeLeader;
-(BOOL)isTouchable;
-(void)touched;


@end

