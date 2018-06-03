{ ***************************************************************************

  Copyright (c) 2016-2018 Kike Pérez

  Unit        : Quick.ImageFX.Types
  Description : Image manipulation with multiple graphic libraries
  Author      : Kike Pérez
  Version     : 4.0
  Created     : 10/04/2013
  Modified    : 27/03/2018

  This file is part of QuickImageFX: https://github.com/exilon/QuickImageFX

 ***************************************************************************

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

 *************************************************************************** }
unit Quick.ImageFX.Types;

interface

uses
  Classes,
  SysUtils,
  Vcl.Controls,
  Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg;

const

  MinGraphicSize = 44;

  DEF_USERAGENT = 'Mozilla/5.0 (compatible, MSIE 11, Windows NT 6.3; Trident/7.0;  rv:11.0) like Gecko';
  DEF_CONNECTION_TIMEOUT = 60000;
  DEF_RESPONSE_TIMEOUT = 60000;

type

  TRGB = record
    R : Byte;
    G : Byte;
    B : Byte;
  end;

  TocvColorEncode = (ceNone,ceRGB,ceBGR, ceGRAY);

  TPixelInfo = record
    R : Byte;
    G : Byte;
    B : Byte;
    A : Byte;
    GV : Byte;
    ColorEncode : TocvColorEncode;
    EncodeInfo : Byte;
  end;

  EImageError = class(Exception);
  EImageDrawError = class(Exception);
  EImageRotationError = class(Exception);
  EImageResizeError = class(Exception);
  EImageTransformError = class(Exception);
  EImageConversionError = class(Exception);

  TImageFormat = (ifBMP, ifJPG, ifPNG, ifGIF);

  TImageActionResult = (arNone, arAlreadyOptim, arOk, arUnknowFmtType, arUnknowError, arNoOverwrited, arResizeError, arRotateError,
                        arColorizeError,arConversionError, arFileNotExist, arZeroBytes, arCorruptedData);

  TJPGQualityLevel = 1..100;
  TPNGCompressionLevel = 0..9;

  TScanlineMode = (smHorizontal, smVertical);


  TResizeFlags = set of (rfNoMagnify, //not stretch if source image is smaller than target size
                         rfCenter, //center image if target is bigger
                         rfFillBorders //if target is bigger fills borders with a color
                         );

  TResizeMode = (rmStretch,     //stretch original image to fit target size without preserving original aspect ratio
                 rmScale,       //recalculate width or height target size to preserve original aspect ratio
                 rmCropToFill,  //preserve target aspect ratio cropping original image to fill whole size
                 rmFitToBounds  //resize image to fit max bounds of target size
                 );

  TResamplerMode = (rsAuto, //uses rmArea for downsampling and rmLinear for upsampling
                    rsGDIStrech, //used only by GDI
                    rsNearest, //low quality - High performance
                    rsGR32Draft,   //medium quality - High performance (downsampling only)
                    rsOCVArea,   //medium quality - High performance (downsampling only)
                    rsLinear,  // medium quality - Medium performance
                    rsGR32Kernel, //high quality - Low performance (depends on kernel width)
                    rsOCVCubic,
                    rsOCVLanczos4,
                    rsVAMPBicubic,
                    rsVAMPLanczos); //high quality - Low performance

  TResizeOptions = class
    NoMagnify : Boolean;
    ResizeMode : TResizeMode;
    ResamplerMode : TResamplerMode;
    Center : Boolean;
    FillBorders : Boolean;
    BorderColor : TColor;
    SkipSmaller : Boolean; //avoid resize smaller resolution images
  end;

  THTTPOptions = class
    UserAgent : string;
    HandleRedirects : Boolean;
    MaxRedirects : Integer;
    AllowCookies : Boolean;
    ConnectionTimeout : Integer;
    ResponseTimeout : Integer;
  end;

  function GCD(a,b : integer):integer;
  function Lerp(a, b: Byte; t: Double): Byte;
  function MinEx(a, b: Longint): Longint;
  function MaxEx(a, b: Longint): Longint;

implementation

function GCD(a,b : integer):integer;
begin
  if (b mod a) = 0 then Result := a
    else Result := GCD(b, a mod b);
end;

function Lerp(a, b: Byte; t: Double): Byte;
var
  tmp: Double;
begin
  tmp := t*a + (1-t)*b;
  if tmp<0 then result := 0 else
  if tmp>255 then result := 255 else
  result := Round(tmp);
end;

function MinEx(a, b: Longint): Longint;
begin
  if a > b then Result := b
  else
    Result := a;
end;

function MaxEx(a, b: Longint): Longint;
begin
  if a > b then Result := a
  else
    Result := b;
end;


end.
