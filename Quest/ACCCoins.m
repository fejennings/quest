//
//  ACCCoins.m
//  Quest
//
//  Created by Frank Jennings on 3/23/14.
//  Copyright (c) 2014 Acceltius. All rights reserved.
//

#import "ACCCoins.h"
#import "ACCLevel.h"
#import "Constants.h"

@interface ACCCoins() {
    
    SKSpriteNode* coin;
}

@end

@implementation ACCCoins



-(id) init {
    if (self = [super init]) {
        
        //do inititalization
        
        
    }
    
    return self;
}

-(void)createWithBaseImage:(NSString*)baseImage andLocation:(CGPoint)coinLocation{
    
    //NSLog(@" %@",baseImage);
    //NSLog(@"x %f y %f",coinLocation.x,coinLocation.y);
    coin=[SKSpriteNode  spriteNodeWithImageNamed:baseImage];
    self.position = coinLocation;
    self.zPosition = 25;
    self.name = @"coin";
    [self addChild:coin];
    
    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 1.0;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:coin.frame.size.width/2];
    self.physicsBody.categoryBitMask = coinCategory;


    
}



@end
