unit config;
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
	SysUtils;

const
	parser_spaces = ' '#9#10#13;
	parser_line   = #10#13;
	parser_border = '=[]{}';

type
			TEmulatorConfigParameter = record
				Name, Left_range, Value, Right_Range, Right_extended: String;
			end;

			TEmulatorConfigDevice = class
			private
				FName : String;
				FType : String;
				FParametersCount: Cardinal;
				FParameters: array [0..99] of TEmulatorConfigParameter;
				function GetParameterByName(Name: String): TEmulatorConfigParameter;
				function GetParameterById(I: Cardinal): TEmulatorConfigParameter;
			public
				constructor Create(DeviceName, DeviceType:String);
				procedure AddParameter(Name, Left_Range, Value, Right_Range, Right_Extended: String);
				function ExtendedParameter(I:Cardinal; ExpectedName: String): String;
				destructor Destroy; override;
				property Name:String read FName;
				property DType:String read FType;
				property ParametersCount : Cardinal read FParametersCount;
				property Parameters[Name:String]:TEmulatorConfigParameter read GetParameterByName;
				property Parameter[I:Cardinal]:TEmulatorConfigParameter read GetParameterById;
			end;

			TEmulatorConfig = class
			private
				FDevicesCount : Cardinal;
				FDevices : array [0..99] of TEmulatorConfigDevice;
				function ReadNextEntity(H:Integer; stop_add:String=''): String;
				function ReadExtendedEntity(H:Integer; stop_chars:String):String;
				function GetDeviceByName(Name: String): TEmulatorConfigDevice;
				function GetDeviceById(I:Cardinal): TEmulatorConfigDevice;
				function AddDevice(DeviceName, DeviceType:String):TEmulatorConfigDevice;
				procedure FreeDevices;
			public
				constructor Create; overload;
				constructor Create(FileName:String); overload;
				procedure LoadFromFile(FileName:String; SystemOnly:Boolean=False);
				destructor Destroy; override;
				property DevicesCount : Cardinal read FDevicesCount;
				property Devices[Name:String]:TEmulatorConfigDevice read GetDeviceByName;
				property Device[I:Cardinal]:TEmulatorConfigDevice read GetDeviceById;
			end;


implementation

constructor TEmulatorConfigDevice.Create(DeviceName, DeviceType:String);
begin
	FParametersCount := 0;
	FName := DeviceName;
	FType := DeviceType;
end;

procedure TEmulatorConfigDevice.AddParameter(Name, Left_Range, Value, Right_Range, Right_Extended: String);
begin
	//FParameters[FParametersCount]:= TEmulatorConfigParameter.Create;
	FParameters[FParametersCount].Name := Name;
	FParameters[FParametersCount].Left_Range := Left_Range;
	FParameters[FParametersCount].Value := Value;
	FParameters[FParametersCount].Right_Range := Right_Range;
	FParameters[FParametersCount].Right_Extended := Right_Extended;
	Inc(FParametersCount);
end;

destructor TEmulatorConfigDevice.Destroy;
//var i:Integer;
begin
	//for i:=0 to FParametersCount-1 do FParameters[i].Free;
	inherited Destroy;
end;

constructor TEmulatorConfig.Create;
begin
	FDevicesCount := 0;
end;

procedure TEmulatorConfig.FreeDevices;
var i:Integer;
begin
	for i:=0 to FDevicesCount-1 do FDevices[i].Free;
	FDevicesCount := 0;
end;

destructor TEmulatorConfig.Destroy;
begin
	FreeDevices;
	inherited Destroy;
end;

constructor TEmulatorConfig.Create(FileName:String);
begin
	Create;
	LoadfromFile(FileName);
end;

function TEmulatorConfig.ReadNextEntity(H:Integer; stop_add:String=''): String;
var S, stop_chars: String;
		L: Integer;
		C: Char;
