{ ***************************************************************************

  Copyright (c) 2023-2024 Kike Pérez

  Unit        : Quick.ImageFX.Vips
  Description : Image manipulation with LibVips
  Author      : Kike Pérez
  Version     : 1.0
  Created     : 12/10/2023
  Modified    : 27/02/2024

  This file is part of QuickImageFX: https://github.com/exilon/QuickImageFX

  Third-party libraries used:
    LibVips (https://github.com/libvips/libvips)
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
unit Quick.ImageFX.Vips;

{$i QuickImageFX.inc}

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  Vcl.ImgList,
  Vcl.Controls,
  System.SysUtils,
  Winapi.ShellAPI,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  {$ENDIF}
  System.UITypes,
  System.Classes,
  System.Math,
  Quick.Image.Engine.Vips,
  CCR.Exif,
  Quick.ImageFX,
  Quick.ImageFX.Types,
  Quick.Base64;

type

  TImageFXVips = class(TImageFX,IImageFX)
  private
    fVipsImage : TVipsImage;
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
    procedure SaveToStreamWithoutCompression(stream : TStream; imgFormat : TImageFormat = ifJPG);
    function IsEmpty: Boolean;
  protected
    function GetPixel(const x, y: Integer): TPixelInfo;
    procedure SetPixel(const x, y: Integer; const P: TPixelInfo);
  public
    property Pixel[const x, y: Integer]: TPixelInfo read GetPixel write SetPixel;
    constructor Create; overload; override;
    constructor Create(const fromfile : string); overload; override;
    destructor Destroy; override;
    function Width : Integer;
    function Height : Integer;
    function NewBitmap(w, h : Integer) : IImageFX;
    function IsNullOrEmpty : Boolean; override;
    function LoadFromFile(const fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromFile2(const fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromStream(stream : TStream) : IImageFX;
    function LoadFromString(const str : string) : IImageFX;
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
    function LoadFromIcon(Icon : TIcon) : IImageFX;
    function LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
    function LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
    function LoadFromResource(const ResourceName : string) : IImageFX;
    function LoadFromImage(image : pVipsImage) : IImageFX;
    procedure GetResolution(var x,y : Integer); overload;
    function AspectRatio : Double;
    function GetPixelImage(const x, y: Integer; image : pVipsImage): TPixelInfo;
    procedure SetPixelImage(const x, y: Integer; const P: TPixelInfo; image : pVipsImage);
    function IsGray : Boolean;
    procedure Assign(Graphic : TGraphic);
    function Clear(pcolor : TColor = clNone) : IImageFX;
    function Resize(w, h : Integer) : IImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX; overload;
    function Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function Draw(stream : TStream; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function Draw(overlay : TVipsImage; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX; overload;
    function DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX; overload;
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
    function AntiAliasing : IImageFX;
    function SetAlpha(Alpha : Byte) : IImageFX;
    procedure SaveToPNG(const outfile : string); override;
    procedure SaveToJPG(const outfile : string); override;
    procedure SaveToBMP(const outfile : string); override;
    procedure SaveToGIF(const outfile : string); override;
    procedure SaveToFile(const outfile : string; aImgFormat : TImageFormat); override;
    function AsImage : pVipsImage;
    function AsBitmap : TBitmap;
    function AsPNG : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    function CloneImage : pVipsImage;
    function Clone : IImageFX;
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
  end;


implementation


constructor TImageFXVips.Create;
begin
  inherited Create;
  fVipsImage := TVipsImage.Create;
end;

constructor TImageFXVips.Create(const fromfile: string);
begin
  Create;
  LoadFromFile(fromfile);
end;

destructor TImageFXVips.Destroy;
begin
  if Assigned(fVipsImage) then fVipsImage.Free;
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

function TImageFXVips.LoadFromFile(const fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
var
  fs : TFileStream;
begin
  Result := Self;
  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('File "%s" not found',[fromfile]));
  end;

  //loads file into VipsImage
  fs := TFileStream.Create(fromfile,fmShareDenyWrite);
  try
    Result := Self.LoadFromStream(fs);
  finally
    fs.Free;
  end;

  if fVipsImage.GetVipsImage = nil then
  begin
    LastResult := arUnknowFmtType;
    raise Exception.Create(Format('Error loading image "%s"',[fromfile]));
  end
  else LastResult := arOk;
end;

function TImageFXVips.LoadFromFile2(const fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
begin
  Result := Self;

  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('File "%s" not found',[fromfile]));
  end;

  //loads file into VipsImage
  LastResult := arUnknowFmtType;
  try
    fVipsImage.LoadFromFile(fromfile);
  except
    on E : Exception do  raise Exception.CreateFmt('Error loading image "%s" (%s)',[fromfile, e.Message]);
  end;
  LastResult := arOk;
end;

function TImageFXVips.LoadFromStream(stream: TStream) : IImageFX;
var
  ExifData : TExifData;
begin
  Result := Self;
  ExifData := nil;

  if (not Assigned(stream)) or (stream.Size = 0) then
  begin
    LastResult := arZeroBytes;
    raise Exception.Create('Stream is empty!');
  end;

  stream.Position := 0;

  fVipsImage.LoadFromStream(stream);

  if fVipsImage.IsNullOrEmpty then raise EInvalidGraphic.CreateFmt('Unknow Graphic format (%s)',[vips_error_buffer()]);

  //if ExifRotation then fVipsImage.RotateByExif;
  if ExifRotation then ProcessExifRotation(stream);

  LastResult := arOk;
end;

function TImageFXVips.LoadFromString(const str: string) : IImageFX;
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

function TImageFXVips.LoadFromFileIcon(const FileName : string; IconIndex : Word) : IImageFX;
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

function TImageFXVips.LoadFromResource(const ResourceName : string) : IImageFX;
var
   icon : TIcon;
   //GPBitmap : TGPBitmap;
begin
  Result := Self;

  icon:=TIcon.Create;
  try
    icon.LoadFromResourceName(HInstance,ResourceName);
    icon.Transparent:=True;
    Self.LoadFromIcon(icon);
  finally
    icon.Free;
  end;
end;

function TImageFXVips.LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
var
  icon : TIcon;
begin
  Result := Self;
  icon := TIcon.Create;
  try
    imgList.GetIcon(ImageIndex,icon);
    icon.Transparent := True;
    Self.LoadFromIcon(icon);

    LastResult := arOk;
  finally
    icon.Free;
  end;
end;

function TImageFXVips.LoadFromIcon(Icon : TIcon) : IImageFX;
var
  ms : TMemoryStream;
  bmp : TBitmap;
begin
  Result := Self;
  ms := TMemoryStream.Create;
  try
    bmp := TBitmap.Create;
    try
      InitBitmap(bmp);
      bmp.Assign(Icon);
      bmp.SaveToStream(ms);
    finally
      bmp.Free;
    end;
    Self.LoadFromStream(ms);
  finally
    ms.Free;
  end;
end;


function TImageFXVips.LoadFromFileExtension(const aFilename : string; LargeIcon : Boolean) : IImageFX;
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

      Self.LoadFromIcon(Icon);

      LastResult := arOk;
    finally
      icon.Free;
      DestroyIcon(aInfo.hIcon);
    end;
  end;
end;

function TImageFXVips.LoadFromImage(image : pVipsImage) : IImageFX;
begin
  Result := Self;
  fVipsImage := image;
end;

function TImageFXVips.AspectRatio : Double;
var
  w, h : Integer;
begin
  if fVipsImage <> nil then
  begin
    w := vips_image_get_width(fVipsImage);
    h := vips_image_get_height(fVipsImage);
    Result := w / h;
  end
  else Result := 0;
end;

procedure TImageFXVips.GetResolution(var x,y : Integer);
begin
  if Assigned(fVipsImage) then
  begin
    x := fVipsImage.Width;
    y := fVipsImage.Height;
    LastResult := arOk;
  end
  else
  begin
    x := -1;
    y := -1;
    LastResult := arCorruptedData;
  end;
end;

function TImageFXVips.IsNullOrEmpty: Boolean;
begin
  Result := fVipsImage = nil;
end;

function TImageFXVips.IsGray: Boolean;
begin
  if Assigned(fVipsImage) then Result := vips_image_hasalpha(fVipsImage) = 0
    else Result := False;
end;

function TImageFXVips.Clear(pcolor : TColor = clNone) : IImageFX;
begin
  Result := Self;
  fVipsImage.Clear(pcolor);
  LastResult := arOk;
end;

function TImageFXVips.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
var
  ImgAux : pVipsImage;
  srcRect,
  tgtRect : TRect;
  crop : Integer;
  srcRatio : Double;
  nw, nh : Integer;
  Resampler : TVipsKernel;
begin
  Result := Self;

  if (not Assigned(fVipsImage)) or ((Self.Width * Self.Height) = 0) then
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
      if (h = 0) and (Self.Height > Self.Width) then
      begin
        h := w;
        w := 0;
      end;
    end
    else ResizeOptions.ResizeMode := rmFitToBounds;
    begin
      if w > h then
      begin
        nh := (w * Self.Height) div Self.Width;
        h := nh;
      end
      else
      begin
        nw := (h * Self.Width) div Self.Height;
        w := nw;
      end;
    end;
  end;

  case ResizeOptions.ResizeMode of
    rmScale: //recalculate width or height target size to preserve original aspect ratio
      begin
        if Self.Width > Self.Height then
        begin
          nh := (w * Self.Height) div Self.Width;
          h := nh;
          nw := w;
        end
        else
        begin
          nw := (h * Self.Width) div Self.Height;
          w := nw;
          nh := h;
        end;
        srcRect := Rect(0,0,Self.Width,Self.Height);
      end;
    rmCropToFill: //preserve target aspect ratio cropping original image to fill whole size
      begin
        nw := w;
        nh := h;
        crop := Round(h / w * Self.Width);
        if crop < Self.Height then
        begin
          //target image is wider, so crop top and bottom
          srcRect.Left := 0;
          srcRect.Top := (Self.Height - crop) div 2;
          srcRect.Width := Self.Width;
          srcRect.Height := crop;
        end
        else
        begin
          //target image is narrower, so crop left and right
          crop := Round(w / h * Self.Height);
          srcRect.Left := (Self.Width - crop) div 2;
          srcRect.Top := 0;
          srcRect.Width := crop;
          srcRect.Height := Self.Height;
        end;
      end;
    rmFitToBounds: //resize image to fit max bounds of target size
      begin
        srcRatio := Self.Width / Self.Height;
        if Self.Width > Self.Height then
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
        srcRect := Rect(0,0,Self.Width,Self.Height);
      end;
    else
    begin
      nw := w;
      nh := h;
      srcRect := Rect(0,0,Self.Width,Self.Height);
    end;
  end;

  //if image is smaller no upsizes
  if ResizeOptions.NoMagnify then
  begin
    if (Self.Width < nw) or (Self.Height < nh) then
    begin
      //if FitToBounds then preserve original size
      if ResizeOptions.ResizeMode = rmFitToBounds then
      begin
        nw := Self.Width;
        nh := Self.Height;
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
        if (w < Self.Width ) or (h < Self.Height) then Resampler := TVipsKernel.VIPS_KERNEL_LINEAR
          else Resampler := TVipsKernel.VIPS_KERNEL_LINEAR;
      end;
    rsNearest : Resampler := TVipsKernel.VIPS_KERNEL_NEAREST;
    rsLinear : Resampler := TVipsKernel.VIPS_KERNEL_LINEAR;
    rsVipsCubic : Resampler := TVipsKernel.VIPS_KERNEL_CUBIC;
    rsVipsLanczos2 : Resampler := TVipsKernel.VIPS_KERNEL_LANCZOS2;
    rsVipsLanczos3 : Resampler := TVipsKernel.VIPS_KERNEL_LANCZOS3
    else Resampler := TVipsKernel.VIPS_KERNEL_LINEAR;
  end;

  //fVipsImage.Resize(srcRect.Width, srcRect.Height,Resampler);
  fVipsImage.Resize(nw, nh,Resampler);

  //ImgAux := cvCreateImage(CvSize(w,h),fVipsImage^.depth,fVipsImage^.nChannels);

  //fills outside zone borders with a color
  if (ResizeOptions.FillBorders) and ((tgtRect.Width < w) or (tgtRect.Height < h)) then
  begin
    //cvRectangle(ImgAux,cvPoint(0,0),cvPoint(w,h),ColorToScalar(ResizeOptions.BorderColor),CV_FILLED);
    fVipsImage.CanvasResize(w,h, TVipsExtend.VIPS_EXTEND_WHITE);
  end;
  if (fVipsImage.Width > nw) or (fVipsImage.Height > nh) then fVipsImage.CanvasResize(w,h, TVipsExtend.VIPS_EXTEND_WHITE);


  //set source and target regions
  //cvSetImageROI(fVipsImage, CvRect(srcRect.Left,srcRect.Top,srcRect.Width,srcRect.Height));
  //cvSetImageROI(ImgAux, CvRect(tgtRect.Left,tgtRect.Top,tgtRect.Width,tgtRect.Height));
  //resize
  try
    //cvResize(fVipsImage,ImgAux,Resampler);
    //cvResetImageROI(fVipsImage);
    //cvResetImageROI(ImgAux);
    //cvReleaseImage(fVipsImage);
    //fVipsImage := ImgAux;
    LastResult := arOk;
  except
    LastResult := arCorruptedData;
    //if ImgAux <> nil then cvReleaseImage(ImgAux);
  end;
end;

function TImageFXVips.Resize(w, h : Integer) : IImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFXVips.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX;
var
  lResizeOptions : TResizeOptions;
begin
  lResizeOptions := TResizeOptions.Create;
  try
    if (rfNoMagnify in ResizeFlags) then lResizeOptions.NoMagnify := True else lResizeOptions.NoMagnify := False;
    if (rfCenter in ResizeFlags) then lResizeOptions.Center := True else lResizeOptions.Center := False;
    if (rfFillBorders in ResizeFlags) then lResizeOptions.FillBorders := True else lResizeOptions.FillBorders := False;
    Result := ResizeImage(w,h,lResizeOptions);
  finally
    lResizeOptions.Free;
  end;
end;

procedure TImageFXVips.Assign(Graphic : TGraphic);
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

function TImageFXVips.DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(Graphic,(fVipsImage.Width - Graphic.Width) div 2, (fVipsImage.Height - Graphic.Height) div 2,alpha);
end;

function TImageFXVips.DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(stream,-1,-1,alpha);
end;

function TImageFXVips.Draw(Graphic : TGraphic; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
var
  stream : TStream;
begin
  stream := TStringStream.Create;
  try
    Graphic.SaveToStream(stream);
    Result := Draw(stream,x,y,alpha);
  finally
    stream.Free;
  end;
end;

function TImageFXVips.Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
var
  overlay : TVipsImage;
begin
  Result := Self;
  try
    //get overlay image
    if (stream = nil) or (stream.Size = 0) then raise EArgumentException.Create('Stream cannot be empty!');

    overlay := TVipsImage.Create;
    try
      overlay.LoadFromStream(stream);
      overlay.Linear(alpha, 0.0);
      fVipsImage.DrawImage(overlay,x,y,TVipsBlendMode.VIPS_BLEND_MODE_OVER);
    finally
      overlay.Free;
    end;
  except
    on E : Exception do raise Exception.CreateFmt('Drawing overlay error: (%s)', [e.Message]);
  end;
end;


function TImageFXVips.Draw(overlay : TVipsImage; x, y : Integer; alpha : Double = 1) : IImageFX;
begin
  Result := Self;
  overlay.Linear(alpha, 0.0);
  fVipsImage.DrawImage(overlay, x, y, TVipsBlendMode.VIPS_BLEND_MODE_OVER);
end;

function TImageFXVips.NewBitmap(w, h : Integer) : IImageFX;
begin
  Result := Self;
  if fVipsImage <> nil then fVipsImage.Free;
  fVipsImage := TVipsImage.Create(w,h);
end;

function TImageFXVips.IsEmpty : Boolean;
begin
  Result := fVipsImage <> nil;
end;

function TImageFXVips.Rotate90 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  fVipsImage.Rotate(TVipsAngle.VIPS_ANGLE_D90);
  LastResult := arOk;
end;

function TImageFXVips.Rotate180 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  fVipsImage.Rotate(TVipsAngle.VIPS_ANGLE_D180);
  LastResult := arOk;
end;

function TImageFXVips.Rotate270 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  fVipsImage.Rotate(TVipsAngle.VIPS_ANGLE_D270);
  LastResult := arOk;
end;

function TImageFXVips.RotateBy(RoundAngle : Integer) : IImageFX;
begin
  // do with vips_similarity()
  raise ENotImplemented.Create('RotateBy Not implemented yet!');
end;


function TImageFXVips.RotateAngle(RotAngle: Single) : IImageFX;
begin
  // do with vips_similarity()
  raise ENotImplemented.Create('RotateAngle Not implemented yet!');
end;


function TImageFXVips.FlipX : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  fVipsImage.Flip(TVipsDirection.VIPS_DIRECTION_HORIZONTAL);
  LastResult := arOk;
end;

function TImageFXVips.FlipY : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  fVipsImage.Flip(TVipsDirection.VIPS_DIRECTION_VERTICAL);
  LastResult := arOk;
end;

function TImageFXVips.GrayScale : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;
  fVipsImage.GrayScale;
  LastResult := arOk;
end;

function TImageFXVips.Height: Integer;
begin
  Result := fVipsImage.Height;
end;

function TImageFXVips.Lighten(StrenghtPercent : Integer = 30) : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;
  fVipsImage.Linear(StrenghtPercent / 100, 0.0);
  LastResult := arOk;
end;

function TImageFXVips.Darken(StrenghtPercent : Integer = 30) : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;
  fVipsImage.Linear(1 + ( StrenghtPercent / 100), 0.0);
  LastResult := arOk;
end;

function TImageFXVips.Tint(mColor : TColor) : IImageFX;
var
  RGB : TRGB;
begin
  Result := Self;
  LastResult := arColorizeError;
  fVipsImage.ColourSpace(TVipsInterpretation.VIPS_INTERPRETATION_RGB);
  LastResult := arOk;
end;

function TImageFXVips.TintAdd(R, G , B : Integer) : IImageFX;
const
  alpha = 1;
var
  x, y : Integer;
  srcPix : TPixelInfo;
  srcHasAlpha : Boolean;
begin
  Result := Self;
  LastResult := arColorizeError;
  {if fVipsImage.nChannels > 3 then srcHasAlpha := True
    else srcHasAlpha := False;

  for y := 0 to fVipsImage^.height - 1 do
  begin
    for x := 0 to fVipsImage^.width - 1 do
    begin
      srcPix := Self.Pixel[x,y];
      srcPix.R := srcPix.R * R; //R
      srcPix.G := srcPix.G * G;; //G
      srcPix.B := srcPix.B * B;; //B
      if (not srcHasAlpha) or (srcPix.A > 0) then Self.Pixel[x,y] := srcPix;
    end;
  end;
  LastResult := arOk;}
end;

function TImageFXVips.TintBlue : IImageFX;
begin
  Result := Tint(clBlue);
end;

function TImageFXVips.TintRed : IImageFX;
begin
  Result := Tint(clRed);
end;

function TImageFXVips.Width: Integer;
begin
  Result := fVipsImage.Width;
end;

function TImageFXVips.TintGreen : IImageFX;
begin
  Result := Tint(clGreen);
end;

function TImageFXVips.Solarize : IImageFX;
begin
  Result := TintAdd(255,-1,-1);
end;

function TImageFXVips.ScanlineH;
begin
  Result := Self;
  DoScanLines(smHorizontal);
end;

function TImageFXVips.ScanlineV;
begin
  Result := Self;
  DoScanLines(smVertical);
end;

procedure TImageFXVips.DoScanLines(ScanLineMode : TScanlineMode);
var
  dolines : Boolean;
  row,col : Integer;
  pix : TPixelInfo;
begin
  LastResult := arColorizeError; dolines := False;
  if ScanlineMode = TScanlineMode.smHorizontal then
  begin
    for row := 0 to fVipsImage.height - 1 do
    begin
      dolines := not dolines;
      if dolines then
      for col := 0 to fVipsImage.width - 1 do
      begin
        pix := Pixel[col,row];
        pix.R := 5; //R
        pix.G := 5; //G
        pix.B := 5; //B
        Pixel[col,row] := pix;
      end;
    end;
  end
  else
  begin
    for row := 0 to fVipsImage.height - 1 do
    begin
      for col := 0 to fVipsImage.width - 1 do
      begin
        if dolines then
        begin
          pix := Pixel[col,row];
          pix.R := 5; //R
          pix.G := 5; //G
          pix.B := 5; //B
          Pixel[col,row] := pix;
        end;
        dolines := not dolines;
      end;
    end;
  end;
end;

procedure TImageFXVips.SaveToPNG(const outfile : string);
begin
  LastResult := arConversionError;
  fVipsImage.SaveToFile(outfile, TVipsImageFormat.ifPNG);
  LastResult := arOk;
end;

procedure TImageFXVips.SaveToJPG(const outfile : string);
begin
  LastResult := arConversionError;
  fVipsImage.SaveToFile(outfile, TVipsImageFormat.ifJPEG);
  LastResult := arOk;
end;

procedure TImageFXVips.SaveToBMP(const outfile : string);
begin
  LastResult := arConversionError;
  fVipsImage.SaveToFile(outfile, TVipsImageFormat.ifBMP);
  LastResult := arOk;
end;

procedure TImageFXVips.SaveToFile(const outfile: string; aImgFormat: TImageFormat);
begin
  LastResult := arConversionError;
  fVipsImage.SaveToFile(outfile, TVipsImageFormat(aImgFormat));
  LastResult := arOk;
end;

procedure TImageFXVips.SaveToGIF(const outfile : string);
begin
  LastResult := arConversionError;
  fVipsImage.SaveToFile(outfile, TVipsImageFormat.ifGIF);
  LastResult := arOk;
end;

function TImageFXVips.AsBitmap : TBitmap;
var
  ms : TMemoryStream;
begin
  LastResult := arConversionError;
  Result := TBitmap.Create;
  InitBitmap(Result);
  ms := TMemoryStream.Create;
  try
    Self.SaveToStreamWithoutCompression(ms,ifBMP);
    Result.LoadFromStream(ms);
  finally
    ms.Free;
  end;
  LastResult := arOk;
end;

function TImageFXVips.AsPNG: TPngImage;
var
  ms : TMemoryStream;
begin
  LastResult := arConversionError;

  Result := TPngImage.CreateBlank(COLOR_RGBALPHA,16,fVipsImage.Width,fVipsImage.Height);
  Result.CompressionLevel := PNGCompressionLevel;
  ms := TMemoryStream.Create;
  try
    Self.SaveToStreamWithoutCompression(ms,ifPNG);
    Result.LoadFromStream(ms);
    //Result.CreateAlpha;
  finally
    ms.Free;
  end;
  LastResult := arOk;
end;

function TImageFXVips.AsJPG : TJPEGImage;
var
  ms : TMemoryStream;
begin
  LastResult := arConversionError;
  Result := TJPEGImage.Create;
  ms := TMemoryStream.Create;
  try
    Self.SaveToStreamWithoutCompression(ms,ifJPG);
    Result.LoadFromStream(ms);
    Result.ProgressiveEncoding := ProgressiveJPG;
    Result.CompressionQuality := JPGQualityPercent;
    Result.Compress;
  finally
    ms.Free;
  end;
  LastResult := arOk;
end;

function TImageFXVips.AsGIF : TGifImage;
var
  ms : TMemoryStream;
begin
  LastResult := arConversionError;
  Result := TGIFImage.Create;
  ms := TMemoryStream.Create;
  try
    Self.SaveToStreamWithoutCompression(ms,ifGIF);
    Result.LoadFromStream(ms);
  finally
    ms.Free;
  end;
  LastResult := arOk;
end;

function TImageFXVips.AsImage: pVipsImage;
begin
  Result := fVipsImage;
end;

function TImageFXVips.GetPixel(const x, y: Integer): TPixelInfo;
begin
  Result := GetPixelImage(x,y,fVipsImage);
end;

function TImageFXVips.GetPixelImage(const x, y: Integer; image : pVipsImage): TPixelInfo;
var
  ColorEncode : TocvColorEncode;
begin
  raise ENotImplemented.Create('Not implemented yet!');
  {FillChar(Result, SizeOf(Result), 0);
  if image.colorModel = cmGRAY then ColorEncode := ceGRAY
  else
  begin
    if image.channelSeq = cmRGB then ColorEncode := ceRGB
      else ColorEncode := ceBGR;
  end;
  Result.EncodeInfo := 1;

  case ColorEncode of
  ceGRAY :
    begin
      Result.ColorEncode := ceGRAY;
      Result.GV := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels))^);
    end;
  ceRGB :
    begin
      Result.ColorEncode := ceRGB;
      Result.R := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 0)^);
      Result.G := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 1)^);
      Result.B := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 2)^);
      if image.nChannels = 4 then Result.A := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 3)^);
    end;
  else
    begin
      Result.ColorEncode := ceBGR;
      Result.B := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 0)^);
      Result.G := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 1)^);
      Result.R := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 2)^);
      if image.nChannels = 4 then Result.A := byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 3)^);
    end;
  end; }
