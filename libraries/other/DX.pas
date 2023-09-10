unit DX;
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

//Модуль работы с системами DirectX. В данный момент реализован
//класс для ввода с клавиатуры через DirectInput

//Частично использован код: Виктор Кода
//http://www.delphikingdom.com/asp/users.asp?ID=1146

interface

uses Windows, DirectInput, Contnrs;

type
			TDXInput = class
			private
				lpDI8: IDirectInput8;
				lpDIKeyboard: IDirectInputDevice8;
				bKeyBuffer: array [0..1, 0..255] of Byte;
				CurrentBuffer: Cardinal;
				ButtonEvents: TQueue;
				FHaveFocus: Boolean;
			public
				constructor Create(hWnd: HWND);
				destructor Destroy; override;
				procedure InitDirectInput(hWnd: HWND);
				procedure ReleaseDirectInput();
				function Update: Boolean;
				function GetNextButton: Word;
			end;

implementation

uses SysUtils;

var
	DIK2VK: array [0..255] of Word;

constructor TDXInput.Create(hWnd: HWND);
begin
	InitDirectInput(hWnd);
	CurrentBuffer := 0;
	ButtonEvents := TQueue.Create;
end;

destructor TDXInput.Destroy;
begin
	ReleaseDirectInput;
	ButtonEvents.Free;
	inherited Destroy;
end;

procedure TDXInput.InitDirectInput;
begin
	lpDI8 := nil;
	lpDIKeyboard := nil;

	// Создаём главный объект DirectInput
	if FAILED( DirectInput8Create( GetModuleHandle( nil ), DIRECTINPUT_VERSION,
																 IID_IDirectInput8, lpDI8, nil ) ) then
		 raise Exception.Create('Не удалось создать главный объект DirectInput');
	lpDI8._AddRef();

	// Создаём объект для работы с клавиатурой
	if FAILED( lpDI8.CreateDevice( GUID_SysKeyboard, lpDIKeyboard, nil ) ) then
		 raise Exception.Create('Не удалось создать объект DirectInput для работы с клавиатурой');
	lpDIKeyboard._AddRef();

	// Устанавливаем предопределённый формат для "простой клавиатуры". В боль-
	// шинстве случаев можно удовлетвориться и установками, заданными в структуре
	// c_dfDIKeyboard по умолчанию, но в особых случаях нужно заполнить её самому
	if FAILED( lpDIKeyboard.SetDataFormat( c_dfDIKeyboard ) ) then
		 raise Exception.Create('Не удалось инициализировать объект клавиатуры DirectInput');

	// Устанавливаем уровень кооперации. Подробности о флагах смотри в DirectX SDK
	if FAILED( lpDIKeyboard.SetCooperativeLevel( hWnd, DISCL_BACKGROUND or
																										 DISCL_NONEXCLUSIVE ) ) then
		 raise Exception.Create('Не удалось установить уровень кооперации DirectInput');

	// Захвытываем клавиатуру
	lpDIKeyboard.Acquire();
end;

procedure TDXInput.ReleaseDirectInput();
begin
	// Удаляем объект для работы с клавиатурой
	if lpDIKeyboard <> nil then // Можно проверить if Assigned( DIKeyboard )
	begin
		lpDIKeyboard.Unacquire(); // Освобождаем устройство
		lpDIKeyboard._Release();
		lpDIKeyboard := nil;
	end;

	// Последним удаляем главный объект DirectInput
	if lpDI8 <> nil then
	begin
		lpDI8._Release();
		lpDI8 := nil;
	end;
end;

function TDXInput.Update(): Boolean;
var
	i:          Integer;
	PrevBuffer: Cardinal;
begin
	PrevBuffer := CurrentBuffer;
	CurrentBuffer := CurrentBuffer xor 1;

	Result := FALSE;

	// Производим опрос состояния клавиш, данные записываются в буфер-массив
	if lpDIKeyboard.GetDeviceState( SizeOf( bKeyBuffer ) div 2, @bKeyBuffer[CurrentBuffer] ) = DIERR_INPUTLOST then
	begin
		// Захватываем снова
		lpDIKeyboard.Acquire();
		// Производим повторный опрос
		if FAILED( lpDIKeyboard.GetDeviceState( SizeOf( bKeyBuffer ) div 2, @bKeyBuffer[CurrentBuffer] ) ) then
			 Exit;
	end;

	for i:=0 to 255 do
		if bKeyBuffer[CurrentBuffer][i] <> bKeyBuffer[PrevBuffer][i] then begin
			if (bKeyBuffer[CurrentBuffer][i] and $80 = $80) then
				ButtonEvents.Push(Pointer(DIK2VK[i] or $8000))
			else
				ButtonEvents.Push(Pointer(DIK2VK[i]));
		end; 

	{if bKeyBuffer[ DIK_NUMPAD4 ] = $080 then Dec( nXPos );}

	Result := TRUE;
