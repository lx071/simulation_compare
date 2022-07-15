//example.c
#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
 
int add(int i, int j)
{
return i + j;
}

#ifdef __cplusplus
}  // TVM_EXTERN_C
#endif