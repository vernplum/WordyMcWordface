//
//  SSBitmapFontNode.m
//  SSBitmapFontLabel
//
//  Created by Mike Daley on 25/10/2015.
//  Copyright (c) 2015 71Squared. All rights reserved.
//

#import "SSBitmapFontLabelNode.h"
#import "SSBitmapFontLabelNode-private.h"
#import "SSBitmapGlyph.h"
#import "SSBitmapFont.h"

#pragma mark -
#pragma mark Private Interface

@interface SSBitmapFontLabelNode ()
{
    NSMutableDictionary *_fontDictionary;
    SSBitmapFont *_fontFactory;
    SKSpriteNode *_container;
    SKSpriteNode *_outerContainer;
    CGFloat _labelHeight;
    CGFloat _lastXOffset;
    NSArray *_labelLines;
}

@end

#pragma mark -
#pragma mark Implementation

@implementation SSBitmapFontLabelNode

- (instancetype)initWithFontDictionary:(NSMutableDictionary *)fontDictionary string:(NSString *)string factory:(SSBitmapFont *)fontFactory
{
    self = [super init];
    if (self)
    {
        _fontDictionary = fontDictionary;
        _fontFactory = fontFactory;
        _outlineColor = [SKColor redColor];
        _text = string;
        _horizontalAlignmentMode = SSBMFLabelHorizontalAlignmentModeCenter;
        _verticalAlignmentMode = SSBMFLabelVerticalAlignmentModeCenter;

        [self createSpritesFromText];
    }
    return self;
}

- (void)createSpritesFromText
{
    
    // Work out how many lines this label is going to have
    _labelLines = [_text componentsSeparatedByString:@"\n"];

    // Store the height to be used for the _container node
    CGFloat containerHeight = _fontFactory.lineHeight;
    CGFloat containerWidth = 0;
    CGFloat lowestXpos = 0;
    _labelHeight = _fontFactory.lineHeight * _labelLines.count;
    
    for (int line = 0; line < _labelLines.count; line++) {
        
        // Create a container that will hold the individual glyph sprite nodes
        _container = [SKSpriteNode node];
        _container.name = [NSString stringWithFormat:@"glyphContainer%i", line];
        
        // This will store the x offset used to render each glyph.
        _lastXOffset = 0;

        NSString *lineText = _labelLines[line];
        
        CGFloat posy = _fontFactory.lineHeight * line;
        
        // Loop through all characters in the string and generate SKSpriteNodes for each for the current line
        for(int i=0; i < lineText.length; i++)
        {
            unichar c = [lineText characterAtIndex:i];
            NSString *subStr = [lineText substringWithRange:NSMakeRange(i, 1)];
            
            // Find the texture and metrics info for the character being processed
            NSString *key = [NSString stringWithFormat:@"%u", c];
            SSBitmapGlyph *bitmapGlyph = [_fontDictionary objectForKey:key];
            
            // Create a new SKSpriteNode with the texture we have and setup its position using the metrics it has
            if(subStr)
            {
                SKSpriteNode *glyphNode = [SKSpriteNode spriteNodeWithTexture:bitmapGlyph.texture];
                glyphNode.name = @"glyph";
                glyphNode.blendMode = self.blendMode;
                glyphNode.colorBlendFactor = self.colorBlendFactor;
                glyphNode.color = self.color;
                
                glyphNode.position = CGPointMake(_lastXOffset + bitmapGlyph.xOffset, _labelHeight - posy - bitmapGlyph.texture.size.height - bitmapGlyph.yOffset);
                glyphNode.anchorPoint = CGPointMake(0.0f, 0.0f);
                [_container addChild:glyphNode];
                _lastXOffset += bitmapGlyph.xAdvance;
                
                // Check the height of the glyph image against the lineheight and set the height of the node to the largest value
                containerHeight = MAX(containerHeight * line, glyphNode.size.height);
                
                // If this is the last leter then adjust the lastXoffset so that the container is sized correctly to enclose
                // all the letters
                if (i == lineText.length - 1) {
                    _lastXOffset += bitmapGlyph.texture.size.width - bitmapGlyph.xAdvance + bitmapGlyph.xOffset;
                }
            }
        }
        
        containerWidth = MAX(containerWidth, _lastXOffset);
        
        // Calculate the _containers size
        _container.size = CGSizeMake(_lastXOffset, containerHeight);
        self.size = CGSizeZero;

        // Calculate the _containers position based on the alignment mode
        _container.position = [self calculatePosition];
        
        lowestXpos = MIN(lowestXpos, _container.position.x);
        
        [self addChild:_container];
    }

    if (_showOutline) {
        SKShapeNode *outline = [SKShapeNode node];
        CGRect outlineRect = CGRectMake(lowestXpos, _container.position.y, containerWidth, _labelHeight);
        outline.path = CGPathCreateWithRect(outlineRect, nil);
        outline.antialiased = NO;
        outline.lineWidth = 1.0;
        outline.strokeColor = _outlineColor;
        [self addChild:outline];
    }
}