end;

function TDXInput.GetNextButton: Word;
begin
	if ButtonEvents.Count > 0 then
		Result := Cardinal(ButtonEvents.Pop)
	else
		Result := 0;
end;

begin
	FillChar(DIK2VK, SizeOf(DIK2VK), 0);
	DIK2VK[DIK_ESCAPE] := VK_ESCAPE;
	DIK2VK[DIK_1] := Ord('1');
	DIK2VK[DIK_2] := Ord('2');
	DIK2VK[DIK_3] := Ord('3');
	DIK2VK[DIK_4] := Ord('4');
	DIK2VK[DIK_5] := Ord('5');
	DIK2VK[DIK_6] := Ord('6');
	DIK2VK[DIK_7] := Ord('7');
	DIK2VK[DIK_8] := Ord('8');
	DIK2VK[DIK_9] := Ord('9');
	DIK2VK[DIK_0] := Ord('0');
	DIK2VK[DIK_MINUS] := $BD; { - on main keyboard }
	DIK2VK[DIK_EQUALS] := $BB;
	DIK2VK[DIK_BACK] := VK_BACK; { backspace }
	DIK2VK[DIK_TAB] := VK_TAB;
	DIK2VK[DIK_Q] := Ord('Q');
	DIK2VK[DIK_W] := Ord('W');
	DIK2VK[DIK_E] := Ord('E');
	DIK2VK[DIK_R] := Ord('R');
	DIK2VK[DIK_T] := Ord('T');
	DIK2VK[DIK_Y] := Ord('Y');
	DIK2VK[DIK_U] := Ord('U');
	DIK2VK[DIK_I] := Ord('I');
	DIK2VK[DIK_O] := Ord('O');
	DIK2VK[DIK_P] := Ord('P');
	DIK2VK[DIK_LBRACKET] := $DB;
	DIK2VK[DIK_RBRACKET] := $DD;
	DIK2VK[DIK_RETURN] := VK_RETURN; { Enter on main keyboard }
	DIK2VK[DIK_LCONTROL] := VK_LCONTROL;
	DIK2VK[DIK_A] := Ord('A');
	DIK2VK[DIK_S] := Ord('S');
	DIK2VK[DIK_D] := Ord('D');
	DIK2VK[DIK_F] := Ord('F');
	DIK2VK[DIK_G] := Ord('G');
	DIK2VK[DIK_H] := Ord('H');
	DIK2VK[DIK_J] := Ord('J');
	DIK2VK[DIK_K] := Ord('K');
	DIK2VK[DIK_L] := Ord('L');
	DIK2VK[DIK_SEMICOLON] := $BA;
	DIK2VK[DIK_APOSTROPHE] := $DE;
	DIK2VK[DIK_GRAVE] := $C0; { accent grave }
	DIK2VK[DIK_LSHIFT] := VK_LSHIFT;
	DIK2VK[DIK_BACKSLASH] := $DC;
	DIK2VK[DIK_Z] := Ord('Z');
	DIK2VK[DIK_X] := Ord('X');
	DIK2VK[DIK_C] := Ord('C');
	DIK2VK[DIK_V] := Ord('V');
	DIK2VK[DIK_B] := Ord('B');
	DIK2VK[DIK_N] := Ord('N');
	DIK2VK[DIK_M] := Ord('M');
	DIK2VK[DIK_COMMA] := $BC;
	DIK2VK[DIK_PERIOD] := $BE; { . on main keyboard }
	DIK2VK[DIK_SLASH] := $BF; { / on main keyboard }
	DIK2VK[DIK_RSHIFT] := VK_RSHIFT;
	DIK2VK[DIK_MULTIPLY] := VK_MULTIPLY; { * on numeric keypad }
	DIK2VK[DIK_LMENU] := VK_LMENU; { left Alt }
	DIK2VK[DIK_SPACE] := VK_SPACE;
	DIK2VK[DIK_CAPITAL] := VK_CAPITAL;
	DIK2VK[DIK_F1] := VK_F1;
	DIK2VK[DIK_F2] := VK_F2;
	DIK2VK[DIK_F3] := VK_F3;
	DIK2VK[DIK_F4] := VK_F4;
	DIK2VK[DIK_F5] := VK_F5;
	DIK2VK[DIK_F6] := VK_F6;
	DIK2VK[DIK_F7] := VK_F7;
	DIK2VK[DIK_F8] := VK_F8;
	DIK2VK[DIK_F9] := VK_F9;
	DIK2VK[DIK_F10] := VK_F10;
	DIK2VK[DIK_NUMLOCK] := VK_NUMLOCK;
	DIK2VK[DIK_SCROLL] := VK_SCROLL; { Scroll Lock }
	DIK2VK[DIK_NUMPADENTER] := VK_RETURN;
	DIK2VK[DIK_NUMPAD7] := VK_NUMPAD7;
	DIK2VK[DIK_NUMPAD8] := VK_NUMPAD8;
	DIK2VK[DIK_NUMPAD9] := VK_NUMPAD9;
	DIK2VK[DIK_SUBTRACT] := VK_SUBTRACT; { - on numeric keypad }
	DIK2VK[DIK_NUMPAD4] := VK_NUMPAD4;
	DIK2VK[DIK_NUMPAD5] := VK_NUMPAD5;
	DIK2VK[DIK_NUMPAD6] := VK_NUMPAD6;
	DIK2VK[DIK_ADD] := VK_ADD; { + on numeric keypad }
	DIK2VK[DIK_NUMPAD1] := VK_NUMPAD1;
	DIK2VK[DIK_NUMPAD2] := VK_NUMPAD2;
	DIK2VK[DIK_NUMPAD3] := VK_NUMPAD3;
	DIK2VK[DIK_NUMPAD0] := VK_NUMPAD0;
	DIK2VK[DIK_DECIMAL] := VK_DECIMAL; { . on numeric keypad }
	DIK2VK[DIK_F11] := VK_F11;
	DIK2VK[DIK_F12] := VK_F12;
	DIK2VK[DIK_F13] := VK_F13; { (NEC PC98) }
	DIK2VK[DIK_F14] := VK_F14; { (NEC PC98) }
	DIK2VK[DIK_F15] := VK_F15; { (NEC PC98) }
	DIK2VK[DIK_KANA] := VK_KANA; { (Japanese keyboard) }
	DIK2VK[DIK_CONVERT] := VK_CONVERT; { (Japanese keyboard) }
	DIK2VK[DIK_RCONTROL] := VK_RCONTROL;
	DIK2VK[DIK_DIVIDE] := VK_DIVIDE; { / on numeric keypad }
	DIK2VK[DIK_RMENU] := VK_RMENU; { right Alt }
	DIK2VK[DIK_PAUSE] := VK_PAUSE; { Pause }
	DIK2VK[DIK_HOME] := VK_HOME; { Home on arrow keypad }
	DIK2VK[DIK_UP] := VK_UP; { UpArrow on arrow keypad }
	DIK2VK[DIK_PRIOR] := VK_PRIOR; { PgUp on arrow keypad }
	DIK2VK[DIK_LEFT] := VK_LEFT; { LeftArrow on arrow keypad }
	DIK2VK[DIK_RIGHT] := VK_RIGHT; { RightArrow on arrow keypad }
	DIK2VK[DIK_END] := VK_END; { End on arrow keypad }
	DIK2VK[DIK_DOWN] := VK_DOWN; { DownArrow on arrow keypad }
	DIK2VK[DIK_NEXT] := VK_NEXT; { PgDn on arrow keypad }
	DIK2VK[DIK_INSERT] := VK_INSERT; { Insert on arrow keypad }
	DIK2VK[DIK_DELETE] := VK_DELETE; { Delete on arrow keypad }
	DIK2VK[DIK_LWIN] := VK_LWIN; { Left Windows key }
	DIK2VK[DIK_RWIN] := VK_RWIN; { Right Windows key }
	DIK2VK[DIK_APPS] := VK_APPS; { AppMenu key }
end.