begin
	S:='';
	//Пропускаем пробелы
	L := FileRead(H, C, 1);
	while (L>0) and (Pos(C, parser_spaces)>0) do L := FileRead(H, C, 1);
	
  //Если не конец файла
	if L>0 then begin
		//Если не разделитель
		if Pos(C, parser_border+stop_add)=0 then begin
			if C='"' then begin
				stop_chars := parser_line+'"';
				L := FileRead(H, C, 1);
			end else
				stop_chars := parser_border+parser_line+stop_add;
			while (L>0) and (Pos(C, stop_chars)=0) do begin
				S:=S+C;
				L := FileRead(H, C, 1);
			end;
			if (L>0) and (C<>'"') then FileSeek(H, -1, 1);
			Result := S;
		end else
			Result := C;
	end else
		Result:='';
	Result := TrimRight(Result);
end;

function TEmulatorConfig.ReadExtendedEntity(H:Integer; stop_chars:String):String;
var C:Char;
		L:Integer;
begin
	Result := '';
	L := FileRead(H, C, 1);
	while (L>0) and (Pos(C, stop_chars)=0) do begin
		Result := Result + C;
		L := FileRead(H, C, 1);
	end;
end;

procedure TEmulatorConfig.LoadfromFile(FileName:String; SystemOnly:Boolean=False);
var H:Integer;
		S, DeviceName, DeviceType, Range_left, ParamName, NewParamName, ParamValue, Range_right, Extended_right:String;
		NewDevice: TEmulatorConfigDevice;
