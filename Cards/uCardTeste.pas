unit uCardTeste;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, uBaseCard, FMX.Objects, FMX.Effects,
  System.Json;

type
  TCardTeste = class(TBaseCard)
    Rectangle1: TRectangle;
    GlowEffect1: TGlowEffect;
    Image1: TImage;
    Nome: TText;
    Preco: TText;
    BTAdc: TRectangle;
    Text1: TText;
    procedure BTAdcClick(Sender: TObject);
    procedure BTAdcTap(Sender: TObject; const Point: TPointF);
  Protected
    Procedure Clear; Override;
    Procedure MoveData; Override;
  private
    Procedure ClickAdc;
  public
    Function GetUrl(aImage : TBitmap) : String; Override;
  end;

var
  CardTeste: TCardTeste;

implementation

Uses
   uImageDownload;

{$R *.fmx}

{ TBaseCard1 }

procedure TCardTeste.BTAdcClick(Sender: TObject);
begin
inherited;
{$IFDEF MSWINDOWS}
ClickAdc;
{$ENDIF}
end;

procedure TCardTeste.BTAdcTap(Sender: TObject; const Point: TPointF);
begin
inherited;
{$IFNDEF MSWINDOWS}
ClickAdc;
{$ENDIF}
end;

procedure TCardTeste.ClickAdc;
begin
ShowMessage('Adicionar produto id = '+Data.GetValue<String>('id'));
end;

procedure TCardTeste.Clear;
begin
Image1.Bitmap := Nil;
Nome.Text := '';
Preco.Text := '';
end;

function TCardTeste.GetUrl(aImage: TBitmap): String;
begin
Result := 'https://app.jusimperium.com.br/Produtos/Imagens/Produtos/Prod_'+Data.GetValue<String>('id')+'.png';
end;

procedure TCardTeste.MoveData;
Var
   P : Single;
begin
TImageDownload.DownloadImage(Self, Image1.Bitmap);
P := Data.GetValue('price').Value.ToSingle;
Nome.Text := Data.GetValue<String>('name');
preco.Text := FormatFloat('##,###,##0.00',P);
end;

Initialization
CardTeste := TCardTeste.Create(Nil);

Finalization
CardTeste.DisposeOf;

end.

