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
    NSDictionary *characterData;
    BOOL useForCollisions;
    float collisionBodyCoversWhatPercent;
    unsigned char collisionBodyType; // 0 to 255
    unsigned char speed;
    unsigned char currentDirection;
    unsigned char prevDirection;
    
    unsigned char fps;
    
    bool useFrontViewFrames;
    bool useRestingFrames;
    bool useSideViewFrames;
    bool useBackViewFrames;
    bool useFrontAttackFrames;
    bool useSideAttackFrames;
    bool useBackAttackFrames;
    bool doesAttackWhenNotLeader;
    bool useAttackParticles;
    bool isTouchable;
    
    float particleDelay;
    int particlesToEmit;
    
    
    SKAction* walkFrontAction;
    SKAction* walkSideAction;
    SKAction* walkBackAction;
    SKAction* repeatRest;
    SKAction* frontAttackAction;
    SKAction* sideAttackAction;
    SKAction* backAttackAction;

}
@end

@implementation ACCCharacter

-(id) init {
    if (self = [super init]) {
        
        //do inititalization
        
        currentDirection=noDirection;
        prevDirection=down;
     }
    
    return self;
}

-(void)createWithDictionary:(NSDictionary *)charData {
    
    NSLog(@"Char in scene");
    
    characterData = [NSDictionary dictionaryWithDictionary:charData];
    character = [SKSpriteNode spriteNodeWithImageNamed:[characterData objectForKey:@"BaseFrame"]];
    
    self.zPosition = 100;
    self.name = @"character";
    
    self.position = CGPointFromString([characterData objectForKey:@"StartLocation"]);
    
    [self addChild:character];
    
    _followingEnabled = [[characterData objectForKey:@"FollowingEnabled"]  boolValue];
    useForCollisions = [[characterData objectForKey:@"UseForCollisions"]  boolValue];
    speed  = [[characterData objectForKey:@"Speed"]  unsignedCharValue];
    _charState = isStopped;
    _charSpeed = 0;
    
    
    //TEXTURE ..../test github
    
    fps  = [[characterData objectForKey:@"FPS"]  unsignedCharValue];
    
    useFrontViewFrames = [[characterData objectForKey:@"UseFrontViewFrames"]  boolValue];
    useRestingFrames= [[characterData objectForKey:@"UseRestingFrames"]  boolValue];
    useSideViewFrames= [[characterData objectForKey:@"UseSideViewFrames"]  boolValue];
    useBackViewFrames= [[characterData objectForKey:@"UseBackViewFrames"]  boolValue];
    useFrontAttackFrames= [[characterData objectForKey:@"UseFrontAttackFrames"]  boolValue];
    useSideAttackFrames= [[characterData objectForKey:@"UseSideAttackFrames"]  boolValue];
    useBackAttackFrames= [[characterData objectForKey:@"UseBackAttackFrames"]  boolValue];
    doesAttackWhenNotLeader= [[characterData objectForKey:@"DoesAttackWhenNotLeader"]  boolValue];
    useAttackParticles= [[characterData objectForKey:@"UseAttackParticles"]  boolValue];
    isTouchable= [[characterData objectForKey:@"IsTouchable"]  boolValue];
    particlesToEmit  = [[characterData objectForKey:@"ParticlesToEmit"]  intValue];

    particleDelay  = [[characterData objectForKey:@"ParticleDelay"]  floatValue];

    _hasOwnHealth = [[characterData objectForKey:@"HasOwnHealth"] boolValue];
    
    
    if (_hasOwnHealth == YES) {
        [self setUpHealthMeter];
    }
    
    
    if (useRestingFrames == YES) {
        [self setUpRest];
    }
    if (useFrontViewFrames == YES) {
        [self setUpWalkFront];
    }
    if (useSideViewFrames == YES) {
        [self setUpWalkSide];
    }
    if (useBackViewFrames == YES) {
        [self setUpWalkBack];
    }
    if (useFrontAttackFrames == YES) {
        [self setUpFrontAttackFrames];
    }
    if (useBackAttackFrames == YES) {
        [self setUpBackAttackFrames];
    }
    if (useSideAttackFrames == YES) {
        [self setUpSideAttackFrames];
    }


    
    if ( useForCollisions == YES) {
        [self setUpPhysics];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.xScale = .75;
        self.yScale = .75;
    }
    
    
}

