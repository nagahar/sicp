#ifndef __EXP_H__
#define __EXP_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "util.h"

//TODO: revise all
//
enum atomtag {
	TYPE_ATOM_SYM = 0,
	TYPE_ATOM_FUNC,
	TYPE_ATOM_INT,
	TYPE_ATOM_REAL,
};

enum entitytag {
	TYPE_PAIR = 0,
	TYPE_ATOM,
};

struct entity {
	enum entitytag type;
	union {
		struct pair *p;
		struct atom *a;
	} as;
};

struct pair {
	struct entity *car;
	struct entity *cdr;
};

struct atom {
	enum atomtag type;
	union {
		char *s;
		struct pair *(*f)(struct pair *arg);
		long i;
		double r;
	} as;
};

struct pair *cons_pair(struct entity *car, struct entity *cdr);

struct entity *cons_ent_pair(struct pair *p);
struct entity *cons_ent_atom(struct atom *a);
struct atom *cons_atom_sym(char *s);
struct atom *cons_atom_func(struct pair *(*f)(struct pair *arg));
struct atom *cons_atom_int(long i);
struct atom *cons_atom_real(double r);
struct entity *prim_proc(struct pair *(*fun)(struct pair *arg));

/***
 * car: deep copy of orig->car
 * cdr: deep copy of orig->cdr
 ***/
struct pair *dup_pair(const struct pair * const orig);
void free_pair(struct pair *n);

int is_pair(const struct entity * const p);
int is_atom(const struct entity * const p);
int is_primitive(const struct pair * const p);
int is_compound(const struct pair * const p);
void show(const struct pair * const p);
int length(const struct pair * const p);

struct llist {
	struct pair *head;
	struct pair *tail;
};

void add_pair(struct entity *newe, struct pair *p, struct llist *l);


#endif

