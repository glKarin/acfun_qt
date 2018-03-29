#ifndef _KARIN_NETLIZARD_GAME_PARSER_STRING_H
#define _KARIN_NETLIZARD_GAME_PARSER_STRING_H

#ifdef __cplusplus
extern "C"
{
#include <stddef.h>
#endif

int Converter_DecodeIntStringToString(const char *arr, const char *split, char **r);
int Converter_DecodeIntArrayToString(const int *arr, size_t length, char **r);

int Converter_EncodeStringToIntArray(const char *text, int **array, size_t *length);
int Converter_EncodeStringToIntString(const char *text, const char *split, char **r);

#ifdef __cplusplus
}
#endif

#endif
