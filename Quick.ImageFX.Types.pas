{ ***************************************************************************

  Copyright (c) 2016-2018 Kike Pérez

  Unit        : Quick.ImageFX.Types
  Description : Image manipulation with multiple graphic libraries
  Author      : Kike Pérez
  Version     : 3.0
  Created     : 10/04/2013
  Modified    : 26/02/2018

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

  TImageActionResult = (arNone, arAlreadyOptim, arOk, arUnknowFmtType, arUnknowError, arNoOverwrited, arResizeError, arRotateError,
                        arColorizeError,arConversionError, arFileNotExist, arZeroBytes, arCorruptedData);

  TJPGQualityLevel = 1..100;
  TPNGCompressionLevel = 0..9;

  TImageFormat = (ifBMP, ifJPG, ifPNG, ifGIF);

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
                    rsOCVLanczos4); //high quality - Low performance

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

  TImageFX = class(TObject);

  IImageFX = interface
  ['{58BC1417-EC58-472E-A503-92B199C21AE8}']
    function LoadFromFile(fromfile : string; CheckIfFileExists : Boolean = False) : TImageFX;
    function LoadFromFile2(fromfile : string; CheckIfFileExists : Boolean = False) : TImageFX;
    function LoadFromStream(stream : TStream) : TImageFX;
    function LoadFromString(str : string) : TImageFX;
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : TImageFX;
    function LoadFromIcon(Icon : TIcon) : TImageFX;
    function LoadFromFileIcon(FileName : string; IconIndex : Word) : TImageFX;
    function LoadFromFileExtension(aFilename : string; LargeIcon : Boolean) : TImageFX;
    function LoadFromResource(ResourceName : string) : TImageFX;
    function LoadFromHTTP(urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : TImageFX;
    procedure GetResolution(var x,y : Integer); overload;
    function GetResolution : string; overload;
    function AspectRatio : Double;
    function AspectRatioStr : string;
    function Clone : TImageFX;
    function IsGray : Boolean;
    function Clear(pcolor : TColor = clWhite) : TImageFX;
    function DrawCentered(png : TPngImage; alpha : Double = 1) : TImageFX; overload;
    function DrawCentered(stream: TStream; alpha : Double = 1) : TImageFX; overload;
    function Draw(png : TPngImage; x, y : Integer; alpha : Double = 1) : TImageFX; overload;
    function Draw(jpg : TJPEGImage; x: Integer; y: Integer; alpha: Double = 1) : TImageFX; overload;
    function Draw(stream : TStream; x, y : Integer; alpha : Double = 1) : TImageFX; overload;
    procedure SaveToPNG(outfile : string);
    procedure SaveToJPG(outfile : string);
    procedure SaveToBMP(outfile : string);
    procedure SaveToGIF(outfile : string);
  end;

  IImageFXTransform = interface
  ['{8B7B6447-8DFB-40F5-B729-0E2F34EB3F2F}']
    function Resize(w, h : Integer) : TImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : TImageFX; overload;
    function Rotate90 : TImageFX;
    function Rotate180 : TImageFX;
    function Rotate270 : TImageFX;
    function RotateBy(RoundAngle : Integer) : TImageFX;
    function RotateAngle(RotAngle : Single) : TImageFX;
    function FlipX : TImageFX;
    function FlipY : TImageFX;
    function GrayScale : TImageFX;
    function ScanlineH : TImageFX;
    function ScanlineV : TImageFX;
    function Lighten(StrenghtPercent : Integer = 30) : TImageFX;
    function Darken(StrenghtPercent : Integer = 30) : TImageFX;
    function Tint(mColor : TColor) : TImageFX;
    function TintAdd(R, G , B : Integer) : TImageFX;
    function TintBlue : TImageFX;
    function TintRed : TImageFX;
    function TintGreen : TImageFX;
    function Solarize : TImageFX;
    function Rounded(RoundLevel : Integer = 27) : TImageFX;
  end;

implementation


end.
