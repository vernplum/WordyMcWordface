//
//  BitmapFontNode.m
//  SSBitmapFontLabel
//
//  Created by Mike Daley on 23/10/2015.
//  Copyright (c) 2015 71Squared. All rights reserved.
//

#import "SSBitmapFont.h"
#import "Structures.h"
#import "SSBitmapGlyph.h"
#import "SSBitmapFontLabelNode.h"
#import "SSBitmapFontLabelNode-private.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark Defines


#pragma mark -
#pragma mark Typedefs/Enums

enum BitmapFontBinaryBlockTypes {
    D_BMFN_HEADER_BLOCK = 0,
    D_BMFN_INFO_BLOCK,
    D_BMFN_COMMON_BLOCK,
    D_BMFN_PAGE_BLOCK,
    D_BMFN_CHAR_BLOCK,
    D_BMFN_KERNING_BLOCK
};

enum DisplayType {
    D_BMFN_NON_RETINA = 0,
    D_BMFN_RETINA,
    D_BMFN_IPHONE_NON_RETINA,
    D_BMFN_IPHONE_RETINA,
    D_BMFN_IPAD_NON_RETINA,
    D_BMFN_IPAD_RETINA
};

#define D_BMFN_DOMAIN @"com.71squared.ssbitmapfont"

#pragma mark -
#pragma mark Private Interface

@interface SSBitmapFont ()

@property (nonatomic, strong, readonly) NSMutableDictionary *fontDictionary;
@property (nonatomic, strong, readonly) SKTextureAtlas *textureAtlas;
@property (nonatomic, strong, readonly) NSString *controlFileExtension;

+ (NSString *)errorTextForCode:(int)code;
+ (NSError *)errorWithCode:(int)code;
+ (NSError *)errorWithCode:(int)code userInfo:(NSDictionary *)userInfo;

@end

#pragma mark -
#pragma mark Public Implementation

@implementation SSBitmapFont

- (instancetype)initWithFile:(NSURL *)url error:(NSError **)error
{
    if (self = [super init]) {
        
        if (!url)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_URL_CANNOT_BE_NIL];
            return nil;
        }
        
        // Defaults
        BOOL isRetina = NO;
        _controlFileExtension = @"skf";

        NSURL *controlFileURL = [url copy];
        _controlFileName = [[url lastPathComponent] stringByDeletingPathExtension];

        if (!controlFileURL) {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_CONTROL_FILE_NOT_FOUND];
            return nil;
        }
        
        NSError *bufferError = nil;
        NSData *buffer = [NSData dataWithContentsOfURL:controlFileURL options:NSDataReadingUncached error:&bufferError];
        if (bufferError)
        {
            // Pass back the error from NSData
            if (error) *error = bufferError;
            return nil;
        }
        
        NSUInteger bufferPosition = 0;
        
        // Load the header and version info and make sure it is valid
        struct bmfontHeader header;
        [buffer getBytes:&header length:4];
        if (header.identifier[0] != 'S' || header.identifier[1] != 'S' || header.identifier[2] != 'B' || header.version != 1)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_BAD_HEADER];
            return nil;
        }
        bufferPosition += sizeof(header);
        
        // ====================================
        // Info Block
        struct bmfontInfoBlock infoBlock;
        [buffer getBytes:&infoBlock range:NSMakeRange(bufferPosition, sizeof(infoBlock))];
        bufferPosition += sizeof(infoBlock);
        
        if (infoBlock.type != D_BMFN_INFO_BLOCK)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_BAD_INFO_BLOCK_TYPE];
            return nil;
        }
        
        struct bmfontInfo info;
        [buffer getBytes:&info range:NSMakeRange(bufferPosition, sizeof(info))];
        bufferPosition += sizeof(info);
        _fontSize = info.fontSize;
        _paddingLeft = info.paddingLeft;
        _paddingTop = info.paddingUp;
        _paddingRight = info.paddingLeft;
        _paddingBottom = info.paddingDown;
        _horizontalSpacing = info.spacingHoriz;
        _verticalSpacing = info.spacingVert;
        
        char fontName[infoBlock.length - sizeof(info)];
        [buffer getBytes:&fontName range:NSMakeRange(bufferPosition, infoBlock.length - sizeof(info))];
        bufferPosition += infoBlock.length - sizeof(info);
        _fontName = [NSString stringWithUTF8String:fontName];
        
        // ====================================
        // Common Block
        struct bmfontCommonBlock commonBlock;
        [buffer getBytes:&commonBlock range:NSMakeRange(bufferPosition, sizeof(commonBlock))];
        bufferPosition += sizeof(commonBlock);
        
        if (commonBlock.type != D_BMFN_COMMON_BLOCK)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_BAD_COMMON_BLOCK_TYPE];
            return nil;
        }
        
        float screenScaleFactor = (isRetina) ? 2.0 : 1.0;
        
        struct bmfontCommon common;
        [buffer getBytes:&common range:NSMakeRange(bufferPosition, commonBlock.length)];
        bufferPosition += commonBlock.length;
        _lineHeight = common.lineHeight / screenScaleFactor;
        _lineHeight = common.lineHeight;
        _base = common.base / screenScaleFactor;
        
        // ====================================
        // Page Block
        struct bmfontPageBlock pageBlock;
        [buffer getBytes:&pageBlock range:NSMakeRange(bufferPosition, sizeof(pageBlock))];
        bufferPosition += sizeof(pageBlock);
        
        if (pageBlock.type != D_BMFN_PAGE_BLOCK)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_BAD_PAGE_BLOCK_TYPE];
            return nil;
        }
        
        char imageFileName[pageBlock.length];
        [buffer getBytes:&imageFileName range:NSMakeRange(bufferPosition, pageBlock.length)];
        bufferPosition += pageBlock.length;
        _atlasFileName = [[NSString stringWithUTF8String:imageFileName] stringByDeletingPathExtension];
        _textureAtlas = [SKTextureAtlas atlasNamed:_atlasFileName];
        
        if (!_textureAtlas)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_ATLAS_FILE_NOT_FOUND];
            return nil;
        }
        
        // ====================================
        // Chars Block
        struct bmfontCharBlock charsBlock;
        [buffer getBytes:&charsBlock range:NSMakeRange(bufferPosition, sizeof(charsBlock))];
        bufferPosition += sizeof(charsBlock);
        
        if (charsBlock.type != D_BMFN_CHAR_BLOCK)
        {
            if (error) *error = [SSBitmapFont errorWithCode:D_BMFN_BAD_CHAR_BLOCK_TYPE];
            return nil;
        }
        
        int numberOfGlyphs = charsBlock.length / sizeof(struct bmfontChars);
        struct bmfontChars glyphs[numberOfGlyphs];
        [buffer getBytes:&glyphs range:NSMakeRange(bufferPosition, charsBlock.length)];
        bufferPosition += charsBlock.length;
        
        _fontDictionary = [NSMutableDictionary new];
        for (int i=0; i < numberOfGlyphs; i++)
        {
            SSBitmapGlyph *bitmapGlyph = [SSBitmapGlyph new];
            
            bitmapGlyph.xOffset = glyphs[i].xOffset / screenScaleFactor;
            bitmapGlyph.yOffset = glyphs[i].yOffset;
            bitmapGlyph.xAdvance = glyphs[i].xAdvance / screenScaleFactor;
            
            NSString *key = [NSString stringWithFormat:@"%u", (unsigned int)glyphs[i].charId];
            SKTexture *texture = [_textureAtlas textureNamed:key];
            if (glyphs[i].charId != 32 && glyphs[i].charId != 12288)
                bitmapGlyph.texture = texture;
            
            if(key)
            {
                [_fontDictionary setObject:bitmapGlyph forKey:key];
            }
        }
        
        // ====================================
        // Kerning Block
        if (bufferPosition + sizeof(struct bmfontKerningBlock) < buffer.length)
        {
            struct bmfontKerningBlock kerningBlock;
            [buffer getBytes:&kerningBlock range:NSMakeRange(bufferPosition, sizeof(kerningBlock))];
            bufferPosition += sizeof(kerningBlock);
            
            int numberOfKerningPairs = kerningBlock.length / sizeof(struct bmfontKerningPairs);
            struct bmfontKerningPairs kerningPairs[numberOfKerningPairs];
            [buffer getBytes:&kerningPairs range:NSMakeRange(bufferPosition, kerningBlock.length)];
        }
        
    }
    
    return self;
}