end;

procedure TImageFXVips.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  SetPixelImage(x,y,P,fVipsImage);
end;

procedure TImageFXVips.SetPixelImage(const x, y: Integer; const P: TPixelInfo; image : pVipsImage);
var
  ColorEncode : TocvColorEncode;
begin
  raise ENotImplemented.Create('Not implemented yet!');
  {if P.EncodeInfo <> 1 then
  begin
    if image.colorModel = cmGRAY then ColorEncode := ceGRAY
    else
    begin
      if image.channelSeq = cmRGB then ColorEncode := ceRGB
        else ColorEncode := ceBGR;
    end;
  end
  else ColorEncode := P.ColorEncode;

  case ColorEncode of
    ceRGB:
      begin
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 0)^) := P.R;
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 1)^) := P.G;
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 2)^) := P.B;
        if image.nChannels = 4 then byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 3)^) := P.A;
      end;
    ceBGR:
      begin
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 0)^) := P.B;
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 1)^) := P.G;
        byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 2)^) := P.R;
        if image.nChannels = 4 then byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels) + 3)^) := P.A;
      end;
    ceGRAY:
      byte(CV_IMAGE_ELEM(image, SizeOf(byte), y, (x * image^.nChannels))^) := P.GV;
  end;}
end;

function TImageFXVips.AsString(imgFormat : TImageFormat = ifJPG) : string;
var
  ss : TStringStream;
