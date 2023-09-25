unit uTesteCardList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, system.Generics.Collections, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects,
  SYstem.JSON,
  uCardList, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, FMX.Layouts;



type
  TForm2 = class(TForm)
    Button1: TButton;
    http: TNetHTTPClient;
    Layout1: TLayout;
    Lin01: TText;
    Lin02: TText;
    CardList1: TCardList;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

Uses
   uImageDownload,
   uCardTeste;

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
Var
   i     : Integer;
   aStr  : TStringStream;
   aArr  : TJsonArray;
   Ltick : Cardinal;
begin

LTick := TThread.GetTickCount;
aStr := TStringStream.Create;
Http.Get('https://app.jusimperium.com.br/Prods5000.json', aStr);
aArr := TJsonObject.ParseJSONValue(aStr.DataString) As TJsonArray;
Lin01.Text := 'Baixar 5000 produtos = '+(TThread.GetTickCount-LTick).ToString+'ms';

LTick := TThread.GetTickCount;
CardTeste.Columns := 2;

CardList1.BeginUpdate;

for i := 0 to aArr.Count-1 do
   CardList1.AddCard(CardTeste, aArr.Items[i] As TJsonObject);

CardList1.EndUpdate;



aStr.DisposeOf;
Lin02.Text := 'Gerar lista de 5000 produtos = '+(TThread.GetTickCount-LTick).ToString+'ms';
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
CardList1.DeleteCard(2);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
TImageDownload.ClearCache;
end;

end.
