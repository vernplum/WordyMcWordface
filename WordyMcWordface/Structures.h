//
//  Structures.h
//  SSBitmapFontLabel
//
//  Created by Mike Daley on 25/10/2015.
//  Copyright (c) 2015 71Squared. All rights reserved.
//

#ifndef SSBitmapFontLabel_Structures_h
#define SSBitmapFontLabel_Structures_h

#pragma mark -
#pragma BMFont Binary Structure

#pragma pack(push, 1)

struct bmfontHeader {
    char        identifier[3];
    UInt8       version;
};

struct bmfontInfoBlock {
    UInt8       type;
    SInt32      length;
};

struct bmfontInfo {
    UInt16      fontSize;
    UInt8       bitField;
    UInt8       charSet;
    UInt16      stretchH;
    UInt8       aa;
    UInt8       paddingUp;
    UInt8       paddingRight;
    UInt8       paddingDown;
    UInt8       paddingLeft;
    UInt8       spacingHoriz;
    UInt8       spacingVert;
    UInt8       outline;
};

struct bmfontCommonBlock {
    UInt8       type;
    UInt32      length;
};

struct bmfontCommon {
    UInt16      lineHeight;
    UInt16      base;
    UInt16      scaleW;
    UInt16      scaleH;
    UInt16      pages;
    UInt8       bitField;
    UInt8       alphaChnl;
    UInt8       redChnl;
    UInt8       greenChnl;
    UInt8       blueChnl;
};

struct bmfontPageBlock {
    UInt8       type;
    UInt32      length;
};

struct bmfontCharBlock {
    UInt8       type;
    UInt32      length;
};

struct bmfontChars {
    UInt32      charId;
    UInt16      x;
    UInt16      y;
    UInt16      width;
    UInt16      height;
    SInt16      xOffset;
    SInt16      yOffset;
    SInt16      xAdvance;
    UInt8       page;
    UInt8       chnl;
};

struct bmfontKerningBlock {
    UInt8       type;
    UInt32      length;
};

struct bmfontKerningPairs {
    UInt32      first;
    UInt32      second;
    SInt16      amount;
};

#endif
