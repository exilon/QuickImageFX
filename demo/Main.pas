unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Mask,
  JvExMask,
  JvToolEdit,
  Vcl.Samples.Spin,
  Vcl.Buttons,
  PngSpeedButton,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Quick.Chrono,
  Quick.ImageFX,
  Quick.ImageFX.Types,
  Quick.ImageFX.GDI,
  Quick.ImageFX.GR32,
  Quick.ImageFX.OpenCV,
  Quick.ImageFX.Vampyre;

  //Needs Quick.Chrono from QuickLibs https://github.com/exilon/QuickLibs

type
  TMainForm = class(TForm)
    btnResize: TButton;
    Memo1: TMemo;
    Button2: TButton;
    btnConvertTo: TButton;
    cbFormat: TComboBox;
    edFilename: TJvFilenameEdit;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    imgSource: TImage;
    imgTarget: TImage;
    btnRotate: TButton;
    Label1: TLabel;
    Label2: TLabel;
    spedX: TSpinEdit;
    spedY: TSpinEdit;
    Label3: TLabel;
    Button3: TButton;
    PngSpeedButton1: TPngSpeedButton;
    btnGrayScale: TButton;
    btnReloadImage: TButton;
    cxNoMagnify: TCheckBox;
    ImageList1: TImageList;
    spedImageIndex: TSpinEdit;
    btnGetImageFromList: TButton;
    Label4: TLabel;
    lblResolution: TLabel;
    btnRounded: TButton;
    spedRounded: TSpinEdit;
    btnScanlineH: TButton;
    btnScanlineV: TButton;
    btnDarken: TButton;
    btnLighten: TButton;
    btnAntiAliasing: TButton;
    btnAlpha: TButton;
    spedAlpha: TSpinEdit;
    PaintBox: TPaintBox;
    btnClear: TButton;
    btnSaveAsString: TButton;
    btnLoadFromString: TButton;
    btnTintRed: TButton;
    btnTintGreen: TButton;
    btnTintBlue: TButton;
    btnSolarize: TButton;
    btnTintAdd: TButton;
    btnRotateAngle: TButton;
    spedRotateAngle: TSpinEdit;
    btnClearTarget: TButton;
    btnLoadFromHTTP: TButton;
    lblNewAspectRatio: TLabel;
    btnWatermark: TButton;
    cxCenter: TCheckBox;
    cxFillBorders: TCheckBox;
    cbResizeMode: TComboBox;
    btnLoadFromStream: TButton;
    btnSaveAsStream: TButton;
    btnCheckJPGCorruption: TButton;
    btnGetExternalIcon: TButton;
    btnRandomGenerator: TButton;
    Button6: TButton;
    cbImageLIb: TComboBox;
    procedure btnResizeClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConvertToClick(Sender: TObject);
    procedure edFilenameChange(Sender: TObject);
    procedure btnRotateClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure PngSpeedButton1Click(Sender: TObject);
    procedure btnGrayScaleClick(Sender: TObject);
    procedure PaintImageTarget;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LoadImagen;
    procedure btnReloadImageClick(Sender: TObject);
    procedure btnGetImageFromListClick(Sender: TObject);
    procedure btnRoundedClick(Sender: TObject);
    procedure btnScanlineHClick(Sender: TObject);
    procedure btnScanlineVClick(Sender: TObject);
    procedure btnDarkenClick(Sender: TObject);
    procedure btnLightenClick(Sender: TObject);
    procedure btnAntiAliasingClick(Sender: TObject);
    procedure btnAlphaClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnLoadFromStringClick(Sender: TObject);
    function RandomImageGenerator(w,h : Integer): Boolean;
    procedure btnSaveAsStringClick(Sender: TObject);
    procedure btnTintRedClick(Sender: TObject);
    procedure btnTintGreenClick(Sender: TObject);
    procedure btnTintBlueClick(Sender: TObject);
    procedure btnSolarizeClick(Sender: TObject);
    procedure btnTintAddClick(Sender: TObject);
    procedure btnRotateAngleClick(Sender: TObject);
    procedure btnClearTargetClick(Sender: TObject);
    procedure btnLoadFromHTTPClick(Sender: TObject);
    procedure spedXChange(Sender: TObject);
    procedure btnWatermarkClick(Sender: TObject);
    procedure btnLoadFromStreamClick(Sender: TObject);
    procedure btnSaveAsStreamClick(Sender: TObject);
    procedure btnCheckJPGCorruptionClick(Sender: TObject);
    procedure btnGetExternalIconClick(Sender: TObject);
    procedure btnRandomGeneratorClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure cbImageLIbChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  crono : TChronometer;
  imagefx : IImageFX;
  PicStr : string;

