unit Tape;
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

interface

uses
		SysUtils, Dialogs, StrUtils,
		Config,
		Core, Utils, Speaker;

type
		TTapeRecorder = class (TComputerDevice)
		private
			FIInput: TInterface;
			FIOutput: TInterface;
			FISpeaker: TInterface;
			FSystemFreq: Cardinal;
			FBaudRate: Cardinal;
			FMode: Cardinal;
			FBuffer: PStorage;
			FBufferLen: Cardinal;
			FBufferPtr: Cardinal;
			FBitPtr: Integer; 
			FTicksPerBit: Cardinal;
			FTicksCounter: Cardinal;
			FSpeaker:TSpeaker;
			FSpkCfg: TEmulatorConfigDevice;
			FBusy: Boolean;
			FMute: Boolean;
			FTotalSeconds: Cardinal;
			procedure SetBaudRate(Value:Cardinal);
			function GetCurrentSeconds:Cardinal;
		public
			constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
			procedure LoadConfig(const SD:TSystemData); override;
			procedure Clock(Counter:Cardinal); override;
			procedure SetData(Buffer: PStorage; Size:Cardinal);
			property BaudRate:Cardinal read FBaudRate write SetBaudRate;
			property Busy:Boolean read FBusy;
			property Mute:Boolean read FMute write FMute;
			property TotalSeconds: Cardinal read FTotalSeconds;
			property CurrentSeconds: Cardinal read GetCurrentSeconds;
			procedure StartRead;
			procedure StopTape;
			procedure LoadFile(Fmt, FileName: String);
			destructor Destroy; override;
		end;

const
		TAPE_STOPPED = 0;
		TAPE_READ 	 = 1;
		TAPE_WRITE 	 = 2;

implementation