begin
	if FDevicesCount > 0 then FreeDevices;
	
	H := FileOpen(FileName, fmOpenRead);
	repeat
		DeviceName := ReadNextEntity(H, ':');
		if DeviceName='' then break; //raise Exception.Create('Ошибка конфигурации - нет имени устройства');
		if DeviceName<>AnsiLowerCase('system') then begin
			S := ReadNextEntity(H, ':');
			if (S='') or (S<>':') then raise Exception.Create('Ошибка конфигурации - нет описания типа '+DeviceName);
			DeviceType := ReadNextEntity(H);
			if DeviceType='' then raise Exception.Create('Ошибка конфигурации - нет описания типа '+DeviceName);
		end else DeviceType:='';

		NewDevice := AddDevice(DeviceName, DeviceType);

		S := ReadNextEntity(H);
		if (S='') or (S<>'{') then raise Exception.Create('Ошибка конфигурации - неверное описание устройства '+DeviceName);

		//Чтение левой части
		ParamName := ReadNextEntity(H);
		if (ParamName='') then raise Exception.Create('Ошибка конфигурации - неверное описание параметров '+DeviceName);
		while ParamName<>'}' do begin
			NewParamName := ParamName;
			S := ReadNextEntity(H);
			if (S='') or ((S<>'[') and (S<>'=')) then raise Exception.Create('Ошибка конфигурации - неверное описание параметров '+DeviceName);
			//Проверяем наличие диапазона в левой части и читаем его
			if S='[' then begin
				Range_left := '';
				while S<>'=' do begin
					Range_left := Range_left + S;
					S := ReadNextEntity(H);
					if (S='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName+':'+ParamName);
				end;
			end else Range_left := '';

			//Чтение правой части
			S := ReadNextEntity(H);
			if (S='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName+':'+ParamName);
			if S<>'{' then begin
				ParamValue := S;
				S := ReadNextEntity(H);
				if (S='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName);
				if S='}' then begin
					NewDevice.AddParameter(NewParamName, Range_left, ParamValue, '', '');
					ParamName := S;
					break;
				end;
				if S='[' then begin
					Range_right := '';
					repeat
						Range_right := Range_right + S;
						S := ReadNextEntity(H);
						if (S='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName+':'+ParamName);
					until S=']';
					Range_right := Range_right + S;
					S := ReadNextEntity(H);
					if (S='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName+':'+ParamName);
				end else
					Range_right := '';
			end else begin
				ParamValue := '';
				Range_right := '';
			end;

			Extended_right := '';
			if S='{' then begin
				Extended_right := ReadExtendedEntity(H, '}');
				ParamName := ReadNextEntity(H);
				if (ParamName='') then raise Exception.Create('Ошибка конфигурации - неверное описание '+DeviceName);
			end else
				ParamName := S;

			NewDevice.AddParameter(NewParamName, Range_left, ParamValue, Range_right, Extended_right);

		end; //Read current parameter
	until SystemOnly and (DeviceName = 'system');
	FileClose(H);
end;

function TEmulatorConfig.GetDeviceByName(Name: String): TEmulatorConfigDevice;
var i:Integer;
begin
	Result := nil;
	for i:=0 to FDevicesCount-1 do
		if FDevices[i].Name = Name then Result := FDevices[i];
end;

function TEmulatorConfig.GetDeviceById(I:Cardinal): TEmulatorConfigDevice;
begin
	if I>FDevicesCount-1 then raise Exception.Create('Обращение по номеру к несуществующему устройству')
	else Result := FDevices[I];
end;

function TEmulatorConfig.AddDevice(DeviceName, DeviceType:String):TEmulatorConfigDevice;
begin
	FDevices[FDevicesCount] := TEmulatorConfigDevice.Create(DeviceName, DeviceType);
	Result := FDevices[FDevicesCount];
	Inc(FDevicesCount);
end;

function TEmulatorConfigDevice.GetParameterByName(Name: String): TEmulatorConfigParameter;
var i:Integer;
		Found: Boolean;
begin
	//Result := nil;
	Found := FALSE;
	for i:=0 to FParametersCount-1 do
		if FParameters[i].Name = Name then begin
			Found := TRUE;
			Result := FParameters[i];
		end;
	if not Found then raise Exception.Create('Параметр '+FName+':'+Name+' не найден');
end;

function TEmulatorConfigDevice.GetParameterById(I:Cardinal): TEmulatorConfigParameter;
begin
	if I>FParametersCount-1 then raise Exception.Create('Обращение по номеру к несуществующему параметру устройства '+Name)
	else Result := FParameters[I];
end;

function TEmulatorConfigDevice.ExtendedParameter(I:Cardinal; ExpectedName: String): String;
var S, ParamName, ParamValue, stop_chars:String;
		L, P, SP: Cardinal;
begin
	S := Trim(Parameter[I].Right_extended);
	L := Length(S);
	Result := '';
	if L=0 then Exit;
	P:=1;
	while P<L do begin
		//Пропускаем пробелы
		while (P<=L) and (Pos(S[P], parser_spaces)>0) do Inc(P);
		SP := P;
		//Название текущего параметра
		while (P<=L) and (Pos(S[P], parser_spaces+'=')=0) do Inc(P);
		if P<L then ParamName := copy(S, SP, P-SP)
		else break;
		//Если еще не знак '=', то пропускаем пробелы
		if S[P]<>'=' then begin
			while (P<=L) and (S[P]<>'=') do Inc(P);
			if P>=L then break;
		end;
		Inc(P);
		//Пропускаем пробелы
		while (P<=L) and (Pos(S[P], parser_spaces)>0) do Inc(P);
		if P>L then break;
		if S[P]='"' then begin
			stop_chars := '"}';
			Inc(P);
			if P>=L then break;
		end else
			stop_chars := parser_spaces+parser_line+'}';
		//читаем значение
		SP := P;
		while (P<=L) and (Pos(S[P], stop_chars)=0) do Inc(P);
		ParamValue := copy(S, SP, P-SP);
		Inc(P);
		if ParamName = ExpectedName then begin
			Result := ParamValue;
			break;
		end;
	end;
end;


//var Config: TEmulatorConfig;
//		i, j: Cardinal;
//		D: TEmulatorConfigDevice;
//begin
//	Config := TEmulatorConfig.Create('computers\orion-128\Orion-128.cfg');
//	for i:= 0 to Config.DevicesCount-1 do begin
//		D := config.device[i];
//		writeln(D.Name+' : '+D.DType);
//		if D.ParametersCount > 0 then
//			for j:=0 to D.ParametersCount-1 do begin
//				writeln('  '+D.Parameter[j].Name+D.Parameter[j].Left_range+' = '+D.Parameter[j].Value+D.Parameter[j].Right_range);
//				if D.Parameter[j].Right_extended<>'' then
//					writeln('    {'+D.Parameter[j].Right_extended+'}');
//			end;
//	end;
//	Config.Free;
//	readln;
end.
