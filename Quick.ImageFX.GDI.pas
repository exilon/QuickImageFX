{ ***************************************************************************

  Copyright (c) 2013-2017 Kike Pérez

  Unit        : Quick.ImageFX.GDI
  Description : Image manipulation with multiple graphic libraries
  Author      : Kike Pérez
  Version     : 3.0
  Created     : 10/05/2013
  Modified    : 07/12/2017

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
unit Quick.ImageFX.GDI;

interface

uses

	 Windows,
   Classes,
   Controls,
   Vcl.ImgList,
   System.SysUtils,
   Vcl.Graphics,
   Winapi.ShellAPI,
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
    fBitmap : TBitmap;
    procedure InitBitmap;
    procedure CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    procedure DoAntialias(bmp1,bmp2 : TBitmap);
    procedure DoAlpha(bmp: TBitMap; Alpha: Byte);
    procedure GPBitmapToBitmap(gpbmp : TGPBitmap; bmp : TBitmap);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : TImageFX;
    procedure SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp : TBitmap);
    function GetPixelImage(const x, y: Integer; bmp : TBitmap): TPixelInfo;
  protected
    function GetPixel(const x, y: Integer): TPixelInfo;
    procedure SetPixel(const x, y: Integer; const P: TPixelInfo);
  public
    property AsBitmap : TBitmap read fBitmap write fBitmap;
    constructor Create; overload;
    constructor Create(fromfile : string); overload;
    destructor Destroy; override;
    function NewBitmap(w, h: Integer): TImageFx;
    property Pixel[const x, y: Integer]: TPixelInfo read GetPixel write SetPixel;
    procedure GetResolution(var x,y : Integer); overload;
    function GetResolution : string; overload;
    function AspectRatio : Double;
    function AspectRatioStr : string;
    class function GetAspectRatio(cWidth, cHeight : Integer) : string;
    function LoadFromFile(fromfile : string) : TImageFX;
    function LoadFromStream(stream : TStream) : TImageFX;
    function LoadFromString(str : string) : TImageFX;
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : TImageFX;
    function LoadFromIcon(Icon : TIcon) : TImageFX;
    function LoadFromFileIcon(FileName : string; IconIndex : Word) : TImageFX;
    function LoadFromFileExtension(aFilename : string; LargeIcon : Boolean) : TImageFX;
    function LoadFromResource(ResourceName : string) : TImageFX;
    function LoadFromHTTP(urlImage : string; out HTTPReturnCode : Integer; RaiseExceptions : Boolean = False) : TImageFX;
    function Resize(w, h : Integer) : TImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : TImageFX; overload;
    function Resize2(x, y : Integer; NoResizeIfSmaller : Boolean = False) : TImageFX;
    function Draw(png : TPngImage; alpha : Double = 1) : TImageFX; overload;
    function Draw(png : TPngImage; x, y : Integer; alpha : Double = 1) : TImageFX; overload;
    function Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : TImageFX; overload;
    function DrawCentered(png : TPngImage; alpha : Double = 1) : TImageFX; overload;
    function DrawCentered(stream: TStream; alpha : Double = 1) : TImageFX; overload;
    function Rotate90 : TImageFX;
    function RotateAngle(rotAngle : Single) : TImageFX;
    function RotateFlip(RotateFlipType : TRotateFlipType) : TImageFX;
    function FlipX : TImageFX;
    function FlipY : TImageFX;
    function GrayScale : TImageFX;
    function ScanlineH : TImageFX;
    function ScanlineV : TImageFX;
    function Lighten : TImageFX;
    function Darken : TImageFX;
    function Tint(R, G , B : Integer) : TImageFX;
    function TintAdd(R, G , B : Integer) : TImageFX;
    function TintBlue : TImageFX;
    function TintRed : TImageFX;
    function TintGreen : TImageFX;
    function Solarize : TImageFX;
    function Rounded(RoundLevel : Integer = 27) : TImageFX;
    function AntiAliasing : TImageFX;
    function SetAlpha(Alpha : Byte) : TImageFX;
    function ExtractFileIcon(FileName : string; IconIndex : Word) : TImageFX;
    function ExtractResourceIcon(ResourceName : string) : TImageFX;
    procedure SaveToPNG(outfile : string);
    procedure SaveToJPG(outfile : string);
    procedure SaveToBMP(outfile : string);
    procedure SaveToGIF(outfile : string);
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
    function AsPNG : TPngImage;
    function AsPNG2 : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
    class function ColorIsLight(Color: TColor): Boolean;
    {Convierte el color en más claro}
    class function GetLightColor(BaseColor: TColor): TColor;
    {Convierte el color en más oscuro}
    class function GetDarkColor(BaseColor: TColor): TColor;
    {Convierte el color en más oscuro o claro definiendo la intensidad}
    class function LightenUp(MyColor: TColor; Factor: Double): TColor;
    class function JPEGCorruptionCheck(jpg : TJPEGImage): Boolean; overload;
    class function JPEGCorruptionCheck(const stream : TMemoryStream): Boolean; overload;
  end;


   {Devuelve una imagen reducida al tamaño especificado y en formato JPG}
   function ResizeImage(bmp : TBitmap; maxWidth,maxHeight : Integer; Proporcional : Boolean) : TBitmap;
   {Hace Crop de un Bitmap}
   procedure CropBitmap(var bmp : TBitmap; aColor : TColor);
   {Redimensionar PNG}
   procedure PNGResize(var png : TPNGImage; MaxWidth, MaxHeight : Integer);



