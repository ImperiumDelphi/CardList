unit uCardRecord;

interface

Uses
   System.Types,
   System.JSON,
   uBaseCard;

Type TCardRecord = Class
  private
    FCard: TBaseCard;
    FData: TJsonObject;
    FBounds: TRectF;
    FBaseCard: TBaseCard;
    procedure SetCard(const Value: TBaseCard);
  protected
  Public
    Constructor Create(aCard : TBaseCard; aData : TJsonObject); Virtual;
    Property BaseCard : TbaseCard   Read FBaseCard  Write FBaseCard;
    Property Card     : TBaseCard   Read FCard      Write SetCard;
    Property Data     : TJsonObject Read FData      Write FData;
    Property Bounds   : TRectF      Read FBounds    Write FBounds;
End;

implementation

{ TCardRecord }

constructor TCardRecord.Create(aCard: TBaseCard; aData: TJsonObject);
begin
FBaseCard := aCard;
FData     := aData;
end;

procedure TCardRecord.SetCard(const Value: TBaseCard);
begin
FCard := Value;
end;

end.
