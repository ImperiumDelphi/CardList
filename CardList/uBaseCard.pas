unit uBaseCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti,
  System.Generics.Collections,
  System.JSON;

type

  TBaseCard = class(TFrame)
  private
    FCardsView : TObjectList<TBaseCard>;
    FData      : TJsonObject;
    FColumns   : Integer;
    FIndex     : Integer;
    FSpace     : Single;
    procedure SetColumns(const Value: Integer);
    procedure CreateCards;
  protected
    procedure SetData(const Value: TJsonObject); Virtual;
    procedure SetParent(const Value: TFmxObject); Override;
    procedure Resize; Override;
  public
    Constructor Create(aOwner : TComponent); Override;
    Constructor CreateOther(aOwner : TComponent);
    Destructor Destroy;
    Procedure ClearData(aPosY, aHeight : Single);
    procedure SetBoundsRect(const Value: TRectF); Override;
    Procedure Clear; Virtual;
    Procedure MoveData; Virtual;
    Function GetUrl(aImage : TBitmap) : String; Virtual;
    Function Count : Integer;
    Function GetCard : TBaseCard;
    Property Data    : TJsonObject Read FData    Write SetData;
    Property Columns : Integer     Read FColumns Write SetColumns;
    Property Space   : Single      Read FSpace   Write FSpace;
  end;

implementation

{$R *.fmx}

{ TBaseCard }

constructor TBaseCard.Create(aOwner: TComponent);
begin
inherited;
Position.X := 10000;
FColumns   := 1;
CreateCards;
end;

constructor TBaseCard.CreateOther(aOwner: TComponent);
begin
Inherited Create(aOwner);
Position.X := 10000;
end;

procedure TBaseCard.CreateCards;
Var
   i        : Integer;
   LName    : String;
   LContext : TRttiContext;
   LInst    : TRttiInstanceType;
   LQtd     : Integer;

   Procedure Add;
   Var
      LCard : TBaseCard;
      V     : TValue;
   Begin
   V          := LInst.GetMethod('CreateOther').Invoke(LInst.metaClassType,[Application.MainForm]);
   LCard      := V.AsObject As TbaseCard;
   LCard.Name := LCard.Name+'_'+FCardsView.Count.ToString;
   FCardsView.Add(LCard);
   End;

begin
FCardsView := TObjectList<TBaseCard>.Create;
LContext   := TRttiContext.Create;
LName      := Self.QualifiedClassName;
LInst      := (LContext.FindType(LName) as TRttiInstanceType);
LQtd       := (Trunc(Screen.Height / Height)+4) * FColumns;
while FCardsView.Count < LQtd do
   Add;
end;

destructor TBaseCard.Destroy;
begin
FCardsView.DisposeOf;
end;

procedure TBaseCard.Clear;
begin
end;

procedure TBaseCard.MoveData;
begin
Repaint;
end;

procedure TBaseCard.Resize;
begin
inherited;
CreateCards;
end;

procedure TBaseCard.SetBoundsRect(const Value: TRectF);
begin
Inherited;
end;

procedure TBaseCard.SetColumns(const Value: Integer);
begin
if Value <> FColumns then
   Begin
   FColumns := Value;
   CreateCards;
   End;
end;

procedure TBaseCard.SetData(const Value: TJsonObject);
begin
FData := Value;
if FData = Nil then
   Clear
Else
   MoveData;
end;

procedure TBaseCard.SetParent(const Value: TFmxObject);
Var
   i : Integer;
begin
Inherited;
if Assigned(FCardsView) then
   for i := 0 to FCardsView.Count-1 do
      FCardsView.Items[i].Parent := Value;
end;

procedure TBaseCard.ClearData(aPosY, aHeight : Single);
Var
   i      : Integer;
   LCard  : TBaseCard;
   LPosY  : Single;
   LTop   : Single;
   LBot   : Single;
   LCardH : Single;
begin
for i := 0 to FCardsView.Count-1 do
   Begin
   LCard  := FCardsView.Items[i];
   LPosY  := LCard.Position.Y;
   LCardH := LCard.Height+LCard.Margins.Top+LCard.Margins.Bottom;
   LTop  := aPosY-LCardH*2;
   LBot  := aPosY + aHeight + LCardH;
   If (aPosY < 0) Or
      Not((LPosY >= LTop) And (LPosY <= LBot)) Then
      Begin
      LCard.Data  := Nil;
      LCard.Width := 1;
      LCard.Position.X := 10000;
      End;
   End;
end;

function TBaseCard.GetCard : TBaseCard;
Var
   i : Integer;
begin
Result := Nil;
for i := 0 to FCardsView.Count-1 do
   Begin
   if FCardsView.Items[i].FData = Nil then
      Begin
      Result := FCardsView.Items[i];
      Result.Repaint;
      Break;
      End;
   End;
end;

function TBaseCard.GetUrl(aImage: TBitmap): String;
begin
end;

function TBaseCard.Count: Integer;
begin
Result := FCardsView.Count;
end;

end.
