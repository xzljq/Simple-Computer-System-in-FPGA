#include "sys.h"

char *vga_start = (char*) VGA_START;
int *zero_line = (int*) VGA_ZERO;
int vga_line = 0;
int vga_ch = 0;
int temp_zero = 0;

int lenth[VGA_MAXLINE];

void vga_init(){
    vga_line = 0;
    vga_ch = 0;
    for(int i=0; i<VGA_MAXLINE; i++){
        for(int j=0; j<VGA_MAXCOL; j++){
            vga_start[(i<<7)+j] = 0;
        }
    }
}

void putch(char ch){
    if(ch==8){ // backspace
        if(vga_line==0 && vga_ch==0) return;
        
        vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = 0;
        if(vga_ch==0){
            vga_ch = VGA_MAXCOL - 1;
            vga_line--;
        }
        else vga_ch--;

    	vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = 0x5F;

	return;
    }

    if(ch==10){ //enter
        vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = 10;
        vga_ch = 0;
        if(vga_line == VGA_MAXLINE-1){
            for(int i=0; i<VGA_MAXCOL; i++){
                vga_start[(temp_zero<<7) + i] = 0;
            }
            temp_zero = (temp_zero + 1)%30;
            *zero_line = temp_zero;
        }
        else vga_line++ ;

    	vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = 0x5F;
	return;
    }

    vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = ch;
    vga_ch++;
    if(vga_ch>=VGA_MAXCOL){
        vga_ch = 0;
        if(vga_line == VGA_MAXLINE-1){
            for(int i=0; i<VGA_MAXCOL; i++){
                vga_start[(temp_zero<<7) + i] = 0;
            }
            temp_zero = (temp_zero + 1)%30;
            *zero_line = temp_zero;

        }
        
        else vga_line++ ;
    }


    vga_start[(((vga_line + temp_zero)%VGA_MAXLINE)<<7)+vga_ch] = 0x5F;

    return;

}

void putstr(char *str){
    for(char *p = str; *p!=0; p++){
        putch(*p);
    }
}

void getstr(char *str)
{
    char last_ascii=0;
    char cur_ascii=0;
    char* ascii=(char *)KB_DATA;
    char* cmd=str;
    int press_begin;
    int i=0;
    while(1)
    {
        cur_ascii=*ascii;
        
        if(cur_ascii!=0)
        {
            if(last_ascii==0)//刚刚按下
            {
                press_begin=gettime();
                if(cur_ascii==13)//enter 检测到回车
                {
                    putch(10);//显存里存换行符10
                    cmd[i]='\0';//字符串中存结束符
                    int j=0;
                    while(j<2500)
                    {
                        j++;
                    }
                    return;
                }
                else if(cur_ascii==8)//backspace
                {
                    if(i<=0)
                    {
                    continue;
                    }
                    putch(8);
                    cmd[--i]=0;
                }
                else//normal
                {
                    putch(cur_ascii);
                    cmd[i++]=cur_ascii;
                }  
            }
        else//按住
        {
            int current=gettime();
            if(current-press_begin>T_08s)
            {
                if(cur_ascii==8)//backspace
                {
                    if(i<=0)
                    {
                    continue;
                    }
                    putch(8);
                    cmd[--i]=0;
                }
                else//normal
                {
                    putch(cur_ascii);
                    cmd[i++]=cur_ascii;
                }

                press_begin+=T_01s;
            }
        }
        }


        last_ascii=cur_ascii;
    }
}



int gettime()//单位：10^-4s
{
    int* t=(int*)TIME;
    return *t;
}


//建议cmd格式 settime 时:分:秒
void settime(int time_set)//将内部时间设置为time_set (10^-4s) 
{
    int* t=(int*)TIME;
    *t=time_set;
}

//建议cmd格式 LEDR n ON 
void open_LEDR(int n)//亮第n个灯
{
    if(n>6)
    {
        return;
    }
    char* LEDR=(char*)(LEDR_START+n);
    *LEDR=(char)1;
}

//LEDR n OFF
void close_LEDR(int n)//灭第n个灯
{
    if(n>6)
    {
        return;
    }
    char* LEDR=(char*)(LEDR_START+n);
    *LEDR=(char)0;
}

//SEG n num
void set_SEG(int n,int num)//第n个SEG显示num
{
    if(n>5)
    {
        return;
    }
    char* SEG=(char*)(SEG_START+n);
    *SEG=(char)num;
}
