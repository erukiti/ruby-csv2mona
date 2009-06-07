/* mkwidth */

#include <windows.h>
#include <stdio.h>

#define pt2px(hdc, pt) (-MulDiv((pt), GetDeviceCaps((hdc), LOGPIXELSY), 72))

int getwidth(HDC hdc, int c)
{
	char buf[1024];
	SIZE size;
	int result;

	if ((c & 0xff00) == 0)
		sprintf(buf, "%c", c &0xff);
	else if ((((c & 0xff00) >= 0x8100 && (c & 0xff00) <= 0x9f00) || ((c & 0xff00) >= 0xe000 && (c & 0xff00) <= 0xef00)) && (((c & 0xff) >= 0x40 && (c & 0xff) <= 0x7e) || ((c & 0xff) >= 0x80 && (c & 0xff) <= 0xfc)))
		sprintf(buf, "%c%c", (c & 0xff00) >> 8, c & 0xff);
	else
		return 0;

	result = GetTextExtentPoint32(hdc, buf, strlen(buf), &size);
	printf("%d,%d\n", c, (int)size.cx);

	if (result)
		return (int)size.cx;
	else
		return 0;
}

int main()
{
	HDC hdc;
	int i;

	hdc = CreateDC("DISPLAY", NULL, NULL, NULL);

	SetMapMode(hdc, MM_TEXT);
	SetTextCharacterExtra(hdc, 0);
	SetTextJustification(hdc, 0, 0);
	SetTextAlign(hdc, TA_TOP | TA_LEFT);
	SelectObject(hdc, CreateFont(pt2px(hdc, 12), 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
	                             SHIFTJIS_CHARSET, OUT_CHARACTER_PRECIS, CLIP_DEFAULT_PRECIS,
	                             DEFAULT_QUALITY, DEFAULT_PITCH, "‚l‚r ‚oƒSƒVƒbƒN"));

	for (i = 0x20; i <= 0xffff; i++)
		getwidth(hdc, i);

	return 0;
}
