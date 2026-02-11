National University of Singapore

**CS1101S --- Programming Methodology**

AY2024/2025 Semester 1

**Final Assessment**

**Time allowed:** 2 hours

**SOLUTIONS**

**[INSTRUCTIONS]{.underline}**

1.  This **QUESTION PAPER** contains **25** Questions in **10**
    Sections, and comprises **24** printed pages, including this page.

2.  The **ANSWER SHEET** comprises **6** printed pages.

3.  Use a pen or pencil to **write** your **Student Number** in the
    designated space on the front page of the **ANSWER SHEET**, and
    **shade** the corresponding circle **completely** in the grid for
    each digit or letter. DO NOT WRITE YOUR NAME!

4.  You must **submit only** the **ANSWER SHEET** and no other
    documents. Do not tear off any pages from the ANSWER SHEET.

5.  All questions must be answered in the space provided in the **ANSWER
    SHEET**; no extra sheets will be accepted as answers.

6.  Write legibly with a **pen** or **pencil** (do not use red color).
    Untidiness will be penalized.

7.  For **multiple choice questions (MCQ)**, **shade** in the **circle**
    of the correct answer **completely**.

8.  The full score of this assessment is **100** marks.

9.  This is a **Closed-Book** assessment, but you are allowed to bring
    with you one double-sided **A4 / letter-sized sheet** of handwritten
    or printed **notes**.

10. Where programs are required, write them in the **Source §4**
    language. A **reference** of some of the **pre-declared functions**
    is given in the **Appendix** of the Question Paper.

11. In any question, unless it is specifically allowed, your answer
    **must not use functions** given in, or written by you for, other
    questions.

**Section A: Orders of Growth \[11 marks\]**

**(1) \[2 marks\] (MCQ)**

What is the order of growth in **space** of the function func1?

> **function** func1(n) {
>
> **return** n \<= 1 ? n : func1(n - 1) + func1(n - 1);
>
> }

  ----------------------------------------------------------------------------------
   **A.**  *Θ(1)*                **E.**  *Θ*(n ^3^ )
  -------- -------------------- -------- -------------------------------------------
   **B.**  *Θ*(log n)            **F.**  *Θ*(n log n)

   **C.**  *Θ*(n) **(answer)**   **G.**  *Θ*(*2^n^* )

   **D.**  *Θ*(n ^2^)            **H.**  *Θ*(n^*1/2*^ )
  ----------------------------------------------------------------------------------

**(2) \[3 marks\] (MCQ)**

What is the order of growth in **time** of the above function func1?

  ----------------------------------------------------------------------------------
   **A.**  *Θ*(1)                **E.**  *Θ*(n ^3^ )
  -------- -------------------- -------- -------------------------------------------
   **B.**  *Θ*(log n)            **F.**  *Θ*(n log n)

   **C.**  *Θ*(n)                **G.**  *Θ*(*2^n^* ) **(answer)**

   **D.**  *Θ*(n ^2^)            **H.**  *Θ*(n^*1/2*^ )
  ----------------------------------------------------------------------------------

**(3) \[3 marks\] (MCQ)**

What is the order of growth in **space** for applications func2(arr, 0)
with respect to the length n of arr?

> **function** func2(arr1, i) {
>
> **const** len = array_length(arr1);
>
> if (i === len) {
>
> **return** 0;
>
> } else {
>
> let arr2 = \[\];
>
> **for** (**let** j = 0; j \<= len; j = j + 1) {
>
> arr2\[j\] = arr1\[j\];
>
> }
>
> **return** arr2\[i\] + func2(arr1, i + 1);
>
> }
>
> }

  ----------------------------------------------------------------------------------
   **A.**  *Θ*(1)                **E.**  *Θ*(n ^3^ )
  -------- -------------------- -------- -------------------------------------------
   **B.**  *Θ*(log n)            **F.**  *Θ*(n log n)

   **C.**  *Θ*(n)                **G.**  *Θ*(*2^n^* )

   **D.**  *Θ*(n ^2^)            **H.**  *Θ*(n^*1/2*^ )
           **(answer)**                  
  ----------------------------------------------------------------------------------

**\**

**(4) \[3 marks\] (MCQ)**