implementation

constructor TImageFX.Create;
begin
  inherited;
  InitBitmap;
end;

procedure TImageFX.InitBitmap;
begin
  fBitmap := TBitmap.Create;
  fBitmap.PixelFormat := pf32bit;
  fBitmap.AlphaFormat := afDefined;
end;

constructor TImageFX.Create(fromfile: string);
var
  GPBitmap : TGPBitmap;
begin
  GPBitmap := TGPBitmap.Create(fromfile);
  try
    if not Assigned(fBitmap) then InitBitmap;
    GPBitmapToBitmap(GPBitmap,fBitmap);
  finally
    GPBitmap.Free;
  end;
end;

destructor TImageFX.Destroy;
begin
  if Assigned(fBitmap) then fBitmap.Free;
  inherited;
end;

function TImageFX.NewBitmap(w, h: Integer): TImageFx;
begin
  if Assigned(Self.fBitmap) then
  begin
    //Self.fBitmap.Canvas.FillRect();
    Self.fBitmap.SetSize(w, h);
  end
  else  Result := Self;
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

function TImageFX.LoadFromFile(fromfile: string) : TImageFX;
var
  GPBitmap : TGPBitmap;
begin
  GPBitmap := TGPBitmap.Create(fromfile);
  try
    if not Assigned(fBitmap) then InitBitmap;
    GPBitmapToBitmap(GPBitmap,fBitmap);
  finally
    GPBitmap.Free;
  end;
end;

function TImageFX.LoadFromStream(stream: TStream) : TImageFX;
var
  Picture : TPicture;
begin
  Result := Self;
  Picture := TPicture.Create;
  try
    stream.Seek(0,soBeginning);
    Picture.Bitmap.LoadFromStream(stream);
    if not Assigned(fBitmap) then InitBitmap;
    fBitmap.Assign(Picture.Bitmap);
  finally
    Picture.Free;
  end;
end;

function TImageFX.LoadFromString(str: string) : TImageFX;
var
  stream : TStringStream;
begin
  Result := Self;
  if str = '' then Exit;
  str := Base64Decode(str);
  stream := TStringStream.Create(str);
  try
    fBitmap.LoadFromStream(stream);
  finally
    stream.Free;
  end;
end;

function TImageFX.Resize2(x, y : Integer; NoResizeIfSmaller : Boolean = False) : TImageFX;
var
  src : TGPBitmap;
  dst : TBitmap;
  Graphics: TGPGraphics;
begin
  Result := Self;
  //Si uno de los valores es 0, lo calcula proporcionalmente
  if x + y = 0 then
  begin
    x := fBitmap.Width;
    y := fBitmap.Height;
  end
  else
  begin
    if y = 0 then y := Round(fBitmap.Height / fBitmap.Width * x);
    if x = 0 then x := Round(fBitmap.Width / fBitmap.Height* y);
  end;

  //Si es más pequeño no agrandar
  if NoResizeIfSmaller then
  begin
    if (fBitmap.Width < x) or (fBitmap.Height < y) then Exit;
  end;

  try
    // create graphics object for output image
    // create the output bitmap in desired size
    src := TGPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
    dst := TBitmap.Create;
    dst.PixelFormat := pf32bit;
    dst.HandleType := bmDIB;
    dst.AlphaFormat := afDefined;
    dst.Width := x;
    dst.Height := y;

    Graphics := TGPGraphics.Create(dst.Canvas.Handle);
    try
      //Graphics.Clear(ColorRefToARGB(ColorToRGB(clNone)));
      Graphics.Clear(MakeColor(0,0,0,0));
      // set the composition mode to copy
      Graphics.SetCompositingMode(CompositingModeSourceCopy);
      // set high quality rendering modes
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      //Graphics.SetInterpolationMode(InterpolationModeHighQuality);
      Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
      Graphics.SetSmoothingMode(SmoothingModeHighQuality);
      // draw the input image on the output in modified size
      Graphics.DrawImage(src, 0, 0, x, y);
      fBitmap.Assign(dst);
    finally
      Graphics.Free;
      src.Free;
      dst.Free;
    end;
  except
    raise Exception.Create('Error scaling image');
  end;
