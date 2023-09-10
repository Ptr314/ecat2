unit Keyboard;
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
uses  Windows, SysUtils,
			Core;

type
			TKeyboard = class (TComputerDevice)
			protected
				function TranslateNameToCode(KeyName:String):Integer;
			public
				procedure KeyDown(Key:Word); virtual; abstract;
				procedure KeyUp(Key:Word); virtual; abstract;
			end;

			TKeyDescription=record
				code: Word;
        name: String[20];
			end;
const
	KeyTranslations: array [0..96] of TKeyDescription =
		(
			{00}(code: VK_SPACE; name: 'space'),
			{01}(code: VK_BACK; name: 'back'),
			{02}(code: VK_RETURN; name: 'ret'),
			{03}(code: VK_SHIFT; name: 'shift'),
			{04}(code: VK_CONTROL; name: 'ctrl'),
			{05}(code: VK_MENU; name: 'alt'),
			{06}(code: VK_CAPITAL; name: 'caps'),
			{07}(code: VK_ESCAPE; name: 'esc'),
			{08}(code: VK_PRIOR; name: 'pgup'),
			{09}(code: VK_NEXT; name: 'pgdn'),
			{10}(code: VK_END; name: 'end'),
			{11}(code: VK_HOME; name: 'home'),
			{12}(code: VK_LEFT; name: 'left'),
			{13}(code: VK_UP; name: 'up'),
			{14}(code: VK_RIGHT; name: 'right'),
			{15}(code: VK_DOWN; name: 'down'),
			{16}(code: VK_INSERT; name: 'ins'),
			{17}(code: VK_DELETE; name: 'del'),
			{18}(code: VK_NUMPAD0; name: 'num0'),
			{19}(code: VK_NUMPAD1; name: 'num1'),
			{20}(code: VK_NUMPAD2; name: 'num2'),
			{21}(code: VK_NUMPAD3; name: 'num3'),
			{22}(code: VK_NUMPAD4; name: 'num4'),
			{23}(code: VK_NUMPAD5; name: 'num5'),
			{24}(code: VK_NUMPAD6; name: 'num6'),
			{25}(code: VK_NUMPAD7; name: 'num7'),
			{26}(code: VK_NUMPAD8; name: 'num8'),
			{27}(code: VK_NUMPAD9; name: 'num9'),
			{28}(code: VK_MULTIPLY; name: 'mult'),
			{29}(code: VK_ADD; name: 'plus'),
			{30}(code: VK_SEPARATOR; name: 'del2'),
			{31}(code: VK_SUBTRACT; name: 'minus'),
			{32}(code: VK_DECIMAL; name: 'ret2'),
			{33}(code: VK_DIVIDE; name: 'div'),
			{34}(code: VK_F1; name: 'f1'),
			{35}(code: VK_F2; name: 'f2'),
			{36}(code: VK_F3; name: 'f3'),
			{37}(code: VK_F4; name: 'f4'),
			{38}(code: VK_F5; name: 'f5'),
			{39}(code: VK_F6; name: 'f6'),
			{40}(code: VK_F7; name: 'f7'),
			{41}(code: VK_F8; name: 'f8'),
			{42}(code: VK_F9; name: 'f9'),
			{43}(code: VK_F10; name: 'f10'),
			{44}(code: VK_F11; name: 'f11'),
			{45}(code: VK_F12; name: 'f12'),
			{46}(code: VK_NUMLOCK; name: 'num'),
			{47}(code: VK_SCROLL; name: 'scroll'),
			{48}(code: ord('0'); name: '0'),
			{49}(code: ord('1'); name: '1'),
			{50}(code: ord('2'); name: '2'),
			{51}(code: ord('3'); name: '3'),
			{52}(code: ord('4'); name: '4'),
			{53}(code: ord('5'); name: '5'),
			{54}(code: ord('6'); name: '6'),
			{55}(code: ord('7'); name: '7'),
			{56}(code: ord('8'); name: '8'),
			{57}(code: ord('9'); name: '9'),
			{58}(code: ord('A'); name: 'A'),
			{59}(code: ord('B'); name: 'B'),
			{60}(code: ord('C'); name: 'C'),
			{61}(code: ord('D'); name: 'D'),
			{62}(code: ord('E'); name: 'E'),
			{63}(code: ord('F'); name: 'F'),
			{64}(code: ord('G'); name: 'G'),
			{65}(code: ord('H'); name: 'H'),
			{66}(code: ord('I'); name: 'I'),
			{67}(code: ord('J'); name: 'J'),
			{68}(code: ord('K'); name: 'K'),
			{69}(code: ord('L'); name: 'L'),
			{70}(code: ord('M'); name: 'M'),
			{71}(code: ord('N'); name: 'N'),
			{72}(code: ord('O'); name: 'O'),
			{73}(code: ord('P'); name: 'P'),
			{74}(code: ord('Q'); name: 'Q'),
			{75}(code: ord('R'); name: 'R'),
			{76}(code: ord('S'); name: 'S'),
			{77}(code: ord('T'); name: 'T'),
			{78}(code: ord('U'); name: 'U'),
			{79}(code: ord('V'); name: 'V'),
			{80}(code: ord('W'); name: 'W'),
			{81}(code: ord('X'); name: 'X'),
			{82}(code: ord('Y'); name: 'Y'),
			{83}(code: ord('Z'); name: 'Z'),
			{84}(code: ord('V'); name: 'V'),
			{85}(code: 192; name: '~'),
			{86}(code: 189; name: '-'),
			{87}(code: 187; name: '='),
			{88}(code: 220; name: '\'),
			{89}(code: 219; name: '['),
			{90}(code: 221; name: ']'),
			{91}(code: 186; name: ';'),
			{92}(code: 222; name: '"'),
			{93}(code: 188; name: ','),
			{94}(code: 190; name: '.'),
			{95}(code: 191; name: '/'),
			{96}(code: VK_TAB; name: 'tab')
		);

implementation

function TKeyboard.TranslateNameToCode;
var i:Integer;
begin
	for i:=0 to ((SizeOf(KeyTranslations) div SizeOf(TKeyDescription))-1) do
		if AnsiLowerCase(KeyName)=AnsiLowerCase(KeyTranslations[i].name) then begin
			Result := KeyTranslations[i].code;
			exit;
		end;
	Result := -1;
end;

end.
