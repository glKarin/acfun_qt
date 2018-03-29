#include "netlizard_string_converter.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define NEW(T) (T*)malloc(sizeof(T))
#define NEW_II(T, size) (T*)calloc(size, sizeof(T))
#define ZERO(ptr, T) memset(ptr, 0, sizeof(T))
#define ZERO_II(ptr, T, size) memset(ptr, 0, sizeof(T) * size)

typedef long long harmattan_long_t;

static char * strjoin(char *arr[], size_t length, const char *split)
{
	if(!arr)
		return NULL;
	const char *Sp = split ? split : ",";
	const size_t Sp_L = strlen(Sp);
	size_t len = 0;
	size_t i;
	for(i = 0; i < length; i++)
		len += strlen(arr[i]);
	len += strlen(Sp) * (length - 1);
	len += 1;
	char *str = NEW_II(char, len);
	char *p = str;

	for(i = 0; i < length; i++)
	{
		size_t l = strlen(arr[i]);
		strncat(p, arr[i], l);
		p += l;
		if(i < length - 1)
		{
			strncat(p, Sp, Sp_L);
			p += Sp_L;
		}
	}

	return str;
}

// instead of itoa
static char * itostr10(int i)
{
	int o = 1;
	int num = i;
	if(i < 0)
	{
		o = 0;
		num = -num;
	}
	int size = 1;
	int base = 10;
	for(; num / base; base *= 10)
		size++;
	if(o == 0)
		size += 1;
	char *str = NEW_II(char, size + 1);
	ZERO(str, size + 1);
	sprintf(str, "%d", i);
	return str;
}

// pointer returned is in heap, need to call free() manually.
// parameter is int array and length.
static char * nlParseString(const int array[], size_t length)
{
	if(!array)
		return NULL;
	int len = 0;
	char *str = NEW(char);
	ZERO(str, char);
	size_t i2;
	for(i2 = 0; i2 < length; i2++)
	{
		harmattan_long_t l1;
		char ch;
		char *tmp = NULL;
		if ((l1 = array[i2]) < 0L) {
			l1 += 4294967296LL;
		}
		ch = (char)(int)((l1 & 0xFF000000) >> 24);
		tmp = NEW_II(char, len + 1 + 1);
		memcpy(tmp, str, len * sizeof(char));
		tmp[len] = ch;
		free(str);
		str = tmp;
		len++;
		str[len] = '\0';
		int i1;
		if ((i1 = (char)(int)((l1 & 0xFF0000) >> 16)) == 0) {
			break;
		}
		ch = (char)i1;
		tmp = NEW_II(char, len + 1 + 1);
		memcpy(tmp, str, len * sizeof(char));
		tmp[len] = ch;
		free(str);
		str = tmp;
		len++;
		str[len] = '\0';
		if ((i1 = (char)(int)((l1 & 0xFF00) >> 8)) == 0) {
			break;
		}
		ch = (char)i1;
		tmp = NEW_II(char, len + 1 + 1);
		memcpy(tmp, str, len * sizeof(char));
		tmp[len] = ch;
		free(str);
		str = tmp;
		len++;
		str[len] = '\0';
		if ((i1 = (char)(int)(l1 & 0xFF)) == 0) {
			break;
		}
		ch = (char)i1;
		tmp = NEW_II(char, len + 1 + 1);
		memcpy(tmp, str, len * sizeof(char));
		tmp[len] = ch;
		free(str);
		str = tmp;
		len++;
		str[len] = '\0';
		//printf("%s\n", str);
	}
	return str;
}

// pointer returned is in heap, need to call free() manually.
// parameter is C-style string
// length is length of returned.
static int * nlEncodeStringC(const char *str, size_t *length)
{
	if(!str)
		return NULL;
	const char *ptr = str;
	int len = 0;
	int *data = NULL;
	while(*ptr)
	{
		int j;
		char arr[4] = {0, 0, 0, 0};
		for(j = 0; j < 4; j++)
		{
			if(*ptr)
				arr[4 - j - 1] = *ptr;
			else
				break;
			ptr ++;
		}
		if(!data)
		{
			data = NEW(int);
			ZERO(data, int);
			int *iptr = (int *)arr;
			if(*iptr < 0)
				*iptr += 4294967296LL;
			*data = *iptr;
		}
		else
		{
			int *tmp = NEW_II(int, len + 1);
			memcpy(tmp, data, sizeof(int) * len);
			int *iptr = (int *)arr;
			if(*iptr < 0)
				*iptr += 4294967296LL;
			tmp[len] = *iptr;
			free(data);
			data = tmp;
		}
		len++;
	}

	if(length)
		*length = len;
	return data;
}

// return 1 for successful, 0 is fail
// "111111111,22222222,33333333" -> "abcd"
int Converter_DecodeIntStringToString(const char *arr, const char *split, char **r)
{
	if(!arr || !r)
		return 0;
	const char *Sp = split ? split : ",";
	char *cp = strdup(arr);
	const char *p = cp;
	size_t len = 0;
	while((p = strchr(p, Sp[0])) != NULL)
	{
		p++;
		len++;
	}
	len += 1;
	//printfi(len);
	int *dec = NEW_II(int, len);
	char *s = strtok(cp, Sp);
	int i = 0;
	do
	{
		dec[i] = atoi(s);
		i++;
	}while((s = strtok(NULL, Sp)) != NULL);

	char *str = nlParseString(dec, len);

	free(dec);
	free(cp);

	if(str)
	{
		*r = str;
		return 1;
	}
	return 0;
}

// return 1 for successful, 0 is fail
// [111111111, 22222222, 33333333] -> "abcd"
int Converter_DecodeIntArrayToString(const int arr[], size_t length, char **r)
{
	if(!arr || !r)
		return 0;

	char *str = nlParseString(arr, length);
	if(str)
	{
		*r = str;
		return 1;
	}
	return 0;
}

// return 1 for successful, 0 is fail
// "abcd" -> [111111111, 22222222, 33333333]
int Converter_EncodeStringToIntArray(const char *text, int **array, size_t *length)
{
	if(!text || !array)
		return 0;
	size_t len = 0;
	int *arr = nlEncodeStringC(text, &len);
	if(!arr)
		return 0;
	//printf("Text -> %s\n", text);
	if(length)
		*length = len;
	*array = arr;
	return 1;
}

// return 1 for successful, 0 is fail
// "abcd" -> "111111111,22222222,33333333"
int Converter_EncodeStringToIntString(const char *text, const char *split, char **r)
{
	if(!text || !r)
		return 0;
	size_t len = 0;
	int *arr = nlEncodeStringC(text, &len);
	if(!arr)
		return 0;
	//printf("Text -> %s\n", text);
	char **a = NEW_II(char *, len);
	size_t i;
	for(i = 0; i < len; i++)
	{
		a[i] = itostr10(arr[i]);
	}
	*r = strjoin(a, len, split);
	free(a);
	return 1;
}

