---
title: "An algorithmic view to Python List"
date: 2019-03-02T12:15:19Z
draft: true
Description: "Python lists are arrays but they use table doubling to have a constant insertion amortized time. This post shows how it's done."
Tags: ["python", "list"]
Categories: ["python"]
author: "Raúl Cumplido"
---

Lately I've been reviewing some algorithms and some data structures. A python `list` is basically an array that allows to read and write at constant time.

An array has constant read time `O(1)` but linear `O(n)` write time as everytime you need to add a new element a new array needs to be allocated in memory
and copied to the new location.

# TODO ADD image

Python list has a constant insertion time. How is Python doing that?

## Table doubling and insertion amortized time

## Python internal implementantion and grow ratio

```
$ vim /home/raulcd/my_projects/cpython/Objects/listobject.c
```


```>>> l = []
>>> import sys
>>> sys.getsizeof(l)
64
>>> l.append(1)
>>> l
[1]
>>> sys.getsizeof(l)
96
>>> l.append(2)
>>> sys.getsizeof(l)
96
>>> l
[1, 2]
>>> l.append(3)
>>> sys.getsizeof(l)
96
>>> l.append(4)
>>> sys.getsizeof(l)
96
>>> l.append(5)
>>> sys.getsizeof(l)
128
>>> l.pop()
5
>>> sys.getsizeof(l)
128
>>> l.pop()
4
>>> sys.getsizeof(l)
112
>>> l.append(5)
>>> sys.getsizeof(l)
112
>>> l.append(6)
>>> sys.getsizeof(l)
112
>>> l.append(7)
>>> sys.getsizeof(l)
112
>>> l.append(8)
>>> sys.getsizeof(l)
144
>>>
```