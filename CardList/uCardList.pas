unit uCardList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts,
  System.Generics.Collections,
  System.JSON,
  FMX.Objects,
  uBaseCard,
  uCardRecord,
  uCardListRecords;

type

  TNewvertScrollBox = Class(TVertScrollBox)
     Private
        FAniTop : TPath;
        FAniBot : TPath;
        FPosY   : Single;
        FClickY : Single;
     Protected
        procedure AniMouseDown(const Touch: Boolean; const X, Y: Single); Override;
        procedure AniMouseMove(const Touch: Boolean; const X, Y: Single); Override;
        procedure AniMouseUp(const Touch: Boolean; const X, Y: Single); Override;
     Public
        Property PosY   : Single Read FPosY   Write FPosY;
        Property AniTop : TPath  Read FAniTop Write FAniTop;
        Property AniBot : TPath  Read FAniBot Write FAniBot;
     End;

  TCardList = class(TFrame)
    AniTop: TPath;
    AniBot: TPath;
  private
    FList     : TCardListRecords;
    FCards    : TList<TBaseCard>;
    FEndList  : TLayout;
    FLastY    : Single;
    FLastW    : Single;
    FClickY   : Single;
    FFingerY  : Single;
    Lista     : TNewVertScrollBox;
    procedure ListaViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
    Procedure CalculateCardsPositions;
    Procedure ShowCards(Const aPosY : Single);
    Procedure AnimateDelete(aIndex : Integer);
  Protected
    Procedure Resize; Override;
  public
    Constructor Create(aOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure BeginUpdate; Override;
    Procedure EndUpdate; Override;
    Procedure AddCard(aCard : TBaseCard; aData : TJsonObject);
    Procedure InsertCard(aIndex : Integer; aCard : TBaseCard; aData : TJsonObject);
    Procedure DeleteCard(aIndex : Integer);
  end;

implementation

Uses
   FMX.Ani;

{$R *.fmx}

{ TFrame1 }

constructor TCardList.Create(aOwner: TComponent);
begin
inherited;
Lista           := TNewVertScrollBox.Create(Self);
Lista.Parent    := Self;
Lista.Align     := TAlignLayout.Contents;
Lista.AniTop    := AniTop;
Lista.AniBot    := AniBot;
FList           := TCardListRecords.Create;
FCards          := TList<TBaseCard>.Create;
FEndList        := TLayout.Create(Self);
AniTop.Height   := 0;
AniBot.Height   := 0;
FEndList.Height := 1;
Lista.OnViewportPositionChange := ListaViewportPositionChange;
Lista.SendToBack;
end;

procedure TCardList.DeleteCard(aIndex: Integer);
begin
AnimateDelete(aIndex);
end;

destructor TCardList.Destroy;
begin
FList .DisposeOf;
FCards.DisposeOf;
inherited;
end;

procedure TCardList.AddCard(aCard: TBaseCard; aData: TJsonObject);
begin
if FCards.IndexOf(aCard) = -1 then
   FCards.Add(aCard);
FList.AddRecord(aCard, aData);
end;

procedure TCardList.InsertCard(aIndex: Integer; aCard: TBaseCard; aData: TJsonObject);
begin
if FCards.IndexOf(aCard) = -1 then
   FCards.Add(aCard);
FList.InsertRecord(aIndex, aCard, aData);
end;

procedure TCardList.BeginUpdate;
begin
inherited;
FLastY  := -1;
end;

procedure TCardList.EndUpdate;
Var
   i, c : Integer;
begin
for i := 0 to FCards.Count-1 do
   Begin
   FCards.Items[i].Parent := Lista;
   FCards.Items[i].ClearData(-1, Height)
   End;
CalculateCardsPositions;
inherited;
end;

procedure TCardList.ListaViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
If FlastY <> Lista.ViewportPosition.Y Then
   Begin
   FlastY := Lista.ViewportPosition.Y;
   ShowCards(FlastY);
   End;
end;

procedure TCardList.Resize;
begin
inherited;
if Assigned(FList) then
   Begin
   CalculateCardsPositions;
   ShowCards(FlastY);
   FLastW := Width;
   End;
end;

procedure TCardList.ShowCards(Const aPosY : Single);
Var
   i      : Integer;
   LRec   : TCardRecord;
   LPosY  : Single;
   LTop   : Single;
   LBot   : Single;
   LCardH : Single;
Begin
if FLastW <> Width then
   for i := 0 to FCards.Count-1 do
      FCards.Items[i].ClearData(-1, Height)
Else
   for i := 0 to FCards.Count-1 do
      FCards.Items[i].ClearData(aPosY, Height);
for I := 0 to FList.Count-1 do
   Begin
   LRec   := FList.Items[i];
   LPosY  := LRec.Bounds.Top;
   LCardH := LRec.BaseCard.Height+LRec.BaseCard.Margins.Top+LRec.BaseCard.Margins.Bottom;
   LTop   := aPosY-LCardH*2;
   LBot   := aPosY + Height + LCardH;
   if (LPosY >= LTop) And (LPosY <= LBot) Then
      Begin
      If (LRec.Card = nil) Or (LRec.Card.BoundsRect <> LRec.Bounds) then
         Begin
         LRec.Card      := LRec.BaseCard.GetCard;
         LRec.Card.Data := LRec.Data;
         LRec.Card.BringToFront;
         End;
      LRec.Card.SetBoundsRect(LRec.Bounds);
      End;
   if LPosY > LBot then
      Break;
   End;
end;

procedure TCardList.CalculateCardsPositions;
Var
   i      : Integer;
   LRec   : TCardRecord;
   LCard  : TBaseCard;
   LPosY  : Single;
   LRect  : TRectF;
   LWidth : Single;
   LWTemp : Single;
   LCol   : Integer;
   LLeft  : Single;
   LRight : Single;
begin
LCard  := Nil;
LPosY  := 0;
LCol   := 0;
LCard  := Nil;
LWidth := Lista.Width;
{$IFDEF MSWINDOWS}
LWidth := LWidth - 12;
{$ENDIF}
for i := 0 to Flist.Count-1 do
   Begin
   LRec  := FList.Items[i];
   if LCard <> LRec.BaseCard then
      Begin
      LCard  := LRec.BaseCard;
      LCol   := LCard.Columns;
      LWTemp := LWidth / LCol;
      End;
   if LCard.Columns = 1 then
      Begin
      LLeft  := LCard.Margins.Left;
      LRight := LLeft + (LWTemp - LCard.Margins.Left - LCard.Margins.Right);
      End
   Else
      Begin
      if LCol = LCard.Columns then
         Begin
         LLeft  := LWTemp * (LCard.Columns - LCol) + LCard.Margins.Left;
         LRight := LLeft + (LWTemp - LCard.Margins.Left - LCard.Space/2);
         End
      Else
         if LCol > 1 then
            Begin
            LLeft  := LWTemp * (LCard.Columns - LCol) + LCard.Space/2;
            LRight := LLeft + (LWTemp - LCard.Space);
            End
         Else
            Begin
            LLeft  := LWTemp * (LCard.Columns - LCol) + LCard.Space/2;
            LRight := LLeft + (LWTemp - LCard.Space/2 - LCard.Margins.Right);
            End
      End;
   LRec.Bounds := TRectF.Create(LLeft, LPosY+LCard.Margins.Top, LRight, LPosY+LCard.Height);
   Dec(LCol);
   if LCol = 0 then
      Begin
      LPosY := LPosY + LCard.Height + LCard.Margins.Top + LCard.Margins.Bottom;
      LCol  := LCard.Columns;
      End;
   End;
FEndList.Position.X := 1;
FEndList.Position.Y := LPosY;
FEndList.Parent     := Lista;
end;

procedure TCardList.AnimateDelete(aIndex: Integer);
begin
TThread.CreateAnonymousThread(
   Procedure
   Var
      LCard  : TBaseCard;
      LRect  : TRectF;
      LRTmp  : TRectF;
      I      : Integer;
   Begin
   LCard := FList.Items[aIndex].Card;
   LRect := LCard.BoundsRect;
   TThread.Synchronize(Nil,
      Procedure
      Begin
      TAnimator.AnimateFloat(LCard, 'Opacity', 0, 0.2);
      End);

   // Não estava no treinamento, alterei para a animação ficar melhor
   // Inclui uma pausa entre uma animação e outra para os cards não se moverem todos
   // ao mesmo tempo.

   Sleep(100);
   for I := aIndex+1 to FList.Count-1 do
      Begin
      if (FList.Items[I].Card <> Nil) and (FList.Items[I].Card.Data <> Nil) then
         Begin

         // Precisamos armazenar a posição atual, pois se pegar após o synchronize,
         // a animação já alterou os valores.

         LRTmp := FList.Items[I].Card.BoundsRect;
         TThread.Synchronize(Nil,
            Procedure
            Begin
            TAnimator.AnimateFloat(FList.Items[I].Card, 'Position.X', LRect.Left, 0.2);
            TAnimator.AnimateFloat(FList.Items[I].Card, 'Position.Y', LRect.Top,  0.2);
            End);
         LRect := LRTmp;
         Sleep(50);
         End
      Else
         Break;
      End;
   Sleep(160);


   TThread.Synchronize(Nil,
      Procedure
      Var
         I : Integer;
      Begin
      LCard.Opacity := 1;
      LCard.Data    := Nil;
      Flist.Delete(aIndex);
      for i := 0 to FList.Count-1 do
         if FList.Items[I].Card <> Nil then
            Begin
            FList.Items[i].Card.Data := Nil;
            FList.Items[i].Card      := Nil;
            End;
      for i := 0 to FCards.Count-1 do
         FCards.Items[I].ClearData(-1, Height);
      CalculateCardsPositions;
      ShowCards(Lista.ViewportPosition.Y);
      End);
   End).Start;
end;



{ TNewvertScrollBox }

procedure TNewvertScrollBox.AniMouseDown(const Touch: Boolean; const X, Y: Single);
begin
inherited;
FClickY := -1;
AniTop.BringToFront;
AniBot.BringToFront;
end;

procedure TNewvertScrollBox.AniMouseMove(const Touch: Boolean; const X, Y: Single);
Var
   LHeight  : Single;
   LPosX    : Single;
   LX1, LX2 : Single;
begin
inherited;
FPosY := ViewportPosition.Y;
LPosX := 1/Width*X;
if LPosX<0.5 then
   Begin
   LX1 := 0.4 - (0.5 - LPosX);
   LX2 := 0.6 - (0.5 - LPosX);
   End;
if LPosX>0.5 then
   Begin
   LX1 := 0.4 + (LPosX - 0.5);
   LX2 := 0.6 + (LposX - 0.5);
   End;
if FPosY = 0 then
   Begin
   if FClickY = -1 then
      FClickY := Y
   Else
      Begin
      LHeight := Y - FClickY;
      if LHeight > 60 then Lheight := 60;
      AniTop.Height := LHeight;
      AniTop.Data.Data := 'M0,0 C'+LX1.ToString.Replace(',','.')+',1 '+Lx2.ToString.Replace(',','.')+',1 1,0 Z';
      End;
   End;
if Round(FPosY+Height) >= ContentBounds.Height then
   Begin
   if FClickY = -1 then
      FClickY := Y
   Else
      Begin
      LHeight := FClickY - Y;
      if LHeight > 60 then Lheight := 60;
      AniBot.Height := LHeight;
      AniBot.Data.Data := 'M0,1 C'+LX1.ToString.Replace(',','.')+',0 '+Lx2.ToString.Replace(',','.')+',0 1,1 Z';
      End;
   End;
end;

procedure TNewvertScrollBox.AniMouseUp(const Touch: Boolean; const X, Y: Single);
begin
inherited;
FClickY := -1;
if AniTop.Height > 0 then
   TThread.Synchronize(nil,
      Procedure
      Begin
      TAnimator.AnimateFloat(AniTop, 'Height', 0, 0.3);
      End);
if AniBot.Height > 0 then
   TThread.Synchronize(nil,
      Procedure
      Begin
      TAnimator.AnimateFloat(AniBot, 'Height', 0, 0.3);
      End);
end;

end.
