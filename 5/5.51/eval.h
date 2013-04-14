#ifndef __EVAL_H__
#define __EVAL_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "exp.h"
#include "env.h"
#include "util.h"

struct pair *eval(struct pair *exp, struct pair *env);

#endif