What is the order of growth in **time** for applications func2(arr, 0)
with respect to the length n of arr?

  ----------------------------------------------------------------------------------
   **A.**  *Θ*(1)                **E.**  *Θ*(n ^3^ )
  -------- -------------------- -------- -------------------------------------------
   **B.**  *Θ*(log n)            **F.**  *Θ*(n log n)

   **C.**  *Θ*(n)                **G.**  *Θ*(*2^n^* )

   **D.**  *Θ*(n ^2^)            **H.**  *Θ*(n^*1/2*^ )
           **(answer)**                  
  ----------------------------------------------------------------------------------

**Section B: Recursion \[11 marks\]**

**(5) \[5 marks\]**

Complete the declaration of the function is_prefix, which takes as
arguments a list xs and a list ys and returns true if xs is a prefix of
the list ys, (i.e. if ys starts with all elements of xs in the same
order) and returns false otherwise. You can assume that ys is a
non-empty list.

For example,

> is_prefix(null, list(1, 2, 3)); // returns true
>
> is_prefix(list(1, 2), list(1, 2, 3)); // returns true
>
> is_prefix(list(2, 3), list(1, 2, 3)); // returns false
>
> is_prefix(list(1, 3), list(1, 2, 3)); // returns false
>
> is_prefix(list(1, 2, 3), list(1, 2, 3)); // returns true

**Write your answer only in the dashed-line box(es).**

**function** is_prefix(xs, ys) {

**return** is_null(xs) ? true

: !is_null(ys) && head(xs) === head(ys)

? is_prefix(tail(xs), tail(ys))

: false ;

}

**(6) \[3 marks\] (MCQ)**

What type of process does the function z does give rise to for i = 0 and
j = null, when k grows bigger and bigger?

> **function** z(i, j, k) {
>
> **return** i \> k ? j : z(i + 1, pair(j, i), k);
>
> **}**

  -----------------------------------------
   **A.**  An iterative process
           **(answer)**
  -------- --------------------------------
   **B.**  A recursive process

   **C.**  Not enough information to
           determine.
  -----------------------------------------

**\**

**(7) \[3 marks\] (MCQ)**

What type of process does the function g give rise to for growing
integers x?

> **function** g(x) {
>
> **const** f = (x, y) =\> x;
>
> **return** x === 0 ? f : g(x - 1)(f, x);
>
> **}**

  -----------------------------------------
   **A.**  An iterative process
  -------- --------------------------------
   **B.**  A recursive process **(answer)**

   **C.**  Not enough information to
           determine.
  -----------------------------------------

**Section C: Higher Order Functions \[7 marks\]**

**(8) \[2 marks\]**

Implement the function logging_function that takes a unary function fn
and a string log, and returns a new logging function. This new function,
when called with an argument, should return a pair whose head is the
result of applying fn to the argument and the tail is the log string.
For example,

> **const** add_one = logging_function(x =\> x + 1, \"+1\");
>
> **const** multiply_two = logging_function(x =\> 2 \* x, \"\*2\");
>
> add_one(1); // returns \[2, \"+1\"\]
>
> multiply_two(2); // returns \[4, \"\*2\"\]

**Write your answer only in the dashed-line box(es).**

**function** logging_function(fn, log) {

**return** x =\> pair(fn(x), log);

}

**(9) \[5 marks\]**

Implement the function compose that takes two unary "logging functions"
(as in the above question) fn1 and fn2, and returns a new function. This
new function, when called with an argument x, should return a pair whose
head is the result of applying fn2(fn1(x)) and the tail is a
concatenated string of the logs from both functions.

For example,

**const** f1 = compose(add_one, add_one);

f1(1); // returns \[3, \"+1+1\"\]

**const** f2 = compose(add_one, multiply_two);

f2(1); // returns \[4, \"+1\*2\"\]

**const f3** = compose(f2, multiply_two);

f3(1); // returns \[8, \"+1\*2\*2\"\]

**Write your answer only in the dashed-line box(es).**

**function** compose(fn1, fn2) {

**function** wrapper(x) {

const a = fn1(x);

const b = fn2(head(a));

return pair(head(b), tail(a) + tail(b));

}

**return** wrapper;

}**\**

**Section D: Tombstone Diagrams \[6 marks\]**

**(10) \[6 marks\]**

You are tasked with reviving the classic game *Super Mario Bros.*,
originally developed for the Nintendo Entertainment System (NES), an
iconic but now obsolete gaming console. Your goal is to enable this game
to run on the latest PlayStation 5 (PS5) console.

Since NES\'s hardware uses custom 6502 assembly language, simply
transferring the game to the PS5 is not straightforward. To make this
possible, you are considering two primary approaches: I) using a
hardware emulator to mimic the NES hardware and II) translating the
assembly code using compilers or interpreters.

