#include "util.h"

int num_char(const char * const str, const char c)
{
	char *sp = calloc(strlen(str) + 1, sizeof(char));
	strncpy(sp, str, strlen(str) + 1);
	int num = 0;
	while ((sp = strchr(sp, c)) != NULL) {
		num++;
		sp++;
	}
	free(sp);
	return num;
}

void *ecalloc(size_t num, size_t sz)
{
	void *tmp = calloc(num, sz);
	if (tmp == NULL) {
		perror("Cannot assign memory");
		exit(EXIT_FAILURE);
	}
	return tmp;
}

