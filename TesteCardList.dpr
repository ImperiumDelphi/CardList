program TesteCardList;

uses
  System.StartUpCopy,
  FMX.Forms,
  uTesteCardList in 'uTesteCardList.pas' {Form2},
  uBaseCard in 'CardList\uBaseCard.pas' {BaseCard: TFrame},
  uCardRecord in 'CardList\uCardRecord.pas',
  uCardListRecords in 'CardList\uCardListRecords.pas',
  uCardList in 'CardList\uCardList.pas' {CardList: TFrame},
  uCardTeste in 'Cards\uCardTeste.pas' {CardTeste: TFrame},
  uImagens in 'Imagens\uImagens.pas' {Imagens},
  uImageDownload in 'CardList\uImageDownload.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TImagens, Imagens);
  Application.Run;
end.