end;

function TImageFX.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : TImageFX;
var
  bmp : TBitmap;
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
          if ResizeOptions.SkipSmaller then
          begin
            LastResult := arAlreadyOptim;
            nw := srcRect.Width;
            nh := srcRect.Height;
            w := nw;
            h := nh;
          end
          else Exit;
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
  if not (ResizeOptions.ResamplerMode in [rsAuto,rsGDIStrech]) then raise Exception.Create('Only GDIStrech Resampler mode supported!');

  bmp := TBitmap.Create;
  try
    bmp.Width := w;
    bmp.Height := h;
    if ResizeOptions.FillBorders then
    begin
      bmp.Canvas.Brush.Color := ResizeOptions.BorderColor;
      bmp.Canvas.FillRect(Rect(0,0,w,h));
    end;
    bmp.Canvas.StretchDraw(tgtRect,fBitmap);
    //StretchTransfer(bmp,tgtRect,tgtRect,fBitmap,srcRect,Resam,dmOpaque,nil);
    try
      fBitmap.Assign(bmp);
      LastResult := arOk;
    except
      LastResult := arCorruptedData;
    end;
  finally
    bmp.Free;
  end;
end;

function TImageFX.Resize(w, h : Integer) : TImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFX.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : TImageFX;
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

function TImageFX.Rotate90 : TImageFX;
begin
  Result := RotateFlip(Rotate90FlipNone);
end;

function TImageFX.RotateAngle(rotAngle : Single) : TImageFX;
begin
  //not implemented
end;

function TImageFX.RotateFlip(RotateFlipType : TRotateFlipType) : TImageFX;
var
  src : TGPBitmap;
begin
  Result := Self;
  //
  src := TGPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
  try
    src.RotateFlip(RotateFlipType);
    GPBitmapToBitmap(src,fBitmap);
  finally
    src.Free;
  end;
end;

function TImageFX.FlipX : TImageFX;
begin
  Result := Self;
  RotateFlip(RotateNoneFlipX);
end;

function TImageFX.FlipY : TImageFX;
begin
  Result := Self;
  RotateFlip(RotateNoneFlipY);
end;

function TImageFX.GrayScale : TImageFX;
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    Reserved: Byte;
  end;
var
  X: Integer;
  Y: Integer;
  Gray: Byte;
  Pixel: PPixelRec;
begin
  Result := Self;
  Assert(fBitmap.PixelFormat = pf32Bit);
  fBitmap.PixelFormat := pf32bit;
  for Y := 0 to (fBitmap.Height - 1) do
  begin
    Pixel := fBitmap.ScanLine[Y];
    for X := 0 to (fBitmap.Width - 1) do
    begin
      //Gray := (Pixel.B + Pixel.G + Pixel.R) div 3;
      Gray := Round(0.30 * Pixel.R + 0.59 * Pixel.G + 0.11 * Pixel.B);
      //Gray := (Pixel.R shr 2) + (Pixel.R shr 4) + (Pixel.G shr 1) + (Pixel.G shr 4) + (Pixel.B shr 3);
      Pixel.R := Gray;
      Pixel.G := Gray;
      Pixel.B := Gray;
      Inc(Pixel);
    end;
  end;
end;

function TImageFX.Lighten : TImageFX;
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    Reserved: Byte;
  end;
var
  X: Integer;
  Y: Integer;
  Gray: Byte;
  Pixel: PPixelRec;
