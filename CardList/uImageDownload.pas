unit uImageDownload;

interface

uses
  System.Threading,
  System.IOUtils,
  FMX.Types,
  FMX.Graphics,
  uBaseCard;


Type
   TImageDownload = Class
      Private
         Class Var
            FBitmapStart : TBitmap;
            FBitmapFail  : TBitmap;
            FImagePath   : String;
         Class Constructor CreateClass;
         Class Destructor DestroyClass;
         class procedure SetBitmapFail (const Value: TBitmap); static;
         class procedure SetBitmapStart(const Value: TBitmap); static;
         class Function URLToFileName(Const aUrl : String) : String;
      Public
         Class Procedure DownloadImage(aCard : TBaseCard; aImage : TBitmap);
         Class Procedure ClearCache;
         Class Property StartImage : TBitmap   Read FBitmapStart Write SetBitmapStart;
         Class Property FailImage  : TBitmap   Read FBitmapFail  Write SetBitmapFail;
      End;

implementation

uses
  System.Net.HttpClient,
  System.Classes, FMX.Objects, System.SysUtils;


{ TImageDownload }

class procedure TImageDownload.ClearCache;
Var
   LLista : TStringList;
   SR     : TSearchRec;
   i      : Integer;
begin
LLista := TStringList.Create;
if FindFirst(FimagePath+PathDelim+'*.*', faAnyFile, SR) = 0 then
   Repeat
      LLista.Add(SR.Name);
      Until FindNext(SR) <> 0;
for i := 0 to LLista.Count-1 do
   if (LLista[i] <> '.') And (LLista[i] <> '..') then
      Deletefile(FImagePath+PathDelim+LLista[I]);
LLista.DisposeOf;
end;

class constructor TImageDownload.CreateClass;
begin
FBitmapStart := TBitmap.Create;
FBitmapFail  := TBitmap.Create;
FImagePath   := System.IOUtils.TPath.GetDocumentsPath + PathDelim + 'ImageCache';
if Not DirectoryExists(FImagePath) then
   CreateDir(FImagePath);
TThreadPool.Default.SetMaxWorkerThreads(4);
end;

class destructor TImageDownload.DestroyClass;
begin
FBitmapStart.DisposeOf;
FBitmapFail .DisposeOf;
end;

class procedure TImageDownload.SetBitmapFail(const Value: TBitmap);
begin
FBitmapFail.Assign(Value);
end;

class procedure TImageDownload.SetBitmapStart(const Value: TBitmap);
begin
FBitmapStart.Assign(Value);
end;

class function TImageDownload.URLToFileName(const aUrl: String): String;
begin
Result := aURL.Replace('/','_').Replace(':','_').Replace('?','_').Replace('%', '_');
end;

class procedure TImageDownload.DownloadImage(aCard: TBaseCard; aImage: TBitmap);
Var
   LFileName : String;
begin
LFileName := FImagePath+PathDelim+URLToFileName(aCard.GetUrl(aImage));
if FileExists(LFileName) Then
   Begin
   aImage.LoadFromFile(LFileName);
   End
Else
   TTask.Run(
      Procedure
      Var
         LCard   : TBaseCard;
         LImage  : TBitmap;
         LHttp   : THttpClient;
         LURL    : String;
         LStr    : TMemoryStream;
         LName   : String;
         LBitmap : TBitmap;
      Begin
      LCard   := aCard;
      LImage  := aImage;
      LHttp   := THttpClient.Create;
      LBitmap := TBitmap.Create;
      LStr    := TMemoryStream.Create;
      LURL    := aCard.GetUrl(LImage);
      LName   := LFileName;
      TThread.Synchronize(Nil,
         Procedure
         Begin
         aImage.Assign(FBitmapStart);
         End);
      Try
         LHttp.Get(LURL, LStr);
         Try
            LBitmap.LoadFromStream(LStr);
            LBitmap.SaveToFile(LName);
         Except
            LBitmap.Assign(FBitmapFail);
            End;
         if LURL = aCard.GetUrl(LImage) then
            TThread.Synchronize(Nil,
               Procedure
               Begin
               aImage.Assign(LBitmap);
               End);
      Except
         TThread.Synchronize(Nil,
            Procedure
            Begin
            aImage.Assign(FBitmapFail);
            End);
         End;
      LStr   .DisposeOf;
      LHttp  .DisposeOf;
      LBitmap.DisposeOf;
      End);
end;

end.
