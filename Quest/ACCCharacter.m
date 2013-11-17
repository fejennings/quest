//
//  ACCCharacter.m
//  Quest
//
//  Created by Frank Jennings on 11/17/13.
//  Copyright (c) 2013 Acceltius. All rights reserved.
//

#import "ACCCharacter.h"
#import "Constants.h"

@interface ACCCharacter() {
    SKSpriteNode* character; // this will be the actual image you see of the character


}
@end

@implementation ACCCharacter

-(id) init {
    if (self = [super init]) {
        
        //do inititalization
        NSLog(@"Char in scene");
        character = [SKSpriteNode spriteNodeWithImageNamed:@"character"];
        [self addChild:character];
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:character.frame.size.width/2];
        self.physicsBody.dynamic = YES;
        self.physicsBody.restitution = 1.5;
        self.physicsBody.allowsRotation = YES;
        
        self.physicsBody.categoryBitMask = playerCategory;
        self.physicsBody.collisionBitMask = wallCategory;
        //self.physicsBody.contactTestBitMask = wallCategory; // sepearate other characters with pipe | playerCategory
    }
    
    return self;
}

@end