begin
  Result := Self;
  Assert(fBitmap.PixelFormat = pf32Bit);
  fBitmap.PixelFormat := pf32bit;
  fBitmap.AlphaFormat := afDefined;
  for Y := 0 to (fBitmap.Height - 1) do
  begin
    Pixel := fBitmap.ScanLine[Y];
    for X := 0 to (fBitmap.Width - 1) do
    begin
      Pixel.R := Round(Pixel.R+((Pixel.R/255)*100));
      Pixel.G := Round(Pixel.G+((Pixel.G/255)*100));
      Pixel.B := Round(Pixel.B+((Pixel.B/255)*100));
      If Pixel.R < 0 Then Pixel.R := 0 Else If Pixel.R > 255 Then Pixel.R := 255;
      If Pixel.G < 0 Then Pixel.G := 0 Else If Pixel.G > 255 Then Pixel.G := 255;
      If Pixel.B < 0 Then Pixel.B := 0 Else If Pixel.B > 255 Then Pixel.B := 255;
      Inc(Pixel);
    end;
  end;
end;

function TImageFX.Darken : TImageFX;
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    Reserved: Byte;
  end;
var
  X: Integer;
  Y: Integer;
  Gray: Byte;
  Pixel: PPixelRec;
begin
  Result := Self;
  Assert(fBitmap.PixelFormat = pf32Bit);
  fBitmap.PixelFormat := pf32bit;
  fBitmap.AlphaFormat := afDefined;
  for Y := 0 to (fBitmap.Height - 1) do
  begin
    Pixel := fBitmap.ScanLine[Y];
    for X := 0 to (fBitmap.Width - 1) do
    begin
      Pixel.R := Round(Pixel.R-((Pixel.R/255)*100));
      Pixel.G := Round(Pixel.G-((Pixel.G/255)*100));
      Pixel.B := Round(Pixel.B-((Pixel.B/255)*100));
      Inc(Pixel);
    end;
  end;
end;

function TImageFX.Tint(R, G , B : Integer) : TImageFX;
var
  scanline: PRGBQuad;
  y: Integer;
  x: Integer;
begin
  Result := Self;
  Assert(fBitmap.PixelFormat = pf32bit);
  for y := 0 to fBitmap.Height - 1 do
  begin
    scanline := fBitmap.ScanLine[y];
    for x := 0 to fBitmap.Width - 1 do
    begin
      with scanline^ do
      begin
        {if (rgbBlue = 255) and (rgbGreen = 255) and (rgbRed = 255) then
        begin
          FillChar(scanline^, sizeof(TRGBQuad), 0);
        end;}
        if B > -1 then rgbBlue := B;
        if G > -1 then rgbGreen := G;
        if R > -1 then rgbRed := R;
      end;
      inc(scanline);
    end;
  end;
end;

function TImageFX.TintAdd(R, G , B : Integer) : TImageFX;
var
  scanline: PRGBQuad;
  y: Integer;
  x: Integer;
begin
  Result := Self;
  Assert(fBitmap.PixelFormat = pf32bit);
  for y := 0 to fBitmap.Height - 1 do
  begin
    scanline := fBitmap.ScanLine[y];
    for x := 0 to fBitmap.Width - 1 do
    begin
      with scanline^ do
      begin
        {if (rgbBlue = 255) and (rgbGreen = 255) and (rgbRed = 255) then
        begin
          FillChar(scanline^, sizeof(TRGBQuad), 0);
        end;}
        rgbBlue := rgbBlue + B;
        rgbGreen := rgbGreen + G;
        rgbRed := rgbRed + R;
      end;
      inc(scanline);
    end;
  end;
end;

function TImageFX.TintBlue : TImageFX;
begin
  Result := Tint(0,0,-1);
end;

function TImageFX.TintRed : TImageFX;
begin
  Result := Tint(-1,0,0);
end;

function TImageFX.TintGreen : TImageFX;
begin
  Result := Tint(0,-1,0);
end;

function TImageFX.Solarize : TImageFX;
begin
  Result := Tint(255,-1,-1);
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
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    Reserved: Byte;
  end;
var
  X: Integer;
  Y: Integer;
  Gray: Byte;
  Pixel: PPixelRec;
