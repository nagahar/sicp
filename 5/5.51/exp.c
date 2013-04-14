#include "exp.h"
const unsigned int MAX_SIZE = floor(log10((double)LONG_MAX));
struct procedure *cons_proc(int type, struct pair *(*fun)(struct pair *arg));
struct atom *alloc_atom(enum atomtag type, void *p);
struct entity *alloc_ent(enum entitytag type, void *p);
void free_atom(struct atom *a);
void free_ent(struct entity *e);
struct pair *prev(struct pair *n, struct llist *l);

/* public function */
struct pair *cons_pair(struct entity *car, struct entity *cdr)
{
	struct pair *new = (struct pair *)ecalloc(1, sizeof(struct pair));
	new->car = car;
	new->cdr = cdr;
	return new;
}


struct entity *cons_ent_pair(struct pair *p)
{
	return alloc_ent(TYPE_PAIR, (void *)p);
}


struct entity *cons_ent_atom(struct atom *a)
{
	return alloc_ent(TYPE_ATOM, (void *)a);
}


struct entity *cons_atom_sym(char *s)
{
	return alloc_ent(TYPE_ATOM_SYM, (void *)s);
}


struct atom *cons_atom_func(struct pair *(*f)(struct pair *arg))
{
	return alloc_ent(TYPE_ATOM_FUNC, (void *)f);
}


struct entity *cons_atom_int(long i)
{
	return alloc_atom(TYPE_ATOM_INT, (void *)i);
}


struct entity *cons_atom_real(double r)
{
	return alloc_atom(TYPE_ATOM_REAL, (void *)r);
}


struct procedure *prim_proc(struct pair *(*fun)(struct pair *arg))
{
	return cons_proc(TYPE_PROC_PRIMITIVE, fun);
}


struct pair *dup_pair(const struct pair * const orig)
{
	struct pair *new = (struct pair *)ecalloc(1, sizeof(struct pair));

	int i;
	for (i = 0; i < 2; i++) {
		struct entity *ent;
		struct entity **n;
		if (i == 0) {
			ent = orig->car;
			n = &new->car;
		} else {
			ent = orig->cdr;
			n = &new->cdr;
		}
		if (ent->type == TYPE_ATOM) {
			struct atom *a = (struct atom *)ent->as.a;
			(*n) = alloc_ent(ent->type,
					(void *)alloc_atom(a->type, (void *)a->as.s));
		} else if (ent->type == TYPE_PAIR) {
			(*n) = alloc_ent(ent->type,
					(void *)dup_pair(p));
		} else {
			perror("Unknown entity type, cannot alloc");
			exit(EXIT_FAILURE);
		}
	}
	return new;
}


void free_pair(struct pair *p)
{
	free_ent(p->car);
	free_ent(p->cdr);
	free(p);
}


void show(const struct pair * const p)
{
	if (p) {
		struct entity *data = p->car;
		if (data->type == TYPE_ATOM) {
			struct atom *a = data->as.a;
			if (a->type == TYPE_ATOM_SYM)
				printf("%s ", a->as.s);
			else if (a->type == TYPE_ATOM_FUNC)
				printf("object@%p ", a->as.p);
			else if (a->type == TYPE_ATOM_INT)
				printf("%d ", a->as.i);
			else if (a->type == TYPE_ATOM_REAL)
				printf("%f ", a->as.r);
		} else if (data->type == TYPE_PAIR) {
			printf("(");
			show(data->as.p);
			printf(")");
		} else {
			perror("Unknown data type");
			exit(EXIT_FAILURE);
		}
		show(p->cdr);
	} else {
		printf("\n");
	}
}


int length(const struct pair * const p)
{
	if (p == NULL)
		return 0;
	else
		return length(p->cdr) + 1;
}


void add_pair(struct entity *newe, struct pair *p, struct llist *l)
{
	struct newp = (struct pair *)ecalloc(1, sizeof(struct pair));
	newp->car = newe;
	/* p is head */
	if (p == NULL) {
		newp->cdr = cons_ent_pair(l->head);
		l->head = newp;
	} else {
		new->cdr = p->cdr;
		p->cdr = cons_ent_pair(newp);
	}

	/* p is tail */
	if (p == l->tail)
		l->tail = newp;
}


/* private function*/
struct atom *alloc_atom(enum atomtag type, void *p)
{
	struct atom *a = (struct atom *)ecalloc(1, sizeof(struct atom));
	a->type = type;

	if (type == TYPE_ATOM_SYM) {
		a->as.s = (char *)p;
	} else if (type == TYPE_ATOM_FUNC) {
		a->as.f = (struct pair *(*)(struct pair *))p;
	} else if (type == TYPE_ATOM_INT) {
		a->as.i = (long)p;
	} else if (type == TYPE_ATOM_REAL) {
		a->as.r = (double)p;
	} else {
		perror("Unknown atom type, cannt alloc");
		exit(EXIT_FAILURE);
	}

}


struct entity *alloc_ent(enum entitytag type, void *p)
{
	struct entity *ent = (struct entity *)ecalloc(1, sizeof(struct entity));

	ent->type = type;
	if (type == TYPE_ATOM) {
		ent->as.a = (struct atom *)p;
	} else if (type == TYPE_PAIR) {
		ent->as.p = (struct pair *)p;
	} else {
		perror("Unknown ent type, cannt alloc");
		exit(EXIT_FAILURE);
	}
	return ent;
}


void free_atom(struct atom *a)
{
	free(a);
}


void free_ent(struct entity *e)
{
	if (e->type == TYPE_ATOM) {
		free_atom(e->as.a);
	} else if (d->type == TYPE_PAIR) {
		free_ent(e->as.p);
	} else {
		perror("Unknown data type, cannot free");
		exit(EXIT_FAILURE);
	}
}



int is_pair(const struct entity * const p)
{
	return (p->type == TYPE_PAIR);
}


int is_atom(const struct entity * const p)
{
	return (p->type == TYPE_ATOM);
}


int is_primitive(const struct entity * const p)
{
	return is_atom(p) &&
		p->as.(a->type) == TYPE_ATOM_FUNC;
}


int is_compound(const struct pair * const p)
{
	return is_atom(p) &&
		p->as.(a->type) == TYPE_ATOM_SYM &&
		!strcmp(p->as.(a->as.s), "compound");
}


