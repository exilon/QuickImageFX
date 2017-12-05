{ ***************************************************************************

  Copyright (c) 2013-2017 Kike Pérez

  Unit        : Quick.ImageFX.GR32
  Description : Image manipulation with GR32
  Author      : Kike Pérez
  Version     : 3.0
  Created     : 10/04/2013
  Modified    : 05/12/2017

  This file is part of QuickImageFX: https://github.com/exilon/QuickImageFX

  Third-party libraries used:
    Graphics32 (https://github.com/graphics32/graphics32)
    CCR-Exif from Chris Rolliston (https://code.google.com/archive/p/ccr-exif)

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
unit Quick.ImageFX.GR32;

interface

uses

	 Windows,
   Classes,
   Controls,
   Vcl.ImgList,
   System.SysUtils,
   Vcl.Graphics,
   Winapi.ShellAPI,
   System.Math,
   GR32,
   GR32_Resamplers,
   GR32_Image,
   GR32_Filters,
   GR32_Transforms,
   GR32_Math,
   System.Net.HttpClient,
   GDIPAPI,
   GDIPOBJ,
   GDIPUTIL,
   Vcl.Imaging.pngimage,
   Vcl.Imaging.jpeg,
   Vcl.Imaging.GIFImg,
   Quick.Base64,
   Quick.ImageFX.Base,
   Quick.ImageFX.Types;


const
  MaxPixelCountA = MaxInt Div SizeOf (TRGBQuad);

type

  TImageFormat = (ifBMP, ifJPG, ifPNG, ifGIF);

  TScanlineMode = (smHorizontal, smVertical);

  PRGBAArray = ^TRGBAArray;
  TRGBAArray = Array [0..MaxPixelCountA -1] Of TRGBQuad;

  PGPColorArr = ^TGPColorArr;
  TGPColorArr = array[0..500] of TGPColor;

  pRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = ARRAY [0 .. $EFFFFFF] OF TRGBQuad;

  TRGBArray = ARRAY[0..32767] OF TRGBTriple;
  pRGBArray = ^TRGBArray;

  TImageFX = class(TImageFXBase)
  private
    fBitmap : TBitmap32;
    procedure InitBitmap(var bmp : TBitmap);
    procedure CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : TImageFX;
    procedure GPBitmapToBitmap(gpbmp : TGPBitmap; bmp : TBitmap32);
    function GetFileInfo(AExt : string; var AInfo : TSHFileInfo; ALargeIcon : Boolean = false) : boolean;
    procedure SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp32 : TBitmap32);
    function GetPixelImage(const x, y: Integer; bmp32 : TBitmap32): TPixelInfo;
  protected
    function GetPixel(const x, y: Integer): TPixelInfo;
    procedure SetPixel(const x, y: Integer; const P: TPixelInfo);
  public
    property AsBitmap32 : TBitmap32 read fBitmap write fBitmap;
    constructor Create; overload; override;
    constructor Create(fromfile : string); overload;
    destructor Destroy; override;
    function NewBitmap(w, h : Integer) : TImageFx;
    property Pixel[const x, y: Integer]: TPixelInfo read GetPixel write SetPixel;
    function LoadFromFile(fromfile : string; CheckIfFileExists : Boolean = False) : TImageFX;
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
    class function GetAspectRatio(cWidth, cHeight : Integer) : string;
    function Clear : TImageFX;
    function Resize(w, h : Integer) : TImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rmLinear) : TImageFX; overload;
    function Draw(png : TPngImage; alpha : Double = 1) : TImageFX; overload;
    function Draw(png : TPngImage; x, y : Integer; alpha : Double = 1) : TImageFX; overload;
    function Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : TImageFX; overload;
    function DrawCentered(png : TPngImage; alpha : Double = 1) : TImageFX; overload;
    function DrawCentered(stream: TStream; alpha : Double = 1) : TImageFX; overload;
    function Rotate90 : TImageFX;
    function Rotate180 : TImageFX;
    function Rotate270 : TImageFX;
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
    function AntiAliasing : TImageFX;
    function SetAlpha(Alpha : Byte) : TImageFX;
    procedure SaveToPNG(outfile : string);
    procedure SaveToJPG(outfile : string);
    procedure SaveToBMP(outfile : string);
    procedure SaveToGIF(outfile : string);
    function AsBitmap : TBitmap;
    function AsPNG : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
  end;


implementation


constructor TImageFX.Create;
begin
  inherited Create;
  fBitmap := TBitmap32.Create;
end;

procedure TImageFX.InitBitmap(var bmp : TBitmap);
begin
  bmp.PixelFormat := pf32bit;
  bmp.HandleType := bmDIB;
  bmp.AlphaFormat := afDefined;
end;

constructor TImageFX.Create(fromfile: string);
begin
  Create;
  LoadFromFile(fromfile);
end;

destructor TImageFX.Destroy;
begin
  if Assigned(fBitmap) then fBitmap.Free;
  inherited;
end;

{function TImageFX.LoadFromFile(fromfile: string) : TImageFX;
var
  fs: TFileStream;
  FirstBytes: AnsiString;
  Graphic: TGraphic;
  bmp : TBitmap;
begin
  Result := Self;

  if not FileExists(fromfile) then
  begin
    fLastResult := arFileNotExist;
    Exit;
  end;

  Graphic := nil;
  fs := TFileStream.Create(fromfile, fmOpenRead);
  try
    SetLength(FirstBytes, 8);
    fs.Read(FirstBytes[1], 8);
    if Copy(FirstBytes, 1, 2) = 'BM' then
    begin
      Graphic := TBitmap.Create;
    end else
    if FirstBytes = #137'PNG'#13#10#26#10 then
    begin
      Graphic := TPngImage.Create;
    end else
    if Copy(FirstBytes, 1, 3) =  'GIF' then
    begin
      Graphic := TGIFImage.Create;
    end else
    if Copy(FirstBytes, 1, 2) = #$FF#$D8 then
    begin
      Graphic := TJPEGImage.Create;
    end;
    if Assigned(Graphic) then
    begin
      try
        fs.Seek(0, soFromBeginning);
        Graphic.LoadFromStream(fs);
        bmp := TBitmap.Create;
        try
          InitBitmap(bmp);
          bmp.Assign(Graphic);
          fBitmap.Assign(bmp);
          fLastResult := arOk;
        finally
          bmp.Free;
        end;
      except
      end;
      Graphic.Free;
    end;
  finally
    fs.Free;
  end;
end;}

function TImageFX.LoadFromFile(fromfile: string; CheckIfFileExists : Boolean = False) : TImageFX;
var
  GPBitmap : TGPBitmap;
  Status : TStatus;
  PropItem : PPropertyItem;
  PropSize: UINT;
  Orientation : PWORD;
begin
  Result := Self;

  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    Exit;
  end;

  GPBitmap := TGPBitmap.Create(fromfile);
  try
    //read EXIF orientation to rotate if needed
    PropSize := GPBitmap.GetPropertyItemSize(PropertyTagOrientation);
    GetMem(PropItem,PropSize);
    try
      Status := GPBitmap.GetPropertyItem(PropertyTagOrientation,PropSize,PropItem);
      if Status = TStatus.Ok then
      begin
        Orientation := PWORD(PropItem^.Value);
        case Orientation^ of
          6 : GPBitmap.RotateFlip(Rotate90FlipNone);
          8 : GPBitmap.RotateFlip(Rotate270FlipNone);
          3 : GPBitmap.RotateFlip(Rotate180FlipNone);
        end;
      end;
    finally
      FreeMem(PropItem);
    end;
    GPBitmapToBitmap(GPBitmap,fBitmap);
    LastResult := arOk;
  finally
    GPBitmap.Free;
  end;
end;

function TImageFX.LoadFromStream(stream: TStream) : TImageFX;
var
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
begin
  Result := Self;

  if not Assigned(stream) then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;

  if not FindGraphicClass(Stream, GraphicClass) then raise EInvalidGraphic.Create('Unknow Graphic format');
  Graphic := GraphicClass.Create;
  try
    stream.Seek(0,soBeginning);
    Graphic.LoadFromStream(stream);
    fBitmap.Assign(Graphic);
    //GetEXIFInfo(stream);
    LastResult := arOk;
  finally
    Graphic.Free;
  end;
end;

function TImageFX.LoadFromString(str: string) : TImageFX;
var
  stream : TStringStream;
begin
  Result := Self;

  if str = '' then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;

  str := Base64Decode(str);
  stream := TStringStream.Create(str);
  try
    fBitmap.LoadFromStream(stream);
    LastResult := arOk;
  finally
    stream.Free;
  end;
end;

function TImageFX.LoadFromFileIcon(FileName : string; IconIndex : Word) : TImageFX;
var
   Icon : TIcon;
begin
  Result := Self;
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractAssociatedIcon(hInstance,pChar(FileName),IconIndex);
    Icon.Transparent := True;
    fBitmap.Assign(Icon);
  finally
    Icon.Free;
  end;
end;

function TImageFX.LoadFromResource(ResourceName : string) : TImageFX;
var
   icon : TIcon;
   GPBitmap : TGPBitmap;
begin
  Result := Self;

  icon:=TIcon.Create;
  try
    icon.LoadFromResourceName(HInstance,ResourceName);
    icon.Transparent:=True;
    GPBitmap := TGPBitmap.Create(Icon.Handle);
    try
      GPBitmapToBitmap(GPBitmap,fBitmap);
    finally
      if Assigned(GPBitmap) then GPBitmap.Free;
    end;
  finally
    icon.Free;
  end;
  //png:=TPngImage.CreateBlank(COLOR_RGBALPHA,16,Icon.Width,Icon.Height);
  //png.Canvas.Draw(0,0,Icon);
  //DrawIcon(png.Canvas.Handle, 0, 0, Icon.Handle);
end;

function TImageFX.LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : TImageFX;
var
  icon : TIcon;
begin
  Result := Self;
  //imgList.ColorDepth := cd32bit;
  //imgList.DrawingStyle := dsTransparent;
  icon := TIcon.Create;
  try
    imgList.GetIcon(ImageIndex,icon);
    fBitmap.Assign(Icon);
  finally
    icon.Free;
  end;
end;

function TImageFX.LoadFromIcon(Icon : TIcon) : TImageFX;
begin
  Result := Self;
  fBitmap.Assign(Icon);
end;

function TImageFX.LoadFromFileExtension(aFilename : string; LargeIcon : Boolean) : TImageFX;
var
  icon : TIcon;
  aInfo : TSHFileInfo;
begin
  Result := Self;
  LastResult := arUnknowFmtType;
  if GetFileInfo(ExtractFileExt(aFilename),aInfo,LargeIcon) then
  begin
    icon := TIcon.Create;
    try
      Icon.Handle := AInfo.hIcon;
      Icon.Transparent := True;
      fBitmap.Assign(Icon);
      LastResult := arOk;
    finally
      icon.Free;
      DestroyIcon(aInfo.hIcon);
    end;
  end;
end;

function TImageFX.LoadFromHTTP(urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : TImageFX;
var
  http : THTTPClient;
  ms : TMemoryStream;
  pic : TGraphic;
begin
  Result := Self;
  HTTPReturnCode := 500;
  LastResult := arUnknowFmtType;
  ms := GetHTTPStream(urlImage,HTTPReturnCode);
  try
    if urlImage.EndsWith('.jpg',True) then  pic := TJPEGImage.Create
      else if urlImage.EndsWith('.png',True) then pic := TPngImage.Create
      else if urlImage.EndsWith('.bmp',True) then pic := TBitmap.Create
      else if urlImage.EndsWith('.gif',True) then pic := TGIFImage.Create
      else raise Exception.Create('Unknow Format');
    try
      pic.LoadFromStream(ms);
      fBitmap.Assign(pic);
      LastResult := arOk;
    finally
      pic.Free;
    end;
  finally
    ms.Free;
  end;
end;

function TImageFX.AspectRatio : Double;
begin
  if Assigned(fBitmap) then Result := fBitmap.width / fBitmap.Height
    else Result := 0;
end;


function TImageFX.AspectRatioStr : string;
begin
  if Assigned(fBitmap) then
  begin
    Result := GetAspectRatio(fBitmap.Width,fBitmap.Height);
  end
  else Result := 'N/A';
end;

class function TImageFX.GetAspectRatio(cWidth, cHeight : Integer) : string;
var
  ar : Integer;
begin
  if cHeight = 0 then Exit;

  ar := GCD(cWidth,cHeight);
  Result := Format('%d:%d',[cWidth div ar, cHeight div ar]);
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

procedure TImageFX.GetResolution(var x,y : Integer);
begin
  if Assigned(fBitmap) then
  begin
    x := fBitmap.Width;
    y := fBitmap.Height;
    LastResult := arOk;
  end
  else
  begin
    x := -1;
    y := -1;
    LastResult := arCorruptedData;
  end;
end;

function TImageFX.GetResolution : string;
begin
  if Assigned(fBitmap) then
  begin
    Result := Format('%d x %d',[fBitmap.Width,fBitmap.Height]);
    LastResult := arOk;
  end
  else
  begin
    Result := 'N/A';
    LastResult := arCorruptedData;
  end;
end;

function TImageFX.Clear : TImageFX;
begin
  Result := Self;
  fBitmap.Clear;
  fBitmap.FillRect(0,0,fBitmap.Width,fBitmap.Height,Color32(clNone));
  LastResult := arOk;
end;

function TImageFX.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : TImageFX;
var
  bmp32 : TBitmap32;
  Resam : TCustomResampler;
  srcRect,
  tgtRect : TRect;
  crop : Integer;
  srcRatio : Double;
  nw, nh : Integer;
begin
  Result := Self;

  if (not Assigned(fBitmap)) or ((fBitmap.Width * fBitmap.Height) = 0) then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;


  //if any value is 0, calculates proportionaly
  if (w * h) = 0 then
  begin
    ResizeOptions.ResizeMode := rmFitToBounds;
    if w > h then
    begin
      nh := (w * fBitmap.Height) div fBitmap.Width;
      h := nh;
      nw := w;
    end
    else
    begin
      nw := (h * fBitmap.Width) div fBitmap.Height;
      w := nw;
      nh := h;
    end;
  end;

  case ResizeOptions.ResizeMode of
    rmScale: //recalculate width or height target size to preserve original aspect ratio
      begin
        if fBitmap.Width > fBitmap.Height then
        begin
          nh := (w * fBitmap.Height) div fBitmap.Width;
          h := nh;
          nw := w;
        end
        else
        begin
          nw := (h * fBitmap.Width) div fBitmap.Height;
          w := nw;
          nh := h;
        end;
        srcRect := Rect(0,0,fBitmap.Width,fBitmap.Height);
      end;
    rmCropToFill: //preserve target aspect ratio cropping original image to fill whole size
      begin
        nw := w;
        nh := h;
        crop := Round(h / w * fBitmap.Width);
        if crop < fBitmap.Height then
        begin
          //target image is wider, so crop top and bottom
          srcRect.Left := 0;
          srcRect.Top := (fBitmap.Height - crop) div 2;
          srcRect.Width := fBitmap.Width;
          srcRect.Height := crop;
        end
        else
        begin
          //target image is narrower, so crop left and right
          crop := Round(w / h * fBitmap.Height);
          srcRect.Left := (fBitmap.Width - crop) div 2;
          srcRect.Top := 0;
          srcRect.Width := crop;
          srcRect.Height := fBitmap.Height;
        end;
      end;
    rmFitToBounds: //resize image to fit max bounds of target size
      begin
        srcRatio := fBitmap.Width / fBitmap.Height;
        if fBitmap.Width > fBitmap.Height then
        begin
          nw := w;
          nh := Round(w / srcRatio);
          if nh > h then //too big
          begin
            nh := h;
            nw := Round(h * srcRatio);
          end;
        end
        else
        begin
          nh := h;
          nw := Round(h * srcRatio);
          if nw > w then //too big
          begin
            nw := w;
            nh := Round(w / srcRatio);
          end;
        end;
        srcRect := Rect(0,0,fBitmap.Width,fBitmap.Height);
      end;
    else
    begin
      nw := w;
      nh := h;
      srcRect := Rect(0,0,fBitmap.Width,fBitmap.Height);
    end;
  end;

  //if image is smaller no upsizes
  if ResizeOptions.NoMagnify then
  begin
    if (fBitmap.Width < nw) or (fBitmap.Height < nh) then
    begin
      //if FitToBounds then preserve original size
      if ResizeOptions.ResizeMode = rmFitToBounds then
      begin
        nw := fBitmap.Width;
        nh := fBitmap.Height;
      end
      else
      begin
        //all cases no resizes, but CropToFill needs to grow to fill target size
        if ResizeOptions.ResizeMode <> rmCropToFill then
        begin
          LastResult := arAlreadyOptim;
          Exit;
        end;
      end;
    end;
  end;

  if ResizeOptions.Center then
  begin
    tgtRect.Top := (h - nh) div 2;
    tgtRect.Left := (w - nw) div 2;
    tgtRect.Width := nw;
    tgtRect.Height := nh;
  end
  else tgtRect := Rect(0,0,nw,nh);

  //selects resampler algorithm
  case ResizeOptions.ResamplerMode of
    rmAuto :
      begin
        if (w < fBitmap.Width ) or (h < fBitmap.Height) then Resam := TDraftResampler.Create
          else Resam := TLinearResampler.Create;
      end;
    rmNearest : Resam := TNearestResampler.Create;
    rmGR32Draft : Resam := TDraftResampler.Create;
    rmGR32Kernel : Resam := TKernelResampler.Create;
    rmLinear : Resam := TLinearResampler.Create;
    else Resam := TKernelResampler.Create;
  end;

  try
    bmp32 := TBitmap32.Create;
    try
      bmp32.Width := w;
      bmp32.Height := h;
      if ResizeOptions.FillBorders then bmp32.FillRect(0,0,w,h,Color32(ResizeOptions.BorderColor));
      StretchTransfer(bmp32,tgtRect,tgtRect,fBitmap,srcRect,Resam,dmOpaque,nil);
      try
        fBitmap.Assign(bmp32);
        LastResult := arOk;
      except
        LastResult := arCorruptedData;
      end;
    finally
      bmp32.Free;
    end;
  finally
    Resam.Free;
  end;
end;

function TImageFX.Resize(w, h : Integer) : TImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFX.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rmLinear) : TImageFX;
var
  ResizeOptions : TResizeOptions;
begin
  ResizeOptions := TResizeOptions.Create;
  try
    if (rfNoMagnify in ResizeFlags) then ResizeOptions.NoMagnify := True else ResizeOptions.NoMagnify := False;
    if (rfCenter in ResizeFlags) then ResizeOptions.Center := True else ResizeOptions.Center := False;
    if (rfFillBorders in ResizeFlags) then ResizeOptions.FillBorders := True else ResizeOptions.FillBorders := False;
    Result := ResizeImage(w,h,ResizeOptions);
  finally
    ResizeOptions.Free;
  end;
end;

function TImageFX.Draw(png : TPngImage; alpha : Double = 1) : TImageFX;
begin
  Result := Self;
  Draw(png, (fBitmap.Width - png.Width) div 2, (fBitmap.Height - png.Height) div 2);
end;

function TImageFX.Draw(png : TPngImage; x, y : Integer; alpha : Double = 1) : TImageFX;
begin
  Result := Self;
  fBitmap.DrawMode := TDrawMode.dmTransparent;
  fBitmap.Canvas.Draw(x,y,png);
end;

function TImageFX.Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : TImageFX;
var
  overlay : TPngImage;
  Buffer : TBytes;
  Size : Int64;
begin
  //get overlay image
  overlay.LoadFromStream(stream);
  //needs x or y center image
  if x = -1 then x := (fBitmap.Width - overlay.Width) div 2;
  if y = -1 then y := (fBitmap.Height - overlay.Height) div 2;
  Result := Draw(overlay,x,y,alpha);
end;

function TImageFX.DrawCentered(png : TPngImage; alpha : Double = 1) : TImageFX;
begin
  Result := Draw(png,(fBitmap.Width - png.Width) div 2, (fBitmap.Height - png.Height) div 2,alpha);
end;

function TImageFX.DrawCentered(stream: TStream; alpha : Double = 1) : TImageFX;
begin
  Result := Draw(stream,-1,-1,alpha);
end;

function TImageFX.NewBitmap(w, h: Integer): TImageFx;
begin
  if Assigned(Self.fBitmap) then
  begin
    Self.fBitmap.Clear;
    Self.fBitmap.SetSize(w, h);
  end
  else  Result := Self;
end;

function TImageFX.Rotate90 : TImageFX;
var
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  bmp32 := TBitmap32.Create;
  try
    bmp32.Assign(fBitmap);
    bmp32.Rotate90(fBitmap);
    LastResult := arOk;
  finally
    bmp32.Free;
  end;
end;

function TImageFX.Rotate180 : TImageFX;
var
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  bmp32 := TBitmap32.Create;
  try
    bmp32.Assign(fBitmap);
    bmp32.Rotate180(fBitmap);
    LastResult := arOk;
  finally
    bmp32.Free;
  end;
end;

function TImageFX.RotateAngle(RotAngle: Single) : TImageFX;
var
  SrcR: Integer;
  SrcB: Integer;
  T: TAffineTransformation;
  Sn, Cn: TFloat;
  Sx, Sy, Scale: Single;
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  //SetBorderTransparent(fBitmap, fBitmap.BoundsRect);
  SrcR := fBitmap.Width - 1;
  SrcB := fBitmap.Height - 1;
  T := TAffineTransformation.Create;
  T.SrcRect := FloatRect(0, 0, SrcR + 1, SrcB + 1);
  try
    // shift the origin
    T.Clear;

    // move the origin to a center for scaling and rotation
    T.Translate(-SrcR * 0.5, -SrcB * 0.5);
    T.Rotate(0, 0, RotAngle);
    RotAngle := RotAngle * PI / 180;

    // get the width and height of rotated image (without scaling)
    GR32_Math.SinCos(RotAngle, Sn, Cn);
    Sx := Abs(SrcR * Cn) + Abs(SrcB * Sn);
    Sy := Abs(SrcR * Sn) + Abs(SrcB * Cn);

    // calculate a new scale so that the image fits in original boundaries
    Sx := fBitmap.Width / Sx;
    Sy := fBitmap.Height / Sy;
    Scale := Min(Sx, Sy);

    T.Scale(Scale);

    // move the origin back
    T.Translate(SrcR * 0.5, SrcB * 0.5);

    // transform the bitmap
    bmp32 := TBitmap32.Create;
    bmp32.SetSize(fBitmap.Width,fBitmap.Height);
    try
      //bmp32.Clear(clBlack32);
      Transform(bmp32, fBitmap, T);
      fBitmap.Assign(bmp32);
      LastResult := arOk;
    finally
      bmp32.Free;
    end;
  finally
    T.Free;
  end;
end;

function TImageFX.Rotate270 : TImageFX;
var
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  bmp32 := TBitmap32.Create;
  try
    bmp32.Assign(fBitmap);
    bmp32.Rotate270(fBitmap);
    LastResult := arOk;
  finally
    bmp32.Free;
  end;
end;

function TImageFX.FlipX : TImageFX;
var
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  bmp32 := TBitmap32.Create;
  try
    bmp32.Assign(fBitmap);
    bmp32.FlipHorz(fBitmap);
    LastResult := arOk;
  finally
    bmp32.Free;
  end;
end;

function TImageFX.FlipY : TImageFX;
var
  bmp32 : TBitmap32;
begin
  Result := Self;
  LastResult := arRotateError;
  bmp32 := TBitmap32.Create;
  try
    bmp32.Assign(fBitmap);
    bmp32.FlipVert(fBitmap);
    LastResult := arOk;
  finally
    bmp32.Free;
  end;
end;

function TImageFX.GrayScale : TImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;
  ColorToGrayScale(fBitmap,fBitmap,True);
  LastResult := arOk;
end;

function TImageFX.Lighten(StrenghtPercent : Integer = 30) : TImageFX;
var
  Bits: PColor32Entry;
  I, J: Integer;
begin
  Result := Self;
  LastResult := arColorizeError;
  Bits := @fBitmap.Bits[0];
  fBitmap.BeginUpdate;
  try
    for I := 0 to fBitmap.Height - 1 do
    begin
      for J := 0 to fBitmap.Width - 1 do
      begin
        if Bits.R + 5 < 255 then Bits.R := Bits.R + 5;
        if Bits.G + 5 < 255 then Bits.G := Bits.G + 5;
        if Bits.B + 5 < 255 then Bits.B := Bits.B + 5;

        Inc(Bits);
      end;
    end;
    LastResult := arOk;
  finally
    fBitmap.EndUpdate;
    fBitmap.Changed;
  end;
end;

function TImageFX.Darken(StrenghtPercent : Integer = 30) : TImageFX;
var
  Bits: PColor32Entry;
  I, J: Integer;
  Percent: Single;
  Brightness: Integer;
begin
  Result := Self;
  LastResult := arColorizeError;
  Percent := (100 - StrenghtPercent) / 100;
  Bits := @fBitmap.Bits[0];
  fBitmap.BeginUpdate;
  try
    for I := 0 to fBitmap.Height - 1 do
    begin
      for J := 0 to fBitmap.Width - 1 do
      begin
        Brightness := Round((Bits.R+Bits.G+Bits.B)/765);
        Bits.R := Lerp(Bits.R, Brightness, Percent);
        Bits.G := Lerp(Bits.G, Brightness, Percent);
        Bits.B := Lerp(Bits.B, Brightness, Percent);

        Inc(Bits);
      end;
    end;
    LastResult := arOk;
  finally
    fBitmap.EndUpdate;
    fBitmap.Changed;
  end;
end;

function TImageFX.Tint(mColor : TColor) : TImageFX;
var
  Bits: PColor32Entry;
  Color: TColor32Entry;
  I, J: Integer;
  Percent: Single;
  Brightness: Single;
begin
  Result := Self;
  LastResult := arColorizeError;
  Color.ARGB := Color32(mColor);
  Percent := 10 / 100;
  Bits := @fBitmap.Bits[0];
  fBitmap.BeginUpdate;
  try
    for I := 0 to fBitmap.Height - 1 do
    begin
      for J := 0 to fBitmap.Width - 1 do
      begin
        Brightness := (Bits.R+Bits.G+Bits.B)/765;
        Bits.R := Lerp(Bits.R, Round(Brightness * Color.R), Percent);
        Bits.G := Lerp(Bits.G, Round(Brightness * Color.G), Percent);
        Bits.B := Lerp(Bits.B, Round(Brightness * Color.B), Percent);

        Inc(Bits);
      end;
    end;
    LastResult := arOk;
  finally
    fBitmap.EndUpdate;
    fBitmap.Changed;
  end;
end;

function TImageFX.TintAdd(R, G , B : Integer) : TImageFX;
var
  Bits: PColor32Entry;
  I, J: Integer;
begin
  Result := Self;
  LastResult := arColorizeError;
  Bits := @fBitmap.Bits[0];

  fBitmap.BeginUpdate;
  try
    for I := 0 to fBitmap.Height - 1 do
    begin
      for J := 0 to fBitmap.Width - 1 do
      begin
        //Brightness := (Bits.R+Bits.G+Bits.B)/765;
        if R > -1 then Bits.R := Bits.R + R;
        if G > -1 then Bits.G := Bits.G + G;
        if B > -1 then Bits.B := Bits.B + B;

        Inc(Bits);
      end;
    end;
    LastResult := arOk;
  finally
    fBitmap.EndUpdate;
    fBitmap.Changed;
  end;
end;

function TImageFX.TintBlue : TImageFX;
begin
  Result := Tint(clBlue);
end;

function TImageFX.TintRed : TImageFX;
begin
  Result := Tint(clRed);
end;

function TImageFX.TintGreen : TImageFX;
begin
  Result := Tint(clGreen);
end;

function TImageFX.Solarize : TImageFX;
begin
  Result := TintAdd(255,-1,-1);
end;

function TImageFX.ScanlineH;
begin
  Result := Self;
  DoScanLines(smHorizontal);
end;

function TImageFX.ScanlineV;
begin
  Result := Self;
  DoScanLines(smVertical);
end;

procedure TImageFX.DoScanLines(ScanLineMode : TScanlineMode);
var
  Bits: PColor32Entry;
  Color: TColor32Entry;
  I, J: Integer;
  DoLine : Boolean;
begin
  LastResult := arColorizeError;
  Color.ARGB := Color32(clBlack);
  Bits := @fBitmap.Bits[0];

  fBitmap.BeginUpdate;
  try
    for I := 0 to fBitmap.Height - 1 do
    begin
      for J := 0 to fBitmap.Width - 1 do
      begin
        DoLine := False;
        if ScanLineMode = smHorizontal then
        begin
          if Odd(I) then DoLine := True;
        end
        else
        begin
          if Odd(J) then DoLine := True;
        end;
        if DoLine then
        begin
          Bits.R := Round(Bits.R-((Bits.R/255)*100));;// Lerp(Bits.R, Round(Brightness * Color.R), Percent);
          Bits.G := Round(Bits.G-((Bits.G/255)*100));;//Lerp(Bits.G, Round(Brightness * Color.G), Percent);
          Bits.B := Round(Bits.B-((Bits.B/255)*100));;//Lerp(Bits.B, Round(Brightness * Color.B), Percent);
        end;
        Inc(Bits);
      end;
    end;
    LastResult := arOk;
  finally
    fBitmap.EndUpdate;
    fBitmap.Changed;
  end;
end;

procedure TImageFX.SaveToPNG(outfile : string);
var
  png : TPngImage;
begin
  LastResult := arConversionError;
  png := AsPNG;
  try
    png.SaveToFile(outfile);
  finally
    png.Free;
  end;
  LastResult := arOk;
end;

procedure TImageFX.SaveToJPG(outfile : string);
var
  jpg : TJPEGImage;
begin
  LastResult := arConversionError;
  jpg := AsJPG;
  try
    jpg.SaveToFile(outfile);
  finally
    jpg.Free;
  end;
  LastResult := arOk;
end;

procedure TImageFX.SaveToBMP(outfile : string);
var
  bmp : TBitmap;
begin
  LastResult := arConversionError;
  bmp := AsBitmap;
  try
    bmp.SaveToFile(outfile);
  finally
    bmp.Free;
  end;
  LastResult := arOk;
end;

procedure TImageFX.SaveToGIF(outfile : string);
var
  gif : TGIFImage;
begin
  LastResult := arConversionError;
  gif := AsGIF;
  try
    gif.SaveToFile(outfile);
  finally
    gif.Free;
  end;
  LastResult := arOk;
end;


procedure TImageFX.SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
var
  graf : TGraphic;
begin
  case imgFormat of
    ifBMP:
      begin
        graf := TBitmap.Create;
        try
          graf := Self.AsBitmap;
          graf.SaveToStream(stream);
        finally
          graf.Free;
        end;
      end;
    ifJPG:
      begin
        graf := TJPEGImage.Create;
        try
          graf := Self.AsJPG;
          graf.SaveToStream(stream);
        finally
          graf.Free;
        end;
      end;
    ifPNG:
      begin
        graf := TPngImage.Create;
        try
          graf := Self.AsPNG;
          graf.SaveToStream(stream);
        finally
          graf.Free;
        end;
      end;
    ifGIF:
      begin
        graf := TGIFImage.Create;
        try
          graf := Self.AsGIF;
          graf.SaveToStream(stream);
        finally
          graf.Free;
        end;
      end;
  end;
end;

procedure TImageFX.GPBitmapToBitmap(gpbmp : TGPBitmap; bmp : TBitmap32);
var
  Graphics : TGPGraphics;
begin
  //bmp.PixelFormat := pf32bit;
  //bmp.HandleType := bmDIB;
  //bmp.AlphaFormat := afDefined;
  bmp.Width := gpbmp.GetWidth;
  bmp.Height := gpbmp.GetHeight;
  Graphics := TGPGraphics.Create(bmp.Canvas.Handle);
  try
    Graphics.Clear(ColorRefToARGB(ColorToRGB(clNone)));
    // set the composition mode to copy
    Graphics.SetCompositingMode(CompositingModeSourceCopy);
    // set high quality rendering modes
    Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    Graphics.SetSmoothingMode(SmoothingModeHighQuality);
    // draw the input image on the output in modified size
    Graphics.DrawImage(gpbmp,0,0,gpbmp.GetWidth,gpbmp.GetHeight);
  finally
    Graphics.Free;
  end;
end;

function TImageFX.GetFileInfo(AExt : string; var AInfo : TSHFileInfo; ALargeIcon : Boolean = False) : Boolean;
var uFlags : integer;
begin
  FillMemory(@AInfo,SizeOf(TSHFileInfo),0);
  uFlags := SHGFI_ICON+SHGFI_TYPENAME+SHGFI_USEFILEATTRIBUTES;
  if ALargeIcon then uFlags := uFlags + SHGFI_LARGEICON
    else uFlags := uFlags + SHGFI_SMALLICON;
  if SHGetFileInfo(PChar(AExt),FILE_ATTRIBUTE_NORMAL,AInfo,SizeOf(TSHFileInfo),uFlags) = 0 then Result := False
    else Result := True;
end;

function TImageFX.AsBitmap : TBitmap;
begin
  LastResult := arConversionError;
  Result := TBitmap.Create;
  InitBitmap(Result);
  Result.Assign(fBitmap);
  LastResult := arOk;
end;

function TImageFX.AsPNG: TPngImage;
var
  n, a: Integer;
  PNB: TPngImage;
  FFF: PRGBAArray;
  AAA: pByteArray;
  bmp : TBitmap;
begin
  LastResult := arConversionError;
  Result := TPngImage.CreateBlank(COLOR_RGBALPHA,16,fBitmap.Width,fBitmap.Height);

  PNB := TPngImage.Create;
  try
    PNB.CompressionLevel := PNGCompressionLevel;
    Result.CompressionLevel := PNGCompressionLevel;
    bmp := AsBitmap;
    try
      PNB.Assign(bmp);
      PNB.CreateAlpha;
      for a := 0 to bmp.Height - 1 do
      begin
        FFF := bmp.ScanLine[a];
        AAA := PNB.AlphaScanline[a];
        for n := 0 to bmp.Width - 1 do
        begin
          AAA[n] := FFF[n].rgbReserved;
        end;
      end;
    finally
      bmp.Free;
    end;
    Result.Assign(PNB);
    LastResult := arOk;
  finally
    PNB.Free;
  end;
end;

function TImageFX.AsJPG : TJPEGImage;
var
  jpg : TJPEGImage;
  bmp : TBitmap;
begin
  LastResult := arConversionError;
  jpg := TJPEGImage.Create;
  jpg.ProgressiveEncoding := ProgressiveJPG;
  jpg.CompressionQuality := JPGQualityPercent;
  bmp := AsBitmap;
  try
    jpg.Assign(bmp);
  finally
    bmp.Free;
  end;
  Result := jpg;
  LastResult := arOk;
end;

function TImageFX.AsGIF : TGifImage;
var
  gif : TGIFImage;
  bmp : TBitmap;
begin
  LastResult := arConversionError;
  gif := TGIFImage.Create;
  bmp := AsBitmap;
  try
    gif.Assign(bmp);
  finally
    bmp.Free;
  end;
  Result := gif;
  LastResult := arOk;
end;

function TImageFX.AsString(imgFormat : TImageFormat = ifJPG) : string;
var
  ss : TStringStream;
begin
  LastResult := arConversionError;
  ss := TStringStream.Create;
  try
    case imgFormat of
      ifBMP : fBitmap.SaveToStream(ss);
      ifJPG : Self.AsJPG.SaveToStream(ss);
      ifPNG : Self.AsPNG.SaveToStream(ss);
      ifGIF : Self.AsGIF.SaveToStream(ss);
      else raise Exception.Create('Format unknow!');
    end;
    Result := Base64Encode(ss.DataString);
    LastResult := arOk;
  finally
    ss.Free;
  end;
end;

function TImageFX.GetPixel(const x, y: Integer): TPixelInfo;
begin
  Result := GetPixelImage(x,y,fBitmap);
end;

procedure TImageFX.CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
var
  BasePtr: Pointer;
begin
  png := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, NewWidth, NewHeight);

  BasePtr := png.AlphaScanline[0];
  ZeroMemory(BasePtr, png.Header.Width * png.Header.Height);
