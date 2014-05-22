//
//  ACCWalls.h
//  Quest
//
//  Created by Frank Jennings on 3/28/14.
//  Copyright (c) 2014 Acceltius. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface ACCWalls : SKNode

-(void )createWithBaseImage:(NSString*)baseImage andLocation:(CGPoint)wallLocation andRotation:(float)wallRotation;


@end