implementation

{$R *.dfm}

procedure TMainForm.btnAlphaClick(Sender: TObject);
begin
  crono.Start;
  //imagefx.SetAlpha(spedAlpha.Value);
  crono.Stop;
  Memo1.Lines.Add('Alpha: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnAntiAliasingClick(Sender: TObject);
begin
  crono.Start;
  //imagefx.AntiAliasing;
  crono.Stop;
  Memo1.Lines.Add('AntiAliasing: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
  PaintBox.Canvas.Brush.Color := clSilver;
  PaintBox.Canvas.FillRect(PaintBox.BoundsRect);
  PaintBox.Repaint;
end;

procedure TMainForm.btnClearTargetClick(Sender: TObject);
begin
  imagefx.Clear;
  PaintImageTarget;
end;

procedure TMainForm.btnConvertToClick(Sender: TObject);
var
  bmp : TBitmap;
  jpg : TJPEGImage;
  png : TPngImage;
begin
  crono.Start;
  imagefx.LoadFromFile(edFilename.FileName);
  case cbFormat.ItemIndex of
    0 : begin
          bmp := imagefx.AsBitmap;
          try
            bmp.SaveToFile('.\newbmp.bmp');
            imgTarget.Picture.Assign(bmp);
          finally
            bmp.Free;
          end;
        end;
    1 : begin
          jpg := imagefx.AsJPG;
          try
            jpg.SaveToFile('.\newjpg.jpg');
            imgTarget.Picture.Assign(jpg);
          finally
            jpg.Free;
          end;
        end;
    2 : begin
          png := imagefx.AsPNG;
          try
            png.SaveToFile('.\newpng.png');
            imgTarget.Picture.Assign(png);
          finally
            png.Free;
          end;
        end;
    3 : imgTarget.Picture.Assign(imagefx.AsGIF);
  end;
  crono.Stop;
  Memo1.Lines.Add('Convert: ' + crono.ElapsedTime);
end;

procedure TMainForm.btnDarkenClick(Sender: TObject);
begin
  crono.Start;
  imagefx.Darken;
  crono.Stop;
  Memo1.Lines.Add('Darken: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnGetImageFromListClick(Sender: TObject);
var
  png : TPngImage;
begin
  crono.Start;
  imagefx.LoadFromImageList(ImageList1,spedImageIndex.Value);
  crono.Stop;
  Memo1.Lines.Add('GetFromImageList: ' + crono.ElapsedTime);
  png := imagefx.Resize(64,64,rmFitToBounds,[rfNoMagnify]).AsPNG;
  try
    PngSpeedButton1.PngImage.Assign(png);
  finally
    png.Free;
  end;
  PngSpeedButton1.Refresh;
end;

procedure TMainForm.btnGrayScaleClick(Sender: TObject);
begin
   crono.Start;
   imagefx.GrayScale;
   crono.Stop;
   Memo1.Lines.Add('GrayScale: ' + crono.ElapsedTime);
   PaintImageTarget;
end;

procedure TMainForm.btnLightenClick(Sender: TObject);
begin
  crono.Start;
  imagefx.Lighten;
  crono.Stop;
  Memo1.Lines.Add('Lighten: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnLoadFromHTTPClick(Sender: TObject);
var
  statuscode : Integer;
begin
  crono.Start;
  imagefx.LoadFromHTTP('https://cdn.pixabay.com/photo/2015/02/01/22/16/parrot-620345_960_720.jpg',statuscode,True);
  crono.Stop;
  Memo1.Lines.Add('LoadFromHTTP: ' + crono.ElapsedTime);
  PaintImageTarget;
end;


procedure TMainForm.btnLoadFromStreamClick(Sender: TObject);
var
  fs : TFileStream;
begin
  fs := TFileStream.Create('..\..\img\Portrait.jpg',fmOpenRead);
  try
    crono.Start;
    imagefx.LoadFromStream(fs);
  finally
    fs.Free;
  end;
  crono.Stop;
  Memo1.Lines.Add('LoadFromStream: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnLoadFromStringClick(Sender: TObject);
begin
  crono.Start;
  imagefx.LoadFromString(PicStr);
  crono.Stop;
  Memo1.Lines.Add('LoadFromString: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnReloadImageClick(Sender: TObject);
begin
  LoadImagen;
end;

procedure TMainForm.LoadImagen;
begin
  if FileExists(edFilename.FileName) then
  begin
    imgSource.Picture.LoadFromFile(edFilename.FileName);
    //imagefx.AsBitmap.Assign(imgSource.Picture.Bitmap);
    crono.Start;
    imagefx.LoadFromFile(edFilename.FileName);
    crono.Stop;
    Memo1.Lines.Add('Load Image: ' + crono.ElapsedTime);
    lblResolution.Caption := imagefx.GetResolution + ' ' + imagefx.AspectRatioStr;
  end;
  imgTarget.Picture.Bitmap.PixelFormat := pf32bit;
  imgTarget.Picture.Bitmap.AlphaFormat := afDefined;
end;

procedure TMainForm.btnRotateAngleClick(Sender: TObject);
begin
  crono.Start;
  imagefx.RotateBy(spedRotateAngle.Value);
  crono.Stop;
  Memo1.Lines.Add('Rotate Angle: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnRotateClick(Sender: TObject);
begin
  crono.Start;
  imagefx.Rotate90;
  crono.Stop;
  Memo1.Lines.Add('Rotate: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnRoundedClick(Sender: TObject);
begin
  crono.Start;
  imagefx.Rounded(spedRounded.Value);
  crono.Stop;
  Memo1.Lines.Add('Rounded: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnSaveAsStreamClick(Sender: TObject);
var
  ms : TMemoryStream;
begin
  crono.Start;
  imagefx.LoadFromFile('..\..\img\guacamayo.png');
  ms := TMemoryStream.Create;
  try
    imagefx.SaveToStream(ms,ifPNG);
    imagefx.LoadFromStream(ms);
  finally
    ms.Free;
  end;
  crono.Stop;
  Memo1.Lines.Add('SaveAsStream: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnSaveAsStringClick(Sender: TObject);
begin
  crono.Start;
  PicStr := imagefx.AsString(ifPNG);
  crono.Stop;
  Memo1.Lines.Add('SaveAsString: ' + crono.ElapsedTime);
end;

procedure TMainForm.btnScanlineHClick(Sender: TObject);
begin
  crono.Start;
  imagefx.ScanlineH;
  crono.Stop;
  Memo1.Lines.Add('Scanline Horizontal: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnScanlineVClick(Sender: TObject);
begin
  crono.Start;
  imagefx.ScanlineV;
  crono.Stop;
  Memo1.Lines.Add('Scanline Vertical: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnSolarizeClick(Sender: TObject);
begin
  crono.Start;
  imagefx.Solarize;
  crono.Stop;
  Memo1.Lines.Add('Solarize: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnTintAddClick(Sender: TObject);
begin
  crono.Start;
  imagefx.TintAdd(-1,-1,255);
  crono.Stop;
  Memo1.Lines.Add('Tint Add: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnTintBlueClick(Sender: TObject);
begin
  crono.Start;
  imagefx.TintBlue;
  crono.Stop;
  Memo1.Lines.Add('Tint Blue: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnTintGreenClick(Sender: TObject);
begin
  crono.Start;
  imagefx.TintGreen;
  crono.Stop;
  Memo1.Lines.Add('Tint Green: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnTintRedClick(Sender: TObject);
begin
  crono.Start;
  imagefx.TintRed;
  crono.Stop;
  Memo1.Lines.Add('Tint Red: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnWatermarkClick(Sender: TObject);
var
  png : TPngImage;
begin
  png := TPngImage.Create;
  try
    png.LoadFromFile('..\..\img\watermark.png');
    crono.Start;
    imagefx.DrawCentered(png,0.5);
  finally
    png.Free;
  end;
  crono.Stop;
  Memo1.Lines.Add('Watermark: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

function TMainForm.RandomImageGenerator(w,h : Integer): Boolean;
var
  x, y : Integer;
  Pixel : TPixelInfo;
begin
  Result := False;
  Randomize;
  imagefx.NewBitmap(w,h);
  for y := 0 to h - 1 do
  begin
    for x := 0 to w - 1 do
    begin
      //Pixel := imageFX.Pixel[x,y];
      Pixel.R := Random(255); //R
      Pixel.G := Random(255); //G
      Pixel.B := Random(255); //B
      Pixel.A := 255; //A
     //repair imageFX.Pixel[x,y] := Pixel;
      //imagefx.SetPixelImage(x,y,Pixel,imagefx.AsImage);
    end;
  end;
  //imagefx.SaveToJPG('D:\random.jpg');
end;


procedure TMainForm.btnResizeClick(Sender: TObject);
var
  rsop : string;
begin
  rsop := cbResizeMode.Text;
  if cxNoMagnify.Checked then rsop := rsop + ',NoMagnify';
  if cxCenter.Checked then rsop := rsop + ',Center';
  if cxFillBorders.Checked then rsop := rsop + ',FillBorders';

  //if cxCenter.Checked then rsop := rsop + 'Center';

  crono.Start;
  imagefx.ResizeOptions.NoMagnify := cxNoMagnify.Checked;
  imagefx.ResizeOptions.ResizeMode := TResizeMode(cbResizeMode.ItemIndex);
  imagefx.ResizeOptions.Center := cxCenter.Checked;
  imagefx.ResizeOptions.FillBorders := cxFillBorders.Checked;
  if cxFillBorders.Checked then imagefx.ResizeOptions.BorderColor := clWhite;
  imagefx.Resize(spedX.Value,spedY.Value);
  crono.Stop;
  Memo1.Lines.Add(Format('Resize [%s]: %s',[rsop,crono.ElapsedTime]));
  PaintImageTarget;
end;

procedure TMainForm.btnCheckJPGCorruptionClick(Sender: TObject);
var
  jpg : TJPEGImage;
begin
  jpg := TJPEGImage.Create;
  try
    jpg.LoadFromFile('..\..\img\corruptedjpg.jpg');
    if imagefx.JPEGCorruptionCheck(jpg) then ShowMessage('Corrupto')
      else ShowMessage('OK');
  finally
    jpg.Free;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  crono.Start;
  if not FileExists('c:\windows\explorer.exe') then
  begin
    ShowMessage('Icon file not found');
    Exit;
  end;

  imagefx.LoadFromFileIcon('c:\windows\explorer.exe',0);
  crono.Stop;
  Memo1.Lines.Add('ExtractIcon: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
   crono.Start;
   with imagefx do
   begin
    case cbFormat.ItemIndex of
      0 : SaveToBMP('.\output.bmp');
      1 : SaveToJPG('.\output.jpg');
      2 : SaveToPNG('.\output.png');
      3 : SaveToGIF('.\output.gif');
    end;
   end;
   crono.Stop;
   Memo1.Lines.Add('SaveFile: ' + crono.ElapsedTime);
end;

procedure TMainForm.btnGetExternalIconClick(Sender: TObject);
begin
  crono.Start;
  imagefx.LoadFromFileExtension('c:\windows\explorer.exe',True);
  crono.Stop;
  Memo1.Lines.Add('GetExtIcon: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.btnRandomGeneratorClick(Sender: TObject);
begin
  crono.Start;
  RandomImageGenerator(1920,1080);
  crono.Stop;
  Memo1.Lines.Add('RandomGenerator: ' + crono.ElapsedTime);
  PaintImageTarget;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  PaintImageTarget;
end;

procedure TMainForm.cbImageLIbChange(Sender: TObject);
begin
  case cbImageLIb.ItemIndex of
   0 : imagefx := TImageFXGDI.Create;
   1 : imagefx := TImageFXGR32.Create;
   2 : imagefx := TImageFXOpenCV.Create;
   3 : imagefx := TImageFXVampyre.Create;
  end;
  LoadImagen;
end;

procedure TMainForm.PaintImageTarget;
var
  bmp : TBitmap;
begin
  bmp := imagefx.AsBitmap;
  try
    imgTarget.Picture.Assign(bmp);
    PaintBox.Canvas.Draw(0,0,bmp);
  finally
    bmp.Free;
  end;
  lblResolution.Caption := imagefx.GetResolution + ' ' + imagefx.AspectRatioStr;
end;

procedure TMainForm.edFilenameChange(Sender: TObject);
begin
  LoadImagen;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  crono.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  crono := TChronometer.Create(False);
  crono.ReportFormatPrecission := TPrecissionFormat.pfFloat;
  imagefx := TImageFXOpenCV.Create;
  LoadImagen;
end;

procedure TMainForm.PngSpeedButton1Click(Sender: TObject);
var
  png : TPngImage;
begin
  crono.Start;
  imagefx.LoadFromFile(edFilename.FileName);
  png := imagefx.Resize(64,64,rmFitToBounds,[rfNoMagnify]).AsPNG;
  try
    PngSpeedButton1.PngImage.Assign(png);
    crono.Stop;
  finally
    png.Free;
  end;
  Memo1.Lines.Add('LoadPNGButton: ' + crono.ElapsedTime);
end;

procedure TMainForm.spedXChange(Sender: TObject);
begin
  if (spedY.Value = 0) or (spedX.Value = 0) then Exit;

  lblNewAspectRatio.Caption := TImageFX.GetAspectRatio(spedX.Value,spedY.Value);
end;

end.