I.  You found a hardware emulator for 6502 written in JavaScript. PS5
    has an inbuilt JavaScript interpreter.

II. You are keen to run the game natively in PS5 hardware. Propose a
    method to achieve this. You have access to one compiler of your
    choosing. You also have access to an x86 PC for the compilation.

Show the tombstone diagrams for both solutions.  Include the final
execution step, showing how the code, once processed through the
emulator, interpreter, or compiler, is executed on the actual processor
of the modern machine.

I.

PS5

PS5

II\.

PS5

PS5

PS5

PS5

**\**

**Section E: Binary Trees \[13 marks\]**

A ***binary tree*** is either empty or has an ***entry***, a ***left
branch*** and a ***right branch***, where the entry is a number and the
left and right branches are binary trees.

The root node of a binary tree is at ***depth*** 0. The right branch and
the left branch of the root node are at depth 1 and so on.

You can access binary trees **using only** the following functions,
which provide the ***binary tree abstraction***:

- **is_empty_tree(tree)** --- Tests whether the given binary tree tree
  is empty.

- **is_tree(x)** --- Checks if x is a binary tree.

- **left_branch(tree)** --- Returns the left subtree of tree if tree is
  not empty.

- **entry(tree)** --- Returns the value of the entry of tree if tree is
  not empty.

- **right_branch(tree)** --- Returns the right subtree of tree if tree
  is not empty.

- **make_empty_tree()** --- Returns an empty binary tree.

- **make_tree(value, left, right)** --- Returns a binary tree with entry
  value, left subtree left, and right subtree right.

You must use this abstraction for all the questions in this section, and
should not make any assumption about how binary trees are represented
and implemented.

**(11) \[3 marks\] (MCQ) \[This question has been voided\]**

Select the correct response to complete the declaration of the function
max_depth, which takes as argument a binary tree and returns the maximum
depth of the tree.

**function** max_depth(t) {

**if** (is_empty_tree(t)) {

**return** \<EXP1\>

} **else** {

**return** \<EXP2\>

}

}

+--------------+---------------------------------------------------------+
| **\<EXP1\>** | **\<EXP2\>**                                            |
+:============:+=========================================================+
| **A.** 0     | 1 + max_depth(left_branch(t))                           |
|              |                                                         |
|              | \+ max_depth(right_branch(t))                           |
+--------------+---------------------------------------------------------+
| **B.** 0     | math_max(max_depth(left_branch(t)),                     |
|              |                                                         |
|              | max_depth(right_branch(t)))                             |
+--------------+---------------------------------------------------------+
| **C.** 0     | math_max(1 + max_depth(left_branch(t)),                 |
|              |                                                         |
|              | 1 + max_depth(right_branch(t)))                         |
+--------------+---------------------------------------------------------+
| **D.** 1     | math_max(1 + max_depth(left_branch(t)),                 |
|              |                                                         |
|              | 1 + max_depth(right_branch(t)))                         |
+--------------+---------------------------------------------------------+
| **E.** 1     | math_max(max_depth(left_branch(t)),                     |
|              |                                                         |
|              | max_depth(right_branch(t)))                             |
+--------------+---------------------------------------------------------+
| **F.** 1     | max_depth(left_branch(t))                               |
|              |                                                         |
|              | \+ max_depth(right_branch(t)))                          |
+--------------+---------------------------------------------------------+
| **G.** 1     | 1.  \+ max_depth(left_branch(t))                        |
|              |                                                         |
|              | > \+ max_depth(right_branch(t))                         |
+--------------+---------------------------------------------------------+

**(12) \[5 marks\]**

Complete the implementation of the count_leaves_at_depths function,
which takes as argument a binary tree t and returns an array of length
max_depth(t). In the returned array, the value at position i contains
the number of leaves at depth i.

