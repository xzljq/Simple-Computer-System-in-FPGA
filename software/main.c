#define NULL         ((void*)0)

#define TRUE         1
#define FALSE        0

#define ERROR_CMD   0
#define ERROR_PARA  1

#define N 80 //len of one row
typedef		 int   uint32_t;
typedef          int   int32_t;


#include "sys.h"


char cmd[100];

int main();

typedef struct Node {
	int number;
	int type;//0为操作数, 1为运算符
	char ch;
}Node;

//stack:
Node nodeStack[N];
char charStack[N];

int nodetop = 0;
Node nodeTop();
void nodePop();
void nodeClear();
void nodePush(Node);
int nodeEmpty();
void nodeClear();

int chartop = 0;
char charTop();
void charPop();
void charClear();
void charPush(char);
int charEmpty();

int stringChrR (const char *string, char token, int *size);
int stringChr (const char *string, char token, int *size);
int stringCpy(char* src, char* dst, int size);
void strInsert(char* str, int pos, char ch);
int stringlen (const char *string);
int stringcmp (const char *srcString, const char *destString, int size); 
void stringAppend(char* str, char ch);

Node Add(Node, Node);
Node Sub(Node, Node);
Node Mul(Node, Node);
Node Div(Node, Node, int* );
Node Mod(Node);//平方和开根号
Node Pow(Node, int);//指数为正时,用乘法的循环；为负时用除法的循环
Node Exp(Node, Node);

int CinJudge(char* str);//判断输入是否合法,非法时将str错误处高亮,并返回NULL
// void PrintNode(Node);
Node GetNode(char*);
void CutSpace(char*);//✔
void ExpressChange(Node*, char*, int*);
Node ExpressCal(char*, int* );//✔
int JudgeOp(char);
int icp(char);//✔
int isp(char);//✔
void Init(char*);//✔字符串预处理,如arg、cjg、|| 

Node CalNode(Node, Node, char,int*);//✔
void PrintHello();//✔
// char* Str[N];
int abs(int n);
int pow(int, int);


void error(uint32_t code);

char hello[] = "hello, world!";
char usr[]="User>>";
// char error_cmd[] = 
void putInt(int a);

int stringlen (const char *string);
int stringcmp (const char *srcString, const char *destString, int size); 
void seTtime();
void calculator();

void printHello();
void printTime(uint32_t time);
void fib_n(uint32_t n);
void printHelp();




