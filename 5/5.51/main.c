#include "main.h"

enum { SIZE = 4096 };

struct pair *parse(char *str);
char *substr(char *src, size_t size);
int pair_size(const char *str);
int word_size(const char *str);
void reverse(char *s, int size);

static char buffer[ SIZE + 1 ];

int main()
{
	printf("EC-Eval(C) input:\n\n");
	fread(buffer, sizeof(int), SIZE, stdin);
	if (!feof(stdin)) {
		perror("Cannot read");
		exit(EXIT_FAILURE);
	}
	struct pair *exp = parse(buffer);
	struct pair *env = setup_environment();

	struct pair *output = eval(exp, env);
	printf("EC-Eval(C) value:\n\n");
	show(output);
	printf("\n\n");
	return EXIT_SUCCESS;
}


struct pair *parse(char *str)
{
	struct llist ll = { NULL, NULL };
	while (*str != '\0') {
		while (isspace(*str))
			str++;

		struct entity *data = NULL;
		size_t size = 0;
		if (*str == '(') {
			size = pair_size(str);
			if (size == 0) {
				printf("%s is not pair", str);
				exit(EXIT_FAILURE);
			}
			struct pair *n = parse(substr(str + 1, size - 2));
			data = cons_ent_pair(n);
		} else {
			size = word_size(str);
			data = cons_ent_atom(cons_atom_sym(substr(str, size)));
		}
		add_pair(data, ll.tail, &ll);
		str += size;
	}
	return ll.head;
}


char *substr(char *src, size_t size)
{
	char *word = (char *)ecalloc(size + 1, sizeof(char));
	strncpy(word, src, size);
	word[size + 1] = '\0';
	return word;
}


int pair_size(const char *str)
{
	int level;
	int i;
	int num_quote = 0;
	for (i = 0, level = 0; (i < SIZE) && (*str != '\0'); i++, str++) {
		if (*str == '"') {
			num_quote++;
		} else if ((num_quote % 2) == 0) {
			if (*str == '(')
				level++;
			else if (*str == ')')
				level--;
		}
		if (0 == level)
			break;
	}

	if (i == 0)
		return i;
	else
		return (i + 1);
}

int word_size(const char *str)
{
	int i = 0;
	while (*str != '\0' && !isspace(*str) && i < SIZE) {
		i++;
		str++;
	}
	if (SIZE < i) {
		perror("Too much word size");
		exit(EXIT_FAILURE);
	}
	return i;
}