+------------------------------------------------------------------+
| **function** count_leaves_at_depths(tree){                       |
|                                                                  |
| **const** ans = \[\];                                            |
|                                                                  |
| **const** max_d = max_depth(tree);                               |
|                                                                  |
| // initialize ans array with zero values for all depths          |
|                                                                  |
| **for**(let i = 0; i \< max_depth(cadet_names); i = i + 1){      |
|                                                                  |
| ans\[i\] = 0;                                                    |
|                                                                  |
| }                                                                |
|                                                                  |
| **function** help(tree, depth) {                                 |
|                                                                  |
| **if**( !is_empty_tree(tree) ){                                  |
|                                                                  |
| const left = left_branch(tree);                                  |
|                                                                  |
| const right = right_branch(tree);                                |
|                                                                  |
| **if** (is_empty_tree(left) && is_empty_tree(right)) {           |
|                                                                  |
| ans\[depth\] = ans\[depth\] + 1;                                 |
|                                                                  |
| } **else** {                                                     |
|                                                                  |
| help(left, depth + 1);                                           |
|                                                                  |
| help(right, depth + 1);                                          |
|                                                                  |
| }                                                                |
|                                                                  |
| }                                                                |
|                                                                  |
| }                                                                |
|                                                                  |
| help(tree, 0);                                                   |
|                                                                  |
| **return** ans;                                                  |
|                                                                  |
| }                                                                |
+==================================================================+

**(13) \[5 marks\]**

***Monotonically Increasing path*** (MI-path) is defined as a path in a
binary tree, starting at the root node and ending at a leaf node where,
every visited node along the path has a value larger than its parent.

Complete the implementation of longest_mi_path, which takes as arguments
a tree and returns the length of the *longest* MI-path in the tree. If
there are no MI-paths it should return 0.

You can assume the tree only contains positive integers as entries.

+-----------------------------------------------------------------------+
| **function** longest_mi_path(t){                                      |
|                                                                       |
| **function** help(t, p){                                              |
|                                                                       |
| if (is_empty_tree(t)){                                                |
|                                                                       |
| return 0;                                                             |
|                                                                       |
| } else {                                                              |
|                                                                       |
| if (entry(t) \> p) {                                                  |
|                                                                       |
| const ans1 = 1 + help(left_branch(t), entry(t));                      |
|                                                                       |
| const ans2 = 1 + help(right_branch(t), entry(t));                     |
|                                                                       |
| return math_max(ans1, ans2);                                          |
|                                                                       |
| } else {                                                              |
|                                                                       |
| return 0;                                                             |
|                                                                       |
| }                                                                     |
|                                                                       |
| }                                                                     |
|                                                                       |
| }                                                                     |
|                                                                       |
| **return** help(t, -1);                                               |
|                                                                       |
| }                                                                     |
+=======================================================================+

**\**

**Section F: Ordering Arrays \[10 marks\]**

In this section, consider the following functions:

> **function** map_array(f, A) {
>
> **const** len = array_length(A);
>
> **for** (**let** i = 0; i \< len; i = i + 1) {
>
> A\[i\] = f(i, A\[i\]);
>
> }
>
> }
>
> **function** sort_ascending(A) {
>
> **const** len = array_length(A);
>
> **for** (**let** i = len - 1; i \>= 1; i = i - 1) {
>
> **for** (**let** j = 0; j \< i; j = j + 1) {
>
> **if** (A\[j\] \> A\[j + 1\]) {
>
> **const** temp = A\[j\];
>
> A\[j\] = A\[j + 1\];
>
> A\[j + 1\] = temp;
>
> }
>
> }
>
> }
>
> }

**(14) \[5 marks\]**

Complete the declaration of the function sort_descending, which takes as
argument an array of numbers, and sorts the array elements in descending
order. For example,

> **const** AA = \[3, 9, 2, -5, 1, 6, 5, -2, 3, 8\];
>
> sort_descending(AA);
>
> AA; *// evaluates to \[9, 8, 6, 5, 3, 3, 2, 1, -2, -5\]*

Your answer must consist of at most three statements, and each statement
must be an application of the function map_array or sort_ascending.
Write each statement in one of the three dashed-line boxes.

**function** sort_descending(A) {

map_array((i, x) =\> -x, A);

sort_ascending(A);

map_array((i, x) =\> -x, A);

}

**(15) \[5 marks\]**

Complete the declaration of the function reverse_array, which takes as
argument an array of numbers, where every number *x* is 0 ≤ *x* \< 1000,
and arranges the array elements in reverse order. For example,

> **const** AA = \[3, 9, 2, 1, 6, 5, 3, 8\];
>
> reverse_array(AA);
>
> AA; *// evaluates to \[8, 3, 5, 6, 1, 2, 9, 3\]*