//setup the entry point
void entry()
{
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

int main()
{
    vga_init();
  
    putstr(hello);
    putch('\n');
    open_LEDR(1);
    open_LEDR(3);
    open_LEDR(5);

    set_SEG(0,0);
    set_SEG(1,1);
    set_SEG(2,2);
    set_SEG(3,3);
    set_SEG(4,4);
    set_SEG(5,5);

    while(1){
        putstr(usr);
        char instr[N];
        // putstr(">>>");
        getstr(instr);
        if(stringcmp(instr, "help", stringlen("help"))==0){
            printHelp();
        }
        else if(stringcmp(instr, "hello", stringlen("hello"))==0)
            printHello();
        else if(stringcmp(instr, "time", stringlen("time"))==0){
            int time = gettime();
            printTime(time);
        }
        else if(stringcmp(instr, "set time", stringlen("set time"))==0){
            seTtime();
        }
        else if(stringcmp(instr, "fib", stringlen("fib"))==0){
            int n=0;
            //get n
            int len = stringlen(instr);
            for(int i = 4; instr[i]!='\0'&&instr[i]!=' '; i++){
                n = 10*n + (int)(instr[i] -'0');
            }
            if(n < 0 || n > 46 || len < 4){
                error(ERROR_PARA);
            }
            else
                fib_n(n);
        }
        else if(stringcmp(instr, "cal", stringlen("cal"))==0){
            calculator();
        }
		else if(stringcmp(instr, "open led", stringlen("open led"))==0){
            int n=0;
            //get n
            int len = stringlen(instr);
			int index = stringlen("open led") + 1;
			if(instr[index] == '-'){
				error(ERROR_PARA);
				continue;
			}
            for(int i = index; instr[i]!='\0'&&instr[i]!=' '; i++){
                n = 10*n + (int)(instr[i] -'0');
            }
            if(n < 0 || n > 6 || len < 4){
                error(ERROR_PARA);
            }
            else
                open_LEDR(n);			
		}
		else if(stringcmp(instr, "close led", stringlen("close led"))==0){
            int n=0;
            //get n
            int len = stringlen(instr);
			int index = stringlen("close led") + 1;
			if(instr[index] == '-'){
				error(ERROR_PARA);
				continue;
			}
            for(int i = index; instr[i]!='\0'&&instr[i]!=' '; i++){
                n = 10*n + (int)(instr[i] -'0');
            }
            if(n < 0 || n > 6 || len < 4){
                error(ERROR_PARA);
            }
            else
                close_LEDR(n);		
		} 
		else if(stringcmp(instr, "set seg", stringlen("set seg"))==0){
            int n=0, num = 0;
            //get n
            int len = stringlen(instr);
			int i;
            for(i = stringlen("set seg") + 1; instr[i]!='\0'&&instr[i]!=' '; i++){
                n = 10*n + (int)(instr[i] -'0');
            }
			if(instr[i]=='\0'){
				error(ERROR_PARA);
				continue;
			}
			for(i++; instr[i]!='\0'&&instr[i]!=' ';i++){
				num = 10*num + (int)(instr[i] -'0');
			}
            if(n < 0 || n > 5 || num < 0 || num > 15){
                error(ERROR_PARA);
            }
            else
                set_SEG(n, num);
		} 
        else
            error(ERROR_CMD);

    }
    return 0;
}


void printHelp()
{
    putstr("hello\n");
    putstr("fib n\n");
    putstr("time\n");
    putstr("set time\n");
    putstr("cal\n");
	putstr("open/close led n\n");
	putstr("set seg n num\n");
	

    // char hello[] = "hello";
    // char 
}

void seTtime(){
    putstr("please input hour, min, sec with space:");
    char t[N];
    getstr(t);
    int hour, min, sec;
    hour = min = sec = 0;
    //split, and judge whether wrong parameter
    int len = stringlen(t);
    int i;
    for(i=0; t[i]!=' '; i++)
        hour = 10*hour+t[i]-'0';
    for(i++; t[i]!=' '; i++)
        min = 10*min + t[i] - '0';
    for(i++; t[i]!=' ' && i!=len; i++)
        sec = 10*sec+t[i]-'0';
    //judge ERROR:
    if(hour > 24 || sec > 59 || min > 59)
        error(ERROR_PARA);
    else  {
        int num = 0;
        num = (sec+60*min+3600*hour)*10000;
        settime(num);
    }
}

void putInt(int a) {//
	char buf[32+1];//sizeof(int)
    int neg_flag = 0;
    if(a < 0){
		a = -a;
        neg_flag = 1;
	}
	char *p = buf + sizeof(buf) - 1;
	*p = '\0';
	//*(--p) = '\n';    no need '\n'
	do {
		*--p = (char)('0' + a % 10);
	} while (a /= 10);
    if(neg_flag)
        *--p = '-';
	putstr(p);
}
int stringlen (const char *string) {
	int i = 0;
	if (string == NULL)
		return 0;
	while (string[i] != 0)
		i ++;
	return i;
}



void error(uint32_t code){
    if(code == ERROR_CMD){
        char error_cmd[] = "Unknown Command!";
        putstr(error_cmd);
        putch('\n');
    }
    else if(code == ERROR_PARA){
        char error_para[] ="Error Parameter!";
        putstr(error_para);
        putch('\n');
    }
}
void printHello(){
    char hello[] = "Hello World!";
    putstr(hello);
    putch('\n');
}
void printTime(int tim){//precision is 0.0001s
    int t, hour, min, sec;
    t = tim / 10000;
    sec = t % 60;
    t /= 60;
    min = t % 60;
    t /= 60;
    hour = t % 24;

    putInt(hour);
    putch(':');
    putInt(min);
    putch(':');
    putInt(sec);
    putch('\n');
}
void fib_n(int n){
    int a0 = 0, a1 = 1, an;
    int index = 1;
    if(n == 0)
        an = 0;
    else if (n == 1)
        an = 1;
    while ((index < n)){
        an = a0 + a1;
        a0 = a1;
        a1 = an;
        index++;
    }
    putInt(an);
    putch('\n'); 
}













void calculator()
{
	PrintHello();
	char ch[N];
	char Str[N][N];
	int index = 0;
    // putstr(">");
	// cin.getline(ch, N);//getline会自动丢弃换行符
	getstr(ch);
	
	while (ch[0] != 'q') {
		if (ch[0] == '1') {
			putstr( "please input expressions:\n");
			//getchar();//除去换行符
			// cin.getline(Str[index], N);
            getstr(Str[index]);


			if (CinJudge(Str[index])) {
				int div_flag = FALSE;
				Node res = ExpressCal(Str[index], &div_flag);
				// PrintNode(res);
				if(div_flag){
					putstr("div zero error!\n");
				}
				else{
					putstr("outcome:");
					// cout << "debug:" << res.number << endl;//
					putInt(res.number);
					putch('\n');
				}
                
			}
			putstr("functions:");
			index++;
		}

		else if (ch[0] == '2') {
			if (index == 0) {
				putstr("no expressions\n");
			}
			else {
				putstr("please input index:\n");
				int cnt=0;
				char cnt_s[N];
				// cin >> cnt;
				getstr(cnt_s);
				for(int i = 0; cnt_s[i]!=0; i++)
					cnt=10*cnt+cnt_s[i]-'0';
				if (cnt > index || cnt < 1) {
					putstr("index outof range!\n");
				}
				else{
					putstr("index");
					putInt(cnt);
					putstr(" expression:");
					putstr(Str[cnt - 1]);
					putch('\n');
				}
			}
			putstr("functions:");
		}
		else {
			putstr("Error!\n");
			putstr("functions:");
		}

        // putstr(">");
		getstr(ch);
	}

	// cout << "thanks!";

	// return 0;
}

void PrintHello()
{

	// cout << "#####################################################################################" << endl;
	// cout << "###########################Welcome to use the calculator#############################" << endl;
	// cout << "#####################################################################################" << endl;
	putstr("input 1 for cal, 2 to look up the history expressoins, q for quit\n");


}
Node ExpressCal(char* exp, int* div_flag)//计算后缀表达式
{
	//if (!CinJudge(str))
		//return NULL;
	char str[N];
	stringCpy(str, exp, stringlen(exp));
	CutSpace(str);
	Init(str);
	// cout << str << endl;
	int a_size = 0;
	Node a[N];
    ExpressChange(a, str, &a_size);
	//PrintVector(a);
	//cout << endl;
	//########开始计算后缀表达式
	// stack<Node> s;
	//change lib to my own func:
	nodeClear();


	for (int i = 0; i < a_size; i++) {
		if (a[i].type == 0)
			nodePush(a[i]);
		else {//遇到操作符,弹出两个数,计算后压栈
			if (a[i].ch == 'm') {//求模只需要一个操作数
				Node n = nodeTop();
				nodePop();
				n = Mod(n);
				nodePush(n);
			}
			else {//共轭、辐角、求模以外的 计算
				// putstr("node stack size:");
				// putInt(nodeTop);
				Node n2 = nodeTop();
				nodePop();
				Node n1 = nodeTop();
				nodePop();
				Node outcome = CalNode(n1, n2, a[i].ch, div_flag);
				nodePush(outcome);
			}
		}
	}
	//PrintNode(s.top());
	Node res = nodeTop();
	return res;
}
Node CalNode(Node n1, Node n2, char ch, int* div_flag)//双目运算
{
	switch (ch) {
	case'+':return Add(n1, n2);
	case'-':return Sub(n1, n2);
	case'*':return Mul(n1, n2);
	case'/':return Div(n1, n2, div_flag);
	case'^':return Exp(n1, n2);
	//case'a':return Arg(n1, n2);
	//case'm':return Mod(n1, n2);
	}
}
// Node* ExpressChange(char* str, int size)
void ExpressChange(Node* a, char* str, int* size)
{
	// char* str(str0);
	// Node a[N];//存数+操作符
	int a_index = 0;
	// stack<char> s;//存操作符
	charClear();
	// char ch = '#';
	charPush('#');

	
	stringAppend(str, '#');
	int len = stringlen(str);
	//str += "#";// || s.top() != '#'
	// int len = str.size();
	// int l = str.length();
	//cout << str << " " << str.size() << " " << sizeof(str);
	for (int i = 0; str[i] != '#' && i < len - 1; i++) {//注意不是每次i都会递增,因此需要可能i--
		if (JudgeOp(str[i]) && (icp(str[i]) > isp(charTop()))) {//是操作符且优先级高于栈内操作符的优先级
			//###########已通过给复数前面加1来优化##############################
			charPush(str[i]);
		}
		else if (JudgeOp(str[i]) && icp(str[i]) < isp(charTop())) {//操作符优先级低于栈内
			//while (icp(str[i]) < isp(s.top())) {//一直循环直到该运算符可以入栈
			//考虑到其它问题,不循环,只做一次
			Node op;
			op.type = 1;
			op.ch = charTop();
			charPop();
			// a.push_back(op);
			a[a_index]=op;
			a_index++;
			i--;
			//}
			//s.push(str[i]);
		}
		else if (str[i] == '(')
			charPush(str[i]);
		else if (str[i] == ')') {
			while (charTop() != '#' && charTop() != '(') {//一直弹出栈中运算符直至遇到左括号
				Node op;
				op.type = 1;
				op.ch = charTop();
				charPop();
				a[a_index]=op;
				a_index++;
				// a.push_back(op);
			}
			if (charTop() == '(')
				charPop();//'('出栈
		}
		else if(str[i] >= '0' && str[i] <= '9'){//操作数,一直取数直至非数字字符
			int in = 0, j, k, cnt = 0;//cnt计取了多少位
			Node num;//str[i] == '.'
			num.number = 0;
			num.type = 0;//操作数
			j = i;
			for (; j < len && str[j] >= '0' && str[j] <= '9'; j++) {
				//将实部和虚部分开来取
				cnt++;
				in = in * 10 + str[j] - '0';//取整数部分
			}
			k = j;
			
			num.number = in;
			
			if (cnt > 0)
				i += cnt - 1;
			// a.push_back(num);
			a[a_index]=num;
			a_index++;
		}
	}
	while (charTop() != '#') {
		Node op;
		op.ch = charTop();
		op.type = 1;
		// a.push_back(op);
		a[a_index]=op;
		a_index++;
		charPop();
	}
	*size = a_index;
}
int JudgeOp(char ch)
{
	if (ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == 'a' || ch == 'c' || ch == '^' || ch == 'm')
		return TRUE;
	else
		return FALSE;
}
int icp(char ch)
{
	switch (ch) {
	case'#':return 0;
	case'(':return 10;
	case'a':
	case'm':
	case'c':return 8;
	case'^':return 6;
	case'*':
	case'/':return 4;
	case'+':
	case'-':return 2;
	case')':return 1;
	}
}
int isp(char ch)
{
	switch (ch) {
	case'#':return 0;
	case'(':return 1;
	case'^':return 7;
	case'*':
	case'/':return 5;
	case'+':
	case'-':return 3;
	case'a':
	case'm':
	case'c':return 9;
	case')':return 10;
	}
	// return 0;'
}
void Init(char* str)
{
	int len = stringlen(str), flag = 0;//flag标记遇到的是第几个|
	//先替换“||”
	for (int i = 0; i < len; i++) {
		if (str[i] == '|') {
			flag++;
			if (flag % 2 == 1) {
				str[i] = '(';
				strInsert(str, i, 'm');
				i++;//插入'm'后,需要多移动一个字符
				len++;//insert ('m')
			}
			else
				str[i] = ')';
		}
	}
	//添加省略的数字1
	
	//###############还要解决负号与减号的问题
	if (str[0] == '-')//起始是负数
		strInsert(str, 0, '0');
	for (int i = 1; i < stringlen(str) - 1; i++) {
		if (str[i] == '-' && str[i - 1] == '(' && (str[i + 1] >= '0' && str[i + 1] <= '9')) {
			//负号后是数字,前是左括号,则该负号为负数的负号
			strInsert(str, i, '0');

			//############这样插入后就不必解决负数次幂的问题#############################

		}
	}
    // cout <<" after init:";
    // cout << str << endl;
}
int CinJudge(char* str)
{
	
	int len = stringlen(str);

	for (int i = 0; i < len - 2; i++) {//操作数内部不能出现空格
		if (str[i] >= '0' && str[i] <= '9' &&
			(str[i + 1] == ' ' && (str[i + 2] >= '0' && str[i + 2] <= '9' || str[i + 2] == '.')
				|| (str[i + 1] == '.' && str[i + 2] == ' '))){

			putstr("ERROR: space can't appear in the num!\n") ;
			return FALSE;			
		}		
	}
	for (int i = 0; i < len; i++)
		if (str[i] >= 33 && str[i] <= 39 || str[i] >= 58 && str[i] <= 93 || str[i] >= 107 && str[i] <= 113) {
			putstr("ERROR: illeagal character ");
            putch(str[i]);
            putstr("!\n");
            //  "出现非法字符!" << str[i]<< endl;
			return FALSE;
		}

//####### 由于多余的空格会影响其它的非法输入,因此在判断空格没有合法后,删去字符串内部空格####
	CutSpace(str);
	if (str[0] == '+' || str[0] == '*' || str[0] == '/') {//第一个字符不能是乘除加
		putstr( "ERROR: ");
        putch(str[0]);
        putstr("match error!\n" );
		return FALSE;
	}
	if (str[len - 1] == '+' || str[len - 1] == '*' || str[len - 1] == '/' || str[len - 1] == '-') {
		//最后一个字符不能是加减乘除
		// cout << "ERROR: " << str[len - 1] << "match error!" << endl;
        putstr( "ERROR: ");
        putch(str[len - 1]);
        putstr("match error!\n" );
		return FALSE;
	}

	//可以尝试用栈,存储左括号的下表即可

	charClear();
	for (int i = 0; i < len; i++) {//先判断括号匹配
		if (str[i] == '(')
			charPush(i);
		else if (!charEmpty() && str[i] == ')')
			charPop();
		else if(charEmpty() && str[i] == ')')  {
            putstr( "ERROR: match error!\n");
			// cout << "ERROR: " << "match error!" << endl;

			return FALSE;
		}
	}
	while (!charEmpty()) {//左括号剩余,可以只输出第一个
		int i = charTop();
		putstr( "ERROR: match error!\n");
		return FALSE;
	}


	for (int i = 0; i < len - 1; i++) {//左括号后的匹配问题：后面不可以是右括号或加乘除
		if (str[i] == '(' && (str[i + 1] == ')' || str[i + 1] == '+' || str[i + 1] == '/' || str[i + 1] == '*')) {

			// cout << "  ERROR: " << str[i + 1] << "match error!" << endl;
            putstr( "ERROR: ");
            putch(str[i+1]);
            putstr("match error!\n" );
			return FALSE;
		}
	}

	for (int i = 0; i < len - 1; i++) {//右括号后的匹配问题：后面不可以是左括号或操作数
		if (str[i] == ')' && (str[i + 1] == '(' || (str[i + 1] >= '0' && str[i + 1] <= '9'))) {

			// cout << "  ERROR: " << str[i + 1] << "match error!" << endl;
            putstr( "ERROR: ");
            putch(str[i+1]);
            putstr("match error!\n" );
			return FALSE;
		}
	}

	for (int i = 0; i < len - 1; i++) {//操作符后面不可以是操作符或者右括号
		if ((str[i] == '+' || str[i] == '-' || str[i] == '*' || str[i] == '/') &&
	(str[i + 1] == '+' || str[i + 1] == '-' || str[i + 1] == '*' 
		|| str[i + 1] == '/' || str[i + 1] == ')')){

			// cout << "  ERROR: " << str[i] << "match error!" << endl;
            putstr( "ERROR: ");
            putch(str[i]);
            putstr("match error!\n" );
			return FALSE;
			return FALSE;
		}
	}



	for (int i = 0; i < len - 1; i++) {//实数后面不可以是左括号
		if (str[i] >= '0' && str[i] <= '9' && (str[i + 1] == '(' )) {

			// cout << "  ERROR: " << str[i + 1] << "match error!" << endl;
            putstr( "ERROR: ");
            putch(str[i+1]);
            putstr("match error!\n" );
			return FALSE;
			return FALSE;
		}
	}


	return TRUE;
	

	
}

void CutSpace(char* str)
{
	int i = 0;
	int j = 0;
	for (; str[i] != '\0'; i++)
	{
		if (str[i] != ' ')
			str[j++] = str[i];
	}
	for (int k = j; k < stringlen(str); k++)
		str[k] = '\0';
}


Node Add(Node n1, Node n2)
{
	Node res;
	res.type = 0;
	res.number = n1.number + n2.number;
	return res;
}
Node Sub(Node n1, Node n2)//n1 - n2
{
	Node res;
	res.type = 0;
	res.number = n1.number - n2.number;
	return res;
}
Node Mul(Node n1, Node n2)
{
	Node res;
	res.type = 0;
	res.number = n1.number * n2.number;
	return res;
}
Node Div(Node n1, Node n2, int* div_flag)
{
	Node res;
	res.type = 0;
	if(n2.number == 0){
		res.number = 0;
		*div_flag = TRUE;
	}
	else
		res.number = n1.number / n2.number;
	return res;
}
Node Mod(Node n) {//平方和开根号
	Node num;
	num.type = 0;
	num.number = abs(n.number);
	return num;
}


Node Exp(Node n1, Node n2)
{
	Node res;
	int n = n2.number;
	if (n == 0) {
		res.type = 0;
		res.number = 1;
	}
	else if (n < 0)
		res.number = 0;
	else if (n > 0) {
		res.number = pow(n1.number, n2.number);
	}
	return res;
}
int abs(int n){
    if(n < 0){
		// printf("n:%d, -n:%d", n, -n);
        return -n;
	}
    else 
        return n;
}
int pow(int n, int k)
{
    int ans = n;
    for(int i = 1; i < k; i++)
        ans *= n;
    return ans;
}

Node nodeTop()
{
    if(nodetop > 0)
        return nodeStack[nodetop-1];
    else {
        putstr("node stack error!");
    }
}
void nodePop()
{
    nodetop--;
}
void nodeClear()
{
    // while(nodetop>0)
    //     nodePop();
	nodetop = 0;
}
int nodeEmpty()
{
    return nodetop<=0;
}
void nodePush(Node a)
{
    nodeStack[nodetop]=a;
    nodetop++;
}



char charTop()
{
    if(chartop > 0)
        return charStack[chartop-1];
    else {
        putstr("char top error!");
    }
}
void charPop()
{
    chartop--;
}
void charClear()
{
    // while(chartop>0)
    //     charPop();
	chartop = 0;
}
int charEmpty()
{
    return chartop<=0;
}
void charPush(char a)
{
    charStack[chartop]=a;
    chartop++;
}


void stringAppend(char* str, char ch)
{
	int len = stringlen(str);
	str[len]=ch;
	str[len+1] = '\0';
}

//insert ch before str[pos], that is, pos==len is inserting in the last
void strInsert(char* str, int pos, char ch)
{
    int len = stringlen(str);
    if(pos < 0 || pos > len)
        return;
    for(int i = len; i!=pos; i--){
        str[i+1]=str[i];
    }
    str[pos+1]=str[pos];
    str[pos]=ch;

}


//copy the first size of src to dst; 
int stringCpy(char* src, char* dst, int size)
{
    int i;
    for(i = 0; i < size && dst[i]!=0; i++){
        src[i]=dst[i];
    }
    if(i!=size && dst[i]==0)
        return FALSE;
    src[i]='\0';
    return TRUE;
}

/*
**dst is wanted str
**size: compare first size str
*/
int stringcmp (const char *srcString, const char *destString, int size) { // compre first 'size' bytes
	int i = 0;
	if (srcString == NULL || destString == NULL)
		return -1;
	while (i != size) {
		if (srcString[i] != destString[i])
			return -1;
		else if (srcString[i] == 0)
			return 0;
		else
			i ++;
	}
	return 0;
}

/*
* find the first token in string
* set *size as the number of bytes before token
* if not found, set *size as the length of *string
*/
int stringChr (const char *string, char token, int *size) {
	int i = 0;
	if (string == NULL) {
		*size = 0;
		return -1;
	}
	while (string[i] != 0) {
		if (token == string[i]) {
			*size = i;
			return 0;
		}
		else
			i ++;
	}
	*size = i;
	return -1;
}

/*
* find the last token in string
* set *size as the number of bytes before token
* if not found, set *size as the length of *string
*/
int stringChrR (const char *string, char token, int *size) {
	int i = 0;
	if (string == NULL) {
		*size = 0;
		return -1;
	}
	while (string[i] != 0)
		i ++;
	*size = i;
	while (i > -1) {
		if (token == string[i]) {
			*size = i;
			return 0;
		}
		else
			i --;
	}
	return -1;
}