-(void)setUpHealthMeter {
    
    _maxHealth = [[characterData objectForKey:@"Health"]floatValue];
    _currentHealth = _maxHealth;
    
    SKSpriteNode* healthBar = [SKSpriteNode spriteNodeWithImageNamed:@"healthbar"];
    healthBar.zPosition = 200;
    healthBar.position = CGPointMake(0,(character.frame.size.height/2)+10);
    [self addChild:healthBar];
    
    SKSpriteNode* green = [SKSpriteNode spriteNodeWithImageNamed:@"green"];
    green.zPosition = 201;
    green.position = CGPointMake(-(green.frame.size.width/2),(character.frame.size.height/2)+10);
    green.anchorPoint = CGPointMake(0.0, 0.5);
    green.name = @"green";
    [self addChild:green];
    
    
    
}

-(void) setUpPhysics {
  
    collisionBodyCoversWhatPercent  = [[characterData objectForKey:@"CollisionBodyCoversWhatPercent"] floatValue];
    CGSize newSize = CGSizeMake( character.size.width *collisionBodyCoversWhatPercent  , character.size.height * collisionBodyCoversWhatPercent);
    
    if ([[ characterData objectForKey:@"CollisionBodyType"] isEqualToString:@"square" ]) {
        collisionBodyType = squareType;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newSize];
    } else {
        collisionBodyType = circleType;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:newSize.width/2];
     }
    
    if ( [[characterData objectForKey:@"DebugBody"]boolValue] == YES) {
        CGRect rect = CGRectMake(-(newSize.width/2), -(newSize.height/2), newSize.width, newSize.height);
        [self debugPath:rect bodyType:collisionBodyType];
    }

    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 0.2;
    self.physicsBody.allowsRotation = NO;
    
    self.physicsBody.categoryBitMask = playerCategory;
    self.physicsBody.collisionBitMask = wallCategory | playerCategory | coinCategory | obstacleCategory;
    self.physicsBody.contactTestBitMask = wallCategory | playerCategory | coinCategory | obstacleCategory; // sepearate other characters with pipe | playerCategory
    
    
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

#pragma mark Setup Rest/Walk frames

-(void) setUpRest {
    
 /*   SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:@"RestingAtlasFile"]];
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:@"RestingFrames"]];
    NSMutableArray* atlasTextures= [NSMutableArray arrayWithCapacity:[array count]];
    unsigned char count = 0;
    for (id object in array) {
        SKTexture* texture = [atlas textureNamed:[array objectAtIndex:count]];
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* atlasAnimation = [SKAction animateWithTextures:atlasTextures timePerFrame:1.0/fps];
    SKAction* wait = [SKAction waitForDuration:0.5 ];
    SKAction* sequence = [SKAction sequence:@[atlasAnimation, wait]];*/
    
    NSString* atlasName = @"RestingAtlasFile";
    NSString* atlasFrames =@"RestingFrames";
    SKAction* sequence = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.5 useWalkFrames:NO timesToAttack:0 withSelectorStr:""];
    repeatRest = [SKAction repeatActionForever:sequence];
    
    [character runAction:repeatRest withKey:@"Move"];
 
   
    
}



-(void) setUpWalkFront {
    NSString* atlasName = @"WalkFrontAtlasFile";
    NSString* atlasFrames =@"WalkFrontFrames";
    SKAction* sequence = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.0 useWalkFrames:NO timesToAttack:0 withSelectorStr:""];
    walkFrontAction = [SKAction repeatActionForever:sequence];
    
    
}
-(void) setUpWalkBack {
    NSString* atlasName = @"WalkBackAtlasFile";
    NSString* atlasFrames =@"WalkBackFrames";
    SKAction* sequence = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.0 useWalkFrames:NO timesToAttack:0 withSelectorStr:""];
    walkBackAction = [SKAction repeatActionForever:sequence];
    
    
}
-(void) setUpWalkSide {
    NSString* atlasName = @"WalkSideAtlasFile";
    NSString* atlasFrames =@"WalkSideFrames";
    SKAction* sequence = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.0 useWalkFrames:NO timesToAttack:0 withSelectorStr:""];
    walkSideAction = [SKAction repeatActionForever:sequence];
    
    
}
//Setup action based on Atlas File and Frames
-(SKAction*)setUpAction:(NSString*)atlasName withFrames:(NSString*)atlasFrames waiting:(float)waits useWalkFrames:(BOOL)useWalk timesToAttack:(int) attack withSelectorStr:(char const*) selector {
    
    SEL select;
    if (strlen(selector) >0) {
        select= sel_registerName(selector);
    }
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:[characterData objectForKey:atlasName]];
    NSArray* array = [NSArray arrayWithArray:[characterData objectForKey:atlasFrames]];
    NSMutableArray* atlasTextures= [NSMutableArray arrayWithCapacity:[array count]];
    unsigned char count = 0;
    for (id object in array) {
        //SKTexture* texture = [atlas textureNamed:[array objectAtIndex:count]];
        SKTexture* texture = [atlas textureNamed:object];
        
        [atlasTextures addObject:texture];
        count ++;
    }
    
    SKAction* animate = [SKAction animateWithTextures:atlasTextures timePerFrame:1.0/fps];
    SKAction* wait = [SKAction waitForDuration:waits];
    SKAction* sequence;
      if (attack>0) {
        
        if (useWalk ==  YES) {
                SKAction* returnToWalking = [SKAction performSelector:(select) onTarget:self];
                sequence = [SKAction sequence:@[animate, returnToWalking]];
        } else {
            sequence  = [SKAction repeatAction:animate count:attack];
        }
    } else {
        sequence = [SKAction sequence:@[animate, wait]];
  
    }
   
    return sequence;
    
}

