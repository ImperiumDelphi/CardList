unit uCardListRecords;

interface

Uses
   System.Generics.Collections,
   System.JSON,
   uBaseCard,
   uCardRecord;

Type
   TCardListRecords = Class(TObjectList<TCardRecord>)
   Public
      Procedure AddRecord   (aCard  : TBaseCard; aData : TJsonObject);
      Procedure InsertRecord(aIndex : Integer; aCard : TBaseCard; aData : TJsonObject);
   End;

implementation

{ TCardListRecords }

procedure TCardListRecords.AddRecord(aCard: TBaseCard; aData: TJsonObject);
begin
Add(TCardRecord.Create(aCard, aData));
end;

procedure TCardListRecords.InsertRecord(aIndex: Integer; aCard: TBaseCard; aData: TJsonObject);
begin
Insert(aIndex, TCardRecord.Create(aCard, aData));
end;

end.
