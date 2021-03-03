## QuickImageFX
----------


Delphi library for simplifying image load/save, conversion and transformation. Can load/save png, jpg, gif and bmp. Can get image from different resources: file, stream, http, imagelist, associated windows icon, executable file icon, etc... Rotate, flip, grayscale and many other transformations.

*NEW: Interface based

*NEW: Vampyre lib engine added

*NEW: New functions added

*NEW: Refactory classes

*NEW: Delphinus support

----------
You can select one or more of the available engines ImageFX supports. Add one or more of below units to your uses clause:

- **Quick.ImageFX.GDI:** Uses GDI+ engine. No needs external libraries but it's slow.
	
    Needed libraries:
    
    - QuickLibs from Exilon (https://github.com/exilon/QuickLibs)
   
- **Quick.ImageFX.GR32:** Uses Graphics32 engine to rotate, transform, resize, etc

	Needed libraries:
    
	- QuickLibs from Exilon (https://github.com/exilon/QuickLibs)
	- Graphics32 (https://github.com/graphics32/graphics32)
	- CCR-Exif from Chris Rolliston (https://code.google.com/archive/p/ccr-exif)   
 
- **Quick.ImageFX.OpenCV:** OpenCV Engine. Uses a thrid party delphi warper for Intel Open Vision library. It's very fast and powerfull. Needs OpenCV external dll's in your project dir.
	
    Needed libraries:  
	
	- QuickLibs from Exilon (https://github.com/exilon/QuickLibs)
	- Delphi-OpenCV from Laex (https://github.com/Laex/Delphi-OpenCV).  
	- CCR-Exif from Chris Rolliston (https://code.google.com/archive/p/ccr-exif)
	
- **Quick.ImageFX.Vampyre:** Vampyre Imaging Library Engine. Uses a thrid party delphi warper for Vampyre Imaging native library. Fast and supports many image formats.
	
    Needed libraries:  
	
	- QuickLibs from Exilon (https://github.com/exilon/QuickLibs)
	- Vampyre-Imaging from Marek Mauder (https://github.com/galfar/imaginglib.git) 
	- CCR-Exif from Chris Rolliston (https://code.google.com/archive/p/ccr-exif)


**Create:** Create instance of ImageFX to load/manipulate images.
```delphi
var
  ImageFX : IImageFX;
begin
  ImageFX := TImageFXGDI //You can create as TImageFXGDI, TImageFXGR32, TImageFXOpenCV or TImageFXVampyre to use different graphic engines
  ImageFX.LoadFromFile('.\test.jpg');
  ImageFX.Rotate90;
  ImageFX.SaveAsPNG('.\Test.png');
end;
```

**Load/Save:** Can load/save png, jpg, gif and bmp and get image from different resources like file, stream, http, imagelist, associated windows icon, executable file icon, etc...

```delphi
//Load image from files like jpg, gif, png and bmp
ImageFX.LoadFromFile('.\file.jpg');
	
//Load/Save image from/to a memorystream, filestream, etc...
ImageFX.LoadFromStream(MyStream);
ImageFX.SaveToStream(MyStream,ifJPG);
	
//Load image from an icon class
ImageFX.LoadFromIcon(MyIcon);
	
//Load image from an icon file
ImageFX.LoadFromFileIcon('.\file.ico');
	
//Get image associated in windows with this type of extension
ImageFX.LoadFromFileExtension('.\file.xls',True);
	
//Load from exe resource
ImageFX.LoadFromResource('Main.ico');
	
//Get image from a http link
ImageFX.LoadFromHTTP('http://www.mysite.com/file.jpg',ReturnHTTPCode,True);
	
//Load/Save from string
ImageFX.LoadFromString(MyImageString);
ImageFX.SaveToString(MyImageString);
```
	
**Image Info:** Get resolution, aspect ratio of an image.

```delphi
ImageFX.GetResolution(x,y)
ImageFX.AspectRatioStr //aspect ratio (4:3,16:9)
ImageFX.IsGray
```
		
**Image Resize:**

```delphi
//Resize image to fit max bounds of 500x300 and fills rest of target size with a border black color
ImageFX.ResizeOptions.BorderColor := clBlack; 
ImageFX.Resize(500,300, rmFitToBounds, [rfCenter], rmLinear);

//Same image resize alternative/advanced mode
ImageFX.ResizeOptions.ResamplerMode := rmLinear;
ImageFX.ResizeOptions.ResizeMode := rmFitToBounds;
ImageFX.ResizeOptions.Center := True;
ImageFX.ResizeOptions.FillBorders := True;
ImageFX.ResizeOptions.BorderColor := clBlack;
ImageFX.Resize(500,300);
```

**ResizeOptions:**
			
- **NoMagnify:** If true not resize image if smallest than especified new size.    

- **ResizeMode:** Resize algorithms to calculate desired final size:
	 - **rmStretch** Stretch original image to fit target size without preserving original aspect ratio.
	 - **rmScale** Recalculate width or height target size to preserve original aspect ratio.
	 - **rmCropToFill** Preserve target aspect ratio cropping original image to fill whole size.
	 - **rmFitToBounds** Resize image to fit max bounds of target size.

- **ResamplerMode:** Resize algorithms to be applied:
	 - **rsAuto** Uses rmArea for downsampling and rmLinear for upsampling
	 - **rsGDIStrech** GDI only mode.
	 - **rsNearest** Low quality - High performance.
	 - **rsGR32Draft** GR32 only. Medium quality - High performance (downsampling only).
	 - **rsOCVArea** OpenCV only. Medium quality - High performance (downsampling only).
	 - **rsLinear** Medium quality - Medium performance.
	 - **rsGR32Kernel** GR32 only. High quality - Low performance (depends on kernel width).
	 - **rsOCVCubic** OpenCV only. High quality - Medium/Low performance.
	 - **rsOCVLanczos4** OpenCV only. High quality - Low performance.

- **Center:** Centers image

- **FillBorders:** Fill borders of a scaled image in destination rectangle if smaller.

- **BorderColor:** Color of filling borders.

**Transforms:** Apply rotations, flips, scanline effects, bright  and others transformations to your images.

```delphi
//Rotate image 90 degrees
ImageFX.Rotate90;
    
//Rotate image 45 degrees
ImageFX.RotateAngle(45);
    
//Convert to grayscale
ImageFX.GrayScale;
    
//Flip image horizontally
ImageFX.FlipX;
    
//Increase bright by 50%
ImageFX.Lighten(50);
    
//Change color of a pixel
PixInfo.R := Random(255); //R
PixInfo.G := Random(255); //G
PixInfo.B := Random(120); //B
PixInfo.A := 200; //Alpha
imageFX.Pixel[x,y] := PixInfo;
    
//Draw an overlay image over current image with 50% transparency
ImageFX.DrawCentered(pngimage,0.5);
```

**Format conversions:** Can convert between image formats.

```delphi
ImageFX.LoadFromFile('.\myfile.jpg');
ImageFX.SaveAsPNG('.\myfile.png');
```

**Almost all functions return self class, so you can chain many actions and effects like this:**

```delphi
//Rotate 90 degrees and flip horizontally, convert to grayscale and save to a png file.
ImageFX.Rotate90.FlipX.GrayScale.SaveToPNG('.\myfile.png');
        
// Load from file, rotate180, resize to 100x100 and assign to a TImage.    
MyImage.Picture.Asssign(ImageFX.LoadFromFile('.\myfile.jpg').Rotate180.Resize(100,100).AsBitmap);
```

>Do you want to learn delphi or improve your skills? [learndelphi.org](https://learndelphi.org)


