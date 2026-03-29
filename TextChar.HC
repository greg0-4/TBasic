DocClear;
I64 ascii = 64;
I64 back = BLUE;
I64 front = YELLOW;

I64 textPos = 0;

I64 combined = (back << 12) | (front << 8) | ascii;
while(1==1) {
TextChar(Fs, 0, textPos, 20, combined);
textPos += 8;
Yield;
}