Your answer must consist of at most three statements, and each statement
must be an application of the function map_array, sort_ascending, or the
function sort_descending from the preceding question. Write each
statement in one of the three dashed-line boxes.

**function** reverse_array(A) {

map_array((i, x) =\> i \* 1000 + x, A);

sort_descending(A);

map_array((i, x) =\> x % 1000, A);

}

**\**

**Section G: Tensors \[20 marks\]**

In mathematics and physics, first-order numerical objects are called
vectors and second-order objects are called matrices. In this question,
the size of a vector specifies how many numbers it contains, so a vector
of size 3 has three numbers. We represent vectors using arrays of
numbers, whose indices start with 0. Therefore, if V is a vector of size
3, we can access all its components using V\[0\], V\[1\], and V\[2\]. We
represent matrices by arrays of arrays of numbers, so we can access the
last (bottom right) number of a 5 x 5 matrix M by M\[4\]\[4\].

The notion of a tensor generalizes the order of numerical objects. A
vector is called a first-order tensor, and a matrix is a second-order
tensor. We assume that multidimensional tensors are hypercubic: They
have a uniform size in every order. A second-order size-5 tensor
(matrix) has 5 x 5 = 25 numbers, and a third-order size-4 tensor has 4 x
4 x 4 = 64 numbers. In this question, we assume that the size of a
tensor is always greater than or equal to 1. As a special case, any
number is considered to be a zero-order tensor of any size greater than
or equal to 1. We represent tensors using arrays, whose indices start
with 0. Therefore, if T is an order-4 size-3 tensor,
T\[0\]\[1\]\[2\]\[0\] returns a number.

**(16) \[5 marks\]**

Write a function make_tensor that takes a non-negative integer *n* as
first argument and an integer *k* greater than or equal to 1 as second
argument and returns an order-*n* size-*k* tensor whose numbers are all
0.

Examples:

const t1 = make_tensor(2, 2);

display(t1); // \[\[0, 0\], \[0, 0\]\]

const t2 = make_tensor(4, 3);

display(t2); // \[ \[ \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\]\],

// \[ \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\]\],

// \[ \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\],

// \[\[0, 0, 0\], \[0, 0, 0\], \[0, 0, 0\]\]\]\]

Only use the provided spaces to complete the function make_tensor.

**\**

+----------------------------------------------------------------------+
| **function** make_tensor(n, k) {                                     |
|                                                                      |
| **if** (n === 0) {                                                   |
|                                                                      |
| **return** 0;                                                        |
|                                                                      |
| **\**                                                                |
|                                                                      |
| } **else** {                                                         |
|                                                                      |
| **const** t = \[\];                                                  |
|                                                                      |
| **for** (**let** i = 0; i \< k; i = i + 1) {                         |
|                                                                      |
| t\[i\] = make_tensor(n - 1, k);                                      |
|                                                                      |
| }                                                                    |
|                                                                      |
| **return** t;                                                        |
|                                                                      |
| **return** t;                                                        |
|                                                                      |
| }                                                                    |
|                                                                      |
| }                                                                    |
+======================================================================+

**(17) \[5 marks\]**

Write a function tensor_write that takes an order-*n* size-*k* tensor t,
an array of indices idxs, and a number v as arguments and writes v to t
at the given position indicated by idxs. You can assume that the size of
the array idxs is *n* and that each element of idxs is a non-negative
integer smaller than *k*. The function tensor_write should return
undefined.

Example:

tensor_write(t2, \[0, 1, 2, 0\], 88); // writes number 88 into tensor t2

// where t2 is as above

display(t2\[0\]\[1\]\[2\]\[0\]); // displays 88

Only use the provided space to complete the function tensor_write.

+----------------------------------------------------------------------+
| **function** tensor_write(t, indices, v) {                           |
|                                                                      |
| for (**let** i = 0; i \< array_length(indices) - 1; i = i + 1) {     |
|                                                                      |
| t = t\[indices\[i\]\];                                               |
|                                                                      |
| }                                                                    |
|                                                                      |
| t\[array_length(indices) - 1\] = v;                                  |
|                                                                      |
| }                                                                    |
+======================================================================+

**(18) \[5 marks\]**

Write a function tensor_order that takes a tensor as argument and
returns its order.

Examples:

display(tensor_order(44)); // displays 0

display(tensor_order(\[6, 5, 4, 3\])); // displays 1

