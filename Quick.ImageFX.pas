{ ***************************************************************************

  Copyright (c) 2016-2024 Kike Pérez

  Unit        : Quick.ImageFX
  Description : Image manipulation
  Author      : Kike Pérez
  Version     : 4.0
  Created     : 21/11/2017
  Modified    : 16/02/2024

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
unit Quick.ImageFX;

{$i QuickImageFX.inc}

interface

uses
  Classes,
  System.SysUtils,
  Winapi.ShellAPI,
  Winapi.Windows,
  {$IFNDEF HAS_FMX}
   Vcl.Controls,
   Vcl.Graphics,
   {$ELSE}
   System.UITypes,
   FMX.Controls,
   FMX.Graphics,
   FMX.Types,
   {$ENDIF}
  System.Math,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  System.Net.HttpClient,
  CCR.Exif,
  Quick.ImageFX.Types;

type

  IImageFX = interface
  ['{58BC1417-EC58-472E-A503-92B199C21AE8}']
    function ResizeOptions : TResizeOptions;
    function NewBitmap(w,h : Integer) : IImageFX;
    function LoadFromFile(const fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromStream(stream : TStream) : IImageFX;
    function LoadFromString(const str : string) : IImageFX;
    {$IFNDEF HAS_FMX}
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
    function LoadFromIcon(Icon : TIcon) : IImageFX;
    {$ENDIF}
    function LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
    function LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
    function LoadFromResource(const ResourceName : string) : IImageFX;
    function LoadFromHTTP(const urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : IImageFX;
    procedure GetResolution(var x,y : Integer); overload;
    function GetResolution : string; overload;
    function AspectRatio : Double;
    function AspectRatioStr : string;
    function IsEmpty : Boolean;
    function Clone : IImageFX;
    function IsGray : Boolean;
    {$IFNDEF HAS_FMX}
    procedure Assign(Graphic : TGraphic);
    function Clear(pcolor : TColor = clWhite) : IImageFX;
    {$ELSE}
    function Clear(pcolor : TAlphacolor = TAlphaColorRec.White) : IImageFX;
    {$ENDIF}
    {$IFNDEF HAS_FMX}
    function Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    {$ENDIF}
    function Draw(stream : TStream; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    {$IFNDEF HAS_FMX}
    function DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX; overload;
    {$ENDIF}
    function DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX; overload;
    function AsBitmap : TBitmap;
    function AsPNG : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    procedure SaveToPNG(const outfile : string);
    procedure SaveToJPG(const outfile : string);
    procedure SaveToBMP(const outfile : string);
    procedure SaveToGIF(const outfile : string);
    procedure SaveToFile(const outfile : string; aImgFormat : TImageFormat);
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
    function Resize(w, h : Integer) : IImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX; overload;
    function Rotate90 : IImageFX;
    function Rotate180 : IImageFX;
    function Rotate270 : IImageFX;
    function RotateBy(RoundAngle : Integer) : IImageFX;
    function RotateAngle(RotAngle : Single) : IImageFX;
    function FlipX : IImageFX;
    function FlipY : IImageFX;
    function GrayScale : IImageFX;
    function ScanlineH : IImageFX;
    function ScanlineV : IImageFX;
    function Lighten(StrenghtPercent : Integer = 30) : IImageFX;
    function Darken(StrenghtPercent : Integer = 30) : IImageFX;
    function Tint(mColor : TColor) : IImageFX;
    function TintAdd(R, G , B : Integer) : IImageFX;
    function TintBlue : IImageFX;
    function TintRed : IImageFX;
    function TintGreen : IImageFX;
    function Solarize : IImageFX;
    function Rounded(RoundLevel : Integer = 27) : IImageFX;
    function JPEGCorruptionCheck(jpg : TJPEGImage): Boolean; overload;
    function JPEGCorruptionCheck(const stream : TMemoryStream): Boolean; overload;
  end;

 TImageFX = class(TInterfacedObject)
  private
    fJPGQualityLevel : TJPGQualityLevel;
    fPNGCompressionLevel : TPNGCompressionLevel;
    fProgressiveJPG : Boolean;
    fResizeOptions : TResizeOptions;
    fHTTPOptions : THTTPOptions;
    fLastResult : TImageActionResult;
    fExifRotation : Boolean;
    function GetHTTPStream(const urlImage: string; out HTTPReturnCode: Integer): TMemoryStream;
  public
    constructor Create; overload; virtual;
    constructor Create(const fromfile : string); overload; virtual;
    destructor Destroy; override;
    property JPGQualityPercent : TJPGQualityLevel read fJPGQualityLevel write fJPGQualityLevel;
    property PNGCompressionLevel : TPNGCompressionLevel read fPNGCompressionLevel write fPNGCompressionLevel;
    property ProgressiveJPG : Boolean read fProgressiveJPG write fProgressiveJPG;
    property HTTPOptions : THTTPOptions read fHTTPOptions write fHTTPOptions;
    property ExifRotation : Boolean read fExifRotation write fExifRotation;
    property LastResult : TImageActionResult read fLastResult write fLastResult;
    function ResizeOptions : TResizeOptions;
    function GetResolution : string;
    function AspectRatioStr : string;
    procedure CloneValues(var ImgTarget : IImageFX);
    procedure InitBitmap(var bmp : TBitmap);
    procedure ProcessExifRotation(stream: TStream);
    function NeedsEXIFRotation(stream: TStream) : Boolean;
    {$IFNDEF HAS_FMX}
    function FindGraphicClass(const Buffer; const BufferSize: Int64; out GraphicClass: TGraphicClass): Boolean; overload;
    function FindGraphicClass(Stream: TStream; out GraphicClass: TGraphicClass): Boolean; overload;
    {$ENDIF}
    function GetImageFmtExt(imgFormat : TImageFormat) : string;
    function GetFileInfo(const AExt : string; var AInfo : TSHFileInfo; ALargeIcon : Boolean = false) : boolean;
    function LoadFromHTTP(const urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : IImageFX;
    class function GetAspectRatio(cWidth, cHeight : Integer) : string;
    class function ColorToRGBValues(PColor: TColor) : TRGB;
    class function RGBValuesToColor(RGBValues : TRGB) : TColor;
    class function ActionResultToString(aImgResult : TImageActionResult) : string;
    class function ColorIsLight(Color: TColor): Boolean;
    class function ColorIsDark(Color: TColor): Boolean;
    class function GetLightColor(BaseColor: TColor): TColor;
    class function GetDarkColor(BaseColor: TColor): TColor;
    class function ChangeColorIntesity(MyColor: TColor; Factor: Double): TColor;
    class procedure CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
    function JPEGCorruptionCheck(jpg : TJPEGImage): Boolean; overload;
    function JPEGCorruptionCheck(const stream : TMemoryStream): Boolean; overload;
    procedure SaveToBMP(const outfile : string); virtual; abstract;
    procedure SaveToGIF(const outfile : string); virtual; abstract;
    procedure SaveToJPG(const outfile : string); virtual; abstract;
    procedure SaveToPNG(const outfile : string); virtual; abstract;
    procedure SaveToFile(const outfile: string; aImgFormat: TImageFormat); virtual;
    class procedure AutoCropBitmap(var bmp : TBitmap; aColor : TColor);
  end;

  TImageFXClass = class of TImageFX;

implementation

{ TImageFX }

constructor TImageFX.Create;
begin
  ProgressiveJPG := False;
  JPGQualityPercent := 85;
  PNGCompressionLevel := 7;
  LastResult := arNone;
  fResizeOptions := TResizeOptions.Create;
  fResizeOptions.NoMagnify := False;
  fResizeOptions.ResizeMode := rmStretch;
  fResizeOptions.ResamplerMode := rsAuto;
  fResizeOptions.Center := False;
  fResizeOptions.FillBorders := False;
  {$IFNDEF HAS_FMX}
  fResizeOptions.BorderColor := clWhite;
  {$ELSE}
  fResizeOptions.BorderColor := TColorRec.White;
  {$ENDIF}
  fResizeOptions.SkipSmaller := False;
  HTTPOptions := THTTPOptions.Create;
  HTTPOptions.UserAgent := DEF_USERAGENT;
  HTTPOptions.ConnectionTimeout := DEF_CONNECTION_TIMEOUT;
  HTTPOptions.ResponseTimeout := DEF_RESPONSE_TIMEOUT;
  HTTPOptions.AllowCookies := False;
  HTTPOptions.HandleRedirects := True;
  HTTPOptions.MaxRedirects := 10;
  fExifRotation := True;
end;

destructor TImageFX.Destroy;
begin
  if Assigned(fResizeOptions) then fResizeOptions.Free;
  if Assigned(HTTPOptions) then HTTPOptions.Free;
  inherited;
end;

{$IFDEF HAS_FMX}
function ColorToRGB(aColor : TColor) : Integer;
begin
  Result := TColorRec.ColorToRGB(aColor);
end;
{$ENDIF}

{$IFNDEF HAS_FMX}
function TImageFX.FindGraphicClass(const Buffer; const BufferSize: Int64; out GraphicClass: TGraphicClass): Boolean;
var
  LongWords: array[Byte] of LongWord absolute Buffer;
  Words: array[Byte] of Word absolute Buffer;
begin
  GraphicClass := nil;
  Result := False;
  if BufferSize < MinGraphicSize then Exit;
  case Words[0] of
    $4D42: GraphicClass := TBitmap;
    $D8FF: GraphicClass := TJPEGImage;
    $4949: if Words[1] = $002A then GraphicClass := TWicImage; //i.e., TIFF
    $4D4D: if Words[1] = $2A00 then GraphicClass := TWicImage; //i.e., TIFF
  else
    begin
      if Int64(Buffer) = $A1A0A0D474E5089 then GraphicClass := TPNGImage
      else if LongWords[0] = $9AC6CDD7 then GraphicClass := TMetafile
       else if (LongWords[0] = 1) and (LongWords[10] = $464D4520) then GraphicClass := TMetafile
        else if StrLComp(PAnsiChar(@Buffer), 'GIF', 3) = 0 then GraphicClass := TGIFImage
         else if Words[1] = 1 then GraphicClass := TIcon
    end;
  end;
  Result := (GraphicClass <> nil);
end;

function TImageFX.FindGraphicClass(Stream: TStream; out GraphicClass: TGraphicClass): Boolean;
var
  Buffer: PByte;
  CurPos: Int64;
  BytesRead: Integer;
begin
  if Stream is TCustomMemoryStream then
  begin
    Buffer := TCustomMemoryStream(Stream).Memory;
    CurPos := Stream.Position;
    Inc(Buffer, CurPos);
    Result := FindGraphicClass(Buffer^, Stream.Size - CurPos, GraphicClass);
  end
  else
  begin
    GetMem(Buffer, MinGraphicSize);
    try
      BytesRead := Stream.Read(Buffer^, MinGraphicSize);
      Stream.Seek(-BytesRead, soCurrent);
      Result := FindGraphicClass(Buffer^, BytesRead, GraphicClass);
    finally
      FreeMem(Buffer);
    end;
  end;
end;
{$ENDIF}

function TImageFX.GetImageFmtExt(imgFormat : TImageFormat) : string;
begin
  case imgFormat of
    ifBMP: Result := '.bmp';
    ifJPG: Result := '.jpg';
    ifPNG: Result := '.png';
    ifGIF: Result := '.gif';
    else Result := '.jpg';
  end;
end;

function TImageFX.GetFileInfo(const AExt : string; var AInfo : TSHFileInfo; ALargeIcon : Boolean = False) : Boolean;
var uFlags : integer;
begin
  FillMemory(@AInfo,SizeOf(TSHFileInfo),0);
  uFlags := SHGFI_ICON+SHGFI_TYPENAME+SHGFI_USEFILEATTRIBUTES;
  if ALargeIcon then uFlags := uFlags + SHGFI_LARGEICON
    else uFlags := uFlags + SHGFI_SMALLICON;
  if SHGetFileInfo(PChar(AExt),FILE_ATTRIBUTE_NORMAL,AInfo,SizeOf(TSHFileInfo),uFlags) = 0 then Result := False
    else Result := True;
end;

function TImageFX.GetHTTPStream(const urlImage : string; out HTTPReturnCode : Integer) : TMemoryStream;
var
  http : THTTPClient;
  StatusCode : Integer;
begin
  StatusCode := 500;
  LastResult := arUnknowFmtType;
  http := THTTPClient.Create;
  try
    http.UserAgent := HTTPOptions.UserAgent;
    http.HandleRedirects := HTTPOptions.HandleRedirects;
    http.MaxRedirects := HTTPOptions.MaxRedirects;
    http.AllowCookies := HTTPOptions.AllowCookies;
    http.ConnectionTimeout := HTTPOptions.ConnectionTimeout;
    http.ResponseTimeout := HTTPOptions.ResponseTimeout;
    Result := TMemoryStream.Create;
    StatusCode := http.Get(urlImage,Result).StatusCode;
    if StatusCode = 200 then
    begin
      if (Result = nil) or (Result.Size = 0)  then
      begin
        StatusCode := 500;
        raise Exception.Create('http stream empty!');
      end
      else LastResult := arOk;
    end else raise Exception.Create(Format('Error %d retrieving url %s',[StatusCode,urlImage]));
  finally
    HTTPReturnCode := StatusCode;
    http.Free;
  end;
end;

function TImageFX.LoadFromHTTP(const urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : IImageFX;
var
  ms : TMemoryStream;
begin
  Result := (Self as IImageFX);
  HTTPReturnCode := 500;
  LastResult := arUnknowFmtType;
  try
    ms := GetHTTPStream(urlImage,HTTPReturnCode);
    try
      (Self as IImageFX).LoadFromStream(ms);
      if (Self as IImageFX).IsEmpty then
      begin
        HTTPReturnCode := 500;
        if RaiseExceptions then raise Exception.Create('Unknown Format');
      end
      else LastResult := arOk;
    finally
      ms.Free;
    end;
  except
    on E : Exception do if RaiseExceptions then raise Exception.Create(e.message);
  end;
end;

class function TImageFX.ColorToRGBValues(PColor: TColor): TRGB;
begin
  Result.B := PColor and $FF;
  Result.G := (PColor shr 8) and $FF;
  Result.R := (PColor shr 16) and $FF;
end;

constructor TImageFX.Create(const fromfile: string);
begin
  Create;
  (Self as IImageFX).LoadFromFile(fromfile);
end;

function TImageFX.ResizeOptions: TResizeOptions;
begin
  Result := fResizeOptions;
end;

function TImageFX.AspectRatioStr : string;
var
  x, y : Integer;
begin
  if not (Self as IImageFX).IsEmpty then
  begin
    (Self as IImageFX).GetResolution(x,y);
    Result := GetAspectRatio(x,y);
  end
  else Result := 'N/A';
end;

function TImageFX.GetResolution : string;
var
  x, y : Integer;
begin
  if not (Self as IImageFX).IsEmpty then
  begin
    (Self as IImageFX).GetResolution(x,y);
    Result := Format('%d x %d',[x,y]);
    LastResult := arOk;
  end
  else
  begin
    Result := 'N/A';
    LastResult := arCorruptedData;
  end;
end;

class function TImageFX.RGBValuesToColor(RGBValues : TRGB) : TColor;
begin
  Result := RGB(RGBValues.R,RGBValues.G,RGBValues.B);
end;

class function TImageFX.ActionResultToString(aImgResult: TImageActionResult) : string;
begin
  case aImgResult of
    arNone : Result := 'None';
    arOk : Result := 'Action Ok';
    arAlreadyOptim : Result := 'Already optimized';
    arRotateError : Result := 'Rotate or Flip error';
    arColorizeError : Result := 'Error manipulating pixel colors';
    arZeroBytes : Result := 'File/Stream is empty';
    arResizeError : Result := 'Resize error';
    arConversionError : Result := 'Conversion error';
    arUnknowFmtType : Result := 'Unknow Format type';
    arFileNotExist : Result := 'File not exists';
    arUnknowError : Result := 'Unknow error';
    arNoOverwrited : Result := 'Not overwrited';
    arCorruptedData : Result := 'Corrupted data';
    else Result := Format('Unknow error (%d)',[Integer(aImgResult)]);
  end;
end;

//check if color is light
class function TImageFX.ColorIsLight(Color: TColor): Boolean;
begin
  Color := ColorToRGB(Color);
  Result := ((Color and $FF) + (Color shr 8 and $FF) +
  (Color shr 16 and $FF))>= $180;
end;

//check if color is dark
class function TImageFX.ColorIsDark(Color: TColor): Boolean;
begin
  Result := not ColorIsLight(Color);
end;

//gets a more light color
class function TImageFX.GetLightColor(BaseColor: TColor): TColor;
begin
  Result := RGB(Min(GetRValue(ColorToRGB(BaseColor)) + 64, 255),
    Min(GetGValue(ColorToRGB(BaseColor)) + 64, 255),
    Min(GetBValue(ColorToRGB(BaseColor)) + 64, 255));
end;

procedure TImageFX.InitBitmap(var bmp: TBitmap);
begin
  {$IFNDEF HAS_FMX}
  bmp.PixelFormat := pf32bit;
  bmp.HandleType := bmDIB;
  bmp.AlphaFormat := afDefined;
  {$ENDIF}
end;

//gets a more dark color
class function TImageFX.GetDarkColor(BaseColor: TColor): TColor;
begin
  Result := RGB(Max(GetRValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetGValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetBValue(ColorToRGB(BaseColor)) - 64, 0));
end;

class function TImageFX.ChangeColorIntesity(MyColor: TColor; Factor: Double): TColor;
var
  Red, Green, Blue: Integer;
  ChangeAmount: Double;
begin
  // get the color components
  Red := MyColor and $FF;
  Green := (MyColor shr 8) and $FF;
  Blue := (MyColor shr 16) and $FF;

  // calculate the new color
  ChangeAmount := Red * Factor;
  Red := Min(Max(Round(Red + ChangeAmount), 0), 255);
  ChangeAmount := Green * Factor;
  Green := Min(Max(Round(Green + ChangeAmount), 0), 255);
  ChangeAmount := Blue * Factor;
  Blue := Min(Max(Round(Blue + ChangeAmount), 0), 255);

  // and return it as a TColor
  Result := Red or (Green shl 8) or (Blue shl 16);
end;

function TImageFX.JPEGCorruptionCheck(jpg : TJPEGImage): Boolean;
var
  w1 : Word;
  w2 : Word;
  ms : TMemoryStream;
begin
  Assert(SizeOf(WORD) = 2);

  ms := TMemoryStream.Create;
  try
    jpg.SaveToStream(ms);
    Result := Assigned(ms);

    if Result then
    begin
      ms.Seek(0, soFromBeginning);
      ms.Read(w1,2);

      ms.Position := ms.Size - 2;
      ms.Read(w2,2);

      Result := (w1 = $D8FF) and (w2 = $D9FF);
    end;
  finally
    ms.Free;
  end;
end;

function TImageFX.JPEGCorruptionCheck(const stream: TMemoryStream): Boolean;
var
  w1 : Word;
  w2 : Word;
begin
  Assert(SizeOf(WORD) = 2);

  Result := Assigned(stream);

  if Result then
  begin
    stream.Seek(0, soFromBeginning);
    stream.Read(w1,2);

    stream.Position := stream.Size - 2;
    stream.Read(w2,2);

    Result := (w1 = $D8FF) and (w2 = $D9FF);
  end;
end;

procedure TImageFX.ProcessExifRotation(stream: TStream);
var
  ExifData : TExifData;
begin
  //read Exif info and rotates image if needed
  stream.Seek(soFromBeginning,0);
  ExifData := TExifData.Create;
  try
    if ExifData.IsSupportedGraphic(stream) then
    begin
      stream.Seek(soFromBeginning,0);
      ExifData.LoadFromGraphic(stream);
      ExifData.EnsureEnumsInRange := False;
      if not ExifData.Empty then
      begin
        case ExifData.Orientation of
          //TExifOrientation.toTopLeft : //Normal
          TExifOrientation.toTopRight : (Self as IImageFX).FlipX; //Mirror horizontal
          TExifOrientation.toBottomRight : (Self as IImageFX).Rotate180; //Rotate 180°
          TExifOrientation.toBottomLeft : (Self as IImageFX).FlipY; //Mirror vertical
          TExifOrientation.toLeftTop : begin (Self as IImageFX).FlipX.Rotate270; end; //Mirrow horizontal and rotate 270°
          TExifOrientation.toRightTop : (Self as IImageFX).Rotate90; //Rotate 90°
          TExifOrientation.toRightBottom : begin (Self as IImageFX).FlipX.Rotate90; end; //Mirror horizontal and rotate 90°
          TExifOrientation.toLeftBottom : (Self as IImageFX).Rotate270; //Rotate 270°
        end;
      end;
    end;
  finally
    ExifData.Free;
  end;
end;

function TImageFX.NeedsEXIFRotation(stream: TStream) : Boolean;
var
  ExifData : TExifData;
begin
  Result := False;
  stream.Seek(soFromBeginning,0);
  ExifData := TExifData.Create;
  try
    if ExifData.IsSupportedGraphic(stream) then
    begin
      stream.Seek(soFromBeginning,0);
      ExifData.LoadFromGraphic(stream);
      ExifData.EnsureEnumsInRange := False;
      if not ExifData.Empty then
      begin
        if (ExifData.Orientation <> TExifOrientation.toUndefined) and (ExifData.Orientation <> TExifOrientation.toTopLeft) then Result := True;
      end;
    end;
  finally
    ExifData.Free;
  end;
end;

class procedure TImageFX.CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
var
  BasePtr: Pointer;
begin
  png := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, NewWidth, NewHeight);

  BasePtr := png.AlphaScanline[0];
  ZeroMemory(BasePtr, png.Header.Width * png.Header.Height);
end;

procedure TImageFX.CloneValues(var ImgTarget : IImageFX);
begin
  (ImgTarget as TImageFX).JPGQualityPercent := Self.JPGQualityPercent;
  (ImgTarget as TImageFX).PNGCompressionLevel := Self.PNGCompressionLevel;
  (ImgTarget as TImageFX).ProgressiveJPG := Self.ProgressiveJPG;
  (ImgTarget as TImageFX).ResizeOptions.NoMagnify := Self.ResizeOptions.NoMagnify;
  (ImgTarget as TImageFX).ResizeOptions.ResizeMode := Self.ResizeOptions.ResizeMode;
  (ImgTarget as TImageFX).ResizeOptions.ResamplerMode := Self.ResizeOptions.ResamplerMode;
  (ImgTarget as TImageFX).ResizeOptions.Center := Self.ResizeOptions.Center;
  (ImgTarget as TImageFX).ResizeOptions.FillBorders := Self.ResizeOptions.FillBorders;
  (ImgTarget as TImageFX).ResizeOptions.BorderColor := Self.ResizeOptions.BorderColor;
  (ImgTarget as TImageFX).HTTPOptions.UserAgent := Self.HTTPOptions.UserAgent;
  (ImgTarget as TImageFX).HTTPOptions.HandleRedirects := Self.HTTPOptions.HandleRedirects;
  (ImgTarget as TImageFX).HTTPOptions.MaxRedirects := Self.HTTPOptions.MaxRedirects;
  (ImgTarget as TImageFX).HTTPOptions.AllowCookies := Self.HTTPOptions.AllowCookies;
  (ImgTarget as TImageFX).HTTPOptions.ConnectionTimeout := Self.HTTPOptions.ConnectionTimeout;
  (ImgTarget as TImageFX).HTTPOptions.ResponseTimeout := Self.HTTPOptions.ResponseTimeout;
end;

function CalcCloseCrop(ABitmap: TBitmap; const ABackColor: TColor) : TRect;
var
  X: Integer;
  Y: Integer;
  Color: TColor;
  Pixel: PRGBTriple;
  RowClean: Boolean;
  LastClean: Boolean;
begin
  {$IFNDEF HAS_FMX}
  if ABitmap.PixelFormat <> pf24bit then
    raise Exception.Create('Incorrect bit depth, bitmap must be 24-bit!');
  {$ELSE}
  if ABitmap.PixelFormat <> TPixelformat.RG32F then
    raise Exception.Create('Incorrect bit depth, bitmap must be 32-bit!');
  {$ENDIF}

  LastClean := False;
  Result := Rect(ABitmap.Width, ABitmap.Height, 0, 0);

  for Y := 0 to ABitmap.Height-1 do
  begin
    RowClean := True;
    Pixel := ABitmap.ScanLine[Y];
    for X := 0 to ABitmap.Width - 1 do
    begin
      Color := RGB(Pixel.rgbtRed, Pixel.rgbtGreen, Pixel.rgbtBlue);
      if Color <> ABackColor then
      begin
        RowClean := False;
        if X < Result.Left then
          Result.Left := X;
        if X + 1 > Result.Right then
          Result.Right := X + 1;
      end;
      Inc(Pixel);
    end;

    if not RowClean then
    begin
      if not LastClean then
      begin
        LastClean := True;
        Result.Top := Y;
      end;
      if Y + 1 > Result.Bottom then
        Result.Bottom := Y + 1;
    end;
  end;

  if Result.IsEmpty then
  begin
    if Result.Left = ABitmap.Width then
      Result.Left := 0;
    if Result.Top = ABitmap.Height then
      Result.Top := 0;
    if Result.Right = 0 then
      Result.Right := ABitmap.Width;
    if Result.Bottom = 0 then
      Result.Bottom := ABitmap.Height;
  end;
end;

class procedure TImageFX.AutoCropBitmap(var bmp : TBitmap; aColor : TColor);
var
  auxbmp : TBitmap;
  rect : TRect;
begin
  rect := CalcCloseCrop(bmp,aColor);
  auxbmp := TBitmap.Create;
  try
    auxbmp.PixelFormat := bmp.PixelFormat;
    auxbmp.Width  := rect.Width;
    auxbmp.Height := rect.Height;
    BitBlt(auxbmp.Canvas.Handle, 0, 0, rect.BottomRight.x, rect.BottomRight.Y, bmp.Canvas.Handle, rect.TopLeft.x, rect.TopLeft.Y, SRCCOPY);
    bmp.Assign(auxbmp);
  finally
    auxbmp.Free;
  end;
end;

class function TImageFX.GetAspectRatio(cWidth, cHeight : Integer) : string;
var
  ar : Integer;
begin
  if cHeight = 0 then Exit;

  ar := GCD(cWidth,cHeight);
  Result := Format('%d:%d',[cWidth div ar, cHeight div ar]);
end;

procedure TImageFX.SaveToFile(const outfile: string; aImgFormat: TImageFormat);
begin
  case aImgFormat of
    TImageFormat.ifBMP : Self.SaveToBMP(outfile);
    TImageFormat.ifJPG : Self.SaveToJPG(outfile);
    TImageFormat.ifPNG : Self.SaveToPNG(outfile);
    TImageFormat.ifGIF : Self.SaveToGIF(outfile);
    else raise Exception.CreateFmt('%s engine not supports this output format!',[Self.ClassName]);
  end;
end;

end.
