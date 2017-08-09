# OC枚举值到字符串转换


>Swift枚举类型引入了Raw Value的概念，每个枚举case的Raw Value可以是其case name。假设有case king，则king.rawValue = "king"。相比之下OC枚举类型就弱爆了，只能绑定整数；要"反射"自己的case name，必须手动实现反射函数。不过，宏替换可以在一定程度上帮助我们自动实现。
>
>
>本文基于[Easy way to use variables of enum types as string in C?
](https://stackoverflow.com/questions/147267/easy-way-to-use-variables-of-enum-types-as-string-in-c/202511#202511)，是笔者无意间看到的。短短几十行宏代码，看了好大一会儿也不知所以然，不得不重新捧起K&R复习Marcos；晚上回家接着细细研读，不禁感叹：竟然还有这种操作！

---

## A. 使用

这套宏的用法分为两步：

### A.1 在.h文件中定义枚举，声明反射函数

```c
// M1
#define RAP_DIRECTION(XX) \
XX(RAPDirectionEast, ) \
XX(RAPDirectionSouth, ) \
XX(RAPDirectionWest, = 50) \
XX(RAPDirectionNorth, = 100) \

// M2
DECLARE_ENUM(RAPDirection, RAP_DIRECTION)
```
	
- M1生成多个枚举case。枚举case的定义格式为XX(name, assign)，name即case name；assign即对应整数值，格式必须为`= Integer`，不填表示使用默认值；
- M2定义枚举，声明反射函数。反射函数的有两个：
	- 根据case获取case name：NSStringFromRAPDirection(RAPDirection value);
	- 根据case name获取case：RAPDirectionFromNSString(NSString *string);

### A.2 在.m文件中实现反射函数

```c
DEFINE_ENUM(RAPDirection, RAP_DIRECTION)
```
- RAPDirection和RAP_DIRECTION要与.h中的宏对应。RAPDirection是枚举类型名称，RAP_DIRECTION是宏，展开后变成多个枚举case。

### A.3 例子

1. 在任意.h文件中定义枚举，声明反射函数：

	```c
	#import "EnumMarcos.h"

	#define RAP_DIRECTION(XX) \
	XX(RAPDirectionEast, ) \
	XX(RAPDirectionSouth, ) \
	XX(RAPDirectionWest, = 50) \
	XX(RAPDirectionNorth, = 100) \

	DECLARE_ENUM(RAPDirection, RAP_DIRECTION)
	```

2. 在相应的.m文件中实现反射函数：

	```c
	DEFINE_ENUM(RAPDirection, RAP_DIRECTION)
	```

3. 尝试使用：

	```c
    NSString *str = NSStringFromRAPDirection(RAPDirectionEast);
    NSLog(@"RAPDirectionEast has case name: %@", str);
    
    
    RAPDirection dir = RAPDirectionFromNSString(@"RAPDirectionNorth");
    NSLog(@"RAPDirectionNorth has case value: %zd", dir);
	```

输出结果：

```
RAPDirectionEast has case name: RAPDirectionEast
RAPDirectionNorth has case value: 100
```



## B. 实现

### B.1 DECLARE_ENUM(EnumType, ENUM_DEF)

```c

#define DECLARE_ENUM(EnumType, ENUM_DEF) \
typedef NS_ENUM(NSInteger, EnumType) { \
ENUM_DEF(ENUM_VALUE) \
}; \
NSString *NSStringFrom##EnumType(EnumType value); \
EnumType EnumType##FromNSString(NSString *string); \
```

- 第1行：EnumType是枚举类型；ENUM_DEF是替换宏，格式为XX(name, assign)，同同ENUM_VALUE，ENUM_CASE以及ENUM_STRCMP的形式一致；
- 第2行：Apple式的枚举定义风格；
- 第3行：ENUM_DEF(ENUM_VALUE)展开为多个ENUM_VALUE，进一步展开为多个`name assign,`的形式；（ENUM_VALUE的分析在下面）
- 第5，6行：声明反射函数。##的用法不再赘述；

#### B.1.1 ENUM_VALUE(name, assign)

```c
#define ENUM_VALUE(name, assign) name assign,
```

- 定义一个枚举case：name即case name；assign即整数值，格式为`= Interfer`。
- 例如：ENUM_VALUE(King, = 13)；展开后：`King = 13,`，注意最后的逗号不可获取。


### B.2 DEFINE_ENUM(EnumType, ENUM_DEF)

```c
#define DEFINE_ENUM(EnumType, ENUM_DEF) \
NSString *NSStringFrom##EnumType(EnumType value) \
{ \
switch(value) \
{ \
ENUM_DEF(ENUM_CASE) \
default: return @""; \
} \
} \
EnumType EnumType##FromNSString(NSString *string) \
{ \
ENUM_DEF(ENUM_STRCMP) \
return (EnumType)0; \
}
```

- 第7行：如果找不到对应case name，返回@"";
- 第8行：如果找不到对应case，则返回0；
- 其他同DECLARE_ENUM(EnumType, ENUM_DEF)；

#### B.2.1 ENUM_CASE(name, assign)

```c
#define ENUM_CASE(name, assign) case name: return @#name;
```

- 展开后是一个switch语句的case，返回一个字符串；#name表示"name"，所以@#name表示@"name"，OC字符串。
- 例如：ENUM_CASE(King, 13)，展开后：case King: return @"King";

#### B.2.1 ENUM_STRCMP(name, assign)

```c
#define ENUM_STRCMP(name, assign) if ([string isEqualToString:@#name]) return name;
```

- 展开后通过比较字符串，返回相应枚举case；
- string是函数`EnumType##FromNSString`的参数，展开时自动填入；
- 例如：ENUM_STRCMP(King, 13)，展开后：if ([string isEqualToString:@"King"]) return King;


## 参考资料

1. [示例代码](https://github.com/Yannmm/OC-Enum-String-Convertible-Example)
2. [Easy way to use variables of enum types as string in C?
](https://stackoverflow.com/questions/147267/easy-way-to-use-variables-of-enum-types-as-string-in-c/202511#202511)