#pragma mark Setup Attack frames

-(void) setUpSideAttackFrames {
    NSString* atlasName = @"SideAttackAtlasFile";
    NSString* atlasFrames =@"SideAttackFrames";
    sideAttackAction = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.5 useWalkFrames:useSideViewFrames timesToAttack:1 withSelectorStr:"runWalkSideTextures"];
}
-(void) setUpFrontAttackFrames {
    NSString* atlasName = @"FrontAttackAtlasFile";
    NSString* atlasFrames =@"FrontAttackFrames";
    frontAttackAction = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.5 useWalkFrames:useFrontViewFrames timesToAttack:1 withSelectorStr:"runWalkFrontTextures"];

}
-(void) setUpBackAttackFrames {
    NSString* atlasName = @"BackAttackAtlasFile";
    NSString* atlasFrames =@"BackAttackFrames";
    backAttackAction = [self setUpAction:atlasName withFrames:atlasFrames waiting:0.5 useWalkFrames:useBackViewFrames timesToAttack:1 withSelectorStr:"runWalkBackTextures"];

   
}

#pragma mark Methods to run SKACtions

-(void)runRestingTextures {
    if (repeatRest == Nil) {
        [self setUpRest];
    }
    [character runAction:repeatRest withKey:@"Move"];
}
-(void)runWalkFrontTextures {
    if (walkFrontAction == Nil) {
        [self setUpWalkFront];
    }
    if (_charState==isMoving) {
        [character runAction:walkFrontAction withKey:@"Move"];
    }
}
-(void)runWalkSideTextures {
    if (walkSideAction == Nil) {
        [self setUpWalkSide];
    }
    if (_charState==isMoving) {
        [character runAction:walkSideAction withKey:@"Move"];
    }
}
-(void)runWalkBackTextures {
    if (walkBackAction == Nil) {
        [self setUpWalkBack];
    }
    if (_charState==isMoving) {
        [character runAction:walkBackAction withKey:@"Move"];
    }
}


#pragma mark Update

-(void) update  {
    
    //check algorithm for declining health
    
    if ((_followingEnabled == YES || _theLeader == YES) && (_charState != isStopped)) { //&& (_charState == isMoving || _charState == isLiningUp)) {

        switch (currentDirection) {
            case up:
                self.position = CGPointMake(self.position.x,self.position.y + speed);
            
                if (self.position.x<_idealX && _theLeader == NO){
                    self.position = CGPointMake(self.position.x+1,self.position.y);
                } else if (self.position.x>_idealX && _theLeader == NO){
                    self.position = CGPointMake(self.position.x-1,self.position.y);
                }

                break;
            case down:
                self.position = CGPointMake(self.position.x,self.position.y - speed);
            
                if (self.position.x<_idealX && _theLeader == NO){
                    self.position = CGPointMake(self.position.x+1,self.position.y);
                } else if (self.position.x>_idealX && _theLeader == NO){
                    self.position = CGPointMake(self.position.x-1,self.position.y);
                }
           
                break;
            case left:
                self.position = CGPointMake(self.position.x-speed ,self.position.y);
            
                if (self.position.y<_idealY && _theLeader == NO){
                    self.position = CGPointMake(self.position.x,self.position.y+1);
                } else if (self.position.y>_idealY && _theLeader == NO){
                    self.position = CGPointMake(self.position.x,self.position.y-1);
                }
            
                break;
        case right:
                self.position = CGPointMake(self.position.x+ speed,self.position.y );
            
                if (self.position.y<_idealY && _theLeader == NO){
                    self.position = CGPointMake(self.position.x,self.position.y+1);
                } else if (self.position.y>_idealY && _theLeader == NO){
                    self.position = CGPointMake(self.position.x,self.position.y-1);
                }
            
                break;
        case noDirection:
                //do something if you have to
            
                break;
        
        default:
            break;
    }
    } // if following enabled
    
    
}

