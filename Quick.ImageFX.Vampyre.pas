{ ***************************************************************************

  Copyright (c) 2013-2017 Kike Pérez

  Unit        : Quick.ImageFX.GR32
  Description : Image manipulation with GR32
  Author      : Kike Pérez
  Version     : 4.0
  Created     : 12/12/2017
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
unit Quick.ImageFX.Vampyre;

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
   Vcl.Imaging.pngimage,
   Vcl.Imaging.jpeg,
   Vcl.Imaging.GIFImg,
   ImagingFormats,
   //ImagingDirect3D9,
   //ImagingJpeg,
   //ImagingBitmap,
   ImagingGif,
   ImagingTypes,
   Imaging,
   ImagingComponents,
   ImagingCanvases,
   Quick.Base64,
   Quick.ImageFX,
   Quick.ImageFX.Types;


const
  MaxPixelCountA = MaxInt Div SizeOf (TRGBQuad);

type

  TScanlineMode = (smHorizontal, smVertical);

  PRGBAArray = ^TRGBAArray;
  TRGBAArray = Array [0..MaxPixelCountA -1] Of TRGBQuad;

  pRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = ARRAY [0 .. $EFFFFFF] OF TRGBQuad;

  TRGBArray = ARRAY[0..32767] OF TRGBTriple;
  pRGBArray = ^TRGBArray;

  TImageFXVampyre = class(TImageFX,IImageFX)
  protected
    fImageData :  TImageData;
    fPImage : PImageData;
  private
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
    procedure SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp32 : TBitmap);
    function GetPixelImage(const x, y: Integer; bmp32 : TBitmap): TPixelInfo;
  protected
    function GetPixel(const x, y: Integer): TPixelInfo;
    procedure SetPixel(const x, y: Integer; const P: TPixelInfo);
  public
    function AsImageData : PImageData;
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
    procedure GetResolution(var x,y : Integer); overload;
    function GetResolution : string; overload;
    function AspectRatio : Double;
    function Clear(pcolor : TColor = clNone) : IImageFX;
    procedure Assign(Graphic : TGraphic);
    function Resize(w, h : Integer) : IImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX; overload;
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


constructor TImageFXVampyre.Create;
begin
  inherited Create;
  fPImage := @fImageData;
  Imaging.FreeImage(fPImage^);
end;

destructor TImageFXVampyre.Destroy;
begin
  Imaging.FreeImage(fPImage^);
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

