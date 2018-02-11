//
//  SSBitmapGlyph.h
//  SSBitmapFontLabel
//
//  Created by Mike Daley on 26/10/2015.
//  Copyright (c) 2015 71Squared. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SSBitmapGlyph : NSObject

@property (nonatomic, strong) SKTexture *texture;
@property (nonatomic, assign) float xOffset;
@property (nonatomic, assign) float yOffset;
@property (nonatomic, assign) float xAdvance;

@end
