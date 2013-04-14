#include <math.h>
#include <limits.h>
#include "env.h"

static struct pair *add(struct pair *operands);
static struct pair *divd(struct pair *operands);
static struct pair *eq(struct pair *operands);
static struct pair *mul(struct pair *operands);
static struct pair *not(struct pair *operands);
static struct pair *sub(struct pair *operands);
static struct pair *ge(struct pair *operands);
static struct pair *gt(struct pair *operands);
static struct pair *le(struct pair *operands);
static struct pair *lt(struct pair *operands);
static struct pair *is_null(struct pair *operands);
static struct pair *not(struct pair *operands);
static struct pair *car(struct pair *operands);
static struct pair *cdr(struct pair *operands);
//static struct pair *cons(struct pair *operands);

static struct pair *fold(struct pair *operands, const int init,
		int (*fun)(int suc, int value));
static struct pair *compare(struct pair *operands, int (*fun)(int suc, int value));
static int add_it(int suc, int value);
static int sub_it(int suc, int value);
static int mul_it(int suc, int value);
static int div_it(int suc, int value);
static int eq_it(int suc, int value);
static int ge_it(int suc, int value);
static int gt_it(int suc, int value);
static int le_it(int suc, int value);
static int lt_it(int suc, int value);

static struct pair *initial_env();
static struct pair *p_names();
static struct pair *p_procedures();
static struct pair *extend_environment(struct pair *vars, struct pair *vals, struct pair *env);

static struct pair ENV = { NULL, NULL };
static struct entity TRUE_CONTENT = {
	.type = TYPE_LITERAL,
	.as.symbol = "1",
};
static struct entity FALSE_CONTENT = {
	.type = TYPE_LITERAL,
	.as.symbol = "0",
};
static struct pair TRUE_NODE = { &TRUE_CONTENT, NULL };
static struct pair FALSE_NODE = { &FALSE_CONTENT, NULL };

static char *names[] = {
	"+",
	"-",
	"*",
	"/" ,
	"=",
	"<",
	">",
	"<=",
	">=",
	"null?",
	"not",
	"car",
	"cdr",
	"cons",
	"#t",
	"#f",
};

static struct pair *(*procedures[])(struct pair *) = {
	add,
	sub,
	mul,
	divd,
	eq,
	lt,
	gt,
	le,
	ge,
	is_null,
	not,
	car,
	cdr,
	cons,
	(struct pair *(*)(struct pair *))&TRUE_NODE,
	(struct pair *(*)(struct pair *))&FALSE_NODE,
};

/* public function */

struct pair *setup_environment()
{
	return initial_env();
}

/* private function */

static struct pair *initial_env()
{
	return extend_environment(p_names(), p_procedures(), &ENV);
}


static struct pair *extend_environment(struct pair *vars, struct pair *vals, struct pair *env)
{
	if (length(vars) == length(vals)) {
		struct pair *new = cons_pair(cons_pair(vals), cons_pair(vars));
		return cons_pair(cons_pair(new), cons_pair(env));
	} else if (length(vars) < length(vals)) {
		perror("Too many arguments supplied");
		exit(EXIT_FAILURE);
	} else {
		perror("Too few arguments supplied");
		exit(EXIT_FAILURE);
	}
}


static struct pair *p_names()
{
	struct llist ll = { NULL, NULL };
	int i;
	int len = sizeof(names) / sizeof(names[0]);
	for (i = 0; i < len; i++)
		add_pair(cons_pair(cons_entity(names[i]), NULL), ll.tail, &ll);
	return ll.head;
}


static struct pair *p_procedures()
{
	struct llist ll = { NULL, NULL };
	int i;
	int len = sizeof(procedures) / sizeof(procedures[0]);
	for (i = 0; i < len; i++)
		add_pair(cons_pair(cons_procedure(prim_proc(procedures[i])), NULL),
				ll.tail, &ll);
	return ll.head;
}


static struct pair *add(struct pair *operands)
{
	return fold(operands, 0, add_it);
}


static struct pair *sub(struct pair *operands)
{
	int init = 0;
	if (is_atom(operands))
		init = atoi(operands->car->as.symbol);
	return fold(operands->cdr, init, sub_it);
}