function TImageFXVampyre.LoadFromFile(const fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
var
  //GPBitmap : TGPBitmap;
  //Status : TStatus;
  //PropItem : PPropertyItem;
  //PropSize: UINT;
  //Orientation : PWORD;
  fs : TFileStream;
begin
  Result := Self;

  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    Exit;
  end;

  //loads file into image
  fs := TFileStream.Create(fromfile,fmShareDenyWrite);
  try
    Self.LoadFromStream(fs);
  finally
    fs.Free;
  end;

  {GPBitmap := TGPBitmap.Create(fromfile);
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
    GPBitmapToImage(GPBitmap,fPImage^);
    LastResult := arOk;
  finally
    GPBitmap.Free;
  end;}
end;

function TImageFXVampyre.LoadFromStream(stream: TStream) : IImageFX;
var
  GraphicClass : TGraphicClass;
begin
  Result := Self;

  if (not Assigned(stream)) or (stream.Size < 1024) then
  begin
    LastResult := arZeroBytes;
    Exit;
  end;
  stream.Seek(0,soBeginning);
  if not FindGraphicClass(Stream, GraphicClass) then raise EInvalidGraphic.Create('Unknow Graphic format');
  stream.Seek(0,soBeginning);
  Imaging.LoadImageFromStream(stream,fPImage^);
  if ExifRotation then ProcessEXIFRotation(stream);
  LastResult := arOk;
end;

function TImageFXVampyre.LoadFromString(const str: string) : IImageFX;
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

function TImageFXVampyre.LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
var
   Icon : TIcon;
begin
  Result := Self;
  Icon := TIcon.Create;
  try
    Icon.Handle := ExtractAssociatedIcon(hInstance,pChar(FileName),IconIndex);
    Icon.Transparent := True;
    //fBitmap.Assign(Icon);
  finally
    Icon.Free;
  end;
end;

function TImageFXVampyre.LoadFromResource(const ResourceName : string) : IImageFX;
var
   icon : TIcon;
   ms : TMemoryStream;
begin
  Result := Self;

  icon:=TIcon.Create;
  try
    icon.LoadFromResourceName(HInstance,ResourceName);
    icon.Transparent:=True;
    ms := TMemoryStream.Create;
    try
      icon.SaveToStream(ms);
      Imaging.LoadImageFromStream(ms,fPImage^);
    finally
      ms.Free;
    end;
  finally
    icon.Free;
  end;
end;

function TImageFXVampyre.LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
var
  icon : TIcon;
  ms : TMemoryStream;
begin
  Result := Self;
  //imgList.ColorDepth := cd32bit;
  //imgList.DrawingStyle := dsTransparent;
  icon := TIcon.Create;
  try
    imgList.GetIcon(ImageIndex,icon);
    ms := TMemoryStream.Create;
    try
      icon.SaveToStream(ms);
      Imaging.LoadImageFromStream(ms,fPImage^);
    finally
      ms.Free;
    end;
  finally
    icon.Free;
  end;
end;

function TImageFXVampyre.LoadFromIcon(Icon : TIcon) : IImageFX;
var
  ms : TMemoryStream;
begin
  Result := Self;
  ms := TMemoryStream.Create;
  try
    icon.SaveToStream(ms);
    Imaging.LoadImageFromStream(ms,fPImage^);
  finally
    ms.Free;
  end;
end;

function TImageFXVampyre.LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
var
  icon : TIcon;
  aInfo : TSHFileInfo;
  ms : TMemoryStream;
begin
  Result := Self;
  LastResult := arUnknowFmtType;
  if GetFileInfo(ExtractFileExt(aFilename),aInfo,LargeIcon) then
  begin
    icon := TIcon.Create;
    try
      Icon.Handle := AInfo.hIcon;
      Icon.Transparent := True;
      ms := TMemoryStream.Create;
      try
        icon.SaveToStream(ms);
        Imaging.LoadImageFromStream(ms,fPImage^);
      finally
        ms.Free;
      end;
      LastResult := arOk;
    finally
      icon.Free;
      DestroyIcon(aInfo.hIcon);
    end;
  end;
end;

function TImageFXVampyre.AspectRatio : Double;
begin
  if not IsEmpty then Result := fPImage.width / fPImage.Height
    else Result := 0;
end;

procedure TImageFXVampyre.GetResolution(var x,y : Integer);
begin
  if not IsEmpty then
  begin
    x := fPImage.Width;
    y := fPImage.Height;
    LastResult := arOk;
  end
  else
  begin
    x := -1;
    y := -1;
    LastResult := arCorruptedData;
  end;
end;

function TImageFXVampyre.Clear(pcolor : TColor = clNone) : IImageFX;
var
  color : TColor32Rec;
begin
  Result := Self;
  color.Color := ColorToRGB(pcolor);
  Imaging.FillRect(fPImage^,0,0,fPImage.Width,fPImage.Height,@color);
  LastResult := arOk;
end;

function TImageFXVampyre.Clone : IImageFX;
begin
  Result := TImageFXVampyre.Create;
  Imaging.CloneImage(fPImage^,(Result as TImageFXVampyre).fPImage^);
  CloneValues(Result);
end;

function TImageFXVampyre.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
var
  resam : TResizeFilter;
  srcRect,
  tgtRect : TRect;
  crop : Integer;
  srcRatio : Double;
  nw, nh : Integer;
  DestImageData : TImageData;
  PDestImage : PImageData;
  fillcolor : TColor32Rec;
begin
  Result := Self;
  LastResult := arResizeError;

  if (not Assigned(fPImage)) or ((fPImage.Width * fPImage.Height) = 0) then
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
      if (h = 0) and (fPImage.Height > fPImage.Width) then
      begin
        h := w;
        w := 0;
      end;
    end
    else ResizeOptions.ResizeMode := rmFitToBounds;
    begin
      if w > h then
      begin
        nh := (w * fPImage.Height) div fPImage.Width;
        h := nh;
        nw := w;
      end
      else
      begin
        nw := (h * fPImage.Width) div fPImage.Height;
        w := nw;
        nh := h;
      end;
    end;
  end;

  case ResizeOptions.ResizeMode of
    rmScale: //recalculate width or height target size to preserve original aspect ratio
      begin
        if fPImage.Width > fPImage.Height then
        begin
          nh := (w * fPImage.Height) div fPImage.Width;
          h := nh;
          nw := w;
        end
        else
        begin
          nw := (h * fPImage.Width) div fPImage.Height;
          w := nw;
          nh := h;
        end;
        srcRect := Rect(0,0,fPImage.Width,fPImage.Height);
      end;
    rmCropToFill: //preserve target aspect ratio cropping original image to fill whole size
      begin
        nw := w;
        nh := h;
        crop := Round(h / w * fPImage.Width);
        if crop < fPImage.Height then
        begin
          //target image is wider, so crop top and bottom
          srcRect.Left := 0;
          srcRect.Top := (fPImage.Height - crop) div 2;
          srcRect.Width := fPImage.Width;
          srcRect.Height := crop;
        end
        else
        begin
          //target image is narrower, so crop left and right
          crop := Round(w / h * fPImage.Height);
          srcRect.Left := (fPImage.Width - crop) div 2;
          srcRect.Top := 0;
          srcRect.Width := crop;
          srcRect.Height := fPImage.Height;
        end;
      end;
    rmFitToBounds: //resize image to fit max bounds of target size
      begin
        srcRatio := fPImage.Width / fPImage.Height;
        if fPImage.Width > fPImage.Height then
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
        srcRect := Rect(0,0,fPImage.Width,fPImage.Height);
      end;
    else
    begin
      nw := w;
      nh := h;
      srcRect := Rect(0,0,fPImage.Width,fPImage.Height);
    end;
  end;

  //if image is smaller no upsizes
  if ResizeOptions.NoMagnify then
  begin
    if (fPImage.Width < nw) or (fPImage.Height < nh) then
    begin
      //if FitToBounds then preserve original size
      if ResizeOptions.ResizeMode = rmFitToBounds then
      begin
        nw := fPImage.Width;
        nh := fPImage.Height;
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
        if (w < fPImage.Width ) or (h < fPImage.Height) then Resam := rfBilinear
          else Resam := rfBicubic;
      end;
    rsNearest : Resam := rfNearest;
    rsVAMPLanczos : Resam := rfLanczos;
    rsVAMPBicubic : Resam := rfBicubic;
    rsLinear : Resam := rfBilinear;
    else Resam := rfBilinear;
  end;

  PDestImage := @DestImageData;
  //Imaging.InitImage(PDestImage^);
  Imaging.NewImage(w,h,fPImage^.Format,PDestImage^);
  try
    try
      if ResizeOptions.FillBorders then
      begin
        //ColorToRGBValues()
        fillcolor.Color := ColorToRGB(ResizeOptions.BorderColor);
        Imaging.FillRect(PDestImage^,0,0,PDestImage.Width,PDestImage.Height,@fillcolor);
      end;
      Imaging.StretchRect(fPImage^,srcRect.Left,srcRect.Top, srcRect.Width, srcRect.Height,
                          PDestImage^, tgtRect.Left, tgtRect.Top, tgtRect.Width, tgtRect.Height, resam);
      Imaging.FreeImage(fPImage^);
      //fPImage := @DestImageData;
      Imaging.CloneImage(PDestImage^,fPImage^);
      FreeImage(PDestImage^);
      LastResult := arOk;
    except
      LastResult := arCorruptedData;
      raise Exception.Create('Resize Error');
    end;
  finally
    FreeImage(PDestImage^);
  end;
end;

function TImageFXVampyre.Resize(w, h : Integer) : IImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFXVampyre.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX;
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

procedure TImageFXVampyre.Assign(Graphic : TGraphic);
var
  ms : TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    LoadFromStream(ms);
  finally
    ms.Free;
  end;
end;

function TImageFXVampyre.Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX;
var
  overlay : PImageData;
  ms : TMemoryStream;
begin
  Result := Self;
  if x = -1 then x := (fPImage.Width - Graphic.Width) div 2;
  if y = -1 then y := (fPImage.Height - Graphic.Height) div 2;
  ms := TMemoryStream.Create;
  try
    Graphic.SaveToStream(ms);
    ms.Seek(0,soBeginning);
    Draw(ms,x,y,alpha);
  finally
    ms.Free;
  end;
end;

function TImageFXVampyre.Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
var
  overlay : TImageData;
  poverlay : PImageData;
  srccanvas : TImagingCanvas;
  tgtcanvas : TImagingCanvas;
  pixel : TColorFPRec;
  x1, y1 : Integer;
begin
  Result := Self;
  stream.Seek(0,soBeginning);
  Imaging.LoadImageFromStream(stream,overlay);
  poverlay := @overlay;
  srccanvas := nil;
  tgtcanvas := nil;
  try
    //if not Imaging.CopyRect(overlay,0,0,overlay.Width,overlay.Height,fPImage^,x,y) then raise EImageDrawError.Create('Drawing error');
    tgtcanvas := TImagingCanvas.CreateForData(fPImage);
    srccanvas := TImagingCanvas.CreateForData(poverlay);
    if x = -1 then x := (fPImage.Width - poverlay.Width) div 2;
    if y = -1 then y := (fPImage.Height - poverlay.Height) div 2;
    try
      for x1 := 0 to poverlay.Width do
      begin
        for y1 := 0 to poverlay.Height do
        begin
          pixel := srccanvas.PixelsFP[x1,y1];
          pixel.A := pixel.A * alpha;
          srccanvas.PixelsFP[x1,y1] := pixel;
        end;
      end;
      srccanvas.DrawAlpha(Rect(0,0,overlay.Width,overlay.Height),tgtcanvas,x,y);
    finally
      srccanvas.Free;
      tgtcanvas.Free;
    end;
  finally
    Imaging.FreeImage(overlay);
  end;
end;

function TImageFXVampyre.DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(Graphic,(fPImage.Width - Graphic.Width) div 2, (fPImage.Height - Graphic.Height) div 2,alpha);
end;

function TImageFXVampyre.DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(stream,-1,-1,alpha);
end;

function TImageFXVampyre.NewBitmap(w, h: Integer): IImageFX;
begin
  Result := Self;
  if not IsEmpty then Imaging.FreeImage(fPImage^);
  if not Imaging.NewImage(w,h,ImagingTypes.TImageFormat.ifA8R8G8B8,fPImage^) then raise EImageError.Create('Error creating image');
end;

function TImageFXVampyre.IsEmpty : Boolean;
begin
  Result := not (Assigned(fPImage) and Imaging.TestImage(fPImage^));
end;

function TImageFXVampyre.Rotate90 : IImageFX;
begin
  Result := Self;
  Imaging.RotateImage(fPImage^,-90);
end;

function TImageFXVampyre.Rotate180 : IImageFX;
begin
  Result := Self;
  Imaging.RotateImage(fPImage^,-180);
end;

function TImageFXVampyre.RotateAngle(RotAngle: Single) : IImageFX;
begin
  Result := Self;
  Imaging.RotateImage(fPImage^,RotAngle * -1);
end;

function TImageFXVampyre.RotateBy(RoundAngle: Integer): IImageFX;
begin
  Result := Self;
  Imaging.RotateImage(fPImage^,RoundAngle * -1);
end;

function TImageFXVampyre.Rotate270 : IImageFX;
begin
  Result := Self;
  Imaging.RotateImage(fPImage^,-270);
end;

function TImageFXVampyre.FlipX : IImageFX;
begin
  Result := Self;
  if not Imaging.MirrorImage(fPImage^) then raise EImageRotationError.Create('FlipX error');
end;

function TImageFXVampyre.FlipY : IImageFX;
begin
  Result := Self;
  if not Imaging.FlipImage(fPImage^) then raise EImageRotationError.Create('FlipY error');
end;

function TImageFXVampyre.GrayScale : IImageFX;
begin
  Result := Self;
  if not Imaging.ConvertImage(fPImage^,ImagingTypes.TImageFormat.ifA16Gray16) then raise EImageResizeError.Create('Error grayscaling');
end;

function TImageFXVampyre.IsGray: Boolean;
begin
  raise ENotImplemented.Create('Not implemented!');
end;

function TImageFXVampyre.Lighten(StrenghtPercent : Integer = 30) : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
{var
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
  end;}
end;

function TImageFXVampyre.Darken(StrenghtPercent : Integer = 30) : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
{var
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
  end;}
end;

function TImageFXVampyre.Tint(mColor : TColor) : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
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
end;}

