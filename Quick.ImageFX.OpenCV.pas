{ ***************************************************************************

  Copyright (c) 2016-2018 Kike P�rez

  Unit        : Quick.ImageFX.OpenCV
  Description : Image manipulation with OpenCV
  Author      : Kike P�rez
  Version     : 4.0
  Created     : 10/04/2016
  Modified    : 27/05/2018

  This file is part of QuickImageFX: https://github.com/exilon/QuickImageFX

  Third-party libraries used:
    Delphi-OpenCV from Laex (https://github.com/Laex/Delphi-OpenCV)
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
unit Quick.ImageFX.OpenCV;

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
  ocv.utils,
  ocv.highgui_c,
  ocv.core_c,
  ocv.core.types_c,
  ocv.imgproc_c,
  ocv.imgproc.types_c,
  CCR.Exif,
  Quick.ImageFX,
  Quick.ImageFX.Types,
  Quick.Base64;


const
  MaxPixelCountA = MaxInt Div SizeOf (TRGBQuad);

  cmRGB: TA4CVChar = 'RGB'#0;
  cmBGR: TA4CVChar = 'BGR'#0;
  cmGRAY: TA4CVChar = 'GRAY';

type

  TOCVParam = array of Integer;

  POCVParam = ^TOCVParam;

  TOCVParams = array[0..5] of TOCVParam;

  TImageFXOpenCV = class(TImageFX,IImageFX)
  private
    fOCVImage : pIplImage;
    procedure DoScanlines(ScanlineMode : TScanlineMode);
    function ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
    function AsPAnsiChar(const str : string): PAnsiChar;
    procedure SaveToStreamWithoutCompression(stream : TStream; imgFormat : TImageFormat = ifJPG);
  protected
    function GetPixel(const x, y: Integer): TPixelInfo;
    procedure SetPixel(const x, y: Integer; const P: TPixelInfo);
  public
    property Pixel[const x, y: Integer]: TPixelInfo read GetPixel write SetPixel;
    constructor Create; overload; override;
    constructor Create(fromfile : string); overload; override;
    destructor Destroy; override;
    function NewBitmap(w, h : Integer) : IImageFX; overload;
    function NewBitmap(w, h: Integer; Depth : Integer; nChannels : Integer): IImageFX; overload;
    function LoadFromFile(fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromFile2(fromfile : string; CheckIfFileExists : Boolean = False) : IImageFX;
    function LoadFromStream(stream : TStream) : IImageFX;
    function LoadFromString(str : string) : IImageFX;
    function LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
    function LoadFromIcon(Icon : TIcon) : IImageFX;
    function LoadFromFileIcon(FileName : string; IconIndex : Word) : IImageFX;
    function LoadFromFileExtension(aFilename : string; LargeIcon : Boolean) : IImageFX;
    function LoadFromResource(ResourceName : string) : IImageFX;
    function LoadFromImage(image : pIplImage) : IImageFX;
    procedure GetResolution(var x,y : Integer); overload;
    function AspectRatio : Double;
    function GetPixelImage(const x, y: Integer; image : pIplImage): TPixelInfo;
    procedure SetPixelImage(const x, y: Integer; const P: TPixelInfo; image : pIplImage);
    function IsEmpty : Boolean;
    function IsGray : Boolean;
    procedure Assign(Graphic : TGraphic);
    function Clear(pcolor : TColor = clNone) : IImageFX;
    function Resize(w, h : Integer) : IImageFX; overload;
    function Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX; overload;
    function Draw(Graphic : TGraphic; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function Draw(stream : TStream; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
    function Draw(overlay : pIplImage; x, y : Integer; alpha : Double = 1) : IImageFX; overload;
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
    procedure SaveToPNG(outfile : string);
    procedure SaveToJPG(outfile : string);
    procedure SaveToBMP(outfile : string);
    procedure SaveToGIF(outfile : string);
    function AsImage : pIplImage;
    function AsBitmap : TBitmap;
    function AsPNG : TPngImage;
    function AsJPG : TJpegImage;
    function AsGIF : TGifImage;
    function AsString(imgFormat : TImageFormat = ifJPG) : string;
    function CloneImage : pIplImage;
    function Clone : IImageFX;
    procedure SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
    class function ColorToScalar(PColor : TColor = clWhite) : TCvScalar;
  end;


implementation


constructor TImageFXOpenCV.Create;
begin
  inherited Create;
  fOCVImage := nil;
end;

constructor TImageFXOpenCV.Create(fromfile: string);
begin
  Create;
  LoadFromFile(fromfile);
end;

destructor TImageFXOpenCV.Destroy;
begin
  if Assigned(fOCVImage) then cvReleaseImage(fOCVImage);
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

function TImageFXOpenCV.LoadFromFile(fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
var
  fs : TFileStream;
begin
  Result := Self;
  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('File "%s" not found',[fromfile]));
  end;

  if fOCVImage <> nil then cvReleaseImage(fOCVImage);

  //loads file into OCVImage
  fs := TFileStream.Create(fromfile,fmShareDenyWrite);
  try
    Self.LoadFromStream(fs);
  finally
    fs.Free;
  end;
  //fOCVImage := cvLoadImage(AsPAnsiChar(fromfile),CV_LOAD_IMAGE_UNCHANGED);
  //cvShowImage('Loaded Image',fOCVImage);
  if fOCVImage = nil then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('Error loading image "%s"',[fromfile]));
  end
  else LastResult := arOk;
end;

function TImageFXOpenCV.LoadFromFile2(fromfile: string; CheckIfFileExists : Boolean = False) : IImageFX;
begin
  Result := Self;

  if (CheckIfFileExists) and (not FileExists(fromfile)) then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('File "%s" not found',[fromfile]));
  end;

  if fOCVImage <> nil then cvReleaseImage(fOCVImage);

  //loads file into OCVImage
  fOCVImage := cvLoadImage(AsPAnsiChar(fromfile),CV_LOAD_IMAGE_UNCHANGED);
  //cvShowImage('Loaded Image',fOCVImage);
  if fOCVImage = nil then
  begin
    LastResult := arFileNotExist;
    raise Exception.Create(Format('Error loading image "%s"',[fromfile]));
  end
  else LastResult := arOk;
end;

function TImageFXOpenCV.LoadFromStream(stream: TStream) : IImageFX;
var
  Buffer : TBytes;
  Size : Int64;
  mat : pCvMat;
  ExifData : TExifData;
begin
  Result := Self;
  ExifData := nil;

  if (not Assigned(stream)) or (stream.Size = 0) then
  begin
    LastResult := arZeroBytes;
    raise Exception.Create('Stream is empty!');
  end;

  if fOCVImage <> nil then cvReleaseImage(fOCVImage);

  stream.Seek(0,soBeginning);
  Size := stream.Size;
  SetLength(Buffer, Size);
  stream.ReadBuffer(Pointer(Buffer)^,Size);
  mat := cvCreateMat(1,Size,CV_64F);
  //fallo
  mat.data.ptr := PByte(Buffer);
  try
    fOCVImage := cvDecodeImage(mat,CV_LOAD_IMAGE_UNCHANGED);
    if fOCVImage = nil then raise EInvalidGraphic.Create('Unknow Graphic format')
  finally
    cvReleaseMat(mat);
  end;

  if ExifRotation then ProcessExifRotation(stream);

  LastResult := arOk;
end;

function TImageFXOpenCV.LoadFromString(str: string) : IImageFX;
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
    Self.LoadFromStream(stream);
    LastResult := arOk;
  finally
    stream.Free;
  end;
end;

function TImageFXOpenCV.LoadFromFileIcon(FileName : string; IconIndex : Word) : IImageFX;
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

function TImageFXOpenCV.LoadFromResource(ResourceName : string) : IImageFX;
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

function TImageFXOpenCV.LoadFromImageList(imgList : TImageList; ImageIndex : Integer) : IImageFX;
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

function TImageFXOpenCV.LoadFromIcon(Icon : TIcon) : IImageFX;
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


function TImageFXOpenCV.LoadFromFileExtension(aFilename : string; LargeIcon : Boolean) : IImageFX;
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

function TImageFXOpenCV.LoadFromImage(image : pIplImage) : IImageFX;
begin
  Result := Self;
  fOCVImage := image;
end;

function TImageFXOpenCV.AspectRatio : Double;
begin
  if fOCVImage <> nil then Result := fOCVImage.width / fOCVImage.Height
    else Result := 0;
end;

procedure TImageFXOpenCV.GetResolution(var x,y : Integer);
begin
  if Assigned(fOCVImage) then
  begin
    x := fOCVImage^.Width;
    y := fOCVImage^.Height;
    LastResult := arOk;
  end
  else
  begin
    x := -1;
    y := -1;
    LastResult := arCorruptedData;
  end;
end;

function TImageFXOpenCV.IsEmpty: Boolean;
begin
  Result := fOCVImage = nil;
end;

function TImageFXOpenCV.IsGray: Boolean;
begin
  if Assigned(fOCVImage) then Result := fOCVImage^.nChannels = 1
    else Result := False;
end;

function TImageFXOpenCV.Clear(pcolor : TColor = clNone) : IImageFX;
begin
  Result := Self;
  cvRectangle(fOCVImage,cvPoint(0,0),cvPoint(fOCVImage^.width,fOCVImage^.height),ColorToScalar(pcolor),CV_FILLED);
  LastResult := arOk;
end;

function TImageFXOpenCV.ResizeImage(w, h : Integer; ResizeOptions : TResizeOptions) : IImageFX;
var
  ImgAux : pIplImage;
  srcRect,
  tgtRect : TRect;
  crop : Integer;
  srcRatio : Double;
  nw, nh : Integer;
  Resampler : Integer;
begin
  Result := Self;

  if (not Assigned(fOCVImage)) or ((fOCVImage.Width * fOCVImage.Height) = 0) then
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
      if (h = 0) and (fOCVImage.Height > fOCVImage.Width) then
      begin
        h := w;
        w := 0;
      end;
    end
    else ResizeOptions.ResizeMode := rmFitToBounds;
    begin
      if w > h then
      begin
        nh := (w * fOCVImage.Height) div fOCVImage.Width;
        h := nh;
      end
      else
      begin
        nw := (h * fOCVImage.Width) div fOCVImage.Height;
        w := nw;
      end;
    end;
  end;

  case ResizeOptions.ResizeMode of
    rmScale: //recalculate width or height target size to preserve original aspect ratio
      begin
        if fOCVImage.Width > fOCVImage.Height then
        begin
          nh := (w * fOCVImage.Height) div fOCVImage.Width;
          h := nh;
          nw := w;
        end
        else
        begin
          nw := (h * fOCVImage.Width) div fOCVImage.Height;
          w := nw;
          nh := h;
        end;
        srcRect := Rect(0,0,fOCVImage.Width,fOCVImage.Height);
      end;
    rmCropToFill: //preserve target aspect ratio cropping original image to fill whole size
      begin
        nw := w;
        nh := h;
        crop := Round(h / w * fOCVImage.Width);
        if crop < fOCVImage.Height then
        begin
          //target image is wider, so crop top and bottom
          srcRect.Left := 0;
          srcRect.Top := (fOCVImage.Height - crop) div 2;
          srcRect.Width := fOCVImage.Width;
          srcRect.Height := crop;
        end
        else
        begin
          //target image is narrower, so crop left and right
          crop := Round(w / h * fOCVImage.Height);
          srcRect.Left := (fOCVImage.Width - crop) div 2;
          srcRect.Top := 0;
          srcRect.Width := crop;
          srcRect.Height := fOCVImage.Height;
        end;
      end;
    rmFitToBounds: //resize image to fit max bounds of target size
      begin
        srcRatio := fOCVImage.Width / fOCVImage.Height;
        if fOCVImage.Width > fOCVImage.Height then
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
        srcRect := Rect(0,0,fOCVImage.Width,fOCVImage.Height);
      end;
    else
    begin
      nw := w;
      nh := h;
      srcRect := Rect(0,0,fOCVImage.Width,fOCVImage.Height);
    end;
  end;

  //if image is smaller no upsizes
  if ResizeOptions.NoMagnify then
  begin
    if (fOCVImage.Width < nw) or (fOCVImage.Height < nh) then
    begin
      //if FitToBounds then preserve original size
      if ResizeOptions.ResizeMode = rmFitToBounds then
      begin
        nw := fOCVImage.Width;
        nh := fOCVImage.Height;
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
        if (w < fOCVImage.Width ) or (h < fOCVImage.Height) then Resampler := CV_INTER_AREA
          else Resampler := CV_INTER_LINEAR;
      end;
    rsNearest : Resampler := CV_INTER_NN;
    rsOCVArea : Resampler := CV_INTER_AREA;
    rsLinear : Resampler := CV_INTER_LINEAR;
    rsOCVCubic : Resampler := CV_INTER_CUBIC;
    rsOCVLanczos4 : Resampler := CV_INTER_LANCZOS4;
    else Resampler := CV_INTER_LINEAR;
  end;

  ImgAux := cvCreateImage(CvSize(w,h),fOCVImage^.depth,fOCVImage^.nChannels);

  //fills outside zone borders with a color
  if (ResizeOptions.FillBorders) and ((tgtRect.Width < w) or (tgtRect.Height < h)) then
  begin
    cvRectangle(ImgAux,cvPoint(0,0),cvPoint(w,h),ColorToScalar(ResizeOptions.BorderColor),CV_FILLED);
  end;

  //set source and target regions
  cvSetImageROI(fOCVImage, CvRect(srcRect.Left,srcRect.Top,srcRect.Width,srcRect.Height));
  cvSetImageROI(ImgAux, CvRect(tgtRect.Left,tgtRect.Top,tgtRect.Width,tgtRect.Height));
  //resize
  try
    cvResize(fOCVImage,ImgAux,Resampler);
    cvResetImageROI(fOCVImage);
    cvResetImageROI(ImgAux);
    cvReleaseImage(fOCVImage);
    fOCVImage := ImgAux;
    LastResult := arOk;
  except
    LastResult := arCorruptedData;
    if ImgAux <> nil then cvReleaseImage(ImgAux);
  end;
end;

function TImageFXOpenCV.Resize(w, h : Integer) : IImageFX;
begin
  Result := ResizeImage(w,h,ResizeOptions);
end;

function TImageFXOpenCV.Resize(w, h : Integer; ResizeMode : TResizeMode; ResizeFlags : TResizeFlags = []; ResampleMode : TResamplerMode = rsLinear) : IImageFX;
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

procedure TImageFXOpenCV.Assign(Graphic : TGraphic);
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

function TImageFXOpenCV.DrawCentered(Graphic : TGraphic; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(Graphic,(fOCVImage.Width - Graphic.Width) div 2, (fOCVImage.Height - Graphic.Height) div 2,alpha);
end;

function TImageFXOpenCV.DrawCentered(stream: TStream; alpha : Double = 1) : IImageFX;
begin
  Result := Draw(stream,-1,-1,alpha);
end;

function TImageFXOpenCV.Draw(Graphic : TGraphic; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
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

function TImageFXOpenCV.Draw(stream: TStream; x: Integer; y: Integer; alpha: Double = 1) : IImageFX;
var
  overlay : pIplImage;
  mat : pCvMat;
  Buffer : TBytes;
  Size : Int64;
begin
  //get overlay image
  stream.Seek(0,soBeginning);
  Size := stream.Size;
  SetLength(Buffer, Size);
  stream.ReadBuffer(Pointer(Buffer)^,Size);
  mat := cvCreateMat(1,Size,CV_64F);
  try
    //fallo
    mat.data.ptr := PByte(Buffer);
    overlay := cvDecodeImage(mat,CV_LOAD_IMAGE_UNCHANGED);
  finally
    cvReleaseMat(mat);
  end;
  SetLength(Buffer,0);
  //needs x or y center image
  if x = -1 then x := (fOCVImage.Width - overlay.Width) div 2;
  if y = -1 then y := (fOCVImage.Height - overlay.Height) div 2;
  Result := Draw(overlay,x,y,alpha);
end;


function TImageFXOpenCV.Draw(overlay : pIplImage; x, y : Integer; alpha : Double = 1) : IImageFX;
var
  i, j, k: Integer;
  opacity: Double;
  overlayPx, srcPx: Byte;
  overlayRect : TCvRect;
  srcHasAlpha : Boolean;
begin
  Result := Self;
  //overlay := cvLoadImage('D:\logo2.png',CV_LOAD_IMAGE_UNCHANGED);
  try
    //if overlay is bigger than underlay, gets only part of the overlay
    if (overlay^.width > fOCVImage^.width) or (overlay^.height > fOCVImage^.height) then
    begin
      overlayRect := cvRect(0,0,fOCVImage^.width,fOCVImage^.height);
      if overlay^.width > fOCVImage^.width then
      begin
        x := 0;
        overlayRect := cvRect(0,0,fOCVImage^.width,overlayRect.height);
      end;
      if overlay^.height > fOCVImage^.height then
      begin
        y := 0;
        overlayRect := cvRect(0,0,overlayRect.width,fOCVImage^.height);
      end;
      cvSetImageROI(overlay,overlayRect);
    end;

    if fOCVImage^.nChannels > 3 then srcHasAlpha := True
      else srcHasAlpha := False;

    //overlay images
    for i := 0 to overlay^.width - 1 do
    begin
      for j := 0 to overlay^.height - 1 do
      begin
        for k := 0 to fOCVImage^.nChannels - 1 do
        begin
          opacity := (overlay^.imageData[j * overlay^.widthStep + i * overlay^.nChannels + 3]) / 255;
          opacity := opacity * alpha;

          overlayPx := overlay^.imageData[j * overlay^.widthStep + i * overlay^.nChannels + k];

          if srcHasAlpha then
          begin
            srcPx := fOCVImage^.imageData[(y + j) * fOCVImage^.widthStep + (i + x) * overlay^.nChannels + k];
            fOCVImage^.imageData[(j + y) * fOCVImage^.widthStep + (i + x) * overlay^.nChannels + k] := Trunc(srcPx * (1 - opacity) + overlayPx * opacity);
          end
          else if opacity > 0 then
          begin
            srcPx := fOCVImage^.imageData[(y + j) * fOCVImage^.widthStep + (i + x) * fOCVImage^.nChannels + k];
            fOCVImage^.imagedata[(j + y) * fOCVImage^.widthStep + (i + x) * fOCVImage^.nchannels + k] := Trunc(srcPx * (1 - opacity) + overlayPx * opacity);
          end;
        end;
        end;
    end;
  finally
    if overlay.roi <> nil then cvResetImageROI(overlay);
    cvReleaseImage(overlay);
  end;
end;

function TImageFXOpenCV.NewBitmap(w, h : Integer) : IImageFX;
begin
  NewBitmap(w,h,IPL_DEPTH_8U,4);
end;

function TImageFXOpenCV.NewBitmap(w, h: Integer; Depth : Integer; nChannels : Integer): IImageFX;
begin
  Result := Self;
  if fOCVImage <> nil then cvReleaseImage(fOCVImage);
  fOCVImage := cvCreateImage(CvSize(w,h),Depth,nChannels);
end;

function TImageFXOpenCV.Rotate90 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  Self.RotateBy(90);
  LastResult := arOk;
end;

function TImageFXOpenCV.Rotate180 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  cvFlip(fOCVImage,fOCVImage,-1);
  LastResult := arOk;
end;

function TImageFXOpenCV.Rotate270 : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  Self.RotateBy(270);
  LastResult := arOk;
end;

function TImageFXOpenCV.RotateBy(RoundAngle : Integer) : IImageFX;
var
  center : TCvPoint2D32f;
  mat : pCvMat;
  ImgAux : pIplImage;
  w : Single;
  h : Single;
  t : Single;
  newWidth : Integer;
  newHeight : Integer;
begin
  Result := Self;
  LastResult := arRotateError;

  w := fOCVImage^.width;
  h := fOCVImage^.height;
  t := (RoundAngle * -1) * Pi / 180;

  if RoundAngle > 90 then
  begin
    center.x := w / 2;
    center.y := center.x;
  end
  else
  begin
    center.x := h / 2;
    center.y := center.x;
  end;

  //calculate rotated bounding box
  newWidth := Round(sin(t) * h + cos(t) * w);
  newHeight := Round(sin(t) * w + cos(t) * h);
  if newWidth < 0 then newWidth := newWidth * -1;
  if newHeight < 0 then newHeight := newHeight * -1;

  ImgAux := cvCreateImage(CvSize(newWidth,newHeight),IPL_DEPTH_8U,fOCVImage^.nChannels);
  mat := cvCreateMat(2,3,CV_32FC1);
  try
    mat := cv2DRotationMatrix(center,RoundAngle * -1,1.0,mat);
    cvWarpAffine(fOCVImage,ImgAux,mat,CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS,cvScalarAll(0));

    cvReleaseImage(fOCVImage);
    fOCVImage := ImgAux;
  finally
    cvReleaseMat(mat);
  end;
  LastResult := arOk;
end;


function TImageFXOpenCV.RotateAngle(RotAngle: Single) : IImageFX;
var
  center : TCvPoint2D32f;
  ImgAux : pIplImage;
  mat : pCvMat;
  w : Integer;
  h : Integer;
  t : single;
  newWidth : Integer;
  newHeight : Integer;
begin
  Result := Self;
  w := fOCVImage^.width;
  h := fOCVImage^.height;
  t := RotAngle * Pi / 180;

  if RotAngle > 90 then
  begin
    center.x := w div 2;
    center.y := center.x;
  end
  else
  begin
    center.x := h div 2;
    center.y := center.x;
  end;

  //calculate rotated bounding box
  newWidth := Round(sin(t) * h + cos(t) * w);
  newHeight := Round(sin(t) * w + cos(t) * h);
  if newWidth < 0 then newWidth := newWidth * -1;
  if newHeight < 0 then newHeight := newHeight * -1;

  ImgAux := cvCreateImage(CvSize(newWidth,newHeight),IPL_DEPTH_8U,fOCVImage^.nChannels);
  mat := cvCreateMat(2,3,CV_32FC1);
  try
    LastResult := arRotateError;
    mat := cv2DRotationMatrix(center,RotAngle * -1, 1.0,mat);
    cvWarpAffine(fOCVImage,ImgAux,mat,CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS,cvScalarAll(0));
    cvReleaseImage(fOCVImage);
    fOCVImage := ImgAux;
  finally
    cvReleaseMat(mat);
  end;
  LastResult := arOk;
end;


function TImageFXOpenCV.FlipX : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  cvFlip(fOCVImage,fOCVImage,1);
  LastResult := arOk;
end;

function TImageFXOpenCV.FlipY : IImageFX;
begin
  Result := Self;
  LastResult := arRotateError;
  cvFlip(fOCVImage,fOCVImage,0);
  LastResult := arOk;
end;

function TImageFXOpenCV.GrayScale : IImageFX;
var
  ImgAux : pIplImage;
begin
  Result := Self;
  LastResult := arColorizeError;
  ImgAux := cvCreateImage(cvGetSize(fOCVImage), fOCVImage.depth, 1);
  //cvCvtColor(fOCVImage,ImgAux,CV_BGRA2GRAY);
  if fOCVImage.channelSeq = cmBGR then cvConvertImage(fOCVImage,ImgAux,CV_BGR2GRAY)
    else cvConvertImage(fOCVImage,ImgAux,CV_BGRA2GRAY);
  cvReleaseImage(fOCVImage);
  fOCVImage := ImgAux;
  LastResult := arOk;
end;

function TImageFXOpenCV.Lighten(StrenghtPercent : Integer = 30) : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;

  cvScaleAdd(fOCVImage,CvScalar(0.1, 0.1, 0.1),fOCVImage,fOCVImage);
  LastResult := arOk;
end;

function TImageFXOpenCV.Darken(StrenghtPercent : Integer = 30) : IImageFX;
begin
  Result := Self;
  LastResult := arColorizeError;

  cvScaleAdd(fOCVImage,CvScalar(-0.1, -0.1, -0.1),fOCVImage,fOCVImage);
  LastResult := arOk;
end;

function TImageFXOpenCV.Tint(mColor : TColor) : IImageFX;
var
  RGB : TRGB;
begin
  Result := Self;
  LastResult := arColorizeError;
  //cvScaleAdd(fOCVImage,CvScalar(0.1, 0.1, 0.1),fOCVImage,fOCVImage);
  RGB := ColorToRGBValues(mColor);
  if (RGB.R > RGB.G) and (RGB.R > RGB.B) then TintAdd(0,0,1)
  else if (RGB.G > RGB.R) and (RGB.G > RGB.B) then TintAdd(0,1,0)
    else TintAdd(1,0,0);

  LastResult := arOk;
end;

function TImageFXOpenCV.TintAdd(R, G , B : Integer) : IImageFX;
const
  alpha = 1;
var
  x, y : Integer;
  srcPix : TPixelInfo;
  srcHasAlpha : Boolean;
  RGB : TRGB;
begin
  Result := Self;
  LastResult := arColorizeError;
  if fOCVImage.nChannels > 3 then srcHasAlpha := True
    else srcHasAlpha := False;

  for y := 0 to fOCVImage^.height - 1 do
  begin
    for x := 0 to fOCVImage^.width - 1 do
    begin
      srcPix := Self.Pixel[x,y];
      srcPix.R := srcPix.R * R; //R
      srcPix.G := srcPix.G * G;; //G
      srcPix.B := srcPix.B * B;; //B
      if (not srcHasAlpha) or (srcPix.A > 0) then Self.Pixel[x,y] := srcPix;
    end;
  end;
  LastResult := arOk;
end;

function TImageFXOpenCV.TintBlue : IImageFX;
begin
  Result := Tint(clBlue);
end;

function TImageFXOpenCV.TintRed : IImageFX;
begin
  Result := Tint(clRed);
end;

function TImageFXOpenCV.TintGreen : IImageFX;
begin
  Result := Tint(clGreen);
end;

function TImageFXOpenCV.Solarize : IImageFX;
begin
  Result := TintAdd(255,-1,-1);
end;

function TImageFXOpenCV.ScanlineH;
begin
  Result := Self;
  DoScanLines(smHorizontal);
end;

function TImageFXOpenCV.ScanlineV;
begin
  Result := Self;
  DoScanLines(smVertical);
end;

procedure TImageFXOpenCV.DoScanLines(ScanLineMode : TScanlineMode);
var
  dolines : Boolean;
  row,col : Integer;
  pix : TPixelInfo;
begin
  LastResult := arColorizeError; dolines := False;
  if ScanlineMode = TScanlineMode.smHorizontal then
  begin
    for row := 0 to fOCVImage.height - 1 do
    begin
      dolines := not dolines;
      if dolines then
      for col := 0 to fOCVImage.width - 1 do
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
    for row := 0 to fOCVImage.height - 1 do
    begin
      for col := 0 to fOCVImage.width - 1 do
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

procedure TImageFXOpenCV.SaveToPNG(outfile : string);
begin
  LastResult := arConversionError;
  cvvSaveImage(AsPAnsiChar(outfile),fOCVImage);
  LastResult := arOk;
end;

procedure TImageFXOpenCV.SaveToJPG(outfile : string);
begin
  LastResult := arConversionError;
  cvSaveImage(AsPAnsiChar(outfile),fOCVImage);
  LastResult := arOk;
end;

procedure TImageFXOpenCV.SaveToBMP(outfile : string);
begin
  LastResult := arConversionError;
  cvSaveImage(AsPAnsiChar(outfile),fOCVImage);
  LastResult := arOk;
end;

procedure TImageFXOpenCV.SaveToGIF(outfile : string);
begin
  LastResult := arConversionError;
  cvSaveImage(AsPAnsiChar(outfile),fOCVImage);
  LastResult := arOk;
end;

function TImageFXOpenCV.AsBitmap : TBitmap;
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

function TImageFXOpenCV.AsPNG: TPngImage;
var
  ms : TMemoryStream;
begin
  LastResult := arConversionError;

  Result := TPngImage.CreateBlank(COLOR_RGBALPHA,16,fOCVImage.Width,fOCVImage.Height);
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

function TImageFXOpenCV.AsJPG : TJPEGImage;
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

function TImageFXOpenCV.AsGIF : TGifImage;
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

function TImageFXOpenCV.AsImage: pIplImage;
begin
  Result := fOCVImage;
end;

function TImageFXOpenCV.GetPixel(const x, y: Integer): TPixelInfo;
begin
  Result := GetPixelImage(x,y,fOCVImage);
end;

function TImageFXOpenCV.GetPixelImage(const x, y: Integer; image : pIplImage): TPixelInfo;
var
  ColorEncode : TocvColorEncode;
begin
  FillChar(Result, SizeOf(Result), 0);
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
  end;
end;

procedure TImageFXOpenCV.SetPixel(const x, y: Integer; const P: TPixelInfo);
begin
  SetPixelImage(x,y,P,fOCVImage);
end;

procedure TImageFXOpenCV.SetPixelImage(const x, y: Integer; const P: TPixelInfo; image : pIplImage);
var
  ColorEncode : TocvColorEncode;
begin
  if P.EncodeInfo <> 1 then
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
  end;
end;

function TImageFXOpenCV.AsString(imgFormat : TImageFormat = ifJPG) : string;
var
  ss : TStringStream;
  mat : pCvMat;
begin
  LastResult := arConversionError;
  ss := TStringStream.Create;
  try
    mat := cvEncodeImage(AsPAnsiChar(GetImageFmtExt(imgFormat)),fOCVImage,nil);
    try
      ss.Write(mat.data.ptr,mat.step * mat.rows);
    finally
      cvReleaseMat(mat);
    end;
    Result := Base64Encode(ss.DataString);
    LastResult := arOk;
  finally
    ss.Free;
  end;
end;

function TImageFXOpenCV.CloneImage : pIplImage;
begin
  Result := cvCloneImage(fOCVImage);
end;

function TImageFXOpenCV.Clone : IImageFX;
begin
  Result := TImageFXOpenCV.Create;
  (Result as TImageFXOpenCV).LoadFromImage(Self.CloneImage);
  CloneValues(Result);
end;


procedure TImageFXOpenCV.SaveToStream(stream : TStream; imgFormat : TImageFormat = ifJPG);
var
  mat : pCvMat;
  params : TOCVParam;
begin
  if stream.Position > 0 then stream.Seek(0,soBeginning);

  if imgFormat = ifJPG then params := [CV_IMWRITE_JPEG_QUALITY, JPGQualityPercent, 0]
    else if imgFormat = ifPNG then params := [CV_IMWRITE_PNG_COMPRESSION, PNGCompressionLevel, 0];
  mat := cvEncodeImage(AsPAnsiChar(GetImageFmtExt(imgFormat)),fOCVImage,@params[0]);
  try
    stream.WriteData(mat.data.ptr,mat.step * mat.rows);
    stream.Seek(soFromBeginning,0);
  finally
    cvReleaseMat(mat);
  end;
end;

procedure TImageFXOpenCV.SaveToStreamWithoutCompression(stream : TStream; imgFormat : TImageFormat = ifJPG);
var
  mat : pCvMat;
begin
  if stream.Position > 0 then stream.Seek(0,soBeginning);

  mat := cvEncodeImage(AsPAnsiChar(GetImageFmtExt(imgFormat)),fOCVImage,nil);
  try
    stream.WriteData(mat.data.ptr,mat.step * mat.rows);
    stream.Seek(soFromBeginning,0);
  finally
    cvReleaseMat(mat);
  end;
end;


class function TImageFXOpenCV.ColorToScalar(PColor : TColor = clWhite) : TCvScalar;
var
  BColor : TRGB;
begin
  BColor := ColorToRGBValues(PColor);
  Result := CvScalar(BColor.R,BColor.G,BColor.B);
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

function TImageFXOpenCV.AsPAnsiChar(const str : string) : PAnsiChar;
begin
  Result := c_str(str);
end;

function TImageFXOpenCV.Rounded(RoundLevel : Integer = 27) : IImageFX;
begin
  //not implemented
  Result := Self;
end;

function TImageFXOpenCV.AntiAliasing : IImageFX;
var
  bmp : TBitmap;
begin
  Result := Self;
  //not implemented
end;

function TImageFXOpenCV.SetAlpha(Alpha : Byte) : IImageFX;
begin
  Result := Self;
  //not implemented
end;

end.