begin
  Assert(fBitmap.PixelFormat = pf32Bit);
  fBitmap.PixelFormat := pf32bit;
  fBitmap.AlphaFormat := afDefined;
  for Y := 0 to (fBitmap.Height - 1) do
  begin
    Pixel := fBitmap.ScanLine[Y];
    for X := 0 to (fBitmap.Width - 1) do
    begin
      {Standard equation}
      if ScanLineMode = smHorizontal then
      begin
        if Odd(y) then
        begin
          Pixel.R := Round(Pixel.R-((Pixel.R/255)*100));
          Pixel.G := Round(Pixel.G-((Pixel.G/255)*100));
          Pixel.B := Round(Pixel.B-((Pixel.B/255)*100));
        end;
      end
      else
      begin
        if Odd(x) then
        begin
          Pixel.R := Round(Pixel.R-((Pixel.R/255)*100));
          Pixel.G := Round(Pixel.G-((Pixel.G/255)*100));
          Pixel.B := Round(Pixel.B-((Pixel.B/255)*100));
        end;
      end;
      Inc(Pixel);
    end;
  end;
end;

procedure TImageFX.SaveToPNG(outfile : string);
var
  Encoder: TGUID;
  GPBitmap : TGPBitmap;
begin
  GPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
  try
    // get encoder and encode the output image
    if GetEncoderClsid('image/png', Encoder) <> -1 then GPBitmap.Save(outfile, Encoder)
      else raise Exception.Create('Failed to get encoder.');
  finally
    GPBitmap.Free;
  end;
end;

function TImageFX.GetPixel(const x, y: Integer): TPixelInfo;
begin
  Result := GetPixelImage(x,y,fBitmap);
end;

procedure TImageFX.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  SetPixelImage(x,y,P,fBitmap);
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

procedure TImageFX.SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp : TBitmap);
begin
  bmp.Canvas.Pixels[x,y] := RGB(P.R,P.G,P.B);
end;

function TImageFX.GetPixelImage(const x, y: Integer; bmp : TBitmap) : TPixelInfo;
var
  lRGB : TRGB;
begin
  lRGB := ColorToRGBValues(bmp.Canvas.Pixels[x,y]);
  Result.R := lRGB.R;
  Result.G := lRGB.G;
  Result.B := lRGB.B;
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

procedure TImageFX.SaveToJPG(outfile : string);
var
  Encoder: TGUID;
  GPBitmap : TGPBitmap;
begin
  GPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
  try
    // get encoder and encode the output image
    if GetEncoderClsid('image/jpeg', Encoder) <> -1 then GPBitmap.Save(outfile, Encoder)
      else raise Exception.Create('Failed to get encoder.');
  finally
    GPBitmap.Free;
  end;
end;

procedure TImageFX.SaveToBMP(outfile : string);
var
  Encoder: TGUID;
  GPBitmap : TGPBitmap;
begin
  GPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
  try
    // get encoder and encode the output image
    if GetEncoderClsid('image/bmp', Encoder) <> -1 then GPBitmap.Save(outfile, Encoder)
      else raise Exception.Create('Failed to get encoder.');
  finally
    GPBitmap.Free;
  end;
end;

procedure TImageFX.SaveToGIF(outfile : string);
var
  Encoder: TGUID;
  GPBitmap : TGPBitmap;
begin
  GPBitmap.Create(fBitmap.Handle,fBitmap.Palette);
  try
    // get encoder and encode the output image
    if GetEncoderClsid('image/gif', Encoder) <> -1 then GPBitmap.Save(outfile, Encoder)
      else raise Exception.Create('Failed to get encoder.');
  finally
    GPBitmap.Free;
  end;
end;

procedure TImageFX.GPBitmapToBitmap(gpbmp : TGPBitmap; bmp : TBitmap);
var
  Graphics : TGPGraphics;
begin
  try
    bmp.PixelFormat := pf32bit;
    bmp.HandleType := bmDIB;
    bmp.AlphaFormat := afDefined;
    bmp.Width := gpbmp.GetWidth;
    bmp.Height := gpbmp.GetHeight;
    Graphics := TGPGraphics.Create(bmp.Canvas.Handle);

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

function TImageFX.AsPNG2 : TPngImage;
var
  png : TPngImage;
  bmp : TBitmap;
begin
  //png := TPngImage.CreateBlank(COLOR_RGBALPHA,16,bmp.Width,bmp.Height);
  png := TPngImage.CreateBlank(COLOR_RGBALPHA,16,fBitmap.Width,fBitmap.Height);
  //CleanTransparentPng(png,fImage.GetWidth,fImage.GetHeight);
  try
    bmp := AsBitmap;
    png.Assign(bmp);
    png.CreateAlpha;
    Result := png;
  finally
    png := nil;
    bmp.Free;
  end;
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
begin
  jpg := TJPEGImage.Create;
  jpg.Assign(fBitmap);
  Result := jpg;
end;

function TImageFX.AsGIF : TGifImage;
var
  gif : TGIFImage;
