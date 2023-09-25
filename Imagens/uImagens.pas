unit uImagens;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TImagens = class(TForm)
    ImgCarga: TImage;
    ImgFalha: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Imagens: TImagens;

implementation

{$R *.fmx}

end.