- (SSBitmapFontLabelNode *)nodeFromString:(NSString *)string {
    return [[SSBitmapFontLabelNode alloc] initWithFontDictionary:_fontDictionary string:string factory:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{Font: %@} : {Size: %upt} : {Lineheight: %u} : {Base: %u}",
            _fontName, (unsigned int)_fontSize, (unsigned int)_lineHeight, (unsigned int)_base];
}



#pragma mark -
#pragma mark NSError Methods

+ (NSString *) errorTextForCode:(int)code {
    NSString * codeText = @"";
    
    switch (code) {
        case D_BMFN_FILE_NOT_FOUND:                            codeText = @"File not found";                            break;
        case D_BMFN_URL_CANNOT_BE_NIL:                         codeText = @"URL cannot be nil";                         break;
        case D_BMFN_ATLAS_FILE_NOT_FOUND:                      codeText = @"Texture atlas file not found";              break;
        case D_BMFN_CONTROL_FILE_NOT_FOUND:                    codeText = @"Control file not found";                    break;
        case D_BMFN_BAD_HEADER:                                codeText = @"Unrecognised header";                       break;
        case D_BMFN_BAD_INFO_BLOCK_TYPE:                       codeText = @"Unrecognised info block type";              break;
        case D_BMFN_BAD_COMMON_BLOCK_TYPE:                     codeText = @"Unrecognised common block type";            break;
        case D_BMFN_BAD_PAGE_BLOCK_TYPE:                       codeText = @"Unrecognised page block type";              break;
        case D_BMFN_BAD_CHAR_BLOCK_TYPE:                       codeText = @"Unrecognised char block type";              break;
        case D_BMFN_BAD_KERNING_BLOCK_TYPE:                    codeText = @"Unrecognised kerning block type";           break;
            
        default: codeText = @"No Error Description!"; break;
    }
    
    return codeText;
}

+ (NSError *) errorWithCode:(int)code {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[SSBitmapFont errorTextForCode:code], NSLocalizedDescriptionKey, nil];
    
    return [NSError errorWithDomain:D_BMFN_DOMAIN
                               code:code
                           userInfo:userInfo];
}

+ (NSError *) errorWithCode:(int)code userInfo:(NSMutableDictionary *)someUserInfo {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:someUserInfo];
    [userInfo setValue:[SSBitmapFont errorTextForCode:code] forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:D_BMFN_DOMAIN
                               code:code
                           userInfo:userInfo];
}

@end
