unit Speaker;
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
		Windows, MMSystem, SysUtils,
		Config, Utils,
		Core, DigitalFilters;

const BuffersCount=32; //Кратно степени 2!
			BuffersCountMask=BuffersCount-1;
			UseFilter=True;

type
		TSpeakerBuffer=array [0..4095] of Byte;
		PSpeakerBuffer=^TSpeakerBuffer;
		TSpeakerData=record
			ClockSampling:Cardinal;
			ClockBuffering:Cardinal;
			SamplesPerSec:Cardinal;
			BitsPerSample:Cardinal;
			BlocksFreq:Cardinal;
			SamplingCount:Cardinal;
			BufferingCount:Cardinal;
			SamplesInBuffer:Cardinal;
			BufferLen:Cardinal;
			BufferLen2:Cardinal;
			BufferPtr:Cardinal;
			BufferLatency:Cardinal;
			CurrentBuffer:Cardinal;
			Buffers: array [-1..BuffersCount-1] of PSpeakerBuffer;
			Headers: array [-1..BuffersCount-1] of TWaveHDR;
			BuffersFlags: array [0..BuffersCount-1] of Byte;
			EmptyCount:Cardinal;
			hEvent: THandle;
			hwo:HWaveOut;
			wfx: TWaveFormatEx;
		end;

		TSpeaker = class (TComputerDevice)
		private
			FIInput: TInterface;
			FIMixer: TInterface;
			SpeakerData:TSpeakerData;
			FFilter: TDigitalFilter;
			FInputWidth: Cardinal;
			FMixerWidth: Cardinal;
			FInputValue: Cardinal;
			procedure InitSound(SysClockFreq: Cardinal);
			function CalcValue:Cardinal;
			procedure FreeSound;
		public
			constructor Create(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice);
			procedure LoadConfig(const SD:TSystemData); override;
			procedure Reset(isCold:Boolean); override;
			procedure CallBack(uMsg:UINT);
			procedure Clock(Counter:Cardinal); override;
			destructor Destroy; override;
		end;

procedure speakerCallback(hwo:HWaveOut; uMsg:UINT; Speaker:TSpeaker; dwParam1, dwParam2:DWORD); stdcall;

implementation

function CreateSpeaker(IM:TInterfaceManager; ConfigDevice:TEmulatorConfigDevice):TComputerDevice;
begin
	Result := TSpeaker.Create(IM, ConfigDevice);
end;

constructor TSpeaker.Create;
var Cpu: TCPU;
begin
	inherited Create(IM, ConfigDevice);
	FIInput := CreateInterface(1, 'input', MODE_R);
	FIMixer := CreateInterface(8, 'mixer', MODE_R);
	Cpu := IM.DM.GetDeviceByName('cpu') as TCPU;
	InitSound(Cpu.ClockValue);
end;

procedure TSpeaker.InitSound(SysClockFreq: Cardinal);
var i:Integer;
		si:TSYSTEMINFO;
		//omega, tt:Extended;

//Параметры сглаживающей RC-цепочки
const
		fs = 2000; //Для конденсатора 10 мкф и динамика 8 ом.
		dt = 1/44100;
		RC = 1/(2*Pi*fs);
		alpha = dt/(RC + dt);