function TImageFXVampyre.TintAdd(R, G , B : Integer) : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
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
end;}

function TImageFXVampyre.TintBlue : IImageFX;
begin
  Result := Tint(clBlue);
end;

function TImageFXVampyre.TintRed : IImageFX;
begin
  Result := Tint(clRed);
end;

function TImageFXVampyre.TintGreen : IImageFX;
begin
  Result := Tint(clGreen);
end;

function TImageFXVampyre.Solarize : IImageFX;
begin
  Result := TintAdd(255,-1,-1);
end;

function TImageFXVampyre.ScanlineH;
begin
  Result := Self;
  DoScanLines(smHorizontal);
end;

function TImageFXVampyre.ScanlineV;
begin
  Result := Self;
  DoScanLines(smVertical);
end;

procedure TImageFXVampyre.DoScanLines(ScanLineMode : TScanlineMode);
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
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
end;}

procedure TImageFXVampyre.SaveToPNG(const outfile : string);
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

procedure TImageFXVampyre.SaveToJPG(const outfile : string);
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

procedure TImageFXVampyre.SaveToBMP(const outfile : string);
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

procedure TImageFXVampyre.SaveToGIF(const outfile : string);
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


procedure TImageFXVampyre.SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
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
        SaveImageToStream('gif',stream,fpImage^);
      end;
  end;