display(tensor_order(\[\[1,1\], \[2,2\]\]); // displays 2

display(tensor_order(t2)); // displays 4, if t2 as above

Only use the provided space to complete the function tensor_order.

+----------------------------------------------------------------------+
| **function** tensor_order(t) {                                       |
|                                                                      |
| **return** is_number(t)                                              |
|                                                                      |
| ? 0                                                                  |
|                                                                      |
| : tensor_order(t\[0\]) + 1;                                          |
|                                                                      |
| }                                                                    |
+======================================================================+

**\**

**(19) \[5 marks\]**

Write a function tensor_add that takes as arguments two tensors t1 and
t2 of the same order and size and returns a tensor of the same order and
size in which the numbers in each position are the results of adding the
numbers of t1 and t2 at the same position. The function tensor_add must
not modify the two argument tensors.

Example:

display(tensor_add(33, 44)); // displays 77

display(tensor_add(\[\[10, 20\], \[30, 40\]\], \[\[1, 2\], \[3, 4\]\]));

// displays \[\[11, 22\], \[33, 44\]\]

Only use the provided space to complete the function tensor_add.

+----------------------------------------------------------------------+
| **function** tensor_add(t1, t2) {                                    |
|                                                                      |
| **if** (is_number(t1) && is_number(t2)) {                            |
|                                                                      |
| return t1 + t2;                                                      |
|                                                                      |
| } **else** {                                                         |
|                                                                      |
| **const** t3 = \[\];                                                 |
|                                                                      |
| **const** len = array_length(t1);                                    |
|                                                                      |
| **for** (let i = 0; i \< len; i = i + 1) {                           |
|                                                                      |
| t3\[i\] = tensor_add(t1\[i\], t2\[i\]);                              |
|                                                                      |
| }                                                                    |
|                                                                      |
| **return** t3;                                                       |
|                                                                      |
| }                                                                    |
|                                                                      |
| }                                                                    |
+======================================================================+

**\**

**Section H: Streams \[14 marks\]**

**(20) \[3 marks\] (MCQ)**

What is the result of evaluating the following Source program in *list
notation*?

> **function** add_streams(s1, s2) {
>
> **return** pair(head(s1) + head(s2),
>
> () =\> add_streams(stream_tail(s1),
>
> stream_tail(s2)));
>
> }
>
> **const** strm = pair(1, () =\> pair(2, () =\> add_streams(strm,
> strm)));
>
> eval_stream(strm, 10);

  ----------------------------------------------------------------------------
  **A.**   list(1, 2, 2, 4, 8, 16, 32, 64, 128, 256)
  -------- -------------------------------------------------------------------
  **B.**   list(1, 2, 2, 4, 4, 6, 6, 8, 8, 10)

  **C.**   list(1, 2, 2, 4, 4, 8, 8, 16, 16, 32) **(answer)**

  **D.**   list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512)

  **E.**   list(1, 2, 4, 6, 8, 10, 12, 14, 16, 18)

  **F.**   list(1, 2, 2, 4, 6, 8, 10, 12, 14, 16)

  **G.**   The program causes an error.
  ----------------------------------------------------------------------------

**(21) \[3 marks\] (MCQ)**

What is the result of evaluating the following Source program in *list
notation*? (The function add_streams is given in the preceding
question.)

> **const** strm =
>
> pair(1, () =\> pair(2, () =\> add_streams(strm,
>
> pair(4, tail(strm)))));
>
> eval_stream(strm, 10);

  ----------------------------------------------------------------------------
  **A.**   list(1, 2, 5, 6, 9, 10, 13, 14, 17, 18)
  -------- -------------------------------------------------------------------
  **B.**   list(1, 2, 5, 7, 10, 12, 15, 17, 20, 22)

  **C.**   list(1, 2, 6, 8, 14, 22, 36, 58, 94, 152)

  **D.**   list(1, 2, 5, 3, 7, 8, 10, 15, 18, 25)

  **E.**   list(1, 2, 5, 4, 10, 6, 15, 8, 20, 10)

  **F.**   list(1, 2, 5, 4, 10, 8, 20, 16, 40, 32) **(answer)**

  **G.**   The program causes an error.
  ----------------------------------------------------------------------------

**(22) \[4 marks\] (MCQ)**

What is the sequence of values printed by the display function when the
following Source program is evaluated? (Refer to the Appendix for the
implementation of stream_ref.)