begin
	GetSystemInfo(si);
	with SpeakerData do begin
		ClockSampling:=0;
		ClockBuffering:=0;
		SamplesPerSec:=44100;
		BitsPerSample:=8;
		BlocksFreq:=50;

		//Через сколько тактов запоминать сигнал
		//Умножаем на 16 для повышения точности
		SamplingCount:=Round(SysClockFreq*16/SamplesPerSec);
		//Через сколько тактов выводить блок
		BufferingCount:=SysClockFreq div BlocksFreq;
		//Кол-во семплов в блоке
		SamplesInBuffer:=SamplesPerSec div BlocksFreq;

		BufferLen:=SamplesInBuffer*(BitsPerSample div 8);
		BufferLen2:=((BufferLen div si.dwPageSize)+1)*si.dwPageSize;

		CurrentBuffer:=0;
		BufferPtr:=0;
		BufferLatency:=0;

		EmptyCount:=1000;

		//Один буфер с тишиной будет использоваться в начале каждой последовательности
		for i:=-1 to BuffersCount-1 do begin
			GetMem(Buffers[i], BufferLen2);
			FillChar(Buffers[i]^, BufferLen2, 127);
			Headers[i].lpData:=Pointer(Buffers[i]);
			Headers[i].dwBufferLength:=BufferLen;
			waveOutPrepareHeader(hwo, @Headers[i], SizeOf(TWaveHDR));
		end;
		//Buffers[-1]^[0]:=100; //Для отладки - чтобы видеть начало пустого фрейма
		wfx.wFormatTag:=WAVE_FORMAT_PCM;
		wfx.nChannels:=1;
		wfx.nSamplesPerSec:=SamplesPerSec;
		wfx.wBitsPerSample:=BitsPerSample;
		wfx.nBlockAlign:=wfx.wBitsPerSample div 8 * wfx.nChannels;
		wfx.nAvgBytesPerSec:=wfx.nSamplesPerSec * wfx.nBlockAlign;
		wfx.cbSize:=0;
		//hEvent:=CreateEvent(nil, false, false, nil);
		//waveOutOpen(@hwo, 0, @wfx, hEvent, 0, CALLBACK_EVENT);
		waveOutOpen(@hwo, 0, @wfx, Integer(@speakerCallback), DWORD(Self), CALLBACK_FUNCTION);
		//waveOutSetVolume(hwo, 0);
	end;

	//omega:=2*PI*440;
	//for i:=0 to SpeakerData.BufferLen do begin
	//	tt:=I/44100;
	//	(SpeakerData.Buffers[0])^[i]:=0; //Round(127*sin(omega*tt))+127;
	//	(SpeakerData.Buffers[1])^[i]:=SpeakerData.Buffers[0]^[i];
	//end;

	//Инициализация цифрового фильтра
	if UseFilter then
		//RC-цепочка
		FFilter := TDigitalFilter.Create(1, //Order
																		[alpha, 0], //CX
																		[0, 1-alpha], //CY
																		1 //Gain
														);
		//Фильтр Баттерворта 2-го порядка с частотой среза 2000 Гц
		//FFilter := TDigitalFilter.Create(2, //Order
		//																[1, 2, 1], //CX
		//																[0, 1.6, -0.67], //CY
		//																60 //Gain
		//					 );
end;

procedure TSpeaker.FreeSound;
var i:Integer;
begin
	waveOutReset(SpeakerData.hwo);
	for i:=-1 to BuffersCount-1 do begin
		waveOutUnprepareHeader(SpeakerData.hwo, @SpeakerData.Headers[i], SizeOf(TWaveHDR));
		FreeMem(SpeakerData.Buffers[i]);
		//VirtualFree(SpeakerData.Buffers[i], 0, MEM_RELEASE);
	end;
	FFilter.Free;
end;

procedure speakerCallback(hwo:HWaveOut; uMsg:UINT; Speaker:TSpeaker; dwParam1, dwParam2:DWORD); stdcall;
begin
	Speaker.CallBack(uMsg);
end;

procedure TSpeaker.CallBack;
begin
	if (uMsg=WOM_DONE) then Dec(SpeakerData.BufferLatency);
end;

{asm
	CMP uMsg, WOM_DONE
	JNZ @EXIT
	DEC SpeakerData.BufferLatency
	@EXIT:
end;

//	if (uMsg=WOM_DONE) and (SoundTimesCount2<200) then begin
//			SoundTimes2[SoundTimesCount2]:=timeGetTime;
//			SoundBuffs2[SoundTimesCount2]:=SpeakerData.BufferLatency;
//			Inc(SoundTimesCount2);
//		end;

end;}