end;

function TImageFXVampyre.AsBitmap : TBitmap;
begin
  LastResult := arConversionError;
  Result := TBitmap.Create;
  InitBitmap(Result);
  ImagingComponents.ConvertDataToBitmap(fPImage^,Result);
end;

function TImageFXVampyre.AsPNG: TPngImage;
var
  n, a: Integer;
  PNB: TPngImage;
  FFF: PRGBAArray;
  AAA: pByteArray;
  bmp : TBitmap;
begin
  LastResult := arConversionError;
  Result := TPngImage.CreateBlank(COLOR_RGBALPHA,16,fPImage.Width,fPImage.Height);

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

function TImageFXVampyre.AsJPG : TJPEGImage;
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

function TImageFXVampyre.AsGIF : TGifImage;
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

function TImageFXVampyre.AsImageData: PImageData;
begin
  Result^ := fPImage^;
end;

function TImageFXVampyre.AsString(imgFormat : TImageFormat = ifJPG) : string;
var
  ss : TStringStream;
begin
  LastResult := arConversionError;
  ss := TStringStream.Create;
  try
    case imgFormat of
      ifBMP : Self.AsBitmap.SaveToStream(ss);
      ifJPG : Self.AsJPG.SaveToStream(ss);
      ifPNG : Self.AsPNG.SaveToStream(ss);
      ifGIF : Self.SaveToStream(ss,ifGIF);
      else raise Exception.Create('Unknow format!');
    end;
    Result := Base64Encode(ss.DataString);
    LastResult := arOk;
  finally
    ss.Free;
  end;