begin
  gif := TGIFImage.Create;
  gif.Assign(fBitmap);
  Result := gif;
end;

{Comprueba si un color es claro o oscuro}
class function TImageFX.ColorIsLight(Color: TColor): Boolean;
Begin
  Color := ColorToRGB(Color);
  Result := ((Color and $FF) + (Color shr 8 and $FF) +
  (Color shr 16 and $FF))>= $180;
End;

function Min(a, b: Longint): Longint;
begin
  if a > b then Result := b
  else
    Result := a;
end;

function Max(a, b: Longint): Longint;
begin
  if a > b then Result := a
  else
    Result := b;
end;

{Convierte el color en más claro}
class function TImageFX.GetLightColor(BaseColor: TColor): TColor;
begin
  Result := RGB(Min(GetRValue(ColorToRGB(BaseColor)) + 64, 255),
    Min(GetGValue(ColorToRGB(BaseColor)) + 64, 255),
    Min(GetBValue(ColorToRGB(BaseColor)) + 64, 255));
end;

{Convierte el color en más oscuro}
class function TImageFX.GetDarkColor(BaseColor: TColor): TColor;
begin
  Result := RGB(Max(GetRValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetGValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetBValue(ColorToRGB(BaseColor)) - 64, 0));
end;

{Convierte el color en más oscuro o claro definiendo la intensidad}
class function TImageFX.LightenUp(MyColor: TColor; Factor: Double): TColor;
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

class function TImageFX.JPEGCorruptionCheck(jpg : TJPEGImage): Boolean;
var
  w1        :  Word;     // un "word" siempre es 2 bytes de longitud
  w2        :  Word;
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

        Result := (w1 = $D8FF) AND (w2 = $D9FF);
      end;
    finally
      ms.Free;
    end;
end;

class function TImageFX.JPEGCorruptionCheck(const stream: TMemoryStream): Boolean;
var
  w1        :  Word;     // un "word" siempre es 2 bytes de longitud
  w2        :  Word;
begin
    Assert(SizeOf(WORD) = 2);

    Result := Assigned(stream);

    if Result then
    begin
      stream.Seek(0, soFromBeginning);
      stream.Read(w1,2);

      stream.Position := stream.Size - 2;
      stream.Read(w2,2);

      Result := (w1 = $D8FF) AND (w2 = $D9FF);
    end;
end;

function ResizeImage(bmp : TBitmap; maxWidth,maxHeight : Integer; Proporcional : Boolean) : TBitmap;
var
  thumbRect : TRect;
Begin
  thumbRect.Left := 0;
  thumbRect.Top := 0;
  Result := TBitmap.Create;
  try
    if Proporcional then
    begin
      if bmp.Width > bmp.Height then
      begin
        thumbRect.Right := maxWidth;
        thumbRect.Bottom := (maxWidth * bmp.Height) div bmp.Width;
      end else
      begin
        thumbRect.Bottom := maxHeight;
        thumbRect.Right := (maxHeight * bmp.Width) div bmp.Height;
      end;

    end else
    begin
      thumbRect.Bottom := maxHeight;
      thumbRect.Right := maxWidth;
    end;
    //redimensiona la imagen
    Result.Width := thumbRect.Right;
    Result.Height := thumbRect.Bottom;
    bmp.Canvas.StretchDraw(thumbRect,Result);
    //assigna el resultado
    Result.Assign(bmp);
  finally
    bmp.Free;
  end;
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
  if ABitmap.PixelFormat <> pf24bit then
    raise Exception.Create('Incorrect bit depth, bitmap must be 24-bit!');

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

procedure CropBitmap(var bmp : TBitmap; aColor : TColor);
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

{Redimensionar PNG}
procedure PNGResize(var png : TPNGImage; MaxWidth, MaxHeight : Integer);
var
  auxpng : TPngImage;
  NewWidth,
  NewHeight : Integer;
  aRect : TRect;