procedure TSpeaker.Clock;
var V:Cardinal;
begin
	//Умножаем на 16 для повышения точности
	Inc(SpeakerData.ClockSampling, Counter shl 4);
	Inc(SpeakerData.ClockBuffering, Counter);
	if (SpeakerData.ClockSampling>=SpeakerData.SamplingCount) then begin
		Dec(SpeakerData.ClockSampling, SpeakerData.SamplingCount);
		V:=CalcValue;
		//if UseFilter then V:=FFilter.Calc(V);
		SpeakerData.Buffers[SpeakerData.CurrentBuffer]^[SpeakerData.BufferPtr]:=V;

		//Для 2 и последующих семплов проверяем, был ли звук, чтобы не ставить пустые буферы.
		if (SpeakerData.BufferPtr>0) then
			SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer]:= SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer] or
			(SpeakerData.Buffers[SpeakerData.CurrentBuffer]^[SpeakerData.BufferPtr-1] xor V);
		Inc(SpeakerData.BufferPtr);
	end;
	if (SpeakerData.ClockBuffering>=SpeakerData.BufferingCount) then begin
		Dec(SpeakerData.ClockBuffering, SpeakerData.BufferingCount);

		//Если очередь пустая, а текущий буфер нет, то ставим один пустой фрейм
		//Это дает фору, которая позволит непрерывно подавать новые фреймы
		if ((SpeakerData.BufferLatency=0) and (SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer]<>0)) then begin
			if UseFilter then FFilter.Reset;
			waveOutWrite(SpeakerData.hwo, @(SpeakerData.Headers[-1]), SizeOf(TWaveHDR));
			Inc(SpeakerData.BufferLatency)
		end;

		//Если фрейм непустой, или не дошли до конца хвоста из пустых фреймов
		if ((SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer]<>0) or (SpeakerData.EmptyCount<5)) then begin

			waveOutWrite(SpeakerData.hwo, @SpeakerData.Headers[SpeakerData.CurrentBuffer], SizeOf(TWaveHDR));
			//Если фрейм был пустой, то запоминаем их количество
			//Иначе обнуляем счетчик
			if (SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer]=0) then
				Inc(SpeakerData.EmptyCount)
			else
				SpeakerData.EmptyCount:=0;

			Inc(SpeakerData.BufferLatency);
			Inc(SpeakerData.CurrentBuffer);
			SpeakerData.CurrentBuffer := SpeakerData.CurrentBuffer and BuffersCountMask;

			//Сбрасываем новый буфер, иначе данные начнут повторяться независимо от реального содержания
			waveOutUnprepareHeader(SpeakerData.hwo, @SpeakerData.Headers[SpeakerData.CurrentBuffer], SizeOf(TWaveHDR));
			waveOutPrepareHeader(SpeakerData.hwo, @SpeakerData.Headers[SpeakerData.CurrentBuffer], SizeOf(TWaveHDR));
		end;
		SpeakerData.BuffersFlags[SpeakerData.CurrentBuffer]:=0;
		SpeakerData.BufferPtr:=0;

	end;
end;

destructor TSpeaker.Destroy;
begin
	FreeSound;
	inherited Destroy;
end;

procedure TSpeaker.Reset(isCold:Boolean);
begin
	inherited Reset(isCold);
	if FIInput.Linked = 0 then
		FInputWidth := 0
	else
		FInputWidth := 1;
	if FIMixer.Linked = 0 then
		FMixerWidth := 0
	else begin
		FMixerWidth := CalcBits(FIMixer.LinkedBits, 8);
	end;
	if FInputWidth + FMixerWidth > 0 then
		FInputValue := 127 div (FInputWidth + FMixerWidth)
	else
		FInputValue := 1;
end;

procedure TSpeaker.LoadConfig;
begin
	inherited LoadConfig(SD);
end;

function TSpeaker.CalcValue:Cardinal;
var V:Cardinal;
		i: Integer;
begin
	V := 0;
	if FInputWidth<>0 then Inc(V, FIInput.Value and 1);
	for i:=0 to FMixerWidth-1 do
		Inc(V, (FIMixer.Value shr i) and 1);
	Result := V*FInputValue + 127;
end;


begin
	RegisterDeviceCreateFunc('speaker', @CreateSpeaker);
end.
