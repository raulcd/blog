---
title: "Data structures: Python lists"
date: 2019-03-02T12:15:19Z
draft: false
Description: "Python lists are arrays but they use dynamic growth to have a constant insertion amortized time. This post shows how it's done."
Tags: ["python", "list"]
Categories: ["python"]
author: "Raúl Cumplido"
---

Lately I've been reviewing some algorithms and some data structures. A python `list` is basically a
dynamic array that allows to read and append at constant time.

An array has constant read time `O(1)` but linear `O(n)` write time as everytime you need to add a
new element a new array needs to be allocated in memory and copied to the new location. 

Python list has a constant insertion time. How is Python doing that?

## Dynamic Array and insertion amortized time

A dynamic array doesn't allocate memory only for the current size but also for future elements.
Some example of growth factor for different implementations can be found
[here](https://en.wikipedia.org/wiki/Dynamic_array#Growth_factor).

Amortized time basically means that probabilistically you can expect it to be constant but there are
some moments where it will take linear time. These are the moments when it needs to reallocate and grow
the array.

## Python internal implementantion and grow ratio

As an example we can see the size of a python list. When the list is empty the size of the object in bytes
is the following.

```
>>> l = []
>>> import sys
>>> sys.getsizeof(l)
64
```

At this point the allocated space for elements is 0.

When we add an element we allocate space for four elements that's why it will grow to 96 bytes on the example
below until you add a 5th element when the list needs to grow again and reallocate memory.

```
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
>>> l.append(4)
>>> sys.getsizeof(l)
96
>>> l.append(5)
>>> sys.getsizeof(l)
128
```

In order to avoid growing/decreasing everytime if we reach a point of adding/deleting elements
There is a hysteresis period in the example below we see that once we remove the 5th element
the list still could allocate 8 elements but when we continue reducing it gets reduced.

```
>>> l.pop()
5
>>> sys.getsizeof(l)
128
>>> l.pop()
4
>>> sys.getsizeof(l)
112
```

Based on wikipedia we see that the growth factor on a python list is `~1.125`. This is basically the result
of growing by allocating the `current size + (current_sizee >> 3) + constant`. Basically growing the current size
shifted 3 bits plus a small constant for small sizes.
The current implementation on
[cpython](https://github.com/python/cpython/blob/234531b4462b20d668762bd78406fd2ebab129c9/Objects/listobject.c#L61):

```
    /* This over-allocates proportional to the list size, making room
     * for additional growth.  The over-allocation is mild, but is
     * enough to give linear-time amortized behavior over a long
     * sequence of appends() in the presence of a poorly-performing
     * system realloc().
     * The growth pattern is:  0, 4, 8, 16, 25, 35, 46, 58, 72, 88, ...
     * Note: new_allocated won't overflow because the largest possible value
     *       is PY_SSIZE_T_MAX * (9 / 8) + 6 which always fits in a size_t.
     */
    new_allocated = (size_t)newsize + (newsize >> 3) + (newsize < 9 ? 3 : 6);
```

I didn't really could get that on my head, the 3 bits shift so I did a small snippet to show the growth factor
[here](https://github.com/raulcd/blog_tests/tree/master/list_data_structure_python)

With my snippet I could see something like when the list will grow and by how much:
```
Current size is: 991
Grow shifted size by 3 bits : 123
Small constant: 6
New allocation ocurrs, size of allocation: 1120
```

And the growing ration which is where we get the `~0.125` growing ratio:

```
New allocation: 2062
Growing ratio: 0.124576
New allocation: 2326
Growing ratio: 0.124624
New allocation: 2623
Growing ratio: 0.125000
New allocation: 2958
Growing ratio: 0.124704
New allocation: 3334
Growing ratio: 0.124738
New allocation: 3757
Growing ratio: 0.124800
New allocation: 4233
Growing ratio: 0.124941
New allocation: 4769
Growing ratio: 0.124948
New allocation: 5372
Growing ratio: 0.124884
New allocation: 6050
Growing ratio: 0.124938
New allocation: 6813
Growing ratio: 0.124890
New allocation: 7671
Growing ratio: 0.125000
New allocation: 8637
Growing ratio: 0.124913
New allocation: 9723
Growing ratio: 0.124949
New allocation: 10945
```