begin
  LastResult := arConversionError;
  ss := TStringStream.Create;
  try
    fVipsImage.SaveToStream(ss, TVipsImageFormat(imgFormat));
    Result := Base64Encode(ss.DataString);
    LastResult := arOk;
  finally
    ss.Free;
  end;
end;

function TImageFXVips.CloneImage : pVipsImage;
begin
  Result := fVipsImage.Clone;
end;

function TImageFXVips.Clone : IImageFX;
begin
  Result := TImageFXVips.Create;
  (Result as TImageFXVips).LoadFromImage(Self.CloneImage);
  CloneValues(Result);
end;

procedure TImageFXVips.SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
begin
  //if stream.Position > 0 then stream.Seek(0,soBeginning);

  try
    fVipsImage.SaveToStream(stream, TVipsImageFormat(imgFormat), JPGQualityPercent);
  except
    on E : Exception do raise Exception.Create('Error saving to stream');
  end;
  //if imgFormat = ifJPG then params := [CV_IMWRITE_JPEG_QUALITY, JPGQualityPercent, 0]
  //  else if imgFormat = ifPNG then params := [CV_IMWRITE_PNG_COMPRESSION, PNGCompressionLevel, 0];
  //mat := cvEncodeImage(AsPAnsiChar(GetImageFmtExt(imgFormat)),fVipsImage,@params[0]);
end;

procedure TImageFXVips.SaveToStreamWithoutCompression(stream : TStream; imgFormat : TImageFormat = ifJPG);
begin
  if stream.Position > 0 then stream.Seek(0,soBeginning);

  fVipsImage.SaveToStream(stream, TVipsImageFormat(imgFormat), 100);
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

function TImageFXVips.Rounded(RoundLevel : Integer = 27) : IImageFX;
begin
  //not implemented
  Result := Self;
end;

function TImageFXVips.AntiAliasing : IImageFX;
begin
  Result := Self;
  //not implemented
end;

function TImageFXVips.SetAlpha(Alpha : Byte) : IImageFX;
begin
  Result := Self;
  //not implemented
end;

end.
