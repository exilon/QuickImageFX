{ ***************************************************************************

  Copyright (c) 2013-2018 Kike P�rez

  Unit        : Quick.ImageFX.GR32
  Description : Image manipulation with GR32
  Author      : Kike P�rez
  Version     : 4.0
  Created     : 10/04/2013
  Modified    : 11/08/2018

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
   GDIPAPI,
   GDIPOBJ,
   GDIPUTIL,
   Vcl.Imaging.pngimage,
   Vcl.Imaging.jpeg,
   Vcl.Imaging.GIFImg,
   Quick.Base64,
   Quick.ImageFX,
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

  TImageFXGR32 = class(TImageFX,IImageFX)
  private
    fBitmap : TBitmap32;
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
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
    destructor Destroy; override;
    function NewBitmap(w, h : Integer) : IImageFX;
    property Pixel[const x, y: Integer]: TPixelInfo read GetPixel write SetPixel;
    function IsEmpty : Boolean;
    function LoadFromFile(const fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromStream(stream : TStream) : IImageFX;
    function LoadFromString(const str : string) : IImageFX;
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
    function LoadFromIcon(Icon : TIcon) : IImageFX;
    function LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
    function LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
    function LoadFromResource(const ResourceName : string) : IImageFX;
    function Clone : IImageFX;
    function IsGray : Boolean;
    procedure Assign(Graphic : TGraphic);
    procedure GetResolution(var x,y : Integer); overload;
    function GetResolution : string; overload;
    function AspectRatio : Double;
    function Clear(pcolor : TColor = clNone) : IImageFX;
    function Resize(w, h : Integer) : IImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX; overload;
    procedure GraphicToBitmap32(Graphic : TGraphic; var bmp32 : TBitmap32);
    function Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : IImageFX; overload;
    function DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX; overload;
    function DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX; overload;
    function Rotate90 : IImageFX;
    function Rotate180 : IImageFX;
    function Rotate270 : IImageFX;
    function RotateAngle(RotAngle : Single) : IImageFX;
    function RotateBy(RoundAngle : Integer) : IImageFX;
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
    function AntiAliasing : IImageFX;
    function SetAlpha(Alpha : Byte) : IImageFX;
    procedure SaveToPNG(const outfile : string);
    procedure SaveToJPG(const outfile : string);
    procedure SaveToBMP(const outfile : string);
    procedure SaveToGIF(const outfile : string);
    function AsBitmap : TBitmap;
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
    function AsPNG : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
  end;


implementation


constructor TImageFXGR32.Create;
begin
  inherited Create;
  fBitmap := TBitmap32.Create;
end;

destructor TImageFXGR32.Destroy;
begin
  if Assigned(fBitmap) then fBitmap.Free;
  inherited;
end;

{function TImageFXGR32.LoadFromFile(fromfile: string) : TImageFX;
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

function TImageFXGR32.LoadFromFile(const fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
var
  fs : TFileStream;
begin
  Result := Self;

  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    Exit;
  end;

  //loads file into stream
  fs := TFileStream.Create(fromfile,fmShareDenyWrite);
  try
    Self.LoadFromStream(fs);
  finally
    fs.Free;
  end;
end;

function TImageFXGR32.LoadFromStream(stream: TStream) : IImageFX;
var
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
begin
  Result := Self;
  if (not Assigned(stream)) or (stream.Size = 0) then
  begin
    LastResult := arZeroBytes;
    raise Exception.Create('Stream is empty!');
  end;
  stream.Seek(0,soBeginning);
  if not FindGraphicClass(Stream,GraphicClass) then raise EInvalidGraphic.Create('Unknow Graphic format');
  Graphic := GraphicClass.Create;
  try
    stream.Seek(0,soBeginning);
    Graphic.LoadFromStream(stream);
    if (Graphic.Transparent) and (not (Graphic is TGIFImage)) then GraphicToBitmap32(Graphic,fBitmap)
    else fBitmap.Assign(Graphic);
    if ExifRotation then ProcessEXIFRotation(stream);
    LastResult := arOk;
  finally
    Graphic.Free;
  end;
end;

function TImageFXGR32.LoadFromString(const str: string) : IImageFX;
var
  stream : TStringStream;
begin
  Result := Self;

  if str = '' then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;

  stream := TStringStream.Create(Base64Decode(str));
  try
    LoadFromStream(stream);
    LastResult := arOk;
  finally
    stream.Free;
  end;
end;

function TImageFXGR32.LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
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

function TImageFXGR32.LoadFromResource(const ResourceName : string) : IImageFX;
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

function TImageFXGR32.LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
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

function TImageFXGR32.LoadFromIcon(Icon : TIcon) : IImageFX;
begin
  Result := Self;
  fBitmap.Assign(Icon);
end;

function TImageFXGR32.LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
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

function TImageFXGR32.AspectRatio : Double;
begin
  if Assigned(fBitmap) then Result := fBitmap.width / fBitmap.Height
    else Result := 0;
end;

procedure TImageFXGR32.GetResolution(var x,y : Integer);
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

function TImageFXGR32.Clear(pcolor : TColor = clNone) : IImageFX;
begin
  Result := Self;
  fBitmap.Clear;
  fBitmap.FillRect(0,0,fBitmap.Width,fBitmap.Height,pColor);
  LastResult := arOk;
end;

function TImageFXGR32.Clone : IImageFX;
begin
  Result := TImageFXGR32.Create;
  (Result as TImageFXGR32).fBitmap.Assign(Self.fBitmap);
  CloneValues(Result);
end;

function TImageFXGR32.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
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
  LastResult := arResizeError;

  if (not Assigned(fBitmap)) or ((fBitmap.Width * fBitmap.Height) = 0) then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;


  //if any value is 0, calculates proportionaly
  if (w * h) = 0 then
  begin
    //scales max w or h
    if ResizeOptions.ResizeMode = rmScale then
    begin
      if (h = 0) and (fBitmap.Height > fBitmap.Width) then
      begin
        h := w;
        w := 0;
      end;
    end
    else ResizeOptions.ResizeMode := rmFitToBounds;
    begin
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
          if not ResizeOptions.SkipSmaller then
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
  case ResizeOptions.ResamplerMode of
    rsAuto :
      begin
        if (w < fBitmap.Width ) or (h < fBitmap.Height) then Resam := TDraftResampler.Create
          else Resam := TLinearResampler.Create;
      end;
    rsNearest : Resam := TNearestResampler.Create;
    rsGR32Draft : Resam := TDraftResampler.Create;
    rsGR32Kernel : Resam := TKernelResampler.Create;
    rsLinear : Resam := TLinearResampler.Create;
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

function TImageFXGR32.Resize(w, h : Integer) : IImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFXGR32.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX;
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

procedure TImageFXGR32.Assign(Graphic : TGraphic);
var
  ms : TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    Graphic.SaveToStream(ms);
    ms.Seek(0,soBeginning);
    LoadFromStream(ms);
  finally
    ms.Free;
  end;
end;

function TImageFXGR32.Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX;
var
  bmp : TBitmap32;
begin
  Result := Self;
  if alpha = 1 then
  begin
    fBitmap.Canvas.Draw(x,y,Graphic);
  end
  else
  begin
    bmp := TBitmap32.Create;
    try
      GraphicToBitmap32(Graphic,bmp);
      bmp.MasterAlpha := Round(255 * alpha);
      bmp.DrawMode := TDrawMode.dmBlend;
      bmp.DrawTo(fBitmap,x,y);
    finally
      bmp.Free;
    end;
  end;
end;

procedure TImageFXGR32.GraphicToBitmap32(Graphic : TGraphic; var bmp32 : TBitmap32);
begin
  bmp32.Width := Graphic.Width;
  bmp32.Height := Graphic.Height;
  bmp32.Canvas.Draw(0,0,Graphic);
end;

function TImageFXGR32.Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
var
  GraphicClass : TGraphicClass;
  overlay : TGraphic;
begin
  //get overlay image
  stream.Seek(0,soBeginning);
  if not FindGraphicClass(stream,GraphicClass) then raise Exception.Create('overlary unknow graphic format');

  overlay := GraphicClass.Create;
  try
    stream.Seek(0,soBeginning);
    overlay.LoadFromStream(stream);
    if overlay.Empty then raise Exception.Create('Overlay error!');
    //needs x or y center image
    if x = -1 then x := (fBitmap.Width - overlay.Width) div 2;
    if y = -1 then y := (fBitmap.Height - overlay.Height) div 2;
    Result := Draw(overlay,x,y,alpha);
  finally
    overlay.Free;
  end;
end;

function TImageFXGR32.DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(Graphic,(fBitmap.Width - Graphic.Width) div 2, (fBitmap.Height - Graphic.Height) div 2,alpha);
end;

function TImageFXGR32.DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(stream,-1,-1,alpha);
end;

function TImageFXGR32.NewBitmap(w, h: Integer): IImageFX;
begin
  if Assigned(Self.fBitmap) then
  begin
    Self.fBitmap.Clear;
    Self.fBitmap.SetSize(w, h);
  end
  else  Result := Self;
end;

function TImageFXGR32.IsEmpty : Boolean;
begin
  Result := fBitmap.Empty;
end;

function TImageFXGR32.Rotate90 : IImageFX;
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

function TImageFXGR32.Rotate180 : IImageFX;
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

function TImageFXGR32.RotateAngle(RotAngle: Single) : IImageFX;
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

function TImageFXGR32.RotateBy(RoundAngle: Integer): IImageFX;
begin
  Result := RotateAngle(RoundAngle);
  LastResult := arOk;
end;

function TImageFXGR32.Rotate270 : IImageFX;
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

function TImageFXGR32.FlipX : IImageFX;
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

function TImageFXGR32.FlipY : IImageFX;
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

function TImageFXGR32.GrayScale : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;
  ColorToGrayScale(fBitmap,fBitmap,True);
  LastResult := arOk;
end;

function TImageFXGR32.IsGray: Boolean;
begin
  raise ENotImplemented.Create('Not implemented!');
end;

function TImageFXGR32.Lighten(StrenghtPercent : Integer = 30) : IImageFX;
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

function TImageFXGR32.Darken(StrenghtPercent : Integer = 30) : IImageFX;
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

function TImageFXGR32.Tint(mColor : TColor) : IImageFX;
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

function TImageFXGR32.TintAdd(R, G , B : Integer) : IImageFX;
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

function TImageFXGR32.TintBlue : IImageFX;
begin
  Result := Tint(clBlue);
end;

function TImageFXGR32.TintRed : IImageFX;
begin
  Result := Tint(clRed);
end;

function TImageFXGR32.TintGreen : IImageFX;
begin
  Result := Tint(clGreen);
end;

function TImageFXGR32.Solarize : IImageFX;
begin
  Result := TintAdd(255,-1,-1);
end;

function TImageFXGR32.ScanlineH;
begin
  Result := Self;
  DoScanLines(smHorizontal);
end;

function TImageFXGR32.ScanlineV;
begin
  Result := Self;
  DoScanLines(smVertical);
end;

procedure TImageFXGR32.DoScanLines(ScanLineMode : TScanlineMode);
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

procedure TImageFXGR32.SaveToPNG(const outfile : string);
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

procedure TImageFXGR32.SaveToJPG(const outfile : string);
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

procedure TImageFXGR32.SaveToBMP(const outfile : string);
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

procedure TImageFXGR32.SaveToGIF(const outfile : string);
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


procedure TImageFXGR32.SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
var
  graf : TGraphic;
begin
  if stream.Position > 0 then stream.Seek(0,soBeginning);

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

procedure TImageFXGR32.GPBitmapToBitmap(gpbmp : TGPBitmap; bmp : TBitmap32);
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

function TImageFXGR32.GetFileInfo(AExt : string; var AInfo : TSHFileInfo; ALargeIcon : Boolean = False) : Boolean;
var uFlags : integer;
begin
  FillMemory(@AInfo,SizeOf(TSHFileInfo),0);
  uFlags := SHGFI_ICON+SHGFI_TYPENAME+SHGFI_USEFILEATTRIBUTES;
  if ALargeIcon then uFlags := uFlags + SHGFI_LARGEICON
    else uFlags := uFlags + SHGFI_SMALLICON;
  if SHGetFileInfo(PChar(AExt),FILE_ATTRIBUTE_NORMAL,AInfo,SizeOf(TSHFileInfo),uFlags) = 0 then Result := False
    else Result := True;
end;

function TImageFXGR32.AsBitmap : TBitmap;
begin
  LastResult := arConversionError;
  Result := TBitmap.Create;
  InitBitmap(Result);
  Result.Assign(fBitmap);
  LastResult := arOk;
end;

function TImageFXGR32.AsPNG: TPngImage;
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

function TImageFXGR32.AsJPG : TJPEGImage;
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

function TImageFXGR32.AsGIF : TGifImage;
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

function TImageFXGR32.AsString(imgFormat : TImageFormat = ifJPG) : string;
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

function TImageFXGR32.GetPixel(const x, y: Integer): TPixelInfo;
begin
  Result := GetPixelImage(x,y,fBitmap);
end;

function TImageFXGR32.Rounded(RoundLevel : Integer = 27) : IImageFX;
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

function TImageFXGR32.AntiAliasing : IImageFX;
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

function TImageFXGR32.SetAlpha(Alpha : Byte) : IImageFX;
begin
  Result := Self;
  //DoAlpha(fBitmap,Alpha);
end;

procedure TImageFXGR32.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  SetPixelImage(x,y,P,fBitmap);
end;

procedure TImageFXGR32.SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp32 : TBitmap32);
begin
  bmp32.Pixel[x,y] := RGB(P.R,P.G,P.B);
end;

function TImageFXGR32.GetPixelImage(const x, y: Integer; bmp32 : TBitmap32) : TPixelInfo;
var
  lRGB : TRGB;
begin
  lRGB := ColorToRGBValues(bmp32.Pixel[x,y]);
  Result.R := lRGB.R;
  Result.G := lRGB.G;
  Result.B := lRGB.B;
end;

function TImageFXGR32.GetResolution: string;
begin

end;

end.
