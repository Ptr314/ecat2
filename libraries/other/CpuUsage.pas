unit CpuUsage;

{
Пример получения информации о загрузке процессоров
Автор: Набережных С.Н. naberegnyhs@rambler.ru
Источник: http://code.progler.ru/view/13

Инициализация:

var
	Info: TSystemInfo;

	GetSystemInfo(Info);
	FQuery:=TPDHQuery.Create;
	for Id:=0 to Info.dwNumberOfProcessors - 1 do
		Cnt[Id] := TCounter.Create(FQuery, Id);

Получение значения (например, по таймеру):
	FQuery.Refresh;
	for Id:=0 to Info.dwNumberOfProcessors - 1 do
		Str[Id] := FloatToStrF(Cnt[Id].Value, ffFixed, 8, 1);

Завершение:
	FQuery.Free;
	for Id:=0 to Info.dwNumberOfProcessors - 1 do
		Cnt[Id].Free;

Примечание: Если нужно получить общую загрузку без разбиения по процессорам,
можно создать только один счетчик и отказаться от GetSystemInfo и циклов:
	Cnt := TCounter.Create(FQuery, -1);

}

interface

uses
	Windows, Messages, SysUtils;

type
	TPDHQuery = class;

	TCounter = class
	private
		FHandle: THandle;
		FQuery: TPDHQuery;
		function GetValue: Double;
	protected
    FID: integer;
  public
		constructor Create(AOwner: TPDHQuery; CpuID: integer);
    destructor Destroy; override;
    property Value: Double read GetValue;
  end;

  TPDHQuery = class
  private
    FHandle: THandle;
    FLocale: integer;
	protected
    function FormatID(ID: integer): WideString;
  public
    constructor Create;
    destructor Destroy; override;
		procedure Refresh;
  end;

implementation

const
  PDHLIB = 'Pdh.dll';

function PdhOpenQueryW(DataSource: PWideChar; UserData: Cardinal;
                       var hQuery: THandle): ULONG; stdcall; external PDHLIB;
function PdhCloseQuery(hQuery: THandle): ULONG; stdcall; external PDHLIB;
function PdhValidatePathW(FullPath: PWideChar): ULONG; stdcall; external PDHLIB;
function PdhAddCounterW(hQuery: THandle; FullCounterPath: PWideChar;
                        UserData: Cardinal; var hCounter: THandle)
                        : ULONG; stdcall; external PDHLIB;
function PdhCollectQueryData(hQuery: THandle): ULONG; stdcall; external PDHLIB;
function PdhVbGetDoubleCounterValue(hCounter: THandle; pStatus: PDWORD)
                         : Double; stdcall; external PDHLIB;
function PdhRemoveCounter(hCounter: THandle): ULONG; stdcall; external PDHLIB;

{ TPDHQuery }

constructor TPDHQuery.Create;
var
  Rslt: ULONG;
begin
	FLocale:=GetSystemDefaultLCID;
	if (FLocale <> 1033) and (FLocale <> 1049) then
		raise Exception.Create('current language not supported.');
	Rslt:=PdhOpenQueryW(nil, 0, FHandle);
	if Rslt <> ERROR_SUCCESS then
		raise Exception.Create('Function OpenQuery failed.');
end;

destructor TPDHQuery.Destroy;
begin
	if FHandle <> 0 then
		PdhCloseQuery(FHandle);
	inherited;
end;

function TPDHQuery.FormatID(ID: integer): WideString;
const
  ID_009: WideString = '\Processor(%s)\%% Processor Time';
  ID_019: WideString = '\Процессор(%s)\%% загруженности процессора';
var
  CPUID: string;
  Fmt: WideString;
begin
  if ID < 0 then CPUID:='_Total' else CPUID:=IntToStr(ID);
  if FLocale = 1033 then Fmt:=ID_009 else Fmt:=ID_019;
  Result:=Format(Fmt, [CPUID]);
end;

procedure TPDHQuery.Refresh;
var
  Rslt: ULONG;
begin
  Rslt:=PdhCollectQueryData(FHandle);
  if Rslt <> ERROR_SUCCESS then
    raise Exception.Create('Function CollectQueryData failed.');
end;

{ TCounter }

constructor TCounter.Create(AOwner: TPDHQuery; CpuID: integer);
var
  ws: WideString;
  Rslt: ULONG;
begin
  FQuery:=AOwner;
  FID:=CpuID;
  ws:=FQuery.FormatID(CpuID);
  Rslt:=PdhValidatePathW(PWideChar(ws));
  if Rslt <> ERROR_SUCCESS then
    raise Exception.CreateFmt('CPU ID %d is invalid.', [CpuID]);
  Rslt:=PdhAddCounterW(FQuery.FHandle, PWideChar(ws), 0, FHandle);
  if Rslt <> ERROR_SUCCESS then
    raise Exception.Create('Function AddCounter failed.');
end;

destructor TCounter.Destroy;
begin
  PdhRemoveCounter(FHandle);
  inherited;
end;

function TCounter.GetValue: Double;
var
  Status: DWORD;
begin
  Result:=PdhVbGetDoubleCounterValue(FHandle, @Status);
end;

end.