#pragma mark Handle Movement

CGFloat degreesToRadians(CGFloat degrees) {
    return degrees *M_PI / 180;
}
CGFloat radiansToDegrees(CGFloat radians) {
    return radians *180 / M_PI;
}

-(void)moveLeftWithPlace:(NSNumber*) place {
    if (_followingEnabled == YES || _theLeader == YES) {
        
        self.zPosition = 100 - [place integerValue]; //converts NSNumber to int
        character.xScale = 1;
        if (useSideViewFrames==YES) {
            character.zRotation = degreesToRadians(0);
            character.xScale = -1; // flip 100% on the X axis
            [self runWalkSideTextures];
        } else if (useFrontViewFrames==YES) {
            character.zRotation = degreesToRadians(-90);
            [self runWalkFrontTextures];
   
        } else {
            character.zRotation = degreesToRadians(-90);
 
        }
        prevDirection = currentDirection;
        currentDirection=left;

    }
}
-(void)moveRightWithPlace:(NSNumber*) place{
    if (_followingEnabled == YES || _theLeader == YES) {

        self.zPosition = 100 - [place integerValue]; //converts NSNumber to int
        character.xScale = 1; // flip 100% on the X axis

        if (useSideViewFrames==YES) {
            character.zRotation = degreesToRadians(0);
                        [self runWalkSideTextures];
        } else if (useFrontViewFrames==YES) {
            character.zRotation = degreesToRadians(90);
            [self runWalkFrontTextures];
            
        } else {
            character.zRotation = degreesToRadians(90);
            
        }
        prevDirection = currentDirection;
        currentDirection = right;

    }
}
-(void)moveUpWithPlace:(NSNumber*) place{
    if (_followingEnabled == YES || _theLeader == YES) {
        self.zPosition = 100 - [place integerValue]; //converts NSNumber to int
        character.xScale = 1; // flip 100% on the X axis
        
        if (useBackViewFrames==YES) {
            character.zRotation = degreesToRadians(0);
            [self runWalkBackTextures];
        } else if (useFrontViewFrames==YES) {
            character.zRotation = degreesToRadians(180);
            [self runWalkFrontTextures];

        } else {
            character.zRotation = degreesToRadians(180);
            
        }
        prevDirection = currentDirection;
        currentDirection=up;
    }
}
-(void)moveDownWithPlace:(NSNumber*) place{
    if (_followingEnabled == YES || _theLeader == YES) {
        self.zPosition = 100 + [place integerValue]; //converts NSNumber to int
        character.xScale = 1; // flip 100% on the X axis
        
        if (useFrontViewFrames==YES) {
            character.zRotation = degreesToRadians(0);
            [self runWalkFrontTextures];
        } else {
            character.zRotation = degreesToRadians(0);
            
        }
        prevDirection = currentDirection;
        currentDirection=down;
    }
}
    

-(void)followIntoPositionWithDirection:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location {
    // Will be used to pick up new follower
    int paddingX = character.frame.size.width;// / 2;
    int paddingY = character.frame.size.height;// / 2;
    CGPoint newPosition;
    
    //Need to add another action if follower has to move "around" the leader
    // indicated for up by x being equal but direction to leader is down
    
    
    if (_followingEnabled == YES ) {
        if (direction==up ) {
            newPosition = CGPointMake(location.x, location.y - (paddingY*place));
            [self moveUpWithPlace:[NSNumber numberWithInt:place]];
        } else if (direction == down) {
            newPosition = CGPointMake(location.x, location.y + (paddingY*place));
            [self moveDownWithPlace:[NSNumber numberWithInt:place]];
        } else if (direction == right) {
            newPosition = CGPointMake(location.x - (paddingX*place), location.y );
            [self moveRightWithPlace:[NSNumber numberWithInt:place]];
        } else if (direction == left) {
            newPosition = CGPointMake(location.x + (paddingX*place), location.y );
            [self moveLeftWithPlace:[NSNumber numberWithInt:place]];
        }
        NSLog(@"Follow %i to %f, %f", place, newPosition.x, newPosition.y);
        SKAction* moveIntoLine = [SKAction moveTo:newPosition duration:0.2f];
        [self runAction:moveIntoLine];
    }
}