function CreateTapeRecorder(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TTapeRecorder.Create(IM, ConfigDevice);
end;

constructor TTapeRecorder.Create;
var Cpu: TCPU;
		Name: String;
begin
	inherited Create(IM, ConfigDevice);
	Name := FConfigData.Name;
	
	FIInput := CreateInterface(1, 'input', MODE_R);
	FIOutput := CreateInterface(1, 'output', MODE_W);
	FISpeaker := CreateInterface(1, 'speaker', MODE_W);
	Cpu := IM.DM.GetDeviceByName('cpu') as TCPU;

	FSystemFreq := Cpu.ClockValue;
	FMode := TAPE_STOPPED;
	FBuffer := nil;
	FBufferLen := 0;
	FBufferPtr := 0;
	FBaudRate := 0;
	FTicksPerBit := 0;
	FTicksCounter := 0;
	FBusy := FALSE;
	FMute := FALSE;
	FTotalSeconds := 0;

	FSpkCfg := TEmulatorConfigDevice.Create(Name+'-speaker', 'speaker');
	FSpkCfg.AddParameter('~input', '', Name+'.speaker', '', '');

	FSpeaker := TSpeaker.Create(IM, FSpkCfg);
end;

procedure TTapeRecorder.LoadConfig;
var S:String;
begin
	inherited LoadConfig(SD);
	try
		S := FConfigData.Parameters['baudrate'].Value;
	except
		S := '1200';
		//raise Exception.Create('В параметрах магнитофона '''+FXMLConfig.AttributeByName['name']+''' не задана скорость!');
	end;
	FBaudRate := ParseNumericValue(S);
	FSpeaker.LoadConfig(SD);
end;

procedure TTapeRecorder.SetData(Buffer: PStorage; Size:Cardinal);
begin
	if Assigned(FBuffer) then FreeMem(FBuffer);
	FMode := TAPE_STOPPED;
	FBuffer := Buffer;
	FBufferLen := Size;
	FBufferPtr := 0;
	FBitPtr := 7;
	FTotalSeconds := (Size * 8) div FBaudRate;
end;

destructor TTapeRecorder.Destroy;
begin
	if Assigned(FBuffer) then FreeMem(FBuffer);
	FSpkCfg.Free;
	inherited Destroy;
end;

procedure TTapeRecorder.Clock;
var V:Cardinal;
begin
	if FMode <> TAPE_STOPPED then begin
		if FTicksCounter < FTicksPerBit then
			Inc(FTicksCounter, Counter)
		else begin
			Dec(FTicksCounter, FTicksPerBit);
			if FBufferPtr < FBufferLen then begin
				if FMode = TAPE_READ then begin
					V := (FBuffer^[FBufferPtr] shr FBitPtr) and $01;
					FIOutput.Change(V);
					if not FMute then FISpeaker.Change(V);
				end else begin
					//FBuffer^[FBufferPtr] := FIInput.Value;
				end;
				Dec(FBitPtr);
				if FBitPtr<0 then begin
					Inc(FBufferPtr);
					FBitPtr := 7;
				end;
			end else
				StopTape;
		end;
	end;
	FSpeaker.Clock(Counter);
end;

procedure TTapeRecorder.StartRead;
begin
	FMode := TAPE_READ;
	FBufferPtr := 0;
	FBitPtr := 7;
	FTicksCounter :=0;
	FIOutput.Change(FBuffer^[0]);
	FBusy := TRUE;
end;

procedure TTapeRecorder.StopTape;
begin
	FMode := TAPE_STOPPED;
	FBusy := FALSE;
end;

procedure TTapeRecorder.SetBaudRate(Value:Cardinal);
begin
	FBaudRate := Value;
	FTicksPerBit := FSystemFreq div FBaudRate;
end;

procedure TTapeRecorder.LoadFile(Fmt, FileName: String);
var P, P1, P2: Integer;
		S, V, C: String;
		FormStr, BaudStr: String;
		FmtArr: array [0..100, 0..1] of Integer;
		FmtCount, i, Baud, DataCount: Cardinal;
		Buffer, BufferTmp: PStorage;
		fh, FL: Integer;
		T: PartsRec;
		W: Word;
begin
	//Fmt=format:baud;value:length;...;data;value:length;...
	P := Pos(';', Fmt);
	S := LeftStr(Fmt, P-1);
	P1 := Pos(':', S);
	FormStr := LeftStr(S, P1-1);
	BaudStr := RightStr(S, Length(S)-P1);
	Baud := ParseNumericValue(BaudStr);

	FmtCount := 0;
	DataCount := 0;
	Inc(P);
	while P<=Length(Fmt) do begin
		P1 := PosEx(';', Fmt, P+1);
		if P1>0 then begin
			S:=Copy(Fmt, P, P1-P);
			P:=P1+1;
		end else begin
			S:=RightStr(Fmt, Length(Fmt)-P+1);
			P:=Length(Fmt)+1;
		end;

		if S='data' then begin
			FmtArr[FmtCount, 0] := 0;
			FmtArr[FmtCount, 1] := 0;
			Inc(DataCount, GetFileSize(FileName));
		end else begin
			P2 := Pos(':', S);
			V := LeftStr(S, P2-1);
			C := RightStr(S, Length(S)-P2);
			FmtArr[FmtCount, 0] := ParseNumericValue(V);
			FmtArr[FmtCount, 1] := ParseNumericValue(C);
			Inc(DataCount, FmtArr[FmtCount, 1]);
		end;
		Inc(FmtCount);
	end;

	GetMem(BufferTmp, DataCount);

	P:=0;
	for i:=0 to FmtCount-1 do begin
		if FmtArr[i, 1]>0 then begin
			FillChar(BufferTmp^[P], FmtArr[i, 1], Byte(FmtArr[i, 0]));
			Inc(P, FmtArr[i, 1]);
		end else begin
			FL := GetFileSize(FileName);
			fh := FileOpen(FileName, fmOpenRead);
			FileRead(fh, BufferTmp^[P], FL);
			FileClose(fh);
			Inc(P, FL);
		end;
	end;

	if FormStr='rk86' then begin
		BaudRate := Baud*2;
		GetMem(Buffer, DataCount*2);
		for i:=0 to DataCount-1 do begin
			//0 => 10
			//1 => 01
			W := BufferTmp^[i];
			T.W := (W and $01) +
             ((W and $02) shl 1) +
						 ((W and $04) shl 2) +
						 ((W and $08) shl 3) +
						 ((W and $10) shl 4) +
						 ((W and $20) shl 5) +
						 ((W and $40) shl 6) +
						 ((W and $80) shl 7);
			T.W := T.W or (not(T.W shl 1) and $AAAA);
			Buffer^[i*2]   := T.H;
			Buffer^[i*2+1] := T.L;
		end;
		SetData(Buffer, DataCount*2);
	end else
		ShowMessage('Формат '''+FormStr+''' не поддерживается!');

	FreeMem(BufferTmp);
end;

function TTapeRecorder.GetCurrentSeconds:Cardinal;
begin
	if FMode = TAPE_READ then begin
		Result := (FBufferPtr * 8) div FBaudRate; 
	end else
		Result := 0;
end;


begin
	RegisterDeviceCreateFunc('taperecorder', @CreateTapeRecorder);
end.
