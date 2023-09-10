unit emulator;
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

//Основной модудь объекта эмулятора

{DEFINE REC_CONTEXT}

interface
uses
	SysUtils, MMSystem, Math, Windows, Dialogs, Graphics, IniFiles,
	Utils, Core, Config, DX,
	i8080, Speaker, i8255, O128display, ScanKbd, i8257, Vg75display, i8275, Keyboard,
  pdp11;

type
{$IFDEF REC_CONTEXT}
			TRecordedContext = packed record
				PC: Word;
				CRC: Word;
			end;
			TContextArray = array [0..1024*1024*1] of TRecordedContext;
			PContextArray = ^TContextArray;
{$ENDIF}

			TEmulator = class
			private
				FLoaded: Boolean;
				FBusy: Boolean;
				FDXInput: TDXInput;

				FClockFreq: Cardinal;
				TimerResolution: Cardinal;
				TimerDelay: Cardinal;
				TimeBitTicks: Cardinal;
				TimerID:MMRESULT;
				LocalCounter: Cardinal;
				FClockCounter: Cardinal;

				FCPU: TCPU;
				FMM: TMemoryMapper;
				FDisplay: TDisplay;
				FKeyboard: TKeyboard;

				FWorkPath:String;
				FIni:TIniFile;

{$IFDEF REC_CONTEXT}
				FPContext: PContextArray;
				FContextCount: Cardinal;
{$ENDIF}
				function GetScreenX:Cardinal;
				function GetScreenY:Cardinal;
			public
				DM: TDeviceManager;
				IM: TInterfaceManager;
				SD: TSystemData;
				CPU_PC: Cardinal;
				HaveFocus: Boolean;
				constructor Create(WorkPath, IniFile:String);
				procedure LoadConfig(FileName: String);
				procedure ReloadConfig;
				procedure Reset(isCold:Boolean);
				procedure Start(UseDI:Boolean; hWnd: HWND);
				procedure Stop;
				procedure TimerProc;
				property ScreenX: Cardinal read GetScreenX;
				property ScreenY: Cardinal read GetScreenY;
				function GetScreen(Required:Boolean):TBitMap;
				procedure KeyDown(Key:Word);
				procedure KeyUp(Key:Word);
				property ClockFreq: Cardinal read FClockFreq; 
				property ClockCounter: Cardinal read FClockCounter write FClockCounter;
				property WorkPath:String read FWorkPath;
				property Loaded: Boolean read FLoaded;
				property MM: TMemoryMapper read FMM;
				function ReadSetup(Section, Ident, Default: String):String;
				procedure WriteSetup(Section, Ident, Value: String);
				destructor Destroy; override;
			end;

//Функция вызывается по таймеру. В качестве user-data передается ссылка на экземпляр TEmulator;
procedure EmulatorTimerProc(uTimerID, uMessage: UINT; Emulator:TEmulator; dw1, dw2: DWORD) stdcall;

implementation

constructor TEmulator.Create(WorkPath, IniFile:String);
begin
	FLoaded := FALSE;
	FBusy := FALSE;
	FDXInput := nil;
	FWorkPath := WorkPath;
	FIni := TIniFile.Create(IniFile);
	HaveFocus := TRUE;
end;

procedure TEmulator.LoadConfig(FileName: String);
var
	Config: TEmulatorConfig;
	SystemConfig, D: TEmulatorConfigDevice;
	i: Cardinal;
	S:String;
begin
	if FLoaded then begin
		//Здесь удаляем предыдущий компьютер
		//Останов таймера
		Stop;
		IM.Free;
		DM.Free;
		FLoaded := False;
	end;
	DM := TDeviceManager.Create();
	IM := TInterfaceManager.Create(DM);
	Config := TEmulatorConfig.Create;
	//try
		Config.LoadFromFile(FileName);
		//Загрузка метаданных
		SystemConfig := Config.Devices['system'];
		SD.SystemFile := FileName;
		SD.SystemPath := ExtractFilePath(FileName);
		SD.SystemType := SystemConfig.Parameters['type'].Value;
		SD.SystemName := SystemConfig.Parameters['name'].Value;
		SD.SystemVersion:= SystemConfig.Parameters['version'].Value;
		SD.SystemCharMap:= SystemConfig.Parameters['charmap'].Value;
		SD.SoftwarePath := ExtractFilePath(ParamStr(0))+'Software/';
		SD.MapperCache := ParseNumericValue(ReadSetup('Core', 'mapper_cache', '8'));
		DecimalSeparator := '.';

		try
			S:= SystemConfig.Parameters['screenratio'].Value;
			SD.ScreenRatio := StrToFloat(S);
		except
			SD.ScreenRatio := 1;
		end;

		try
			S:= SystemConfig.Parameters['screenscale'].Value;
			SD.ScreenScale := StrToInt(S)
		except
			SD.ScreenScale := 1;
		end;

		try
			SD.AllowedFiles :=  SystemConfig.Parameters['files'].Value;
		except
			SD.AllowedFiles := '';
		end;

		with Config do begin
			//Создание устройств
			for i := 0 to DevicesCount - 1 do begin
				D := Device[i];
				if D.DType <> '' then DM.AddDevice(IM, D);
			end;
			DM.LoadDevicesConfig(SD);
		end;
	//except
	//	exit;
	//end;
	Config.Free;
	FLoaded := TRUE;
end;

procedure TEmulator.ReloadConfig;
begin
	LoadConfig(SD.SystemFile);
end;

procedure TEmulator.Reset(isCold:Boolean);
begin
	DM.ResetDevices(isCold);
