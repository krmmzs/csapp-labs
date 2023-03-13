# datalab

## Prerequisites

[lab code](http://csapp.cs.cmu.edu/3e/labs.html)

我使用的ubuntu

第一次执行make会报错，需要装一些库

```bash
sudo apt-get install gcc-multilib
```

### Test

测试函数
```bash
./btest
```

检查代码规范
```bash
./dlc bits.c
```

这时候再make只有文件本身的errors and warnings

## Main

主要文件是`datalab-handout/bits.c`，里面有一些函数的实现，需要自己实现。

一共需要完成13个函数，每个函数都是一个题目

## Solutions

### bitXor

```c
//1
/* 
 * bitXor - x^y using only ~ and & 
 *   Example: bitXor(4, 5) = 1
 *   Legal ops: ~ &
 *   Max ops: 14
 *   Rating: 1
 */
```

感觉是比较巧妙的题目，尝试在脑中dfs
先列出异或真值表

| x | y | x^y |
|---|---|-----|
| 0 | 0 | 0   |
| 0 | 1 | 1   |
| 1 | 0 | 1   |
| 1 | 1 | 0   |

其中为了和&产生联系, 取出结果为1的两行，让0取反 & 1同样得到1

```c
~x & y, x & ~y
```

两者取|即可得到结果，|的意思是两种情况满足其一即可

```c
~x & y | x & ~y
```

但是本题是不能使用|的, 用De Morgan's Law进行转化即可

<img src="/images/csapp-datalab-01.png" alt="csapp-datalab-01.png" style="zoom:50%;" />

<img src="/images/csapp-datalab-02.png" alt="csapp-datalab-02.png" style="zoom:50%;" />

```c
int bitXor(int x, int y) {
    return ~(x & y) & (~(~x & ~y));
}
```

### tmin

> return minimum two's complement integer 

最高位为1，其余位为0

直接返回0x80000000是违反最大只能使用255的规定的

> Integer constants 0 through 255 (0xFF), inclusive. You are
not allowed to use big constants such as 0xffffffff.

```c
int tmin(void) {
    return 1 << 31;
}
```

### isTmax

> returns 1 if x is the maximum, two's complement number,

当最高位为0, 其余位为1时，即为最大值

本质就是来判断x的二进制表示是否为期望的二进制表示

等价变化的game

> Legal ops: ! ~ & ^ | +

不能使用位移。。。

尝试做一些等价变化的dfs

让Tmax + 1, 得到最高位为1, 其余为0的数

两者取反即可判断是否相等了, 对应的操作就是两者按位异或即可: (x + 1) ^ (~x)

```c
int isTmax(int x) {
    return !((x + 1) ^ (~x));
}
```

但是报错了
```bash
Score	Rating	Errors	Function
ERROR: Test isTmax(-1[0xffffffff]) failed...
...Gives 1[0x1]. Should be 0[0x0]
Total points: 0/1
```

没有考虑到-1的情况

$!!$ 这里是一个规格化的操作

因为!会让非0的数的二进制表示为000000, 再!就会变成000001

而0的二进制表示为000000, 再!就会变成000001, 再!就会变成000000

这个书上并没有说，而且也没有看到有人详细讲了这个。。。

补上即可

```c
int isTmax(int x) {
    int tmin = x + 1;
    int equal = tmin ^ (~x);

    return (!!tmin) & (!equal);
}
```

第二种解法是利用，自己与自己异或可以得到0的性质
同样需要考虑-1的情况

```c
int isTmax(int x) {
    return !(~(x + 1) ^ x) & !!(x + 1);
```

### allOddBits

> return 1 if all odd-numbered bits in word set to 1

所有奇数位为1就返回1, 那么偶数位就可以变化，来构造出对判断有帮助的数

可以设置为全0

缩小规模为4位

&拥有一种遮盖性(mask)，当一个为0就可以把另一个遮盖掉

1010为mask序列, 让1010与num进行&操作，即可得到num的奇数位就可以达到遮蔽偶数位的效果

所以回到之前，让x与mask序列进行&操作，即可得到形如x0x0x0...的序列

异或的其中一个作用就是判不同, 让x0x0x0...与101010...异或，如果为0，说明所有奇数位都为1，否则就不是

那么问题就变成了，如何构造出mask序列

其中一种方法是让题目能够表示的最大的mask序列进行位移和|操作

0xAA = mask_8 = 10101010, 左移8位, 1010101000000000, 两者再|操作, 1010101010101010(mask_16)

mask_16 = 1010101010101010, 左移16位, 10101010101010100000000000000000, 两者再|操作, 10101010101010101010101010101010(mask_32)

构造成功

```c
int allOddBits(int x) {
    int mask = 0xAA;
    mask = (mask << 8) | mask;
    mask = (mask << 16) | mask;
    return !((mask & x) ^ mask);
}
```

### negative

> return -x 

非常常用的一个操作

```c
int negative(int x) {
    return ~x + 1;
}
```

原因：
x与自己取反以后相加是全1，再加1就是全0

也就是 x + ~x + 1 = 0，得出-x = ~x + 1

### isAsciiDigit

> return 1 if 0x30 <= x <= 0x39 (ASCII codes for characters '0' to '9')

0x30 = 00110000, 0x39 = 00111001

不等式比大小常用的方法是做差

做差不能直接使用可以用-x = ~x + 1来等价代换

sign_1 = x - 0x30 -> sign_1 = x + ~0x30 + 1
sign_2 = 0x39 - x -> sign_2 = 0x39 + ~x + 1

再根据最高位的符号位来判断正负

!(sign_1 >> 31) & !(sign_2 >> 31)

### conditional

> same as x ? y : z 

用位运算来实现c中的三目运算符

第一个需要解决的是如何判断x

```c
x != 0, y
x == 0, z
```

判断0可以用!!来替换, if x != 0, !!x == 1, if x == 0, !!x == 0(这在前面其实用到了)

用一个变量来存: condition = !!x

如何需要思考如何返回y或者z， 两者是互斥的

|运算能尽可能得实现互斥(当其中一个为全0的时候)

y | z

所以需要一个因子能在两种不同的情况下让其中一个为0

容易想到的是全0和全1

用condition来构造全0和全1

flag = ~condition + 1, 即可得到全0和全1

flag 和 ~flag 就实现了互斥对

最终得到 flag & y | ~flag & z

```c
int conditional(int x, int y, int z) {
    int condition = !!x;
    int flag = ~condition + 1;
    return (flag & y) | (~flag & z);
}
```

### isLessOrEqual

> if x <= y  then return 1, else return 0 

比大小做差

y - x >= 0 -> y + ~x + 1 >= 0

sign = (y + ~x + 1) >> 31

if (sign >> 31) == 0 y - x >= 0, return 1

if (sign >> 31) == -1 y - x < 0, return 0

return !(sign >> 31)

但是 y - x 可能会溢出

1. y < 0, x > 0, y - x < 0, 但是如果溢出就会变成正数，所以需要特殊判断y < 0 && x > 0
2. y > 0, x < 0, y - x > 0, 但是如果溢出就会变成负数，所以需要特殊判断y > 0 && x < 0

1. x > 0 => s_x = x >> 31, s_x == 0, y < 0 => s_y = y >> 31, s_y == -1, 可得 of_1 = (!s_x) & s_y

所以需要满足 !(sign>>31) 但是不满足 of_1, 得到 return (!of_1) & (!(sign>>31))

2. x < 0 => s_x = x >> 31, s_x == -1, y > 0 => s_y = y >> 31, s_y == 0, 可得 of_2 = s_x & (!s_y)

这里直接就return 1, 所以只要满足x < 0, y > 0就可以了

return of_2


```c
return of_2 | (!(of_1)) & (!(sign>>31));
```

### logicalNeg

> implement the ! operator, using all of the legal operators except ! 

也就是实现只有当x == 0的时候，!x才为1

用-x可以得到x的相反数，仍然为0

也就是0很特殊，相反数以后，最高位都是0

(x | negate_x) >> 31 = 0

还需要思考不等于0的情况

如果不等于0， 相反数其中最高位其中一个为1， (x | negate_x) >> 31 = -1

将条件摆在一起
- if x == 0 return 1 (x | negate_x) >> 31 == 0
- if x != 0 return 0 (x | negate_x) >> 31 == -1

```c
return ((x | ~x + 1) >> 31) + 1;
```

### howManyBits

> return the minimum number of bits required to represent x in two's complement

最直观的方法从找到高位的1， 然后加上一个符号位

查找的问题，概率论加持的最快方法是二分查找

分割区间的性质是是否含有1

没有1就是全0, 判断全0可以用!!

flag = !!(x >> 16), if flag = 1, bit_num > 16, if flag = 0, bit_num < 16

为了能够搜索其中一个区间，我们需要一个位移操作

x = x >> cnt_16

构造cnt_16 = flag << 4, if falg = 1, cnt_16 = 16, if flag = 0, cnt_16 = 0

接下来8, 4, 2, 1同理

最后求和所有的标记加上符号位即可，但是这样的方法并不能满足负数的情况

看几个例子：

2 bit: -2 ~ 1
3 bit: -4 ~ 3
32 bit: -2147483648(2^31) ~ 2147483647(2^31 - 1)

那么可以把负数转化为正数处理，因为不是对称的，所以进行-1即可

```c
int howManyBits(int x) {
    int flag = x >> 31;
    int cnt_16, cnt_8, cnt_4, cnt_2, cnt_1, cnt_0;
    int sign = x >> 31;
    x = (sign & (~x)) | (~sign & x); // 根据符号位来判断x的正负，从而决定是否取反(不具有普遍性)
    flag = !!(x >> 16);
    cnt_16 = flag << 4;
    x = x >> cnt_16;

    flag = !!(x >> 8);
    cnt_8 = flag << 3;
    x = x >> cnt_8;

    flag = !!(x >> 4);
    cnt_4 = flag << 2;
    x = x >> cnt_4;

    flag = !!(x >> 2);
    cnt_2 = flag << 1;
    x = x >> cnt_2;

    flag = !!(x >> 1);
    cnt_1 = flag;
    x = x >> cnt_1;

    cnt_0 = x;
    return cnt_16 + cnt_8 + cnt_4 + cnt_2 + cnt_1 + cnt_0 + 1;
}
```

---

接下來是float的主场了

float限制非常少

> For the problems that require you to implement floating-point operations,
the coding rules are less strict.  You are allowed to use looping and
conditional control.  You are allowed to use both ints and unsigneds.
You can use arbitrary integer and unsigned constants. You can use any arithmetic,
logical, or comparison operations on int or unsigned data.

---

### floatScale2

> Return bit-level equivalent of expression 2*f for floating point arguments f.

这里操作是做浮点数，但是传入和传出都是`unsigned int`

`unsigned int` ?-> `float`

两者都是32位的，所以要分别获取 `unsigned int` 1位的`s`, 8位的`exp`, 23位的`frac`

最高位好获得，直接uf & 0x80000000

exp = (0x7F800000 & uf) >> 23, frac = uf & 0x7FFFFF 

接下里处理浮点数，浮点数有四种规则，需要根据`exp`进行分类讨论

- if (exp == 0xFF) && (frac != 0) => NaN

按照规则返回 uf.

- if (exp == 0xFF) && (frac == 0)

按照规则返回 uf.

- if (exp == 0) && (frac == 0) return uf
- if (exp == 0) && (frac != 0) For frac * 2, frac << 1 return s | (exp << 23) | (frac << 1)

- if (exp != 0) && (exp != 255), return s | ((exp + 1) << 23) | frac

这里因为要乘2所以让exp + 1, 但是这样会偏移导致当exp位254的时候产生exp+1=255, 表示为无穷

return s | (0xFF << 23)

```c
unsigned floatScale2(unsigned uf) {
    unsigned s = uf & 0x80000000;
    unsigned exp = (uf & 0x7F800000) >> 23;
    unsigned frac = uf & 0x007FFFFF;
    unsigned ret = 0;
    unsigned inf = s | (0xFF << 23);

    if (exp == 0xFF) {
        return uf;
    }
    if (exp == 0) {
        if (frac == 0) {
            return uf;
        }
        frac = frac << 1;
        ret = s | (exp << 23) | frac;
        return ret;
    }
    exp = exp + 1;
    if (exp == 0xFF) {
        return inf;
    }
    ret = s | (exp << 23) | frac;
    return ret;
}
```

### floatFloat2Int

把一个单精度浮点数强制转化成整形数

由于单精度浮点数的范围比int大得多, 且int的范围是-2^31 ~ 2^31 - 1, 所以需要进行分类讨论

if E < 0, 此时浮点数本身表示的并不是整数, return 0;

V = (-1)^s * M * 2^E

- E = 31, s = 1, V = -2^31
- E = 31, s = 0, V = 2^31 - 1

可得到 if E > 31 return 0x80000000

已经处理好了

```c
  -----            --------
      |            |
----------------------------->
      0            31
```

现在处理E: 0～31

- s = uf >> 31
- exp = (uf & 0x7F800000) >> 23

0 <= E <= 31 => 127 <= exp <= 158(E = exp - bias(127))

根据exp的范围可以得到是规格化的数, M = 1 + f

- frac(M) = (uf & 0x7FFFFF) | 0x00800000 （这里比较巧妙）

这里E可以理解为等一下要右移的位数等价于移动小数点，因为要转int,所以会截断

if 0 <= E <= 23, 需要截断, 直接右移23 - E位 <=> return frac >> (23 - E)

if 24 <= E <= 31, 不需要截断, 直接左移E - 23位 <=> return frac << (E - 23)

最后确定一下符号位就好了

```c
int floatFloat2Int(unsigned uf) {
    int sign = uf >> 31;
    int exp = (uf & 0x7F800000) >> 23;
    int frac = (uf & 0x007FFFFF);
    int res = 0;
    int E = exp - 127;
    frac = frac | 0x00800000;

    if (E < 0) {
        return 0;
    }
    if (E > 31) {
        return 0x80000000u;
    }
    if (E > 23) {
        res = frac << (E - 23);
    } else {
        res = frac >> (23 - E);
    }

    if (sign == 1) {
        return ~res + 1;
    } else {
        return res;
    }
}
```

### floatPower2

> Return bit-level equivalent of the expression 2.0^x (2.0 raised to the power x) for any 32-bit integer x.

> If the result is too small to be represented as a denorm, return
If too large, return +INF.

这里给了如果太大或者太小的返回值

来分析一下当x取什么值会导致y太大或者太小

在float那里，非规格化的数有两个用途，一个是表示0, 一个是表示非常接近0的数

当exp = 0000 0000, f = 000...01, 此时就是float最接近0的数字

代入 V = (-1)^s * M * 2^E, 可以得到V_min = 2^-149(E = 1 - bias = -126, M = f = 2^(23))

也就是当x < -149的时候，y < 2^-149, 此时y太小了, return 0

当exp = 1111 1111(此时是规格化的), f = 000...00， E = exp - bias = 127, M = 1 + f = 2^(23), 此时V_max = 2^127

也就是当x > 127的时候，y > 2^127, 此时y太大了, return +INF(由0xFF << 23得到)

此时只剩下中间的区间了

其中，有些值很靠近0, 需要用非规格化的数来表示，其余的用规格化的数来表示

需要得到分界点t

这里感觉考察的是非规格和规格之间平滑过度的点

规格化最小值：当exp = 1, E = exp - bias = -126, V_min = 2^-126

非规格化最大值：当exp = 0, E = exp - bias = -127, V_max = 2^-149

让t为127

Normalized: -149 <= x <= -127, Denormalized: -126 <= x <= 127

此时来构造非规格化的数

exp = 0000 0000, frac = 0x1 << (x + 149)

来构造规格化的数

if x == -126, E = -126, E = exp - 127, exp = 1
if x == -125, E = -125, E = exp - 127, exp = 2
    ...
if x == 127, E = 127, E = exp - 127, exp = 254

-126 <= x <= 127, exp = x + 127, return exp << 23

```c
unsigned floatPower2(int x) {
    int exp;
    unsigned res;

    if (x < -149) {
        return 0;
    }

    if (x > 127) {
        return (0xFF << 23);
    }

    if (x < -126) {
        return 0x1 << (x + 149);
    }

    exp = x + 127;
    res = exp << 23;
    return res;
}```
