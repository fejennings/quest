//
//  ACCWalls.m
//  Quest
//
//  Created by Frank Jennings on 3/28/14.
//  Copyright (c) 2014 Acceltius. All rights reserved.
//

#import "ACCWalls.h"
#import "ACCLevel.h"
#import "Constants.h"

@interface ACCWalls() {
    
    
    SKSpriteNode* wall;
}

@end

@implementation ACCWalls



-(id) init {
    if (self = [super init]) {
        
        //do inititalization
        
        
    }
    
    return self;
}

-(void)createWithBaseImage:(NSString*)baseImage andLocation:(CGPoint)wallLocation andRotation:(float)wallRotation{
    
    //NSLog(@" %@",baseImage);
    //NSLog(@"x %f y %f",wallLocation.x,wallLocation.y);
    wall=[SKSpriteNode  spriteNodeWithImageNamed:baseImage];
    CGRect wallRect = CGRectMake(wallLocation.x, wallLocation.y, wall.frame.size.width, wall.frame.size.height);
    self.position = wallLocation;
    self.zPosition = 10;
    self.zRotation = walldegreesToRadians(wallRotation);

    self.name = @"wall";
    [self addChild:wall];
    
    //collisionBodyCoversWhatPercent  = [[characterData objectForKey:@"CollisionBodyCoversWhatPercent"] floatValue];
    float collisionBodyCoversWhatPercent = 0.9;
    CGSize newSize = CGSizeMake( wallRect.size.width *collisionBodyCoversWhatPercent  , wallRect.size.height * collisionBodyCoversWhatPercent);
    
    float shrinkage = 0.9;
    
    int offsetX = (wall.frame.size.width - (wall.frame.size.width*shrinkage))/2;
    int offsetY = (wall.frame.size.height - (wall.frame.size.height*shrinkage))/2;
    CGRect wallWithSmallerRect = CGRectMake(wall.frame.origin.x+offsetX, wall.frame.origin.y+offsetY, wall.frame.size.width*shrinkage, wall.frame.size.height*shrinkage);

    CGRect rect = CGRectMake(-(newSize.width/2), -(newSize.height/2), newSize.width, newSize.height);
    int collisionBodyType = squareType;
    // 1 Create a physics body that borders the screen
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
    // 2 Set physicsBody of scene to borderBody
    self.physicsBody = borderBody;
    // 3 Set the friction of that physicsBody to 0
    self.physicsBody.friction = 0.0f;

    //self.physicsBody.dynamic = NO;
    //self.physicsBody.restitution = 0.0;
    //self.physicsBody.allowsRotation = NO;
    //self.physicsBody.density = 100.0;
    //self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newSize];
    //CGRect rect = CGRectMake(-(newSize.width/2), -(newSize.height/2), newSize.width, newSize.height);
    [self debugPath:wallWithSmallerRect bodyType:collisionBodyType];


    self.physicsBody.categoryBitMask = obstacleCategory;
    
    
    
}

-(void) debugPath:(CGRect)theRect bodyType:(int)type {
    
    SKShapeNode *pathShape= [[SKShapeNode alloc] init];
    
    CGPathRef thePath;
    if (type == squareType) {
        
        thePath = CGPathCreateWithRect(theRect, NULL);
    } else {
        CGRect adjustedRect = CGRectMake(theRect.origin.x, theRect.origin.y, theRect.size.width, theRect.size.width);
        
        thePath = CGPathCreateWithEllipseInRect(adjustedRect, NULL);
    }
    
    pathShape.path = thePath;
    
    pathShape.lineWidth = 1;
    pathShape.strokeColor = [SKColor greenColor];
    pathShape.position = CGPointMake(0,0);
    
    [self addChild:pathShape];
    pathShape.zPosition = 1000;
    
    
}
#pragma mark Handle Movement

CGFloat walldegreesToRadians(CGFloat degrees) {
    return degrees *M_PI / 180;
}
CGFloat wallradiansToDegrees(CGFloat radians) {
    return radians *180 / M_PI;
}


@end