end;

procedure TEmulator.Start;
var tc:TTimeCaps;
		TR:Integer;
begin
	if FLoaded then begin
		if UseDI and not Assigned(FDXInput) then FDXInput := TDXInput.Create(hWnd);

		FCPU := DM.GetDeviceByName('cpu') as TCPU;
		FMM := DM.GetDeviceByName('mapper') as TMemoryMapper;
		FDisplay := DM.GetDeviceByName('display') as TDisplay;
		FKeyboard := DM.GetDeviceByName('keyboard') as TKeyboard;
		Reset(TRUE);

		FClockFreq := FCPU.ClockValue;
		TimerResolution := StrToInt(ReadSetup('Core', 'TimerResolution', '5'));
		TimerDelay := StrToInt(ReadSetup('Core', 'TimerDelay', '20'));
		TimeBitTicks := Integer(Round(FClockFreq * TimerDelay / 1000));

		if timeGetDevCaps(@tc, sizeof(tc))<>TIMERR_NOERROR then
			raise Exception.Create('Не удалось получить параметры таймера!');
		TR:=Min(Max(tc.wPeriodMin, TimerResolution), tc.wPeriodMax);
		TimerID:=timeSetEvent(TimerDelay, TR, @EmulatorTimerProc, DWORD(Self), TIME_PERIODIC);
		if TimerID=0 then
			raise Exception.Create('Не удалось инициализировать таймер!');
		FBusy := FALSE;
		{$IFDEF REC_CONTEXT}
			GetMem(FPContext, SizeOf(TContextArray));
			FContextCount := 0;
		{$ENDIF}
	end else
		raise Exception.Create('Эмулятор не инициализирован, запуск невозможен!');
end;

procedure TEmulator.Stop;
{$IFDEF REC_CONTEXT}
var //F:Text;
		//I:Cardinal;
		FH: Integer;
{$ENDIF}
begin
	if FLoaded then begin
		timeKillEvent(TimerID);
		if Assigned(FDXInput) then begin
			FDXInput.Free;
			FDXInput := nil;
		end;
		{$IFDEF REC_CONTEXT}
			FH := FileCreate(FWorkPath + 'CONTEXT.BIN');
			FileWrite(FH, FPContext^, SizeOf(TRecordedContext)*FContextCount);
			FileClose(FH);
			FreeMem(FPContext);
		{$ENDIF}
	end;
	//Гарантированно дожидаемся окончания последнего интервала
	Sleep(50);
end;

function TEmulator.GetScreenX:Cardinal;
begin
	Result := FDisplay.SX;
end;

function TEmulator.GetScreenY:Cardinal;
begin
	Result := FDisplay.SY;
end;

function TEmulator.GetScreen(Required:Boolean):TBitMap;
begin
	Result := FDisplay.GetScreen(Required);
end;

procedure EmulatorTimerProc;
begin
	Emulator.TimerProc;
end;

procedure TEmulator.TimerProc;
var Counter: Cardinal;
		Btn: Word;
{$IFDEF REC_CONTEXT}
		F: TWD1793;
{$ENDIF}
begin
	if not FBusy then begin
		FBusy := TRUE;
		try
			repeat
				{$IFDEF REC_CONTEXT}
					if FContextCount=$12624 then
						Inc(FClockCounter);

					if FContextCount*SizeOf(TRecordedContext) < SizeOf(TContextArray) then begin
						FPContext^[FContextCount].PC := FCPU.ContextPC;
						FPContext^[FContextCount].CRC := FCPU.ContextCRC;
						F:=TWD1793(DM.GetDeviceByName('fdc'));
						CRC16_update(FPContext^[FContextCount].CRC, @(F.FRegs), 5);
						CRC16_update(FPContext^[FContextCount].CRC, @LocalCounter, SizeOf(LocalCounter));
						Inc(FContextCount);
					end;
				{$ENDIF}
				//Запоминаем PC на случай ошибки
				CPU_PC := FCPU.ContextPC;
				//Выполняем следующую команду, результат - число тактов
				Counter:=FCPU.Execute;
				Inc (LocalCounter, Counter);
				Inc (FClockCounter, Counter);
				//Оповещаем устройства, что прошло определенное время
				DM.Clock(Counter);
			until ((LocalCounter>=TimeBitTicks) or (Counter=0));
			FMM.SortCacheItems;

      //Обработка DirectInput
			if Assigned(FDXInput) and HaveFocus then begin
				if not FDXInput.Update then Abort;

				Btn := FDXInput.GetNextButton;
				while Btn > 0 do begin
					if Btn and $8000 <> 0 then
						KeyDown(Btn and $7FFF)
					else
						KeyUp(Btn);
					Btn := FDXInput.GetNextButton;
				end;
			end;

		except
			timeKillEvent(TimerID);
			MessageBeep(0);
		end;
		Dec(LocalCounter, TimeBitTicks);
		FBusy := FALSE;
	end;
end;

procedure TEmulator.KeyDown(Key:Word);
begin
	FKeyboard.KeyDown(Key);
end;

procedure TEmulator.KeyUp(Key:Word);
begin
	Fkeyboard.KeyUp(Key);
end;

destructor TEmulator.Destroy;
begin
	if Assigned(FIni) then FIni.Free;
	inherited Destroy;
end;

function TEmulator.ReadSetup(Section, Ident, Default: String):String;
begin
	Result:= FIni.ReadString(Section, Ident, Default);
end;

procedure TEmulator.WriteSetup(Section, Ident, Value: String);
begin
	FIni.WriteString(Section, Ident, Value);
end;


end.