> **function** dpair(x, y) {
>
> display(x);
>
> **return** pair(x, y);
>
> }
>
> **const** stm = dpair(1, () =\> dpair(2, () =\> dpair(3, () =\>
> stm)));
>
> stream_ref(stm, 6);
>
> stream_ref(stm, 6);

  ----------------------------------------------------------------------------
  **A.**   1 2 3 2 3 2 3
  -------- -------------------------------------------------------------------
  **B.**   1 2 3 2 3 2 3 2 3 **(answer)**

  **C.**   1 2 3 2 3 1 2 3 2 3

  **D.**   1 2 3 1 2 3 1 2 3

  **E.**   1 2 3 1 2 3 1 2 3 1 2 3

  **F.**   1 2 3 2 3 1 2 3

  **G.**   1 2 3 1 2 3
  ----------------------------------------------------------------------------

**(23) \[4 marks\] (MCQ)**

Consider the function memo_fun from the lectures:

> **function** memo_fun(fun) {
>
> **let** already_run = false;
>
> **let** result = undefined;
>
> **function** mfun() {
>
> **if** (!already_run) {
>
> result = fun();
>
> already_run = true;
>
> **return** result;
>
> } **else** {
>
> **return** result;
>
> }
>
> }
>
> **return** mfun;
>
> }

What is the sequence of values printed by the display function when the
following Source program is evaluated? (The function dpair is declared
in the preceding question.)

> **const** stm = dpair(1, memo_fun(() =\> dpair(2, () =\> dpair(3, ()
> =\> stm))));
>
> stream_ref(stm, 6);
>
> stream_ref(stm, 6);

  ----------------------------------------------------------------------------
  **A.**   1 2 3 3 3 3 **(answer)**
  -------- -------------------------------------------------------------------
  **B.**   1 2 3 3

  **C.**   1 2 3 3 1

  **D.**   1 2 3 3 1 2 3 3

  **E.**   1 2 3 3 1 2 3 1 2 3 1

  **F.**   1 2 3

  **G.**   1 2 3 1 2 3
  ----------------------------------------------------------------------------

**\**

**Section I: Recursive evaluator \[3 marks\]**

Consider the following modified version of the recursive evaluator of
the textbook. The changes are highlighted in bold.

