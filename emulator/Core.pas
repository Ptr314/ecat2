unit Core;
{
English:

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.

		Author: Panther <http://www.emuverse.ru/wiki/User:Panther>

Russian:
		Этот файл является свободным программным обеспечением, вы можете
		распространять и изменять его на условиях лицензии GNU General Public
		License, опубликованной Free Software Foundation, версии 3, или
		более поздней, на ваше усмотрение.

		Программа распространяется с надеждой, что она окажется полезной,
		но БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, в том числе подразумеваемых гарантий
		КОММЕРЧЕСКОЙ ЦЕННОСТИ или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ.
		Подробнее смотрите текст лицензии GNU General Public License.

		Копия текста лицензии должна поставляться вместе с этим файлом,
		в противном случае вы можете получить ее по адресу
		<http://www.gnu.org/licenses/>

		Автор: Panther <http://www.emuverse.ru/wiki/User:Panther>
}

{$DEFINE CACHE_STATS}

//Описание основных структур и классов, составляющие ядро эмуляции

interface

uses  SysUtils, Forms, Graphics, Dialogs, Math,
			Config,
			Utils;

const
			cMaxInterfaces = 200;
			cMaxLinks = 100;
			cMaxLinkSize = 10;
type
			TStorage = array [0..10*1024*1024] of Byte;
			PStorage = ^TStorage;

			TScreenColor = array [0..2] of Byte;

			TInterfaceCallbackFunc = procedure (NewValue, OldValue: Cardinal) of object;

			TInterfaceManager = class;
			TInterface = class;

			TSystemData = record
				SystemFile: String;
				SystemPath: String;
				SystemType: String;
				SystemName: String;
				SystemVersion: String;
				SystemCharMap: String;
				SoftwarePath: String;
				ScreenRatio: Extended;
				ScreenScale: Cardinal;
				AllowedFiles: String;
				MapperCache: Cardinal;
			end;

			TComputerDevice = class
			private
				FType: String;
				FName: String;
				FClockStored: Cardinal;
				FClockMiltiplier: Cardinal;
				FClockDivider: Cardinal;
			protected
				FIM: TInterfaceManager;
				FConfigData: TEmulatorConfigDevice;
				function CreateInterface(	Size: Cardinal;
																	Name: String;
																	IMode: Cardinal;
																	CallBack: TInterfaceCallbackFunc = nil):TInterface;
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure Reset(isCold:Boolean); virtual;
				procedure LoadConfig(const SD:TSystemData); virtual;
				property DType: String read FType write FType;
				property Name: String read FName write FName;
				property IM: TInterfaceManager read FIM;
				//procedure LoadXMLConfig(XMLNode: TXmlNode); virtual;
				procedure Clock(Counter:Cardinal); virtual;
				procedure SystemClock(Counter:Cardinal); virtual;
			end;

			TAddressableDevice = class (TComputerDevice)
			protected
				function GetValue(Address:Cardinal):Cardinal; virtual; abstract;
				procedure SetValue(Address:Cardinal; Value:Cardinal); virtual; abstract;
			public
				property Value[Address:Cardinal]:Cardinal read GetValue write SetValue; default;
			end;

			TMemoryCallback = procedure (Address: Cardinal) of Object;
			TMemory = class (TAddressableDevice)
			private
				FSize: Cardinal;
				FFill: Byte;
				FCanRead: Boolean;
				FCanWrite: Boolean;
				FBuffer: PStorage;
				FReadCallback: TMemoryCallback;
				FWriteCallback: TMemoryCallback;
				procedure SetSize(Value:Cardinal);
			protected
				FIAddress: TInterface;
				FIData: TInterface;
				function GetValue(Address:Cardinal):Cardinal; override;
				procedure SetValue(Address:Cardinal; Value:Cardinal); override;
				procedure AddressChanged(NewValue, OldValue: Cardinal); virtual; 
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure SetCallback(F:TMemoryCallback; Mode:Cardinal);
				property CanRead:Boolean read FCanRead;
				property CanWrite:Boolean read FCanWrite;
				property Size:Cardinal read FSize write SetSize;
				property Fill:Byte read FFill write FFill;
				property Buffer:PStorage read FBuffer;
				destructor Destroy; override;
			end;

			TROM = class (TMemory)
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure LoadConfig(const SD:TSystemData); override;
			end;

			TRAM = class (TMemory)
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure LoadConfig(const SD:TSystemData); override;
				procedure Reset(isCold:Boolean); override;
			end;

			TPort = class (TAddressableDevice)
			private
				FSize: Cardinal;
				FIInput: TInterface;
				FIData: TInterface;
				FFlipMask: Cardinal;
				FIAccess: TInterface;
				FIFlip: TInterface;
				procedure FlipChanged(NewValue, OldValue: Cardinal);
			protected
				FValue: Cardinal;
				function GetValue(Address:Cardinal):Cardinal; override;
				procedure SetValue(Address:Cardinal; Value:Cardinal); override;
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure Reset(isCold:Boolean); override;
			end;

			TPortAddress = class (TPort)
			protected
				procedure SetValue(Address:Cardinal; Value:Cardinal); override;
			end;

			TDeviceDescription = record
				Device: TComputerDevice;
				DeviceType: string [50];
				DeviceName: string [50];
			end;

			TDeviceManager = class
			private
				FDevicesCount: Integer;
				FDevices: array [0..100] of TDeviceDescription;
				//FError: Boolean;
				FErrorMsg: String;
				FErrorDevice: TComputerDevice;
				function GetDevice(Index:Integer):TDeviceDescription;
			public
				constructor Create;
				procedure AddDevice(IM:TInterfaceManager; ConfigDevice: TEmulatorConfigDevice);
				procedure Clear;
				procedure LoadDevicesConfig(const SD:TSystemData);
				function GetDeviceByName(Name:String; Required:Boolean=True):TComputerDevice;
				function GetDeviceIndex(Name:String):Integer;
				procedure ResetDevices(isCold:Boolean);
				procedure Clock(Counter:Cardinal);
				procedure Error(Device:TComputerDevice; Msg:String);
				procedure ErrorClear;
				property DevicesCount:Integer read FDevicesCount;
				property Devices[Index:Integer]: TDeviceDescription read GetDevice; default;
				property ErrorDevice: TComputerDevice read FErrorDevice;
				property ErrorMsg: String read FErrorMsg;
				destructor Destroy; override;
			end;

			TLinkedInterface = record
				I: TInterface;
				Mask: Cardinal;
				Shift: Cardinal;
			end;

			TLinkData = record
				S: TLinkedInterface;
				D: TLinkedInterface;
			end;
			
			TInterface = class
			private
				FSize: Cardinal;
				FValue: Cardinal;
				FOldValue: Cardinal; //Предыдущее значение для процедуры установки
				FEdgeValue: Cardinal; //Предыдущее значение для триггера фронтов
				FMask: Cardinal;
				FMode: Cardinal;
				FIM: TInterfaceManager;
				FName: String;
				FDevice: TComputerDevice;
				FLinked: Integer;
				FLinkedBits: Cardinal;
				FLinkedInterfaces: array [0..cMaxLinks-1] of TLinkData;
				FCallBack: TInterfaceCallbackFunc;
				procedure SetSize(V: Cardinal);
				procedure SetMode(V: Cardinal);
			public
				constructor Create(	Device:TComputerDevice;
														IM:TInterfaceManager;
														IntSize:Cardinal;
														Name:String;
														IMode: Cardinal;
														CallBack: TInterfaceCallbackFunc = nil);
				property Value:Cardinal read FValue;
				property Mask:Cardinal read FMask;
				property Name:String read FName;
				property Device:TComputerDevice read FDevice;
				property Size:Cardinal read FSize write SetSize;
				property Mode:Cardinal read FMode write SetMode;
				property Linked: Integer read FLinked;
				property LinkedBits: Cardinal read FLinkedBits;
				procedure Connect(S, D:TLinkedInterface);
				procedure Change(Value: Cardinal); //Вызывается устройством для изменения выхода
				procedure Changed(Link:TLinkData; Value: Cardinal); //Вызывается связанными интерфейсами
																														//при изменении значения на них
				procedure Clear;
				function PosEdge: Boolean;	//Триггеры фронтов для 0-го бита
				function NegEdge: Boolean;
			end;

			TInterfaceManager = class
			private
				FInterfacesCounter: Cardinal;
				FInterfaces: array [0..cMaxInterfaces-1] of TInterface;
				//FLinks: array [0..cMaxLinks-1, 0..cMaxLinkSize-1] of TLinkData;
				FDM: TDeviceManager;
			public
				constructor Create(DM:TDeviceManager);
				procedure RegisterInterface(Int:TInterface);
				function GetInterfaceByName(DevName, IntName:String):TInterface;
				procedure Clear;
				//procedure RegisterLink(const LinkData: TLinkData);
				procedure InterfaceChanged(I:TInterface);
				property DM: TDeviceManager read FDM;
				destructor Destroy; override;
			end;

			TMapperRange = record
				ConfigMask: Cardinal;			//AND-маска, которая накладывается на значение порта конфигурации
				ConfigValue: Cardinal;		//Число, с которым сравнивается значение порта после маски
				RangeBegin: Cardinal;			//Адрес начала диапазона
				RangeEnd: Cardinal;				//Адрес конца диапазона
				AddressMask: Cardinal;		//AND-маска, которая накладывается на адрес
				AddressValue: Cardinal;		//Число, с которым сравнивается адрес после маски
				Device: TComputerDevice;	//Устройство, соответствующее наложенным условиям
				Base: Cardinal;						//Адрес во внутр. адр. пр-ве устройства, соотв. RangeBegin системы
				Mode: Cardinal;						//Режим допустимости чтения-записи для устройства
				Cache: Boolean;						//Разрешение кеширования записи
			end;

			TMapperCacheEntry = record
				CRangeBegin: Cardinal;
				CRangeEnd: Cardinal;
				CDevice: TComputerDevice;
				CBase: Cardinal;
				CCounter: Cardinal;
			end;
			TMapperCache = array [0..15] of TMapperCacheEntry;

			TMemoryMapper = class (TComputerDevice)
			private
				FIConfig: TInterface;
				FIAddress: TInterface;
				FRangesCount:Cardinal;
				FPortsToMem: Boolean;
				FPortsMask: Cardinal;
				FCancelInitMask: Cardinal;
				FFirstRange: Cardinal;
				FRanges: array [0..100] of TMapperRange;
				FPortsCount:Cardinal;
				FPorts: array [0..100] of TMapperRange;

				FCacheSize: Cardinal;
				FReadCache: TMapperCache;
				FWriteCache: TMapperCache;
				FReadCacheItems: Cardinal;
				FWriteCacheItems: Cardinal;
				procedure ConfigChanged(NewValue, OldValue: Cardinal);
				procedure AddCacheEntry(var Cache: TMapperCache; var CacheItems: Cardinal; const Range:TMapperRange);
			public
				{$IFDEF CACHE_STATS}
				CacheHit: Cardinal;
				CacheMiss: Cardinal;
				{$ENDIF}
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure LoadConfig(const SD:TSystemData); override;
				function Read(Address:Cardinal):Cardinal;
				procedure Write(Address, Value:Cardinal);
				function ReadPort(Address:Cardinal):Cardinal;
				procedure WritePort(Address, Value:Cardinal);
				procedure Reset(isCold:Boolean); override;
				procedure SortCacheItems;
			end;

			TPageMapper = class (TAddressableDevice)
			private
				FPagesCount: Cardinal;
				FPages : array[0..15] of TMemory;
				FFrame : Cardinal;
				FIPage: TInterface;
				FISegment: TInterface;
				FPageMask: Cardinal;
				FSegmentMask: Cardinal;
			protected
				function GetValue(Address:Cardinal):Cardinal; override;
				procedure SetValue(Address:Cardinal; Value:Cardinal); override;
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				procedure LoadConfig(const SD:TSystemData); override;
			end;

			TCPU = class(TComputerDevice)
			private
				FClock: Cardinal;
				FMM: TMemoryMapper;
				FDebugMode: Cardinal;
				FBreakCount:Integer;												//Счетчик контрольных точек
				FBreakPoints: array [0..15] of Cardinal;		//Адреса контрольных точек
			protected
				FIAddress: TInterface;
				FIData: TInterface;
				FReset: Boolean;
				function GetPC:Cardinal; virtual; abstract;
				{$IFDEF REC_CONTEXT}
				function GetContextCRC:Word; virtual; abstract;
				{$ENDIF}
			public
				procedure LoadConfig(const SD:TSystemData); override;
				property ClockValue: Cardinal read FClock write FClock;
				property Mapper: TMemoryMapper read FMM;
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				function Execute:Cardinal; virtual; abstract;
				property DebugMode: Cardinal read FDebugMode write FDebugMode;
				property BreakCount: Integer read FBreakCount write FBreakCount;
				function CheckBreakPoint(Address: Cardinal):Boolean;
				procedure AddBreakPoint(Addr: Cardinal);
				procedure RemoveBreakPoint(Addr: Cardinal);
				procedure ClearBreakPoints;
				procedure Reset(isCold:Boolean); override;
				property ContextPC:Cardinal read GetPC;
				{$IFDEF REC_CONTEXT}
				property ContextCRC:Word read GetContextCRC;
				{$ENDIF}
			end;

			TDisplay = class (TComputerDevice)
			protected
				FBitMap: TBitmap;
				FSX: Cardinal;
				FSY: Cardinal;
				FValid: Boolean;
				FRepaint: Boolean;
			public
				constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
				destructor Destroy; override;
				property SX:Cardinal read FSX;
				property SY:Cardinal read FSY;
				function GetScreen(Required:Boolean):TBitmap; virtual; abstract;
			end;

			TDeviceCreateFunc = function(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;

			TDeviceCreateFuncData = record
				DType: String;
				CreateFunc: TDeviceCreateFunc;
			end;

			PartsRec=packed record
				case Integer of
					0: (L, H:Byte);
					1: (W:Word);
					2: (C:Cardinal);
			end;
			T8BitInstrRec=record
				Address:Integer;
				Code:Byte;
				IsTrue:Boolean;
				Len: Integer;
				Txt: String[31];
			end;

			TTapeBuffer = record
				Length: Cardinal;
				Data: PStorage;
			end;


const
	cMaxDeviceCreateFuncs = 100;

const
	MODE_OFF = 0;
	MODE_R = 1;
	MODE_W = 2;
	MODE_RW = MODE_R + MODE_W;

	//Виды операций для дизассемблирования
	OP_SIMPLE=0;
	OP_DATA8=1;
	OP_DATA16=2;
	OP_ADDR16=3;

	DEBUG_OFF=0;
	DEBUG_STOPPED=1;
	DEBUG_STEP=2;
	DEBUG_BRAKES=3;


var
		DeviceCreateFuncData: array [0..cMaxDeviceCreateFuncs-1] of TDeviceCreateFuncData;
		DeviceCreateFuncsCount: Cardinal;

procedure RegisterDeviceCreateFunc(Typ: String; Func:Pointer);
function CreateDevice(IM:TInterfaceManager; Typ: String; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;

implementation

constructor TComputerDevice.Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
var ClockStr: String;
		P: Integer;
begin
	FIM := IM;
	FConfigData := ConfigDevice;
	DType := FConfigData.DType;
	Name := FConfigData.Name;
	try
		ClockStr := FConfigData.Parameters['clock'].Value;
		if ClockStr<>'' then begin
			P := Pos('/', ClockStr);
			if P>0 then begin
				FClockMiltiplier := ParseNumericValue(Copy(ClockStr, 1, P-1));
				FClockDivider := ParseNumericValue(Copy(ClockStr, P+1, Length(ClockStr)-P));
			end else begin
				FClockMiltiplier := ParseNumericValue(ClockStr);
				FClockDivider := 1;
			end;
		end else
			Abort;
	except
		FClockMiltiplier := 1;
		FClockDivider := 1;
	end;
	FClockStored := 0;
end;

procedure TComputerDevice.LoadConfig(const SD:TSystemData);
var i:Integer;
		ParaName, IntName, Conn, SBits, TBits, ConDevName, ConIntName: String;
		SBit1, SBit2, TBit1, TBit2: Cardinal;
		P:Integer;
		LD:TLinkData;
begin
	for i:=0 to FConfigData.ParametersCount-1 do begin
		ParaName := FConfigData.Parameter[i].Name;
		if ParaName[1] = '~' then begin
			IntName := copy(ParaName, 2, Length(ParaName));
			if IntName='' then
				raise Exception.Create('Для устройства '''+Name+''' не указано название интерфейса!');

			LD.S.I:= IM.GetInterfaceByName(Name, IntName);

			Conn := FConfigData.Parameter[i].Value;
			if Conn='' then
				raise Exception.Create('Для интерфейса '''+Name+'.'+IntName+''' не указано подключение!');
			P := Pos('.', Conn);
			ConDevName := Copy(Conn, 1, P-1);
			ConIntName := Copy(Conn, P+1, Length(Conn)-P);
			LD.D.I := IM.GetInterfaceByName(ConDevName, ConIntName);

			SBits := FConfigData.Parameter[i].Left_range;
			if SBits<>'' then begin
				SBits := Copy(SBits, 2, Length(SBits)-2);
				ConvertRange(SBits, SBit1, SBit2);
				LD.S.Shift := SBit1;
				LD.S.Mask := CreateMask(SBit2 - SBit1 + 1, SBit1);
			end else begin
				LD.S.Shift := 0;
				LD.S.Mask := CreateMask(LD.S.I.Size, 0);
			end;
			
			TBits := FConfigData.Parameter[i].Right_range;
			if TBits<>'' then begin
				TBits := Copy(TBits, 2, Length(TBits)-2);
				ConvertRange(TBits, TBit1, TBit2);
				LD.D.Shift := TBit1;
				LD.D.Mask := CreateMask(TBit2 - TBit1 + 1, TBit1);
			end else begin
				LD.D.Shift := 0;
				LD.D.Mask := CreateMask(LD.D.I.Size, 0);
			end;

			LD.S.I.Connect(LD.S, LD.D);
		end;
	end;
end;

function TComputerDevice.CreateInterface;
var I:TInterface;
begin
	I := TInterface.Create(self, FIM, Size, Name, IMode, CallBack);
	Result := I;
end;

procedure TComputerDevice.Reset;
begin
	//По умолчанию ничего не делает
	//Метод может быть переопределен наследниками
	//Если им нужна реакция на сброс
end;

procedure TComputerDevice.SystemClock(Counter:Cardinal);
var InternalClock: Cardinal;
begin
	if FClockMiltiplier =	FClockDivider then
		Clock(Counter)
	else begin
		Inc(FClockStored, Counter*FClockMiltiplier);
		InternalClock := FClockStored div FClockDivider;
		if InternalClock > 0 then begin
			Clock(InternalClock);
			Dec(FClockStored, InternalClock * FClockDivider);
		end;
	end;
end;

procedure TComputerDevice.Clock;
begin
	//По умолчанию ничего не делает
	//Метод может быть переопределен наследниками
	//Если им нужно тактирование
end;

constructor TMemory.Create;
begin
	inherited Create(IM, ConfigDevice);
	FSize := 0;
	FFill := 0;
	FCanRead := false;
	FCanWrite := false;
	FBuffer := nil;

	FIAddress := CreateInterface(16, 'address', MODE_R, AddressChanged);
	FIData := CreateInterface(8, 'data', MODE_W);

	FReadCallback := nil;
	FWriteCallback := nil;
end;

procedure TMemory.SetSize(Value:Cardinal);
var i:Integer;
begin
	if FBuffer<>nil then FreeMem(FBuffer);
	FSize := Value;
	GetMem(FBuffer, FSize);

	for i:=0 to FSize-1 do
		FBuffer^[i]:=Random(255);
end;

function TMemory.GetValue(Address:Cardinal):Cardinal;
begin
	if CanRead and (Address < FSize) then Result := FBuffer[Address]
	else Result := $FF;
	if Assigned(FReadCallback) then FReadCallback(Address);
end;

procedure TMemory.SetValue(Address:Cardinal; Value:Cardinal);
begin
	if CanWrite and (Address < FSize) then FBuffer[Address] := Byte(Value);
	if Assigned(FWriteCallback) then FWriteCallback(Address);
end;

procedure TMemory.AddressChanged(NewValue, OldValue: Cardinal);
var Address: Cardinal;
begin
	Address := NewValue and CreateMask(FIAddress.Size, 0);
	if Address < FSize then
		if FType='rom' then FIData.Change(FBuffer[Address])
end;

procedure TMemory.SetCallback(F:TMemoryCallback; Mode:Cardinal);
begin
	if (Mode and MODE_R > 0) then FReadCallback := F;
	if (Mode and MODE_W > 0) then FWriteCallback := F;
end;

destructor TMemory.Destroy;
begin
	if FBuffer<>nil then FreeMem(FBuffer);
	inherited Destroy;
end;

constructor TROM.Create;
begin
	inherited Create(IM, ConfigDevice);
	FCanRead := true;
	FCanWrite := false;
end;

procedure TROM.LoadConfig;
var H, L:Integer;
		FileName: String;
begin
	inherited LoadConfig(SD);
	Size:=ParseNumericValue(FConfigData.Parameters['size'].Value);

	try
		Fill := ParseNumericValue(FConfigData.Parameters['fill'].Value);
	except
		Fill := $FF;
	end;

	if FBuffer<>nil then FillChar(FBuffer^, Size, Fill);

	FileName := SD.SystemPath + FConfigData.Parameters['image'].Value;

	H := FileOpen(FileName, fmOpenRead);
	if H >= 0 then begin
		L := FileSeek(H,0,2);
		if L > Integer(Size) then
			raise Exception.Create('Файл для устройства '''+Name+''' превышает выделенный диапазон памяти!');
		FileSeek(H,0,0);
		FillChar(FBuffer^, Size, $FF);
		FileRead(H, FBuffer^, L);
		FileClose(H);
	end else            
		raise Exception.Create('Файл '''+FileName+''' не найден!');

end;

constructor TRAM.Create;
begin
	inherited Create(IM, ConfigDevice);
	FCanRead := true;
	FCanWrite := true;
end;

procedure TRAM.LoadConfig;
begin
	inherited LoadConfig(SD);
	Size:=ParseNumericValue(FConfigData.Parameters['size'].Value);
	try
		Fill := ParseNumericValue(FConfigData.Parameters['fill'].Value);
	except
		Fill := $00;
	end;
	Reset(TRUE);
end;

procedure TRAM.Reset(isCold:Boolean);
begin
	if (isCold) and (FBuffer<>nil) then FillChar(FBuffer^, Size, Fill);
end;

constructor TPort.Create;
begin
	inherited Create(IM, ConfigDevice);
	FValue := Cardinal(0);

	try
		FSize := ParseNumericValue(FConfigData.Parameters['size'].Value);
	except
		FSize := 8;
	end;

	try
		FFlipMask := ParseNumericValue(FConfigData.Parameters['flipmask'].Value);
	except
		FFlipMask := Cardinal(-1);
	end;

	FIInput := CreateInterface(FSize, 'data', MODE_R);
	FIData := CreateInterface(FSize, 'value', MODE_W);

	FIAccess := CreateInterface(1, 'access', MODE_W);
	FIFlip := CreateInterface(1, 'flip', MODE_R, FlipChanged);
end;

function TPort.GetValue(Address:Cardinal):Cardinal;
begin
	Result := FValue;
end;

procedure TPort.SetValue(Address:Cardinal; Value:Cardinal);
begin
	FIAccess.Change(0);
	FValue := Value;
	FIData.Change(FValue);
	FIAccess.Change(1);
end;

procedure TPort.Reset(isCold:Boolean);
begin
	{if isCold then} SetValue(0, 0);
end;

procedure TPort.FlipChanged(NewValue, OldValue: Cardinal);
begin
	if (OldValue and $1 = 1) and (NewValue and $1 = 0) then
		SetValue(0, FValue xor FFlipMask);
end;

procedure TPortAddress.SetValue(Address:Cardinal; Value:Cardinal);
begin
	FIAccess.Change(0);
	FValue := Address;
	FIData.Change(FValue);
	FIAccess.Change(1);
end;

constructor TDeviceManager.Create;
begin
	FDevicesCount := 2;
	FErrorMsg := '';
	FErrorDevice := nil;
end;

destructor TDeviceManager.Destroy;
begin
	Clear;
	inherited Destroy;
end;

procedure TDeviceManager.AddDevice;
var Name:String;
		Index: Cardinal;
begin
	Name := ConfigDevice.Name;

	if Name='cpu' then Index := 0
	else
	if Name='mapper' then Index := 1
	else begin
		Inc(FDevicesCount);
		Index := FDevicesCount-1;
	end;

	with FDevices[Index] do begin
		DeviceType := AnsiLowerCase(ConfigDevice.DType);
		DeviceName := Name;
		Device := CreateDevice(IM, DeviceType, ConfigDevice);
	end;
end;

procedure TDeviceManager.LoadDevicesConfig(const SD:TSystemData);
var i:Cardinal;
begin
	for i:=0 to FDevicesCount-1 do FDevices[i].Device.LoadConfig(SD);
end;

function TDeviceManager.GetDeviceByName(Name:String; Required:Boolean=True):TComputerDevice;
var i:Cardinal;
begin
	Result := nil;
	for i:=0 to FDevicesCount-1 do
		if FDevices[i].Device.Name=Name then begin
			Result := FDevices[i].Device;
			break;
		end;
	if (Result = nil) and Required then
		raise Exception.Create('Устройство '''+Name+''' не найдено!');
end;

function TDeviceManager.GetDeviceIndex(Name:String):Integer;
var i:Integer;
begin
	Result := -1;
	for i:=0 to FDevicesCount-1 do
		if FDevices[i].Device.Name=Name then begin
			Result := i;
			break;
		end;
	if Result < 0 then
		raise Exception.Create('Устройство '''+Name+''' не найдено!');
end;

function TDeviceManager.GetDevice(Index:Integer):TDeviceDescription;
begin
	Result := FDevices[Index];
end;

procedure TDeviceManager.Clear;
var i:Integer;
begin
	for i:=0 to FDevicesCount-1 do FDevices[i].Device.Free;
	FDevicesCount := 2;
	FillChar(FDevices,SizeOf(FDevices), 0);
end;


constructor TMemoryMapper.Create;
begin
	inherited Create(IM, ConfigDevice);
	FRangesCount := 0;
	FPortsCount := 0;
	FPortsToMem := TRUE;
	FFirstRange := 1;
	FCancelInitMask := 0;
	FIAddress := CreateInterface(16, 'address', MODE_R);
	FIConfig := CreateInterface(8, 'config', MODE_R, ConfigChanged);
	FReadCacheItems := 0;
	FWriteCacheItems := 0;
	{$IFDEF CACHE_STATS}
	CacheHit := 0;
	CacheMiss := 0;
	{$ENDIF}
end;

procedure TMemoryMapper.LoadConfig;
var i, j, Index:Cardinal;
		Addr, M, C, Range, MaskStr, ParamName: String;
		P: Integer;
		ConfigDev: String;
		LD:TLinkData;
		MR: TMapperRange;
begin
	inherited LoadConfig(SD);
	//Соединить FIConfig с FXMLConfig.AttributeByName['config']

	FCacheSize := SD.MapperCache;
	if FCacheSize > SizeOf(TMapperCache)/SizeOf(TMapperCacheEntry) then
		raise Exception.Create('Размер кеша Mapper не должен первышать ' +
					IntToStr(SizeOf(TMapperCache) div SizeOf(TMapperCacheEntry)));

	try
		ConfigDev := FConfigData.Parameters['config'].Value;
	except
		ConfigDev := '';
	end;

	if ConfigDev<>'' then begin
		LD.D.I := IM.GetInterfaceByName(ConfigDev, 'value');
		LD.D.Shift := 0;
		LD.D.Mask := CreateMask(LD.D.I.Size, 0);

		LD.S.I := IM.GetInterfaceByName(Name, 'config');
		LD.S.I.Size := LD.D.I.Size; 
		LD.S.Shift := 0;
		LD.S.Mask := CreateMask(LD.S.I.Size, 0);

		LD.S.I.Connect(LD.S, LD.D);
	end else
		FIConfig.Change(0);

	try
		FPortsToMem := FConfigData.Parameters['portstomemory'].Value='1';
	except
		FPortsToMem := False;
	end;

	try
		if FConfigData.Parameters['wideports'].Value='0' then
			FPortsMask := $FF
		else
			FPortsMask := Cardinal(-1);
	except
		FPortsMask := $FF
	end;

	try
		M := FConfigData.Parameters['cancelinit'].Value;
		FCancelInitMask := ParseNumericValue(M)
	except
		FCancelInitMask := 0;
	end;

	//Загрузка диапазонов
	for i := 0 to FConfigData.ParametersCount - 1 do begin
		ParamName := FConfigData.Parameter[i].Name;
		if (ParamName = '@memory') or (ParamName = '@port') then begin
			Range := FConfigData.Parameter[i].Left_range;
			P := Pos('][', Range);
			if P>0 then begin
				C := Copy(Range, 2, P-2);
				Addr := Copy(Range, P+2, Length(Range) - P - 2);
				P := Pos(':', C);
				if P>0 then begin
					MaskStr := copy(C, P+1, Length(C)-P);
					C := copy(C, 1, P-1);
				end;
			end else begin
				C := '';
				Addr := Copy(Range, 2, Length(Range) - 2);
				MaskStr := '';
			end;

			if C='*' then begin
				Index := 0;
				FFirstRange := 0;
				C := '';
			end else begin
				Inc (FRangesCount);
				Index := FRangesCount;
			end;
			
			with MR{FRanges[Index]} do begin
				try
					ConfigMask := ParseNumericValue(MaskStr);
				except
					ConfigMask := CreateMask(FIConfig.Size, 0);
				end;

				try
					ConfigValue := ParseNumericValue(C);
				except
					ConfigValue := 0;
					ConfigMask := 0;
				end;
				
				P := Pos('-', Addr);
				if P=0 then begin
					if ParamName = '@port' then begin
						RangeBegin := ParseNumericValue(Addr);
						RangeEnd := RangeBegin;
					end else
						raise Exception.Create('Неправильно указан диапазон: ' + Addr);
				end else begin
					RangeBegin := ParseNumericValue(Copy(Addr, 1, P-1));
					RangeEnd := ParseNumericValue(Copy(Addr, P+1, Length(Addr)-P));
				end;

				Device := IM.DM.GetDeviceByName(FConfigData.Parameter[i].Value);

				Range := FConfigData.Parameter[i].Right_Range;
				try
					Base := ParseNumericValue(copy(Range,2,Length(Range)-2));
				except
					Base := 0;
				end;
				
				M := UpperCase(FConfigData.ExtendedParameter(i, 'mode'));
				if M='R' then
					Mode := MODE_R
				else
				if M='W' then
					Mode := MODE_W
				else
					Mode := MODE_RW;

				try
					AddressMask := ParseNumericValue(FConfigData.ExtendedParameter(i, 'addr_mask'));
					AddressValue := ParseNumericValue(FConfigData.ExtendedParameter(i, 'addr_value'));
				except
					AddressMask := 0; AddressValue := 0;
				end;
				//Кеш записи отключается либо для сложных случаев
				//либо когда он вообще отключен
				Cache := (AddressMask=0) and (FCacheSize>0);
			end;
			if ParamName = '@memory' then
				FRanges[Index] := MR
			else begin
				FPorts[FPortsCount] := MR;
				Inc(FPortsCount);
			end;
		end;
	end;
	//Также из кеша нужно исключить диапазоны,
	//пересекающиеся с уже отмеченными
	if FCacheSize>0 then
		for i:=FFirstRange to FRangesCount do
			if not FRanges[i].Cache then
				for j:=FFirstRange to FRangesCount do
					if not ((FRanges[j].RangeEnd < FRanges[i].RangeBegin)
									or (FRanges[j].RangeBegin > FRanges[i].RangeEnd))
						 and (FRanges[j].ConfigMask = FRanges[i].ConfigMask)
						 and (FRanges[j].ConfigValue = FRanges[i].ConfigValue)
					then FRanges[j].Cache := False;
end;

procedure TMemoryMapper.Reset;
begin
	if (FCancelInitMask <> 0) then FFirstRange := 0;
	FReadCacheItems := 0;
	FWriteCacheItems := 0;
end;

constructor TInterface.Create;
begin
	FIM := IM;
	Size := IntSize;
	FDevice := Device;
	FName := Name;
	FLinked := 0;
	FCallBack := CallBack;
	FValue := Cardinal(-1);
	FOldValue := Cardinal(-1);
	FEdgeValue := Cardinal(-1);
	FMode:=IMode;
	FLinkedBits := 0;
	IM.RegisterInterface(self);
end;

constructor TInterfaceManager.Create;
begin
	FDM := DM;
	FInterfacesCounter := 0;
end;

destructor TInterfaceManager.Destroy;
begin
	Clear;
	inherited Destroy;
end;

procedure TInterfaceManager.RegisterInterface;
begin
	Inc(FInterfacesCounter);
	FInterfaces[FInterfacesCounter-1] := Int;
end;

procedure TInterfaceManager.Clear;
var i:Integer;
begin
	for i:=0 to FInterfacesCounter-1 do
		FInterfaces[i].Free;

	FInterfacesCounter := 0;
	FillChar(FInterfaces,SizeOf(FInterfaces), 0);
end;

procedure TInterfaceManager.InterfaceChanged(I:TInterface);
begin
end;

function TInterfaceManager.GetInterfaceByName;
var i:Integer;
begin
	Result := nil;
	for i:=0 to FInterfacesCounter-1 do
		if (FInterfaces[i].Device.Name=DevName) and (FInterfaces[i].Name=IntName) then
			Result := FInterfaces[i];
	if Result=nil then
		raise Exception.Create('Интерфейс '''+DevName+'.'+IntName+''' не найден!');
end;

procedure TInterface.Connect(S, D:TLinkedInterface);
var i, Index:Integer;
begin
	Index := -1;
	for i:=0 to FLinked-1 do
		if FLinkedInterfaces[i].D.I = D.I then Index := i;
	if Index < 0 then begin
		Inc(FLinked);
		FLinkedInterfaces[FLinked-1].S := S;
		FLinkedInterfaces[FLinked-1].D := D;
		D.I.Connect(D, S);
		FLinkedBits := FLinkedBits or S.Mask;
	end;
end;

procedure RegisterDeviceCreateFunc(Typ: String; Func:Pointer);
begin
		Inc(DeviceCreateFuncsCount);

		with DeviceCreateFuncData[DeviceCreateFuncsCount-1] do begin
			DType :=  Typ;
			@CreateFunc := Func;
		end;
end;

function CreateDevice(IM:TInterfaceManager; Typ: String; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
var i:Cardinal;
begin
	Result:=nil;
	for i:=0 to DeviceCreateFuncsCount-1 do
		if DeviceCreateFuncData[i].DType = Typ then
			Result:=DeviceCreateFuncData[i].CreateFunc(IM, ConfigDevice);
	if Result=nil then
		raise Exception.Create('Тип устройства '''+Typ+''' не найден!');
end;

function CreatePort(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TPort.Create(IM, ConfigDevice);
end;

function CreatePortAddress(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TPortAddress.Create(IM, ConfigDevice);
end;

function CreateROM(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TROM.Create(IM, ConfigDevice);
end;

function CreateRAM(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TRAM.Create(IM, ConfigDevice);
end;

function CreateMMapper(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TMemoryMapper.Create(IM, ConfigDevice);
end;

function CreatePageMapper(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TPageMapper.Create(IM, ConfigDevice);
end;

procedure TInterface.SetSize;
begin
	FSize := V;
	FMask := CreateMask(V, 0);
end;

procedure TInterface.SetMode;
var i:Integer;
		PrevMode: Cardinal;
		LI: TInterface;
begin
	PrevMode := FMode;
	FMode := V;
	//Если интерфейс переключился с вывода на ввод, нужно правильно
	//установить его значение, если оно контролируется другим интерфейсом.
	//Поэтому просматриваем все соединенные интерфейсы, и если один из них
	//находится в режиме вывода, то имитируем установку его значения,
	//чтобы правильно выставились значения на текущем интерфейсе
	if (FMode=MODE_R) and (PrevMode=MODE_W) then
		for i:=0 to FLinked-1 do begin
			LI:=FLinkedInterfaces[i].D.I;
			if LI.Mode=MODE_W then
				LI.Change(LI.Value);
		end;
	if FMode=MODE_OFF then Change(Cardinal(-1));
end;

constructor TCPU.Create;
begin
	inherited Create(IM, ConfigDevice);

	try
		ClockValue := ParseNumericValue(ConfigDevice.Parameters['clock'].Value);
	except
		raise Exception.Create('Не задана рабочая частота процессора!');
	end;

	FReset := TRUE;

	DebugMode :=DEBUG_OFF;
	//DebugMode :=DEBUG_STOPPED;
	BreakCount := 0;
end;

function TMemoryMapper.Read;
var i:Integer;
begin
	for i:=0 to FReadCacheItems-1 do
		with FReadCache[i] do
			if (Address >= CRangeBegin) and (Address <= CRangeEnd) then begin
				Result:=TAddressableDevice(CDevice).Value[Address - CRangeBegin + CBase];
				Inc(CCounter);
				{$IFDEF CACHE_STATS}
				Inc(CacheHit);
				{$ENDIF}
				exit;
			end;

	if (FFirstRange=0) and ((Address and FCancelInitMask) <> 0) then begin
		FFirstRange := 1;
		FReadCacheItems := 0;
		FWriteCacheItems := 0;
	end;
	for i:=FFirstRange to FRangesCount do
		with FRanges[i] do begin
			if ((FIConfig.Value and ConfigMask) = ConfigValue) and
				 (Address >= RangeBegin) and (Address <= RangeEnd) and
				 (Address and AddressMask = AddressValue) and
				 (Mode and MODE_R <> 0) then begin
						Result:=TAddressableDevice(Device).Value[Address - RangeBegin + Base];
						if Cache then AddCacheEntry(FReadCache, FReadCacheItems, FRanges[i]);
						{$IFDEF CACHE_STATS}
						Inc(CacheMiss);
						{$ENDIF}
					 	exit;
					end;
		end;
	Result := Cardinal(-1);
end;

procedure TMemoryMapper.Write;
var i:Integer;
		{D: TComputerDevice;
		CS: Cardinal;}
begin
	//CS := 1000;
	for i:=0 to FWriteCacheItems-1 do
		with FWriteCache[i] do
			if (Address >= CRangeBegin) and (Address <= CRangeEnd) then begin
				(CDevice as TAddressableDevice).Value[Address - CRangeBegin + CBase] := Value;
				//CS := i; D := CDevice;
				Inc(CCounter);
				{$IFDEF CACHE_STATS}
				Inc(CacheHit);
				{$ENDIF}
				exit;
			end;

	for i:=FFirstRange to FRangesCount do
		with FRanges[i] do begin
			if ((FIConfig.Value and ConfigMask) = ConfigValue) and
				 (Address >= RangeBegin) and (Address <= RangeEnd) and
				 (Address and AddressMask = AddressValue) and
				 (Mode and MODE_W <> 0) then begin
					  (Device as TAddressableDevice).Value[Address - RangeBegin + Base] := Value;
						if Cache then AddCacheEntry(FWriteCache, FWriteCacheItems, FRanges[i]);
						//if (CS < 1000) and (D<>Device) then FIM.DM.Error(self, 'Expected: '+Device.Name+', Got from cache: '+D.Name+' at address '+IntToHex(Address, 4));
						{$IFDEF CACHE_STATS}
						Inc(CacheMiss);
						{$ENDIF}
						exit;
					end;
		end;
end;

function TMemoryMapper.ReadPort;
var i:Cardinal;
		A: Cardinal;
begin
	if FPortsToMem then
		Result := Read(Address)
	else begin
		A := Address and FPortsMask;
		for i:=0 to FPortsCount-1 do
			with FPorts[i] do begin
				if ((FIConfig.Value and ConfigMask) = ConfigValue) and
					 (A >= RangeBegin) and (A <= RangeEnd) and
					 (A and AddressMask = AddressValue) and
					 (Mode and MODE_R <> 0) then begin
						 Result:=TAddressableDevice(Device).Value[A - RangeBegin + Base];
						 exit;
						end;
			end;
		Result := Cardinal(-1);
	end;
end;

procedure TMemoryMapper.WritePort;
var i:Cardinal;
		A: Cardinal;
begin
	if FPortsToMem then
		Write(Address, Value)
	else begin
		A := Address and FPortsMask;
		for i:=0 to FPortsCount-1 do
			with FPorts[i] do begin
				if ((FIConfig.Value and ConfigMask) = ConfigValue) and
					 (A >= RangeBegin) and (A <= RangeEnd) and
					 (A and AddressMask = AddressValue) and
					 (Mode and MODE_W <> 0) then begin
						 (Device as TAddressableDevice).Value[A - RangeBegin + Base] := Value;
						 exit;
						end;
			end;
	end;
end;

procedure TMemoryMapper.ConfigChanged(NewValue, OldValue: Cardinal);
begin
	FReadCacheItems := 0;
	FWriteCacheItems := 0;
end;

procedure TMemoryMapper.AddCacheEntry(var Cache: TMapperCache; var CacheItems: Cardinal; const Range:TMapperRange);
begin
	if CacheItems < FCacheSize then begin
		with Cache[CacheItems], Range do begin
			CRangeBegin := RangeBegin;
			CRangeEnd := RangeEnd;
			CBase := Base;
			CDevice := Device;
			CCounter := 1;
		end;
		Inc(CacheItems);
	end;
end;

procedure TMemoryMapper.SortCacheItems;
var i, j: Integer;
		T: TMapperCacheEntry;
		Done: Boolean;
begin
	if FCacheSize>0 then begin
		//Сортировка кеша чтения по используемости
		for i:=1 to Integer(FReadCacheItems)-1 do begin
			Done := TRUE;
			for j:=1 to Integer(FReadCacheItems)-i do
				if FReadCache[j].CCounter > FReadCache[j-1].CCounter then begin
					T := FReadCache[j];
					FReadCache[j] := FReadCache[j-1];
					FReadCache[j-1] := T;
					Done := FALSE;
				end;
			if Done then Break;
		end;
		//И обнуление счетчиков строк
		for i:=0 to Integer(FReadCacheItems)-1 do FReadCache[i].CCounter := 0;

		//Сортировка кеша записи по используемости
		for i:=1 to Integer(FWriteCacheItems)-1 do begin
			Done := TRUE;
			for j:=1 to Integer(FWriteCacheItems)-i do
				if FWriteCache[j].CCounter > FWriteCache[j-1].CCounter then begin
					T := FWriteCache[j];
					FWriteCache[j] := FWriteCache[j-1];
					FWriteCache[j-1] := T;
					Done := FALSE;
				end;
			if Done then Break;
		end;
		//И обнуление счетчиков строк
		for i:=0 to Integer(FWriteCacheItems)-1 do FWriteCache[i].CCounter := 0;
	end;
end;


procedure TCPU.LoadConfig;
begin
	inherited LoadConfig(SD);
	FMM := IM.DM.GetDeviceByName('mapper') as TMemoryMapper;
end;

procedure TDeviceManager.ResetDevices(isCold:Boolean);
var i:Cardinal;
begin
	for i:=0 to FDevicesCount-1 do FDevices[i].Device.Reset(isCold);
end;

procedure TDeviceManager.Clock;
var i:Cardinal;
begin
	//Процессо пропускаем
	for i:=1 to FDevicesCount-1 do FDevices[i].Device.SystemClock(Counter);
end;

procedure TDeviceManager.Error(Device:TComputerDevice; Msg:String);
begin
	FErrorDevice := Device;
	FErrorMsg := Msg;
	Abort;
end;

procedure TDeviceManager.ErrorClear;
begin
	FErrorDevice := nil;
end;

function TCPU.CheckBreakPoint;
var i:Integer;
begin
	Result := FALSE;
	for i:=0 to FBreakCount-1 do
		if FBreakPoints[i]=Address then begin
			Result := TRUE;
			exit;
		end;
end;

procedure TCPU.ClearBreakPoints;
begin
	FBreakCount := 0;
end;

procedure TCPU.AddBreakPoint(Addr: Cardinal);
begin
	if FBreakCount < SizeOf(FBreakPoints) div SizeOf(FBreakPoints[0]) then begin
		Inc(FBreakCount);
		FBreakPoints[FBreakCount - 1] := Addr;
	end;
end;

procedure TCPU.RemoveBreakPoint(Addr: Cardinal);
var N, i:Integer;
begin
	N:=-1;
	for i:=0 to FBreakCount-1 do
		if FBreakPoints[i] = Addr then N := i;
	if N>=0 then begin
		for i:=N to FBreakCount-2 do
			FBreakPoints[i] := FBreakPoints[i+1];
		Dec(FBreakCount);
	end;
end;

procedure TCPU.Reset;
begin
	FReset := TRUE;
end;

procedure TInterface.Change(Value: Cardinal);
var i: Integer;
begin
	if Mode=MODE_W then begin
		//if FOldValue <> Value then begin
			FOldValue := FValue;
			FValue := Value;
			for i:=0 to FLinked-1 do
				FLinkedInterfaces[i].D.I.Changed(FLinkedInterfaces[i], Value);
		//end;
	end else
	if Mode=MODE_OFF then
	 	FIM.DM.Error(FDevice, 'Попытка записать в отключенный интерфейс!');
end;

procedure TInterface.Clear;
begin
	Change(Cardinal(-1));
end;

procedure TInterface.Changed(Link:TLinkData; Value: Cardinal);
var NewValue: Cardinal;
begin
	if Mode=MODE_R then begin
		NewValue := FValue and not Link.D.Mask;		//Обнуляем целевые биты
		NewValue := NewValue or
							(
								(Value and Link.S.Mask)			//Берем нужные биты исходного значения
								shr Link.S.Shift						//Сдвигаем их вправо до начала
							)
							shl Link.D.Shift;							//А теперь ставим на нужное место в конечой переменной
		//if NewValue<>FValue then begin
			FOldValue := FValue;
			FValue := NewValue;
			if Assigned(FCallBack) then FCallback(FValue, FOldValue);
		//end;
	end;
		//else FIM.DM.Error(FDevice, 'Попытка изменения выходного интерфейса!');
end;

function TInterface.PosEdge: Boolean;
begin
	Result := ((FValue and 1) = 1) and ((FEdgeValue and 1) = 0);
	FEdgeValue := FValue;
end;

function TInterface.NegEdge: Boolean;
begin
	Result := ((FValue and 1) = 0) and ((FEdgeValue and 1) = 1);
	FEdgeValue := FValue;
end;


constructor TPageMapper.Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
begin
	inherited Create(IM, ConfigDevice);
	FPagesCount := 0;
	FillChar(FPages, SizeOf(FPages), 0);
	FIPage := CreateInterface(8, 'page', MODE_R);
	FISegment := CreateInterface(8, 'segment', MODE_R);
end;

procedure TPageMapper.LoadConfig(const SD:TSystemData);
var i: Cardinal;
		ParaName, Range: String;
		PageID : Cardinal;
begin
	inherited LoadConfig(SD);
	for i:=0 to FConfigData.ParametersCount-1 do begin
		ParaName := FConfigData.Parameter[i].Name;
		if ParaName = '@page' then begin
			Range := FConfigData.Parameter[i].Left_range;
			if Range='' then raise Exception.Create('Неверное описание '+Name);
			PageID := ParseNumericValue(copy(Range, 2, Length(Range)-2));
			if PageID >= FPagesCount then FPagesCount := PageID + 1;
			FPages[PageID] := TMemory(IM.DM.GetDeviceByName(FConfigData.Parameter[i].Value));
		end;
	end;

	FPageMask := CreateMask(Round(Log2(FPagesCount+1)), 0);

	try
		FFrame := ParseNumericValue(FConfigData.Parameters['frame'].Value);
	except
		//Если параметр не задан, то сегментирование отключается
		FFrame := FPages[0].Size;
	end;
	FSegmentMask := CreateMask(Round(Log2(FPages[0].Size div FFrame)), 0);
end;

function TPageMapper.GetValue(Address:Cardinal):Cardinal;
begin
	if FFrame = FPages[0].Size then
		Result := FPages[FIPage.Value and FPageMask].Value[Address]
	else
		Result := FPages[FIPage.Value and FPageMask].Value[(FISegment.Value and FSegmentMask)*FFrame +  Address];
end;

procedure TPageMapper.SetValue(Address:Cardinal; Value:Cardinal);
begin
	if FFrame = FPages[0].Size then
		FPages[FIPage.Value and FPageMask].Value[Address] := Value
	else
		FPages[FIPage.Value and FPageMask].Value[(FISegment.Value and FSegmentMask)*FFrame +  Address] := Value;
end;

constructor TDisplay.Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
begin
	inherited Create(IM, ConfigDevice);
	FBitMap := TBitMap.Create;
	FValid := False;
	FRepaint := True;
end;

destructor TDisplay.Destroy;
begin
	FBitMap.Free;
	FBitMap := nil;
	inherited Destroy;
end;

begin
	DeviceCreateFuncsCount := 0;

	RegisterDeviceCreateFunc('port', @CreatePort);
	RegisterDeviceCreateFunc('port-address', @CreatePortAddress);
	RegisterDeviceCreateFunc('rom', @CreateROM);
	RegisterDeviceCreateFunc('ram', @CreateRAM);
	RegisterDeviceCreateFunc('page_mapper', @CreatePageMapper);
	RegisterDeviceCreateFunc('memory_mapper', @CreateMMapper);
end.