#pragma mark STOP Moving

-(void)stopMoving {
    NSLog(@"Stop Moving");
    prevDirection = currentDirection;
    _charState = isStopped;
    
}

-(void)stopMovingFromWallHit {
    NSLog(@"Stop Moving Wall Hit");
    prevDirection = currentDirection;
    _charState = isStopped;

}
-(void)stopInFormation:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location{
    if (_followingEnabled == YES && currentDirection != noDirection) {
    
    int paddingX = character.frame.size.width;// / 2;
    int paddingY = character.frame.size.height;// / 2;
    SKAction* rests;
    CGPoint newPosition;
    
    //Need to add another action if follower has to move "around" the leader
    // indicated for up by x being equal but direction to leader is down
    
        if (place ==0) {
            NSLog(@"zero place");
        }
 
        if (direction==up ) {
                newPosition = CGPointMake(location.x, location.y - (paddingY*place));
            rests = [SKAction performSelector:@selector(restup) onTarget:self];
        } else if (direction == down) {
            newPosition = CGPointMake(location.x, location.y + (paddingY*place));
            rests = [SKAction performSelector:@selector(restdown) onTarget:self];
        } else if (direction == right) {
             newPosition = CGPointMake(location.x - (paddingX*place), location.y );
            rests = [SKAction performSelector:@selector(restright) onTarget:self];
         } else if (direction == left) {
             newPosition = CGPointMake(location.x + (paddingX*place), location.y );
             rests = [SKAction performSelector:@selector(restleft) onTarget:self];
        } else {
             newPosition = self.position; // not in course.  Caused second rotate to put followers on top of each other.
            NSLog(@"Rest  - Should be here no direction");
        }
        NSLog(@"Move %i to %f, %f", place, newPosition.x, newPosition.y);
        SKAction* moveIntoLine = [SKAction moveTo:newPosition duration:0.2f];
        SKAction* stop = [SKAction performSelector:@selector(stopMoving) onTarget:self];
        SKAction* sequence = [SKAction sequence:@[moveIntoLine, stop, rests]];
        [self runAction:sequence];
 
        
    }

    
}

-(void)restup {
    [self rest:up];
}
-(void)restdown {
    [self rest:down];
}
-(void)restright {
    [self rest:right];
}
-(void)restleft {
    [self rest:left];
}
-(void)rest:(int) direction {
    
        
        //Need to add another action if follower has to move "around" the leader
    // indicated for up by x being equal but direction to leader is down

    if (_followingEnabled == YES || _theLeader) {

        [character removeActionForKey:@"Move"];
        _charState = isStopped;
        
        if (direction==up ) {
            character.zRotation = degreesToRadians(180);
            //character.zPosition = 100 - place;
        } else if (direction == down) {
            //character.zPosition = 100 + place;
            character.zRotation = degreesToRadians(0);
        } else if (direction == right) {
            //character.zPosition = 100 - place;
            character.zRotation = degreesToRadians(90);
        } else if (direction == left) {
            //character.zPosition = 100 - place;
            character.zRotation = degreesToRadians(-90);
        } else {
            //other.
        }
        NSLog(@"Rest at %f", character.zRotation );
        if (useRestingFrames==YES) {
            if (repeatRest==nil) {
                [self setUpRest];
            }
            [character runAction:repeatRest withKey:@"Move"];
            
        } else {
           // not using resting frames
        }
    }
    
}

#pragma mark ATTACK

