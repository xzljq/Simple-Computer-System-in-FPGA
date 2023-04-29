#define VGA_ZERO 0x00200000
#define VGA_START 0x00200004
#define VGA_LINE_O 0x00210000
#define VGA_MAXLINE 30
#define VGA_MASK 0x003f
#define VGA_MAXCOL 70

#define KB_DATA 0X00300000
//#define KB_BUFFER_START 0x00301000

#define TIME 0x00400000
#define T_01s 1000
#define T_08s 8000

#define LEDR_START 0x00500000

#define SEG_START 0x0050000a

void putstr(char *str);
void putch(char ch);
void vga_init(void);
void getstr(char *str);

int gettime();
void settime(int time_set);

void open_LEDR(int n);
void close_LEDR(int n);

void set_SEG(int n,int num);