end;

function TImageFXVampyre.GetPixel(const x, y: Integer): TPixelInfo;
begin
  raise ENotImplemented.Create('Not implemented!');
  //Result := GetPixelImage(x,y,fImageData^);
end;

function TImageFXVampyre.Rounded(RoundLevel : Integer = 27) : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
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
end; }

function TImageFXVampyre.AntiAliasing : IImageFX;
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
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
end;}

function TImageFXVampyre.SetAlpha(Alpha : Byte) : IImageFX;
begin
  Result := Self;
  //DoAlpha(fBitmap,Alpha);
end;

procedure TImageFXVampyre.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  raise ENotImplemented.Create('Not implemented!');
  //SetPixelImage(x,y,P,fBitmap);
end;

procedure TImageFXVampyre.SetPixelImage(const x, y: Integer; const P: TPixelInfo; bmp32 : TBitmap);
begin
  raise ENotImplemented.Create('Not implemented!');
  //bmp32.Pixel[x,y] := RGB(P.R,P.G,P.B);
end;

function TImageFXVampyre.GetPixelImage(const x, y: Integer; bmp32 : TBitmap) : TPixelInfo;
begin
  raise ENotImplemented.Create('Not implemented!');
end;
{var
  lRGB : TRGB;
begin
  lRGB := ColorToRGBValues(bmp32.Pixel[x,y]);
  Result.R := lRGB.R;
  Result.G := lRGB.G;
  Result.B := lRGB.B;
end;}

function TImageFXVampyre.GetResolution: string;
begin

end;

end.