- (CGPoint)calculatePosition
{
    CGPoint newPosition = CGPointZero;
    
    switch (_verticalAlignmentMode) {
        case SSBMFLabelVerticalAlignmentModeBottom:
            newPosition.y = 0;
            break;
        case SSBMFLabelVerticalAlignmentModeBaseline:
        {
            long baseLine = _fontFactory.lineHeight - _fontFactory.base;
            newPosition.y = -baseLine;
            break;
        }
        case SSBMFLabelVerticalAlignmentModeCenter:
            newPosition.y = -(_labelHeight * 0.5);
            break;
        case SSBMFLabelVerticalAlignmentModeTop:
            newPosition.y = -(_labelHeight * 1.0);
            break;
            
        default:
            break;
    }
    
    switch (_horizontalAlignmentMode) {
        case SSBMFLabelHorizontalAlignmentModeLeft:
            newPosition.x = 0;
            break;
        case SSBMFLabelHorizontalAlignmentModeCenter:
            newPosition.x = -(_lastXOffset * 0.5);
            break;
        case SSBMFLabelHorizontalAlignmentModeRight:
            newPosition.x = -(_lastXOffset * 1.0);
            break;
            
        default:
            break;
    }
    
    return newPosition;
}

- (void)setText:(NSString *)text
{
    [self removeAllChildren];
    _text = text;
    [self createSpritesFromText];
}

- (void)setShowOutline:(BOOL)showOutline
{
    _showOutline = showOutline;
    [self removeAllChildren];
    [self createSpritesFromText];
}

- (void)setOutlineColor:(SKColor *)outlineColor
{
    _outlineColor = outlineColor;
    [self removeAllChildren];
    [self createSpritesFromText];
}

- (void)setVerticalAlignmentMode:(SSBMFLabelVerticalAlignmentMode)verticlaAlignmentMode
{
    _verticalAlignmentMode = verticlaAlignmentMode;
    [self removeAllChildren];
    [self createSpritesFromText];
}

- (void)setHorizontalAlignmentMode:(SSBMFLabelHorizontalAlignmentMode)horizontalAlignmentMode
{
    _horizontalAlignmentMode = horizontalAlignmentMode;
    [self removeAllChildren];
    [self createSpritesFromText];
}

- (void)setBlendMode:(SKBlendMode)blendMode
{
    [super setBlendMode:blendMode];
    for (int line = 0; line < _labelLines.count; line++ ) {
        NSString *childName = [NSString stringWithFormat:@"glyphContainer%i", line];
        [[self childNodeWithName:childName] enumerateChildNodesWithName:@"glyph" usingBlock:^(SKNode *node, BOOL *stop) {
            if ([node isKindOfClass:[SKSpriteNode class]]) {
                [(SKSpriteNode *)node setBlendMode:blendMode];
            }
        }];
    }
}

- (void)setColorBlendFactor:(CGFloat)colorBlendFactor
{
    [super setColorBlendFactor:colorBlendFactor];
    for (int line = 0; line < _labelLines.count; line++ ) {
        NSString *childName = [NSString stringWithFormat:@"glyphContainer%i", line];
        [[self childNodeWithName:childName] enumerateChildNodesWithName:@"glyph" usingBlock:^(SKNode *node, BOOL *stop) {
            if ([node isKindOfClass:[SKSpriteNode class]]) {
                [(SKSpriteNode *)node setColorBlendFactor:colorBlendFactor];
            }
        }];
    }
}

- (void)setTextureFilteringMode:(SKTextureFilteringMode)textureFilteringMode
{
    for (int line = 0; line < _labelLines.count; line++ ) {
        NSString *childName = [NSString stringWithFormat:@"glyphContainer%i", line];
        [[self childNodeWithName:childName] enumerateChildNodesWithName:@"glyph" usingBlock:^(SKNode *node, BOOL *stop) {
            if ([node isKindOfClass:[SKSpriteNode class]]) {
                [[(SKSpriteNode *)node texture] setFilteringMode:textureFilteringMode];
            }
        }];
    }
}

- (void)setColor:(SKColor *)color
{
    [super setColor:color];
    for (int line = 0; line < _labelLines.count; line++ ) {
        NSString *childName = [NSString stringWithFormat:@"glyphContainer%i", line];
        [[self childNodeWithName:childName] enumerateChildNodesWithName:@"glyph" usingBlock:^(SKNode *node, BOOL *stop) {
            if ([node isKindOfClass:[SKSpriteNode class]]) {
                [(SKSpriteNode *)node setColor:color];
            }
        }];
    }
}

- (void)setFontColor:(UIColor *)color
{
    NSRange allGlyphs = NSMakeRange(0, [[self text] length]);
    [self setFontColor:color forRange:allGlyphs];
}

- (void)setFontColor:(UIColor *)color forRange:(NSRange)range
{
    SKNode *container = [[self children] firstObject];
    if (container == nil)
    {
        NSAssert(container, @"Error: setFontColor - SSBitmapFontLabelNode empty!");
    }
    
    int ptr = 0;
    for (SKNode *container in [self children])
    {
        for (SKNode *ch in [container children])
        {
            SKSpriteNode *node = (SKSpriteNode *)ch;
            if (ptr >= range.location && (ptr - range.location) < range.length)
            {
                [node setColor:color];
                [node setColorBlendFactor:1.0];
            }
            ++ptr;
        }
        // Treat the line-feed as a character
        ++ptr;
    }
}

- (CGSize)size
{
    // Return the size of the inner container as the size of self must be zero to stop it rendering a background
    // when setting the color and blendFactor on a label
    return _container.size;
}

@end
