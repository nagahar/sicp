#include "eval.h"

int is_application(const struct pair * const exp);
int is_number(const struct pair * const exp);
int is_self_evaluating(const struct pair * const exp);
int is_string(const struct pair * const exp);
int is_variable(const struct pair * const exp);
//int is_quoted(const struct pair * const exp);
//int is_assignment(const struct pair * const exp);
//int is_definition(const struct pair * const exp);
//int is_if(const struct pair * const exp);
//int is_lambda(const struct pair * const exp);
//int is_begin(const struct pair * const exp);
struct pair *apply(struct pair *procedure, struct pair *arguments);
struct pair *apply_primitive(struct pair *procedure, struct pair *arguments);
struct pair* each_eval(struct pair *exp, struct pair *env);
struct pair *lookup_variable_values(const struct pair * const var,
		struct pair *env);
struct pair *scan(const struct pair * const var,
		struct pair *vars, struct pair * vals, struct pair *env);
struct pair *env_loop(const struct pair * const var, struct pair *env);


struct pair *eval(struct pair *exp, struct pair *env)
{
	struct pair *retval = NULL;
	if (is_self_evaluating(exp)) {
		retval = dup_pair(exp);
	} else if (is_variable(exp)) {
		retval = lookup_variable_values(exp, env);
	} else if (is_application(exp)) {
		struct pair *list = each_eval(exp, env);
		retval = apply(list, list->cdr);
		free_pair(list);
	} else {
		perror("Unknown expression type");
		exit(EXIT_FAILURE);
	}
	return retval;
}


int is_self_evaluating(const struct pair * const exp)
{
	if (is_number(exp))
		return TRUE;
	else if(is_string(exp))
		return TRUE;
	else
		return FALSE;
}


int is_application(const struct pair * const exp)
{
	return is_pair(exp);
}


int is_variable(const struct pair * const exp)
{
	if (is_atom(exp) &&
			!is_number(exp) &&
			!is_string(exp))
		return TRUE;
	else
		return FALSE;
}


struct pair *apply(struct pair *procedure, struct pair *arguments)
{
	struct pair *retval = NULL;
	if (is_primitive(procedure)) {
		fprintf(stderr, "primitive!\n");
		retval = apply_primitive(procedure, arguments);
		if (retval->car->type == TYPE_PAIR)
			show(retval);
		else if (retval->car->type == TYPE_LITERAL)
			printf("retval:%s\n", retval->car->as.symbol);
		else if (retval->car->type == TYPE_PROCEDURE)
			printf("proc:%p\n", retval->car->as.proc);
	} else if (is_compound(procedure)) {
		printf("compound!\n");
	} else {
		perror("Unknown procedure type");
		exit(EXIT_FAILURE);
	}

	return retval;
}


struct pair *apply_primitive(struct pair *procedure, struct pair *arguments)
{
	return procedure->car->as.proc->body(arguments);
}

int is_number(const struct pair * const exp)
{
	if (!is_atom(exp))
		return FALSE;

	char *p = exp->car->as.symbol;
	int num = 0;

	while (isdigit(*p) > 0) {
		p++;
		num++;
	}

	if (num > 0)
		return TRUE;
	else
		return FALSE;

}

int is_string(const struct pair * const exp)
{
	if (!is_atom(exp))
		return FALSE;

	char *p = exp->car->as.symbol;
	int num = 0;

	if (*p != '"')
		return FALSE;

	while (*p != '\0') {
		p++;
		if (*p == '"')
			num++;
	}

	if (num > 0 && (num % 2) == 0)
		return TRUE;
	else
		return FALSE;
}


struct pair* each_eval(struct pair *exp, struct pair *env)
{
	struct pair *n = exp->car->as.box;
	struct llist ll = { NULL, NULL };
	while (n != NULL) {
		puts("Each eval ************");
		struct pair *new = eval(n, env);
		add_pair(new, ll.tail, &ll);
		puts("NEXT");
		n = n->cdr;
	}
	show(ll.head);
	puts("@@@@@@@@@@@@@");
	return ll.head;
}


struct pair *scan(const struct pair * const var,
		struct pair *vars, struct pair * vals, struct pair *env)
{
	struct pair *varn = vars->car->as.box;
	struct pair *valn = vals->car->as.box;
	struct pair *retval = NULL;
	while (varn != NULL) {
		if (is_atom(varn) &&
				!strcmp(varn->car->as.symbol, var->car->as.symbol)) {
			retval = dup_pair(valn);
			return retval;
		}
		varn = varn->cdr;
		valn = valn->cdr;
	}
	fprintf(stderr, "###########\n");

	retval = env_loop(var, env->cdr);
	return retval;
}


struct pair *env_loop(const struct pair * const var, struct pair *env)
{
	if (env == NULL) {
		perror("Unbound variable");
		exit(EXIT_FAILURE);
	}
	fprintf(stderr, "env_loop in\n");
	struct pair *n = env->car->as.box;
	struct pair vars = { n->car, NULL };
	struct pair vals = { n->cdr->car, NULL };
	struct pair *retval = scan(var, &vars, &vals, env);
	return retval;
}


struct pair *lookup_variable_values(const struct pair * const var,
		struct pair *env)
{
	if (!is_atom(var))
		return NULL;
	return env_loop(var, env);
}


