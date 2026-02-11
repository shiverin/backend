# Source Academy SICP - Sample Document for RAG Testing

## Chapter 1: Building Abstractions with Functions

This chapter introduces the fundamental concepts of computer science through
the lens of JavaScript programming. The key ideas include:

### 1.1 The Elements of Programming

A powerful programming language serves as a framework for organizing ideas about
computational processes. Every programming language provides three mechanisms:

1. **Primitive expressions** - the simplest entities the language is concerned with
2. **Means of combination** - compound elements are built from simpler ones
3. **Means of abstraction** - compound elements can be named and manipulated as units

Programming deals with two key elements: functions and data. Data is the "stuff"
we want to manipulate, and functions are descriptions of rules for manipulating data.

### 1.2 Functions and the Processes They Generate

Functions are patterns for the local evolution of a computational process. They
specify how each stage of a process is built upon the previous stage.

A linear recursive process is characterized by a chain of deferred operations.
The expansion occurs as the process builds up a chain of operations, followed by
a contraction as the operations are performed. A linear iterative process, on the
other hand, can be characterized by a fixed number of state variables.

### 1.3 Formulating Abstractions with Higher-Order Functions

Higher-order functions are functions that manipulate other functions. They can
accept functions as arguments and return functions as values. This is a powerful
means of abstraction that allows us to express general methods of computation.

The ability to pass functions as arguments significantly enhances the expressive
power of our programming language. We can create common patterns of usage as
named concepts and work in terms of these abstractions directly.

## Chapter 2: Building Abstractions with Data

This chapter extends the notion of abstraction to compound data structures.

### 2.1 Introduction to Data Abstraction

Data abstraction isolates how a compound data object is used from how it is
constructed from primitive data objects. The basic idea is to structure programs
that use compound data objects so that they operate on "abstract data."

### 2.2 Hierarchical Data and the Closure Property

The closure property allows us to create hierarchical structures — structures
whose parts are themselves structures. Pairs provide a primitive way to
construct compound data, and the closure property of pairs enables us to
build up complex structures like sequences and trees.