static struct pair *mul(struct pair *operands)
{
	return fold(operands, 1, mul_it);
}


static struct pair *divd(struct pair *operands)
{
	int init = 0;
	if (is_atom(operands))
		init = atoi(operands->car->as.symbol);
	return fold(operands->cdr, init, div_it);
}


static struct pair *eq(struct pair *operands)
{
	return compare(operands, eq_it);
}


static struct pair *le(struct pair *operands)
{
	return compare(operands, le_it);
}


static struct pair *ge(struct pair *operands)
{
	return compare(operands, ge_it);
}


static struct pair *lt(struct pair *operands)
{
	return compare(operands, lt_it);
}


static struct pair *gt(struct pair *operands)
{
	return compare(operands, gt_it);
}


static struct pair *is_null(struct pair *operands)
{
	if (length(operands) == 1 && operands == NULL)
		return &TRUE_NODE;
	return &FALSE_NODE;
}


static struct pair *not(struct pair *operands)
{
	if (length(operands) == 1 && is_atom(operands)) {
		if (!strcmp(operands->car->as.symbol, "#t"))
			return &FALSE_NODE;
		else if (!strcmp(operands->car->as.symbol, "#f"))
			return &TRUE_NODE;
	}
	perror("Neighter #t nor #f");
	exit(EXIT_FAILURE);
}


static struct pair *car(struct pair *operands)
{
	if (length(operands) != 1) {
		perror("Too much operands at car");
		exit(EXIT_FAILURE);
	}
	if (is_pair(operands))
		return dup_pair(operands->car->as.box);
	else
		return NULL;
}


static struct pair *cdr(struct pair *operands)
{
	if (length(operands) != 1) {
		perror("Too much operands at cdr");
		exit(EXIT_FAILURE);
	}
	if (is_pair(operands)) {
		return dup_pairs(operands->car->as.box->cdr);
	} else {
		return NULL;
	}
}


static struct pair *cons(struct pair *operands)
{
	if (length(operands) != 2) {
		perror("Too much operands at cons");
		exit(EXIT_FAILURE);
	}

	struct pair *x = dup_pair(operands);
	struct pair *y = dup_pair(operands->cdr);
	x->cdr = y;

	struct llist list = { NULL, NULL };
	struct pair *n = operands;
	while (n != NULL) {
		if (!is_pair(n) && !is_atom(n) && !is_procedure(n)) {
			perror("Unhandle value");
			exit(EXIT_FAILURE);
		}
		add_pair(dup_pair(n), list.tail, &list);
		n = n->cdr;
	}
	return list.head;
}


static struct entity *fold(struct pair *operands, const int init,
		int (*fun)(int suc, int value))
{
	int retval = init;
	struct pair *n = operands;
	while (n != NULL) {
		if (is_atom(n))
			retval = fun(retval, atoi(n->car->as.symbol));
		n = n->cdr;
	}
	return cons_ent_atom(cons_atom_int(retval));
}


static struct entity *compare(struct pair *operands, int (*fun)(int suc, int value))
{
	int len = length(operands);
	if (len < 2) {
		perror("Few arguments");
		exit(EXIT_FAILURE);
	}
	int retval = TRUE;
	struct pair *n = operands;
	while (n != NULL && n->cdr != NULL) {
		if (is_atom(n))
			retval &= fun(atoi(n->car->as.symbol),
					atoi(n->cdr->car->as.symbol));
		n = n->cdr;
	}

	if (retval)
		return &TRUE_NODE;
	else
		return &FALSE_NODE;
}


static int add_it(int suc, int value)
{
	return suc + value;
}


static int sub_it(int suc, int value)
{
	return suc - value;
}


static int mul_it(int suc, int value)
{
	return suc * value;
}


static int div_it(int suc, int value)
{
	if (value == 0) {
		perror("Dividing with zero");
		exit(EXIT_FAILURE);
	}
	return suc / value;
}


static int eq_it(int suc, int value)
{
	return suc == value;
}


static int le_it(int suc, int value)
{
	return suc <= value;
}


static int ge_it(int suc, int value)
{
	return suc >= value;
}


static int lt_it(int suc, int value)
{
	return suc < value;
}


static int gt_it(int suc, int value)
{
	return suc > value;
}