function evaluate(component, env) {

return is_literal(component)

? literal_value(component)

: is_name(component)

? lookup_symbol_value(symbol_of_name(component), env)

: is_application(component)

? apply(evaluate(function_expression(component), env),

list_of_values(arg_expressions(component), env)**,**

**env**)

...

: error(component, \"unknown syntax \-- evaluate\");

}

function apply(fun, args**,** **env**) {

if (is_primitive_function(fun)) {

return apply_primitive_function(fun, args);

} else if (is_compound_function(fun)) {

const result = evaluate(function_body(fun),

extend_environment(

function_parameters(fun),

args,

**env**));

return is_return_value(result)

? return_value_content(result)

: undefined;

} else {

error(fun, \"unknown function type \-- apply\");

}

}

**(24) \[3 marks\] (MCQ)**

What is the result of running the following program using this modified
evaluator?

**const** f = x =\> y =\> x + y;

**const** x = 4;

f(2)(3);

  ---------------------------------------------------------------------------------
  **A.**   4                              **E.**   error: unbound name x
  -------- ------------------------------ -------- --------------------------------
  **B.**   5                              **F.**   error: unbound name y

  **C.**   6                              **G.**   error: unbound name f

  **D.**   7 (answer)                     **H.**   none of the other options
  ---------------------------------------------------------------------------------

**\**

**Section J: CSE machine \[5 marks\]**

The CSE machine includes env instructions to handle environments in
function calls. During the execution of call instructions, env
instructions are placed on the control so that the environment at the
time of the function call is restored when the function returns.

You saw in the lectures that proper tail calls in JavaScript do not
create env instructions because the environment at the time of the
function call is not needed after the function returns.

Another case when env instructions are not necessary is **when the
environment to be used for evaluating the function body is the same as
the environment at the time of the function call.** Consider this
example:

**const** ones_stream = () =\> pair(1, ones_stream); // 1

**const** ones = ones_stream(); // 2

head(tail(tail(ones)())()); // 3

The application of ones_stream in line 2 creates the env instruction in
the control, shown here just before it is executed.

![A diagram of a program Description automatically
generated](media/image3.png){width="4.524752843394576in"
height="3.3196227034120733in"}

The environment that was used for evaluating the body of ones_stream is
the same as the environment that the env instruction is about to
restore. The env instruction therefore does nothing: It is unnecessary.

**(25) \[5 marks\]**

Modify the CSE machine for simple functions to avoid the creation of
unnecessary data structures when the environment to be used for
evaluating the function body is the same as the environment at the time
of the function call. Only change the program by filling the indicated
boxes. Do not make any other modifications. Your modification must not
change the result of evaluating any given Source program.

**function** evaluate(program) {

**let** C = list(make_block(program));

**let** S = null; E = the_global_environment;

**while** (! is_null(C)) {

**const** command = head(C);

C = tail(C);

**if** (...) { ...

} ... **else** **if** (is_call_instruction(command)) {

**const** arity = call_instruction_arity(command);

**let** args = null; let n = arity;

**while** (n \> 0) {

args = pair(head(S), args);

S = tail(S); n = n - 1;

}

**const** fun = head(S);

S = tail(S);

**if** (is_primitive_function(fun)) {

S = pair(apply_primitive_function(fun, args),

S);

} **else** **if** (is_simple_function(fun)) {

**if** (

\<condition\>

) {

\<block\>

} **else** {

C = pair(function_body(fun),

pair(make_env_instruction(E),

C));

E = extend_environment(

function_parameters(fun),

args,

function_environment(fun));

}

} **else** { error(fun, \"unknown function type \-- call\"); }

...

Implementation of the function extend_environment is available in the
appendix for your reference.

Write the appropriate condition and block to complete the
implementation.

+----------------------------------------------------------------------+
| arity === 0 &&                                                       |
|                                                                      |
| function_environment(fun) === E                                      |
|                                                                      |
| C = pair(function_body(fun), C);                                     |
+======================================================================+

**Appendix**

We assume the following pre-declared functions in Source §4 are declared
as follows:

> **function** map(f, xs) {
>
> **return** is_null(xs)
>
> ? xs
>
> : pair(f(head(xs)), map(f, tail(xs)));
>
> }
>
> **function** filter(pred, xs) {
>
> **return** is_null(xs)
>
> ? null
>
> : pred(head(xs))
>
> ? pair(head(xs), filter(pred, tail(xs)))
>
> : filter(pred, tail(xs));
>
> }
>
> **function** accumulate(f, initial, xs) {
>
> **return** is_null(xs)
>
> ? initial
>
> : f(head(xs), accumulate(f, initial, tail(xs)));
>
> }
>
> **function** append(xs, ys) {
>
> **return** is_null(xs)
>
> ? ys
>
> : pair(head(xs), append(tail(xs), ys));
>
> }
>
> **function** stream_map(f, s) {
>
> **return** is_null(s)
>
> ? null
>
> : pair(f(head(s)), () =\> stream_map(f, stream_tail(s)));
>
> }
>
> **function** stream_filter(p, s) {
>
> **return** is_null(s)
>
> ? null
>
> : p(head(s))
>
> ? pair(head(s), () =\> stream_filter(p, stream_tail(s)))
>
> : stream_filter(p, stream_tail(s));
>
> }
>
> **function** stream_ref(s, n) {
>
> **return** n === 0
>
> ? head(s)
>
> : stream_ref(stream_tail(s), n - 1);
>
> }
>
> **function** enum_stream(low, hi) {
>
> **return** low \> hi
>
> ? null
>
> : pair(low, () =\> enum_stream(low + 1, hi));
>
> }
>
> **function** eval_stream(s, n) {
>
> **return** n === 0
>
> ? null
>
> : pair(head(s), eval_stream(stream_tail(s), n - 1));
>
> }
>
> **function** integers_from(n) {
>
> **return** pair(n, () =\> integers_from(n + 1));
>
> }
>
> **function** extend_environment(symbols, vals, base_env) {
>
> **return** length(symbols) === length(vals)
>
> ? pair(make_frame(symbols, vals), base_env)
>
> : length(symbols) \< length(vals)
>
> ? error(\"too many arguments supplied: \" +
>
> stringify(symbols) + \", \" +
>
> stringify(vals))
>
> : error(\"too few arguments supplied: \" +
>
> stringify(symbols) + \", \" +
>
> stringify(vals));
>
> }

**--------- END OF PAPER ---------**