-(void)attack {
    
    if ((_theLeader==YES || doesAttackWhenNotLeader == YES) && _charState ==isMoving) {
        if (currentDirection ==down && useFrontAttackFrames == YES) {
            [character removeAllActions];
            if (frontAttackAction==nil) {
                [self setUpFrontAttackFrames];
            }
            [character runAction:frontAttackAction];
            
        } else if (currentDirection== left || currentDirection==right) {
            [character removeAllActions];
            if (useSideAttackFrames==YES) {
                if (sideAttackAction==nil) {
                    [self setUpSideAttackFrames];
                }
                [character runAction:sideAttackAction];

            } else if (useFrontAttackFrames==YES) {
                [character removeAllActions];
                if (frontAttackAction==nil) {
                    [self setUpFrontAttackFrames];
                }
                [character runAction:frontAttackAction];

            }
            
        } else if (currentDirection==up) {
            [character removeAllActions];
            if (useBackAttackFrames==YES) {
                if (backAttackAction==nil) {
                    [self setUpBackAttackFrames];
                }
                [character runAction:backAttackAction];
                
            } else if (useFrontAttackFrames==YES) {
                [character removeAllActions];
                if (frontAttackAction==nil) {
                    [self setUpFrontAttackFrames];
                }
                [character runAction:frontAttackAction];
            }

        }
        if (useAttackParticles == YES && currentDirection != noDirection) {
            [self performSelector:@selector(addEmitter) withObject:nil afterDelay:particleDelay];
        }
    }
    
}

-(void)addEmitter {
    NSString* emitterPath = [[NSBundle mainBundle] pathForResource:[characterData objectForKey:@"AttackParticleFile"] ofType:@"sks"];
    SKEmitterNode* emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitter.zPosition = 150;
    
    switch (currentDirection) {
        case up: {
            emitter.position = CGPointMake(0,character.frame.size.height/2);
            
            break;
            
        }
        case down: {
            emitter.position = CGPointMake(0,-(character.frame.size.height/2));
            
            break;
            
        }
        case left: {
            emitter.position = CGPointMake(-(character.frame.size.height/2),0);
            
            break;
            
        }
        case right: {
            emitter.position = CGPointMake(character.frame.size.height/2,0);
            
            break;
            
        }
        default: {
            emitter.position = CGPointMake(0, 0);
        }
    }
    emitter.numParticlesToEmit = particlesToEmit;
    [self addChild:emitter];
    
}

#pragma mark Leader Stuff

-(void) makeLeader {
    
    _theLeader = YES;

}
-(void) removeLeader {
    _theLeader = NO;
}
-(int)returnDirection {
    return currentDirection;
}

#pragma mark leader tochable Stuff
-(BOOL)isTouchable {
    return isTouchable;
}

-(void)touched {
    if (_followingEnabled == NO) {
        //display info
    } else if (_theLeader == NO){
        //make leader
    } else {
        //do something as leader
    }
}

#pragma mark Do Damage

-(void) doDamageWithAmount:(float)amount {
    
    _currentHealth = _currentHealth - amount;
    
    if(_currentHealth<0) {
        _currentHealth =0;
    }
    [self childNodeWithName:@"green"].xScale = _currentHealth / _maxHealth;
    [self performSelector:@selector(damageActions) withObject:Nil afterDelay:0.05];
}

-(void) damageActions {
    
    SKAction* push;
    SKAction* pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.5],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.5],
                                              ]];
    [character runAction:pulseRed];
    if (currentDirection == left) {
        push = [SKAction moveByX:100 y:0 duration:0.2];
        
    } else     if (currentDirection == right) {
        push = [SKAction moveByX:-100 y:0 duration:0.2];
        
    } else     if (currentDirection == up) {
        push = [SKAction moveByX:0 y:-100 duration:0.2];
        
    } else     if (currentDirection == down) {
        push = [SKAction moveByX:0 y:100 duration:0.2];
        
    }
    [self runAction:push];
    [self performSelector:@selector(damageDone) withObject:Nil afterDelay:0.021];

    
}

-(void) damageDone {
    prevDirection=currentDirection;
    if (_currentHealth <= 0) {
  
        [self enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop){
            [node removeFromParent ];
        }];
        
        _isDying=YES;
        
        [self deathEmitter];
        
        self.physicsBody.dynamic=NO;
        self.physicsBody = nil;
        
        [self performSelector:@selector(removeFromParent) withObject:nil afterDelay:1.0];

        
    }
    
    
}

-(void)deathEmitter {
    NSString* emitterPath = [[NSBundle mainBundle] pathForResource:[characterData objectForKey:@"DeathFire"] ofType:@"sks"];
    SKEmitterNode* emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitter.zPosition = 150;
    emitter.position = CGPointMake(0,- (character.frame.size.height/2)+10);
    emitter.numParticlesToEmit=150;
    
    [self addChild:emitter];
    
}


@end