end;

function TImageFX.Rounded(RoundLevel : Integer = 27) : TImageFX;
var
  rgn : HRGN;
  auxbmp : TBitmap;
begin
  Result := Self;
  auxbmp := TBitmap.Create;
  try
    auxbmp.Assign(fBitmap);
    fBitmap.Clear($00FFFFFF);
    with fBitmap.Canvas do
    begin
      Brush.Style:=bsClear;
      //Brush.Color:=clTransp;
      Brush.Color:=clNone;
      FillRect(Rect(0,0,auxbmp.Width,auxbmp.Height));
      rgn := CreateRoundRectRgn(0,0,auxbmp.width + 1,auxbmp.height + 1,RoundLevel,RoundLevel);
      SelectClipRgn(Handle,rgn);
      Draw(0,0,auxbmp);
      DeleteObject(Rgn);
    end;
    //bmp32.Assign(auxbmp);
  finally
    FreeAndNil(auxbmp);
  end;
end;

function TImageFX.AntiAliasing : TImageFX;
var
  bmp : TBitmap;
begin
  Result := Self;
  bmp := TBitmap.Create;
  try
    //DoAntialias(fBitmap,bmp);
    fBitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

function TImageFX.SetAlpha(Alpha : Byte) : TImageFX;
begin
  Result := Self;
  //DoAlpha(fBitmap,Alpha);
end;

procedure TImageFX.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  SetPixelImage(x,y,P,fBitmap);
end;

procedure TImageFX.SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp32 : TBitmap32);
begin
  bmp32.Pixel[x,y] := RGB(P.R,P.G,P.B);
end;

function TImageFX.GetPixelImage(const x, y: Integer; bmp32 : TBitmap32) : TPixelInfo;
var
  lRGB : TRGB;
begin
  lRGB := ColorToRGBValues(bmp32.Pixel[x,y]);
  Result.R := lRGB.R;
  Result.G := lRGB.G;
  Result.B := lRGB.B;
end;

end.
