unit Quick.Image.Engine.Vips;

interface

uses
  Classes,
  System.SysUtils,
  System.UITypes;

type

  TColor = System.UITypes.TColor;

  TColorRec = System.UITypes.TColorRec;

  TVipsImageFormat = (ifBMP, ifJPEG, ifPNG, ifGIF, ifTIFF, ifJP2K, ifWEBP, ifHEIF, ifAVIF, ifJXL);

  TVipsForeignTiffCompression = (
    VIPS_FOREIGN_TIFF_COMPRESSION_NONE,     // No compression
    VIPS_FOREIGN_TIFF_COMPRESSION_JPEG,    // JPEG compression
    VIPS_FOREIGN_TIFF_COMPRESSION_DEFLATE, // Deflate (zip) compression
    VIPS_FOREIGN_TIFF_COMPRESSION_PACKBITS, // Packbits compression
    VIPS_FOREIGN_TIFF_COMPRESSION_CCITTFAX4, // Fax4 compression
    VIPS_FOREIGN_TIFF_COMPRESSION_LZW,     // LZW compression
    VIPS_FOREIGN_TIFF_COMPRESSION_WEBP,    // WEBP compression
    VIPS_FOREIGN_TIFF_COMPRESSION_ZSTD,    // ZSTD compression
    VIPS_FOREIGN_TIFF_COMPRESSION_JP2K,    // JP2K compression
    VIPS_FOREIGN_TIFF_COMPRESSION_LAST     // Último valor de la enumeración
  );

  TVipsForeignTiffPredictor = (
    VIPS_FOREIGN_TIFF_PREDICTOR_NONE = 1,         // Without prediction
    VIPS_FOREIGN_TIFF_PREDICTOR_HORIZONTAL = 2,   // Horizontal differencing
    VIPS_FOREIGN_TIFF_PREDICTOR_FLOAT = 3,       // Floating point predictor
    VIPS_FOREIGN_TIFF_PREDICTOR_LAST          // Last enumeration value
  );

  TVipsForeignTiffResunit = (
    VIPS_FOREIGN_TIFF_RESUNIT_CM,    // Use centimeters
    VIPS_FOREIGN_TIFF_RESUNIT_INCH,  // Use inches
    VIPS_FOREIGN_TIFF_RESUNIT_LAST    // Last enumeration value
  );

  TVipsRegionShrink = (
    VIPS_REGION_SHRINK_MEAN,     // Use the average
    VIPS_REGION_SHRINK_MEDIAN,   // Use the median
    VIPS_REGION_SHRINK_MODE,     // Use the mode
    VIPS_REGION_SHRINK_MAX,      // Use the maximum
    VIPS_REGION_SHRINK_MIN,      // Use the minimum
    VIPS_REGION_SHRINK_NEAREST,  // Use the top-left pixel
    VIPS_REGION_SHRINK_LAST      // Last enumeration value
  );

  TVipsForeignDzDepth = (
    VIPS_FOREIGN_DZ_DEPTH_ONEPIXEL,  // Create layers down to 1x1 pixel
    VIPS_FOREIGN_DZ_DEPTH_ONETILE,   // Create layers down to 1x1 tile
    VIPS_FOREIGN_DZ_DEPTH_ONE,       // Only create a single layer
    VIPS_FOREIGN_DZ_DEPTH_LAST       // Last enumeration value
  );

  TVipsForeignPngFilter = (
    VIPS_FOREIGN_PNG_FILTER_NONE = $08, //no filtering
    VIPS_FOREIGN_PNG_FILTER_SUB = $10, //difference to the left
    VIPS_FOREIGN_PNG_FILTER_UP = $20, //difference up
    VIPS_FOREIGN_PNG_FILTER_AVG = $40, //average of left and up
    VIPS_FOREIGN_PNG_FILTER_PAETH = $80, //pick best neighbor predictor automatically
    VIPS_FOREIGN_PNG_FILTER_ALL = $F8 //adaptive
  );

  TVipsForeignWebpPreset = (
    VIPS_FOREIGN_WEBP_PRESET_DEFAULT, //default preset
    VIPS_FOREIGN_WEBP_PRESET_PICTURE, //digital picture, like portrait, inner shot
    VIPS_FOREIGN_WEBP_PRESET_PHOTO, //outdoor photograph, with natural lighting
    VIPS_FOREIGN_WEBP_PRESET_DRAWING, //hand or line drawing, with high-contrast details
    VIPS_FOREIGN_WEBP_PRESET_ICON, //small-sized colorful images
    VIPS_FOREIGN_WEBP_PRESET_TEXT, //text-like
    VIPS_FOREIGN_WEBP_PRESET_LAST
  );

  TVipsForeignHeifCompression = (
    VIPS_FOREIGN_HEIF_COMPRESSION_HEVC = 1, //x265
    VIPS_FOREIGN_HEIF_COMPRESSION_AVC = 2, //x264
    VIPS_FOREIGN_HEIF_COMPRESSION_JPEG = 3, //jpeg
    VIPS_FOREIGN_HEIF_COMPRESSION_AV1 = 4, //aom
    VIPS_FOREIGN_HEIF_COMPRESSION_LAST
  );

  TVipsForeignHeifEncoder = (
    VIPS_FOREIGN_HEIF_ENCODER_AUTO, //auto
    VIPS_FOREIGN_HEIF_ENCODER_AOM, //aom
    VIPS_FOREIGN_HEIF_ENCODER_RAV1E, //RAV1E
    VIPS_FOREIGN_HEIF_ENCODER_SVT, //SVT-AV1
    VIPS_FOREIGN_HEIF_ENCODER_X265, //x265
    VIPS_FOREIGN_HEIF_ENCODER_LAST
  );

  TVipsForeignSubsample = (
    VIPS_FOREIGN_SUBSAMPLE_AUTO, //prevent subsampling when quality >= 90
    VIPS_FOREIGN_SUBSAMPLE_ON, //always perform subsampling
    VIPS_FOREIGN_SUBSAMPLE_OFF, //never perform subsampling
    VIPS_FOREIGN_SUBSAMPLE_LAST
  );

  TVipsDirection = (
    VIPS_DIRECTION_HORIZONTAL,  // Left-right
    VIPS_DIRECTION_VERTICAL,    // Top-bottom
    VIPS_DIRECTION_LAST         // Last enumeration value
  );

  TVipsAngle = (
    VIPS_ANGLE_D0,    // No rotate
    VIPS_ANGLE_D90,   // 90 degrees clockwise
    VIPS_ANGLE_D180,  // 180-degree rotate
    VIPS_ANGLE_D270,  // 90 degrees anti-clockwise
    VIPS_ANGLE_LAST    // Last enumeration value
  );

  TVipsKernel = (
    VIPS_KERNEL_NEAREST,    // Nearest pixel to the point
    VIPS_KERNEL_LINEAR,     // Convolve with a triangle filter
    VIPS_KERNEL_CUBIC,      // Convolve with a cubic filter
    VIPS_KERNEL_MITCHELL,   // Convolve with a Mitchell kernel
    VIPS_KERNEL_LANCZOS2,   // Convolve with a two-lobe Lanczos kernel
    VIPS_KERNEL_LANCZOS3,   // Convolve with a three-lobe Lanczos kernel
    VIPS_KERNEL_LAST        // Last enumeration value
  );

  TVipsExtend = (
    VIPS_EXTEND_BLACK,        // New pixels are black, i.e., all bits are zero.
    VIPS_EXTEND_COPY,         // Each new pixel takes the value of the nearest edge pixel.
    VIPS_EXTEND_REPEAT,       // The image is tiled to fill the new area.
    VIPS_EXTEND_MIRROR,       // The image is reflected and tiled to reduce hash edges.
    VIPS_EXTEND_WHITE,        // New pixels are white, i.e., all bits are set.
    VIPS_EXTEND_BACKGROUND    // Color set from the background property.
  );

  TVipsCombineMode = (
    VIPS_COMBINE_MODE_SET,   // Set pixels to the new value.
    VIPS_COMBINE_MODE_ADD,   // Add pixels.
    VIPS_COMBINE_MODE_LAST   // Last member (for iteration or indicating the end).
  );

  TVipsBlendMode = (
    VIPS_BLEND_MODE_CLEAR,        // Where the second object is drawn, the first is removed.
    VIPS_BLEND_MODE_SOURCE,       // The second object is drawn as if nothing were below.
    VIPS_BLEND_MODE_OVER,         // The image shows what you would expect if you held two semi-transparent slides on top of each other.
    VIPS_BLEND_MODE_IN,           // The first object is removed completely, the second is only drawn where the first was.
    VIPS_BLEND_MODE_OUT,          // The second is drawn only where the first isn't.
    VIPS_BLEND_MODE_ATOP,         // This leaves the first object mostly intact but mixes both objects in the overlapping area.
    VIPS_BLEND_MODE_DEST,         // Leaves the first object untouched, the second is discarded completely.
    VIPS_BLEND_MODE_DEST_OVER,    // Like OVER, but swaps the arguments.
    VIPS_BLEND_MODE_DEST_IN,      // Like IN, but swaps the arguments.
    VIPS_BLEND_MODE_DEST_OUT,     // Like OUT, but swaps the arguments.
    VIPS_BLEND_MODE_DEST_ATOP,    // Like ATOP, but swaps the arguments.
    VIPS_BLEND_MODE_XOR,          // Something like a difference operator.
    VIPS_BLEND_MODE_ADD,          // A bit like adding the two images.
    VIPS_BLEND_MODE_SATURATE,     // A bit like the darker of the two.
    VIPS_BLEND_MODE_MULTIPLY,     // At least as dark as the darker of the two inputs.
    VIPS_BLEND_MODE_SCREEN,       // At least as light as the lighter of the inputs.
    VIPS_BLEND_MODE_OVERLAY,      // Multiplies or screens colors, depending on the lightness.
    VIPS_BLEND_MODE_DARKEN,       // The darker of each component.
    VIPS_BLEND_MODE_LIGHTEN,      // The lighter of each component.
    VIPS_BLEND_MODE_COLOUR_DODGE, // Brighten first by a factor second.
    VIPS_BLEND_MODE_COLOUR_BURN,  // Darken first by a factor of second.
    VIPS_BLEND_MODE_HARD_LIGHT,   // Multiply or screen, depending on lightness.
    VIPS_BLEND_MODE_SOFT_LIGHT,   // Darken or lighten, depending on lightness.
    VIPS_BLEND_MODE_DIFFERENCE,   // Difference of the two.
    VIPS_BLEND_MODE_EXCLUSION,    // Somewhat like DIFFERENCE but lower-contrast.
    VIPS_BLEND_MODE_LAST
  );

   TVipsInterpretation = (
    VIPS_INTERPRETATION_ERROR,      // Error condition
    VIPS_INTERPRETATION_MULTIBAND,  // Generic many-band image
    VIPS_INTERPRETATION_B_W,        // Some kind of single-band image
    VIPS_INTERPRETATION_HISTOGRAM,  // A 1D image, e.g., histogram or lookup table
    VIPS_INTERPRETATION_XYZ,        // The first three bands are CIE XYZ
    VIPS_INTERPRETATION_LAB,        // Pixels are in CIE Lab space
    VIPS_INTERPRETATION_CMYK,       // The first four bands are in CMYK space
    VIPS_INTERPRETATION_LABQ,       // Implies VIPS_CODING_LABQ
    VIPS_INTERPRETATION_RGB,        // Generic RGB space
    VIPS_INTERPRETATION_CMC,        // A uniform colorspace based on CMC(1:1)
    VIPS_INTERPRETATION_LCH,        // Pixels are in CIE LCh space
    VIPS_INTERPRETATION_LABS,       // CIE LAB coded as three signed 16-bit values
    VIPS_INTERPRETATION_sRGB,       // Pixels are sRGB
    VIPS_INTERPRETATION_YXY,        // Pixels are CIE Yxy
    VIPS_INTERPRETATION_FOURIER,    // Image is in Fourier space
    VIPS_INTERPRETATION_RGB16,      // Generic 16-bit RGB
    VIPS_INTERPRETATION_GREY16,     // Generic 16-bit mono
    VIPS_INTERPRETATION_MATRIX,     // A matrix
    VIPS_INTERPRETATION_scRGB,      // Pixels are scRGB
    VIPS_INTERPRETATION_HSV,        // Pixels are HSV
    VIPS_INTERPRETATION_LAST        // End marker
  );

  TVipsArrayDouble = TArray<Double>;

  TRGB = record
    R : Byte;
    G : Byte;
    B : Byte;
  end;

  pVipsImage = Pointer;

  TVipsImage = class
    private
      fVipsImage : pVipsImage;
      fAutorotate : Boolean;
      fInternalBuffer : Pointer;
      function GetWidth : Integer;
      function GetHeight : Integer;
      procedure FreePreviousImage;
      procedure AllocateInternalBuffer(aSize : Cardinal);
      class function ColorToRGBValues(PColor: TColor): TRGB;
      class function ColorToVipsColor(PColor: TColor): TVipsArrayDouble;
    public
      property Width : Integer read GetWidth;
      property Height : Integer read GetHeight;
      property AutoRotate : Boolean read fAutoRotate write fAutoRotate;
      class constructor Create;
      class destructor Destroy;
      constructor Create; overload;
      constructor Create(aWidth, aHeight : Integer); overload;
      constructor CreateEmpty;
      constructor CreateFromVipsImage(aVipsImage : TVipsImage);
      constructor CreateFromFile(const aFilename : string);
      destructor Destroy; override;
      function GetVipsImage : pVipsImage;
      procedure LoadFromFile(const aFilename : string);
      procedure LoadFromStream(aStream : TStream);
      procedure SaveToFile(const aFileName: string; aImageFormat: TVipsImageFormat; aQuality : Integer = 75);
      procedure SaveToStream(aStream: TStream; aImageFormat: TVipsImageFormat; aQuality : Integer = 75);
      function GetBandsCount : Integer;
      procedure Resize(aNewWidth, aNewHeight: Integer; aVipsKernel : TVipsKernel = TVipsKernel.VIPS_KERNEL_LINEAR; aGap : Double = 2.0);
      procedure Flip(aDirection : TVipsDirection);
      procedure Rotate(aAngle : TVipsAngle);
      procedure CanvasResize(aNewWidth, aNewHeight : Integer; aExtendBackground : TVipsExtend);
      procedure CombineImage(aImage: TVipsImage; aLeft, aTop: Integer; aCombineMode : TVipsCombineMode);
      procedure DrawRect(aLeft, aTop, aWidth, aHeight : Integer; aColor : TColor);
      procedure Crop(aLeft, aTop, aWidth, aHeight : Integer);
      procedure MergeImage(aImage: TVipsImage; aDirection: TVipsDirection);
      procedure RotateByExif;
      procedure DrawImage(aOverlay: TVipsImage; aLeft, aTop : Integer; mode: TVipsBlendMode);
      procedure FillRect(aLeft, aTop, aWidth, aHeight : Integer; aColor : TColor);
      procedure Linear(aMultiply : Double; aAdd : Double);
      procedure Clear(aColor : TColor);
      procedure GrayScale;
      procedure ColourSpace(aColourSpace : TVipsInterpretation);
      function Clone : TVipsImage;
  end;

  function vips_init(argv0: PAnsiChar): Integer; cdecl; external 'libvips-42.dll';
  procedure vips_shutdown; cdecl; external 'libvips-42.dll';
  procedure vips_leak_set(aLeak : Boolean); cdecl; external 'libvips-42.dll';
  procedure vips_operation_block_set(setname : PAnsichar; aEnable : Boolean);cdecl; external 'libvips-42.dll';
  procedure vips_block_untrusted_set(aEnable : Boolean);cdecl; external 'libvips-42.dll';
  function vips_tracked_get_mem : Integer;cdecl; external 'libvips-42.dll';
  function vips_image_new : pVipsImage; cdecl; external 'libvips-42.dll';
  function vips_image_new_memory : pVipsImage; cdecl; external 'libvips-42.dll';
  function vips_image_new_matrix(aWidth, Height : Integer) : pVipsImage; cdecl; external 'libvips-42.dll';
  function vips_image_get_width(const inImage : pVipsImage) : Integer; cdecl; external 'libvips-42.dll';
  function vips_image_get_height(const inImage : pVipsImage) : Integer; cdecl; external 'libvips-42.dll';
  function vips_image_get_bands (const inImage : pVipsImage) : Integer; cdecl; external 'libvips-42.dll';
  function vips_image_new_from_buffer(buffer : Pointer; len : Cardinal; formatOptions : PAnsiChar; args : Pointer) : pVipsImage; cdecl; varargs; external 'libvips-42.dll';
  function vips_image_new_from_memory(buffer : Pointer; len : Cardinal; args : Pointer) : pVipsImage; cdecl; varargs; external 'libvips-42.dll';
  function vips_image_new_from_file(filename: PAnsiChar; args : Pointer): pVipsImage; cdecl; varargs; external 'libvips-42.dll';
  function vips_foreign_find_load_buffer(const data; size : Cardinal) : PAnsiChar; cdecl; varargs; external 'libvips-42.dll';
  function vips_image_copy_memory(aInImage : pVipsImage) : pVipsImage; cdecl; external 'libvips-42.dll';
  function vips_image_hasalpha(aInImage: pVipsImage): Integer; cdecl; external 'libvips-42.dll';
  function vips_resize(inImage: pVipsImage; out outImage: pVipsImage; scale: Double; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_image_write_to_file(image: pVipsImage; filename: PAnsiChar; args: Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_gifsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer) : Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_gifsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jpegsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jpegsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jp2ksave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jp2ksave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jxlsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_jxlsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_tiffsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_tiffsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_ppmsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_ppmsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_heifsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_heifsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_webpsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_webpsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_pngsave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer) : Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_pngsave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_magicksave(inImage: pVipsImage; filename: PAnsiChar; args : Pointer) : Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_magicksave_buffer(inImage: pVipsImage; out buffer : Pointer; out len : Cardinal; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';

  function vips_draw_rect(inImage: pVipsImage; ink: TVipsArrayDouble; lenInkArray : Integer; x, y, width, height: Integer; args: Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_flip(inImage: pVipsImage; out outImage: pVipsImage; direction: TVipsDirection; args: Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_rot(inImage: pVipsImage; out outImage: pVipsImage; angle: TVipsAngle; args: Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_embed(inImage: pVipsImage; out outImage: pVipsImage; x: Integer; y: Integer; width: Integer; height: Integer; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_draw_image(inImage, subImage: pVipsImage; x: Integer; y: Integer; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_join(inImage1: pVipsImage; inImage2: pVipsImage; out outImage: pVipsImage; direction: TVipsDirection; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_crop (inImage : pVipsImage; out outImage : pVipsImage; aleft, aTop, aWidth, aHeight : Integer; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_bandjoin2(inImage1: pVipsImage; inImage2: pVipsImage; out outImage: pVipsImage; direction: TVipsDirection; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_composite2(base: pVipsImage; overlay: pVipsImage; out outImage: pVipsImage; mode: TVipsBlendMode): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_linear(inImage: pVipsImage; out outImage: pVipsImage; const a, b: TVipsArrayDouble; const aLen : Integer;  args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_linear1(inImage: pVipsImage; out outImage: pVipsImage; a, b: Double; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_colourspace(inputImage: pVipsImage; out outputImage: pVipsImage; space: TVipsInterpretation): Integer; cdecl; varargs; external 'libvips-42.dll';
  function vips_autorot(inputImage : pVipsImage; out outputImage: pVipsImage; args : Pointer): Integer; cdecl; varargs; external 'libvips-42.dll';

  function vips_error_buffer(): PAnsiChar; cdecl; external 'libvips-42.dll';
  procedure vips_error_clear(); cdecl; external 'libvips-42.dll';

  procedure g_object_unref(obj: Pointer); cdecl; external 'libgobject-2.0-0.dll';
  procedure g_free(mem: Pointer); cdecl; external 'libglib-2.0-0.dll';

implementation

{ TVipsImage }

procedure vips_object_unref_ex(inImage : pVipsImage);
begin
  g_object_unref(inImage);
end;

class constructor TVipsImage.Create;
begin
  //vips_init('QuickImageFx');
  //vips_block_untrusted_set(False);
  //vips_operation_block_set('fitload',False);
end;

class destructor TVipsImage.Destroy;
begin
  //vips_shutdown;

end;

constructor TVipsImage.Create;
begin
   fVipsImage := nil;
   fAutoRotate := True;
end;

constructor TVipsImage.Create(aWidth, aHeight : Integer);
begin
  Create;
  fVipsImage := vips_image_new_matrix(aWidth, aHeight);
  if fVipsImage = nil then raise Exception.Create('Cannot create VipsImage!');
end;

constructor TVipsImage.CreateEmpty;
begin
  Create;
  fVipsImage := vips_image_new;
  if fVipsImage = nil then raise Exception.Create('Cannot create VipsImage!');
end;

constructor TVipsImage.CreateFromFile(const aFilename: string);
begin
  Create;
  Self.LoadFromFile(aFilename);
  if fVipsImage = nil then raise Exception.Create('Cannot load image from file!');
end;

constructor TVipsImage.CreateFromVipsImage(aVipsImage: TVipsImage);
begin
  Create;
  fVipsImage := aVipsImage.GetVipsImage;
end;

destructor TVipsImage.Destroy;
begin
  if fVipsImage <> nil then
  begin
    g_object_unref(fVipsImage);
    fVipsImage := nil;
  end;
  if fInternalBuffer <> nil then FreeMem(fInternalBuffer);
  inherited;
end;

class function TVipsImage.ColorToRGBValues(PColor: TColor): TRGB;
begin
  Result.B := PColor and $FF;
  Result.G := (PColor shr 8) and $FF;
  Result.R := (PColor shr 16) and $FF;
end;

class function TVipsImage.ColorToVipsColor(PColor: TColor): TVipsArrayDouble;
begin
  Result := [PColor and $FF, (PColor shr 8) and $FF, (PColor shr 16) and $FF];
end;

procedure TVipsImage.CombineImage(aImage: TVipsImage; aLeft, aTop: Integer; aCombineMode : TVipsCombineMode);
var
  res : Integer;
begin
  res := vips_draw_image(fVipsImage, aImage.GetVipsImage, aLeft, aTop, PAnsiChar('mode'), aCombineMode, nil);
  if res <> 0 then raise Exception.CreateFmt('Error drawing image! (%s)',[vips_error_buffer()]);
end;

procedure TVipsImage.DrawImage(aOverlay: TVipsImage; aLeft, aTop : Integer; mode: TVipsBlendMode);
var
  res : Integer;
  newImage : pVipsImage;
  x, y : Integer;
begin
  x := aLeft;
  y := aTop;
  if x = -1 then x := (Self.GetWidth - aOverlay.Width) Div 2;
  if y = -1 then y := (Self.GetHeight - aOverlay.Height) Div 2;
  
  res := vips_composite2(fVipsImage, aOverlay.GetVipsImage, newImage, mode,
      PAnsiChar('x'), x,
      PAnsiChar('y'), y, 
      nil);
  if res <> 0 then raise Exception.CreateFmt('Error drawing image! (%s)',[vips_error_buffer()]);
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
  newImage := nil;
  //vips_object_unref(aOverlay.GetVipsImage);
  //vips_object_unref(newImage);
end;

procedure TVipsImage.MergeImage(aImage: TVipsImage; aDirection: TVipsDirection);
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_join(fVipsImage, aImage.GetVipsImage, newImage, aDirection, nil);
  if res <> 0 then raise Exception.CreateFmt('Error merging image! (%s)',[vips_error_buffer()]);
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.Crop(aLeft, aTop, aWidth, aHeight: Integer);
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_crop(fVipsImage, newImage, aLeft, aTop, aWidth, aHeight, nil);
  if res <> 0 then raise Exception.CreateFmt('Error cropping image! (%s)',[vips_error_buffer()]);
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.DrawRect(aLeft, aTop, aWidth, aHeight: Integer; aColor: TColor);
var
  res : Integer;
begin
  res := vips_draw_rect(fVipsImage, ColorToVipsColor(aColor), 3, aLeft, aTop, aWidth, aHeight, PAnsiChar('fill'), 0, nil);
  if res <> 0 then raise Exception.Create('Error drawing rect!');
end;

procedure TVipsImage.FillRect(aLeft, aTop, aWidth, aHeight: Integer; aColor: TColor);
var
  res : Integer;
begin
  res := vips_draw_rect(fVipsImage, ColorToVipsColor(aColor), 3, aLeft, aTop, aWidth, aHeight, PAnsiChar('fill'), 1, nil);
  if res <> 0 then raise Exception.Create('Error drawing filled rect!');
end;

procedure TVipsImage.Linear(aMultiply, aAdd: Double);
var
  res : Integer;
  newImage : pVipsImage;
begin
  //res := vips_linear1(fVipsImage, newImage, aMultiply, aAdd, nil);
  res := vips_linear(fVipsImage, newImage, [1.0 , 1.0, 1.0, aMultiply], [0.0, 0.0, 0.0, aAdd], 4, nil);
  if res <> 0 then raise Exception.Create('Error aplying linear!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.AllocateInternalBuffer(aSize: Cardinal);
begin
  GetMem(fInternalBuffer, aSize);
end;

procedure TVipsImage.CanvasResize(aNewWidth, aNewHeight : Integer; aExtendBackground : TVipsExtend);
var
  newImage : pVipsImage;
  x, y : Integer;
begin
  x := (aNewWidth - GetWidth) Div 2;
  y := (aNewHeight - GetHeight) Div 2;
  if vips_embed(fVipsImage, newImage, x, y, aNewWidth, aNewHeight, PAnsiChar('extend'), aExtendBackground,  nil) <> 0 then raise Exception.Create('Error embeding image!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.Clear(aColor: TColor);
var
  res : Integer;
begin
  res := vips_draw_rect(fVipsImage, ColorToVipsColor(aColor), 3, 0, 0, Self.Width, Self.Height, PAnsiChar('fill'), 1, nil);
  if res <> 0 then raise Exception.Create('Cannot clear image!');
end;

function TVipsImage.Clone: TVipsImage;
begin
  Result := TVipsImage.CreateFromVipsImage(vips_image_copy_memory(fVipsImage));
  if Result = nil then raise Exception.Create('Cannot clone image!');
end;

procedure TVipsImage.Flip(aDirection: TVipsDirection);
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_flip(fVipsImage,newImage,aDirection,nil);
  if res <> 0 then raise Exception.Create('Error flip image!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.FreePreviousImage;
begin
  if fVipsImage <> nil then g_object_unref(fVipsImage);
  if fInternalBuffer <> nil then FreeMem(fInternalBuffer);
end;

function TVipsImage.GetBandsCount: Integer;
begin
  Result := vips_image_get_bands(fVipsImage);
end;

function TVipsImage.GetHeight: Integer;
begin
  Result := vips_image_get_height(fVipsImage);
end;

function TVipsImage.GetWidth: Integer;
begin
  Result := vips_image_get_width(fVipsImage);
end;

function TVipsImage.GetVipsImage: pVipsImage;
begin
  Result := fVipsImage;
end;

procedure TVipsImage.LoadFromFile(const aFilename: string);
begin
  FreePreviousImage;

  fVipsImage := vips_image_new_from_file(PAnsiChar(AnsiString(aFilename)), nil);
  if fVipsImage = nil then raise Exception.CreateFmt('Loading error (%s)',[vips_error_buffer()]);
end;

procedure TVipsImage.LoadFromStream(aStream: TStream);
begin
  if aStream.Size = 0 then raise Exception.Create('Stream is empty!');

  FreePreviousImage;

  aStream.Position := 0;
  AllocateInternalBuffer(aStream.Size);
  aStream.ReadBuffer(fInternalBuffer^, aStream.Size);
  fVipsImage := vips_image_new_from_buffer(fInternalBuffer, aStream.Size, nil, nil);
  if fVipsImage = nil then raise Exception.Create(vips_error_buffer());
end;

procedure TVipsImage.SaveToFile(const aFileName: string; aImageFormat: TVipsImageFormat; aQuality : Integer = 75);
var
  res : Integer;
begin
  if fVipsImage = nil then raise EArgumentException.Create('Not valid pVipsImage!');
  case aImageFormat of
    TVipsImageFormat.ifBMP :
      begin
        res := vips_magicksave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('quality '), 0, //(0-100) quality factor [Default 0]
                             PAnsiChar('format'), ('BMP'), //format to save as (BMP, GIF, etc...)
                             //PAnsiChar('optimize_gif_frames'), 0, //(gboolean) apply GIF frames optimization
                             //PAnsiChar('optimize_gif_transparency'), 0, //(gboolean) apply GIF transparency optimization
                             PAnsiChar('bitdepth'), 1, //(int) number of bits per pixel (1 to 8)
                             nil);
      end;
    TVipsImageFormat.ifGIF :
      begin
        res := vips_gifsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             //PAnsiChar('dither'), 0.0, //(gdouble) amount of dithering for 8bpp quantization (1, 2, 4 or 8) bits
                             PAnsiChar('effort'), 7, //quantisation CPU effort (1 is the fastest, 10 is the slowest) [Default 7]
                             //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to (1-8) [Default 8]
                             //PAnsiChar('interframe_maxerror '), 0.0, //(double) maximum inter-frame error for transparency
                             //PAnsiChar('reuse'), 0, ///(gboolean) reuse palette from input
                             PAnsiChar('interlace'), 0, //(gboolean) write an interlaced (progressive) GIF
                             //PAnsiChar('interpalette_maxerror'), 0, //(double) maximum inter-palette error for palette reusage
                             nil);
      end;
    TVipsImageFormat.ifTIFF :
      begin
        res := vips_tiffsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('compression'), TVipsForeignTiffCompression.VIPS_FOREIGN_TIFF_COMPRESSION_JPEG, // Use JPEG compression
                             PAnsiChar('Q'), aQuality, // Quality factor (0-100) [Default: 75]
                             PAnsiChar('predictor'), TVipsForeignTiffPredictor.VIPS_FOREIGN_TIFF_PREDICTOR_HORIZONTAL, // Use horizontal predictor
                             //PAnsiChar('profile'), PAnsiChar(''), // Path to ICC profile file
                             PAnsiChar('tile'), 1, //(gboolean) Enable writing a tiled TIFF file
                             PAnsiChar('tile_width'), 128, // Tile size (width)
                             PAnsiChar('tile_height'), 128, // Tile size (height)
                             PAnsiChar('pyramid'), 0, //(gboolean) Enable writing an image pyramid
                             //PAnsiChar('bitdepth'), 4, //(int) Change bit depth to 4
                             PAnsiChar('miniswhite'), 0, //(gboolean) Write 1-bit images as MINISWHITE
                             PAnsiChar('resunit'), TVipsForeignTiffResunit.VIPS_FOREIGN_TIFF_RESUNIT_CM, // Resolution unit in centimeters
                             PAnsiChar('xres'), 300.0, // Horizontal resolution in pixels/mm
                             PAnsiChar('yres'), 300.0, // Vertical resolution in pixels/mm
                             PAnsiChar('bigtiff'), 1, //(gboolean) Enable writing a BigTiff file
                             PAnsiChar('properties'), 0, //(gboolean) Enable writing an IMAGEDESCRIPTION tag
                             PAnsiChar('region_shrink'), TVipsRegionShrink.VIPS_REGION_SHRINK_MAX, // How to shrink each 2x2 region
                             PAnsiChar('level'), 9, //(int) Zstd compression level
                             PAnsiChar('lossless'), 0, //(gboolean) WebP lossless mode
                             PAnsiChar('depth'), TVipsForeignDzDepth.VIPS_FOREIGN_DZ_DEPTH_ONE, // Pyramid depth
                             PAnsiChar('subifd'), 1, //(gboolean) Write pyramid layers as sub-IFDs
                             PAnsiChar('premultiply'), 1, //(gboolean) Write with premultiplied alpha
                             nil);
      end;
    TVipsImageFormat.ifJPEG :
      begin
        res := vips_jpegsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                             //PAnsiChar('profile'), PAnsiChar(''), //filename of ICC profile to attach
                             //PAnsiChar('optimize_coding'), 0, //(gboolean) compute optimal Huffman coding tables
                             //PAnsiChar('interlace'), 0, //(gboolean) write an interlaced (progressive) jpeg
                             PAnsiChar('strip'), 1, //(gboolean) remove metadata from image
                             PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                             //PAnsiChar('trellis_quant'), 0, //(gboolean) apply trellis quantisation to each 8x8 block
                             //PAnsiChar('overshoot_deringing'), 0, //(gboolean) overshoot samples with extreme values
                             //PAnsiChar('optimize_scans'), 0, //(gboolean) split DCT coefficients into separate scans
                             //PAnsiChar('quant_table'), 0, //(int) quantization table index [Default 0]
                             //PAnsiChar('restart_interval'), 1, //(int) restart interval in mcu
                             nil);
      end;
    TVipsImageFormat.ifJP2K :
      begin
        res := vips_jp2ksave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                             PAnsiChar('lossless'), 1, //(gboolean) enables lossless compression
                             PAnsiChar('tile_width'), 512, //(int) for tile size [Default 512]
                             PAnsiChar('tile_height'), 512, //(int) for tile size [Default 512]
                             PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                             nil);
      end;
    TVipsImageFormat.ifPNG :
      begin
        res := vips_pngsave(fVipsImage, PAnsiChar(AnsiString(aFileName)),
                            PAnsiChar('compression'), 6, //(int) compression level  (0 - 9). [Default 6]
                            PAnsiChar('interlace'), 0, //(gboolean) interlace image [Default False]
                            //PAnsiChar('profile'), PAnsiChar(''), //(gcharray) ICC profile to embed
                            PAnsiChar('filter'), TVipsForeignPngFilter.VIPS_FOREIGN_PNG_FILTER_NONE, //row filter flag(s) [Default None]
                            //PAnsiChar('palette'), 0, //(gcboolean) enable quantisation to 8bpp palette
                            //PAnsiChar('Q'), 1, //(int) quality for 8bpp quantisation
                            //PAnsiChar('dither'), 0.0, //(gdouble) amount of dithering for 8bpp quantization (1, 2, 4 or 8) bits
                            //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                            PAnsiChar('effort'), 7, //quantisation CPU effort (1 is the fastest, 10 is the slowest) [Default 7]
                            nil);
      end;
    TVipsImageFormat.ifWEBP :
      begin
        res := vips_webpsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                             PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                             PAnsiChar('preset'), TVipsForeignWebpPreset.VIPS_FOREIGN_WEBP_PRESET_DEFAULT, //choose lossy compression preset
                             PAnsiChar('smart_subsample'), 0, //(gcboolean) enables high quality chroma subsampling
                             PAnsiChar('near_lossless'), 0, //(gcboolean) preprocess in lossless mode (controlled by Q)
                             PAnsiChar('alpha_q'), 100, //(int) set alpha quality in lossless mode (1-100) [Default 100]
                             PAnsiChar('effort'), 4, //level of CPU effort to reduce file size (0-6) [Default 4]
                             PAnsiChar('min_size'), 0, //(gcboolean) minimise size
                             PAnsiChar('mixed'), 0, //(gcboolean) allow both lossy and lossless encoding
                             //PAnsiChar('kmin'), 0, //(int) minimum number of frames between keyframes
                             //PAnsiChar('kmax'), 0, //(int) maximmun number of frames between keyframes
                             PAnsiChar('strip'), 1, //(gcboolean) remove all metadata from image
                             //PAnsiChar('profile'), PAnsiChar(''), //(gcharray) ICC profile to embed
                             nil);
      end;
    TVipsImageFormat.ifHEIF :
      begin
        res := vips_heifsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('Q'), aQuality, //quality factor
                             //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                             PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                             PAnsiChar('compression'), TVipsForeignHeifCompression.VIPS_FOREIGN_HEIF_COMPRESSION_HEVC, //write with this compression
                             PAnsiChar('effort'), 4, //quantisation CPU effort (0 is the fastest, 0 is the slowest) [Default 4] only for AV1
                             PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                             PAnsiChar('encoder'), TVipsForeignHeifEncoder.VIPS_FOREIGN_HEIF_ENCODER_AUTO, //encoding effort
                             nil);
      end;
    TVipsImageFormat.ifAVIF :
      begin
        res := vips_heifsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('Q'), aQuality, //quality factor
                             //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                             PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                             PAnsiChar('compression'), TVipsForeignHeifCompression.VIPS_FOREIGN_HEIF_COMPRESSION_AVC, //write with this compression
                             PAnsiChar('effort'), 0, //quantisation CPU effort (0 is the fastest, 9 is the slowest) [Default 4] only for AV1
                             PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                             PAnsiChar('encoder'), TVipsForeignHeifEncoder.VIPS_FOREIGN_HEIF_ENCODER_AOM, //encoding effort
                             nil);
      end;
    TVipsImageFormat.ifJXL :
      begin
        res := vips_jxlsave(fVipsImage,PAnsiChar(AnsiString(aFileName)),
                             PAnsiChar('tier'), 0, //(int) sets the overall decode speed the encoder will target. Minimum is 0 (highest quality), and maximum is 4 (lowest quality). [Default 0].
                             PAnsiChar('distance'), 1.0, //sets the target maximum encoding error. Minimum is 0 (highest quality), and maximum is 15 (lowest quality). Default is 1.0 (visually lossless)
                             //PAnsiChar('effort'), 0, // encoding effort
                             PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                             PAnsiChar('Q'), aQuality, //quality factor
                             nil);
      end
    else raise Exception.Create('Unknown image format for output!');
  end;
  if res <> 0 then raise Exception.CreateFmt('Conversion error: %s',[vips_error_buffer()]);
end;

procedure TVipsImage.SaveToStream(aStream: TStream; aImageFormat: TVipsImageFormat; aQuality : Integer = 75);
var
  res : Integer;
  buf : Pointer;
  len : Cardinal;
begin
  if fVipsImage = nil then raise EArgumentException.Create('Not valid pVipsImage!');

  aStream.Position := 0;
  //buf := nil;
  //len := 0;
  try
    case aImageFormat of
      TVipsImageFormat.ifBMP :
        begin
          res := vips_magicksave_buffer(fVipsImage,buf, len,
                               PAnsiChar('quality '), aQuality, //(0-100) quality factor [Default 0]
                               PAnsiChar('format'), ('BMP'), //format to save as (BMP, GIF, etc...)
                               //PAnsiChar('optimize_gif_frames'), 0, //(gboolean) apply GIF frames optimization
                               //PAnsiChar('optimize_gif_transparency'), 0, //(gboolean) apply GIF transparency optimization
                               PAnsiChar('bitdepth'), 1, //(int) number of bits per pixel (1 to 8)
                               nil);
        end;
      TVipsImageFormat.ifGIF :
        begin
          res := vips_gifsave_buffer(fVipsImage,buf, len,
                               //PAnsiChar('dither'), 0.0, //(gdouble) amount of dithering for 8bpp quantization (1, 2, 4 or 8) bits
                               PAnsiChar('effort'), 7, //quantisation CPU effort (1 is the fastest, 10 is the slowest) [Default 7]
                               //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to (1-8) [Default 8]
                               //PAnsiChar('interframe_maxerror '), 0.0, //(double) maximum inter-frame error for transparency
                               //PAnsiChar('reuse'), 0, ///(gboolean) reuse palette from input
                               PAnsiChar('interlace'), 0, //(gboolean) write an interlaced (progressive) GIF
                               //PAnsiChar('interpalette_maxerror'), 0, //(double) maximum inter-palette error for palette reusage
                               nil);
        end;
      TVipsImageFormat.ifTIFF :
        begin
          res := vips_tiffsave_buffer(fVipsImage, buf, len,
                               PAnsiChar('compression'), TVipsForeignTiffCompression.VIPS_FOREIGN_TIFF_COMPRESSION_JPEG, // Use JPEG compression
                               PAnsiChar('Q'), aQuality, // Quality factor (0-100) [Default: 75]
                               PAnsiChar('predictor'), TVipsForeignTiffPredictor.VIPS_FOREIGN_TIFF_PREDICTOR_HORIZONTAL, // Use horizontal predictor
                               //PAnsiChar('profile'), PAnsiChar(''), // Path to ICC profile file
                               PAnsiChar('tile'), 1, //(gboolean) Enable writing a tiled TIFF file
                               PAnsiChar('tile_width'), 512, // Tile size (width)
                               PAnsiChar('tile_height'), 512, // Tile size (height)
                               PAnsiChar('pyramid'), 0, //(gboolean) Enable writing an image pyramid
                               //PAnsiChar('bitdepth'), 4, //(int) Change bit depth to 4
                               PAnsiChar('miniswhite'), 0, //(gboolean) Write 1-bit images as MINISWHITE
                               PAnsiChar('resunit'), TVipsForeignTiffResunit.VIPS_FOREIGN_TIFF_RESUNIT_CM, // Resolution unit in centimeters
                               PAnsiChar('xres'), 300.0, // Horizontal resolution in pixels/mm
                               PAnsiChar('yres'), 300.0, // Vertical resolution in pixels/mm
                               PAnsiChar('bigtiff'), 1, //(gboolean) Enable writing a BigTiff file
                               PAnsiChar('properties'), 1, //(gboolean) Enable writing an IMAGEDESCRIPTION tag
                               PAnsiChar('region_shrink'), TVipsRegionShrink.VIPS_REGION_SHRINK_MAX, // How to shrink each 2x2 region
                               PAnsiChar('level'), 9, //(int) Zstd compression level
                               PAnsiChar('lossless'), 0, //(gboolean) WebP lossless mode
                               PAnsiChar('depth'), TVipsForeignDzDepth.VIPS_FOREIGN_DZ_DEPTH_ONE, // Pyramid depth
                               PAnsiChar('subifd'), 1, //(gboolean) Write pyramid layers as sub-IFDs
                               PAnsiChar('premultiply'), 1, //(gboolean) Write with premultiplied alpha
                               nil);
        end;
      TVipsImageFormat.ifJPEG :
        begin
          res := vips_jpegsave_buffer(fVipsImage,buf, len,
                               PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                               //PAnsiChar('profile'), PAnsiChar(''), //filename of ICC profile to attach
                               //PAnsiChar('optimize_coding'), 0, //(gboolean) compute optimal Huffman coding tables
                               //PAnsiChar('interlace'), 0, //(gboolean) write an interlaced (progressive) jpeg
                               PAnsiChar('strip'), 1, //(gboolean) remove metadata from image
                               PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                               //PAnsiChar('trellis_quant'), 0, //(gboolean) apply trellis quantisation to each 8x8 block
                               //PAnsiChar('overshoot_deringing'), 0, //(gboolean) overshoot samples with extreme values
                               //PAnsiChar('optimize_scans'), 0, //(gboolean) split DCT coefficients into separate scans
                               //PAnsiChar('quant_table'), 0, //(int) quantization table index [Default 0]
                               //PAnsiChar('restart_interval'), 1, //(int) restart interval in mcu
                               nil);
        end;
      TVipsImageFormat.ifJP2K :
        begin
          res := vips_jp2ksave_buffer(fVipsImage,buf, len,
                               PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                               PAnsiChar('lossless'), 1, //(gboolean) enables lossless compression
                               PAnsiChar('tile_width'), 512, //(int) for tile size [Default 512]
                               PAnsiChar('tile_height'), 512, //(int) for tile size [Default 512]
                               PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                               nil);
        end;
      TVipsImageFormat.ifPNG :
        begin
          res := vips_pngsave_buffer(fVipsImage,buf, len,
                              PAnsiChar('compression'), 6, //(int) compression level  (0 - 9). [Default 6]
                              PAnsiChar('interlace'), 0, //(gboolean) interlace image [Default False]
                              //PAnsiChar('profile'), PAnsiChar(''), //(gcharray) ICC profile to embed
                              PAnsiChar('filter'), TVipsForeignPngFilter.VIPS_FOREIGN_PNG_FILTER_NONE, //row filter flag(s) [Default None]
                              //PAnsiChar('palette'), 0, //(gcboolean) enable quantisation to 8bpp palette
                              //PAnsiChar('Q'), 1, //(int) quality for 8bpp quantisation
                              //PAnsiChar('dither'), 0.0, //(gdouble) amount of dithering for 8bpp quantization (1, 2, 4 or 8) bits
                              //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                              PAnsiChar('effort'), 7, //quantisation CPU effort (1 is the fastest, 10 is the slowest) [Default 7]
                              nil);
        end;
      TVipsImageFormat.ifWEBP :
        begin
          res := vips_webpsave_buffer(fVipsImage,buf, len,
                               PAnsiChar('Q'), aQuality, //(0-100) quality factor [Default 75]
                               PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                               PAnsiChar('preset'), TVipsForeignWebpPreset.VIPS_FOREIGN_WEBP_PRESET_DEFAULT, //choose lossy compression preset
                               PAnsiChar('smart_subsample'), 0, //(gcboolean) enables high quality chroma subsampling
                               PAnsiChar('near_lossless'), 0, //(gcboolean) preprocess in lossless mode (controlled by Q)
                               PAnsiChar('alpha_q'), 100, //(int) set alpha quality in lossless mode (1-100) [Default 100]
                               PAnsiChar('effort'), 4, //level of CPU effort to reduce file size (0-6) [Default 4]
                               PAnsiChar('min_size'), 0, //(gcboolean) minimise size
                               PAnsiChar('mixed'), 0, //(gcboolean) allow both lossy and lossless encoding
                               //PAnsiChar('kmin'), 0, //(int) minimum number of frames between keyframes
                               //PAnsiChar('kmax'), 0, //(int) maximmun number of frames between keyframes
                               PAnsiChar('strip'), 1, //(gcboolean) remove all metadata from image
                               //PAnsiChar('profile'), PAnsiChar(''), //(gcharray) ICC profile to embed
                               nil);
        end;
      TVipsImageFormat.ifHEIF :
        begin
          res := vips_heifsave_buffer(fVipsImage,buf, len,
                               PAnsiChar('Q'), aQuality, //quality factor (Default: 50)
                               //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                               PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                               PAnsiChar('compression'), TVipsForeignHeifCompression.VIPS_FOREIGN_HEIF_COMPRESSION_HEVC, //write with this compression
                               PAnsiChar('effort'), 4, //quantisation CPU effort (0 is the fastest, 0 is the slowest) [Default 4] only for AV1
                               PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                               PAnsiChar('encoder'), TVipsForeignHeifEncoder.VIPS_FOREIGN_HEIF_ENCODER_AUTO, //encoding effort
                               nil);
        end;
      TVipsImageFormat.ifAVIF :
        begin
          res := vips_heifsave_buffer(fVipsImage,buf, len,
                               PAnsiChar('Q'), aQuality, //quality factor
                               //PAnsiChar('bitdepth'), 8, //(int) set write bit depth to 1, 2, 4, 8 or 16
                               PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                               PAnsiChar('compression'), TVipsForeignHeifCompression.VIPS_FOREIGN_HEIF_COMPRESSION_AV1, //.VIPS_FOREIGN_HEIF_COMPRESSION_AVC, //write with this compression
                               PAnsiChar('effort'), 0, //quantisation CPU effort (0 is the fastest, 9 is the slowest) [Default 4] only for AV1
                               //PAnsiChar('subsample_mode'), TVipsForeignSubsample.VIPS_FOREIGN_SUBSAMPLE_AUTO, //chroma subsampling mode
                               PAnsiChar('encoder'), TVipsForeignHeifEncoder.VIPS_FOREIGN_HEIF_ENCODER_AOM, //encoding effort
                               nil);
        end;
      TVipsImageFormat.ifJXL :
        begin
          res := vips_jxlsave_buffer(fVipsImage,buf, len,
                               PAnsiChar('tier'), 0, //(int) sets the overall decode speed the encoder will target. Minimum is 0 (highest quality), and maximum is 4 (lowest quality). [Default 0].
                               PAnsiChar('distance'), 1.0, //sets the target maximum encoding error. Minimum is 0 (highest quality), and maximum is 15 (lowest quality). Default is 1.0 (visually lossless)
                               //PAnsiChar('effort'), 0, // encoding effort
                               PAnsiChar('lossless'), 0, //(gcboolean) enable lossless encoding
                               PAnsiChar('Q'), aQuality, //quality factor
                               nil);
        end
      else raise Exception.Create('Unknown image format for output!');
    end;

    if (buf = nil) or (len = 0) then raise Exception.Create('Buffer error!');

    aStream.WriteBuffer(buf^,len);
    if aStream.Size = 0 then res := -1;

    aStream.Position := 0;

    //if res <> 0 then raise Exception.CreateFmt('Conversion error: %s',[vips_error_buffer()]);
    if res <> 0 then raise Exception.Create('Conversion error!');
  finally
    if buf <> nil then
      g_free(buf);
    buf := nil;
    //FreeMem(buf);
  end;
end;

procedure TVipsImage.Resize(aNewWidth, aNewHeight: Integer; aVipsKernel : TVipsKernel = TVipsKernel.VIPS_KERNEL_LINEAR; aGap : Double = 2.0);
var
  newImage : Pointer;
  //scaleWidth : Double;
  //scaleHeight : Double;
  scale : Double;
  res : Integer;
begin
  //calc scale factor for w & h
  //scaleWidth := aNewWidth / Self.Width;
  //scaleHeight := aNewHeight / Self.Height;

  //get w or h
  //if scaleWidth > scaleHeight then
  //  scale := scaleWidth
  //else
  //  scale := scaleHeight;

  scale := aNewWidth / Self.Width;

  res := vips_resize(fVipsImage, newImage, scale,
                     //PAnsiChar('vscale'), 1.0, //(double) vertical scale factor
                     PAnsiChar('kernel'), aVipsKernel, //to reduce with
                     PAnsiChar('gap'), aGap, //(double) reducing gap to use [Default 2.0]
                     nil);
  if res <> 0 then raise Exception.CreateFmt('Resize error: %s',[vips_error_buffer()]);
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;


procedure TVipsImage.Rotate(aAngle: TVipsAngle);
var
  newImage : Pointer;
begin
  if vips_rot(fVipsImage,newImage,aAngle,nil) <> 0 then raise Exception.CreateFmt('Rotate error: %s',[vips_error_buffer()]);
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.RotateByExif;
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_autorot(fVipsImage,newImage,nil);
  if res <> 0 then raise Exception.Create('Error rotating EXIF!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.GrayScale;
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_colourspace(fVipsImage,newImage,TVipsInterpretation.VIPS_INTERPRETATION_B_W,nil);
  if res <> 0 then raise Exception.Create('Error converting to grayscale!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

procedure TVipsImage.ColourSpace(aColourSpace: TVipsInterpretation);
var
  res : Integer;
  newImage : pVipsImage;
begin
  res := vips_colourspace(fVipsImage,newImage,aColourSpace,nil);
  if res <> 0 then raise Exception.Create('Error converting colourspace!');
  g_object_unref(fVipsImage);
  fVipsImage := newImage;
end;

initialization
  vips_init('QuickImageFx');
  //vips_leak_set(true);


finalization
  vips_shutdown;

end.