Begin
  auxpng:=TPngImage.Create;
  Try
    auxpng.Assign(png);

    // Calculos para que quede proporcional
    If (MaxWidth/png.Width) < (MaxHeight/png.Height) then
    Begin
      MaxHeight:= Trunc((MaxWidth*png.Height)/png.Width);
    End
    Else
    Begin
      MaxWidth:= Trunc((png.Width*MaxHeight)/png.Height);
    End;

    If png.Width>MaxWidth Then NewWidth:=MaxWidth else NewWidth:=png.Width;
    If png.Height>MaxHeight Then NewHeight:=MaxHeight else NewHeight:=png.Height;

    // posición nueva
    // Hay que centarla para que queden márgenes iguales a ambos lados
    aRect.Left := ((png.Width - NewWidth) div 2);
    aRect.Top := ((png.Height - NewHeight) div 2);
    aRect.Right:= aRect.Left + NewWidth;
    aRect.Bottom := aRect.Top + NewHeight;

    png.Resize(MaxWidth,MaxHeight);
    //png.Canvas.Brush.Style := bsClear;
    //png.Canvas.Brush.Color:=$00FFFFFF;
    png.Canvas.FillRect(Rect(0,0,png.Width,png.Height));

    //ShowMessage(IntToStr(NewWidth));
    png.Canvas.StretchDraw(aRect,auxpng);
  finally
    auxpng.Free;
  end;
end;

function TImageFX.ExtractFileIcon(FileName : string; IconIndex : Word) : TImageFX;
var
   Icon : TIcon;
   GPBitmap : TGPBitmap;
begin
  Result := Self;
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractAssociatedIcon(hInstance,pChar(FileName),IconIndex);
    //Icon.Transparent := True;
    //fImage.FromHICON(ExtractAssociatedIcon(hInstance,pChar(FileName),IconIndex));
    //ConvertToPNG(Icon, png);
    fBitmap.Handle := Icon.Handle;
    GPBitmap := TGPBitmap.Create(Icon.Handle);
    GPBitmapToBitmap(GPBitmap,fBitmap);
  finally
    Icon.Free;
    if Assigned(GPBitmap) then GPBitmap.Free;
  end;
  //png:=TPngImage.CreateBlank(COLOR_RGBALPHA,16,Icon.Width,Icon.Height);
  //png.Canvas.Draw(0,0,Icon);
  //DrawIcon(png.Canvas.Handle, 0, 0, Icon.Handle) ;
end;

function TImageFX.ExtractResourceIcon(ResourceName : string) : TImageFX;
var
   icon : TIcon;
   GPBitmap : TGPBitmap;
begin
  Result := Self;

  icon:=TIcon.Create;
  Try
    icon.LoadFromResourceName(HInstance,ResourceName);
    icon.Transparent:=True;
    GPBitmap := TGPBitmap.Create(Icon.Handle);
    GPBitmapToBitmap(GPBitmap,fBitmap);
  Finally
    icon.Free;
    if Assigned(GPBitmap) then GPBitmap.Free;
  End;
  //png:=TPngImage.CreateBlank(COLOR_RGBALPHA,16,Icon.Width,Icon.Height);
  //png.Canvas.Draw(0,0,Icon);
  //DrawIcon(png.Canvas.Handle, 0, 0, Icon.Handle);
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

function TImageFX.LoadFromIcon(Icon : TIcon) : TImageFX;
begin
  Result := Self;
  fBitmap.Assign(Icon);
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

procedure TImageFX.DoAlpha(bmp: TBitMap; Alpha: Byte);
var
  pscanLine32 : pRGBQuadArray;
  i, j: Integer;
  lAlpha : Integer;
begin
  for i := 0 to bmp.Height - 1 do
  begin
    pscanLine32 := bmp.Scanline[i];
    for j := 0 to bmp.Width - 1 do
    begin
      lAlpha := Round(255 * (bmp.width- j) / bmp.width )+ Alpha;
      if lAlpha > 255 then lAlpha := 255;
      pscanLine32[j].rgbReserved := lAlpha;
      pscanLine32[j].rgbBlue := Round(pscanLine32[j].rgbBlue * lAlpha / 255);
      pscanLine32[j].rgbRed :=  Round(pscanLine32[j].rgbRed * lAlpha / 255);
      pscanLine32[j].rgbGreen :=  Round(pscanLine32[j].rgbGreen * lAlpha / 255);
    end;
  end;

end;

procedure TImageFX.CleanTransparentPng(var png: TPngImage; NewWidth, NewHeight: Integer);
var
  BasePtr: Pointer;
begin
  png := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, NewWidth, NewHeight);

  BasePtr := png.AlphaScanline[0];
  ZeroMemory(BasePtr, png.Header.Width * png.Header.Height);
end;

procedure TImageFX.DoAntialias(bmp1,bmp2 : TBitmap);
  var
    r1,g1,b1:Integer;
    Y, X, j:integer;
    SL1, SL2, SL3: pRGBQuadArray;
begin
  // Tamaño del bitmap destino
  bmp2.Height := bmp1.Height;
  bmp2.Width := bmp1.Width;
  fBitmap.PixelFormat := pf32bit;
  fBitmap.AlphaFormat := afDefined;
  // SCANLINE
  SL1 := bmp1.ScanLine[0];
  SL2 := bmp1.ScanLine[1];
  SL3 := bmp1.ScanLine[2];

  // recorrido para todos los pixels
  for Y := 1 to (bmp1.Height - 2) do begin
    for X := 1 to (bmp1.Width - 2) do begin
      R1 := 0;  G1 := 0; B1 := 0;
      // los 9 pixels a tener en cuenta
      for j := -1 to 1 do begin
        // FIla anterior
        R1 := R1 + SL1[X+j].rgbRed    + SL2[X+j].rgbRed    + SL3[X+j].rgbRed;
        G1 := G1 + SL1[X+j].rgbGreen  + SL2[X+j].rgbGreen  + SL3[X+j].rgbGreen;
        B1 := B1 + SL1[X+j].rgbBlue   + SL2[X+j].rgbBlue   + SL3[X+j].rgbBlue;
      end;
      // Nuevo color
      R1 := Round(R1 div 9);
      G1:= Round(G1 div 9);
      B1:= Round(B1 div 9);
      // Asignar el nuevo
      bmp2.Canvas.Pixels[X, Y] := RGB(R1,G1,B1);
    end;
    // Siguientes...
    SL1 := SL2;
    SL2 := SL3;
    SL3 := bmp1.ScanLine[Y+1];
  end;
end;

function TImageFX.Rounded(RoundLevel : Integer = 27) : TImageFX;
var
  rgn : HRGN;
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    //auxbmp.Clear($00FFFFFF);
    bmp.PixelFormat := pf32bit;
    bmp.AlphaFormat := afDefined;
    bmp.HandleType := bmDIB;
    bmp.Width := fBitmap.Width;
    bmp.Height := fBitmap.Height;
    //bmp.Transparent := True;
    with bmp.Canvas do
    begin
      Brush.Style := bsClear;
      Brush.Color := clNone;
      //Pen.Color := clNone;
      FillRect(Rect(0,0,fBitmap.Width,fBitmap.Height));
      rgn := CreateRoundRectRgn(0,0,fBitmap.width+1,fBitmap.height+1,RoundLevel,RoundLevel);
      SelectClipRgn(Handle,rgn);
      StretchDraw(Rect(0,0,fBitmap.Width,fBitmap.Height),fBitmap);
      //Draw(0,0,fBitmap);
      //bmp.SaveToFile('d:\prueba.bmp');
      DeleteObject(Rgn);
    end;
    fBitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

function TImageFX.AntiAliasing : TImageFX;
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    DoAntialias(fBitmap,bmp);
    fBitmap.Assign(bmp);
  finally
    bmp.Free;
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
  //fBitmap.DrawMode := TDrawMode.dmTransparent;
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

function TImageFX.SetAlpha(Alpha : Byte) : TImageFX;
begin
  DoAlpha(AsBitmap,Alpha);
end;

{Procedure BlendPng (Source1, Source2: TPngImage; X, Y:Word; OutMerge: TPngImage);
Var
BTOut, BT_out: TBitmap;
Begin
  OutMerge.CreateBlank(COLOR_RGBALPHA, 8, Source1.Width, Source1.Height);
  BT_out := TBitmap.Create;
  BT_out.PixelFormat: = pf32bit;
  BT_out.SetSize(Source1.Width, Source1.Height);
  BTOut := TBitmap.Create;
  BTOut.PixelFormat: = pf32bit;
  BTOut.SetSize(Source1.Width, Source1.Height);
  BuildPNG2BMP(OutMerge, BT_out);
  BitBlt(BTOut.Canvas.Handle, 0, 0, BTOut.Width, BTOut.Height,BT_out.Canvas.Handle, 0, 0, SRCCOPY);
  BuildPNG2BMP(Source1, BT_out);
  BTOut.Canvas.Draw(0, 0, BT_out);
  BuildPNG2BMP(Source2, BT_out);
  BTOut.Canvas.Draw(x, y, BT_out);
  // X, Y a position of the second image on the first, the second should be equal or less on the size of the first.
  BuildBMP2PNG(BTOut, OutMerge);
  BT_out.Free;
  BTOut.Free;
End;}

end.
