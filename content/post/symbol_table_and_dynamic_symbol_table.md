---
title: "Keeping symbols to yourself"
date: 2025-02-05T11:11:19Z
draft: true
Description: "Obfucasting symbols from the external world so your Shared Objects don't expose them."
Tags: ["build", "C++", "learning"]
Categories: ["build"]
author: "Raúl Cumplido"
---

I usually forget things so I created this blog post so I can come back to it in the future with what
I learnt while working on it.

The [One Definition Rule](https://en.wikipedia.org/wiki/One_Definition_Rule) on C++ tells us
that we can't have more than one definition in the entire program for classes and structs. I hit
some issues with it while doing some work on Arrow in order to [load newer Kernels](https://github.com/raulcd/kernel-loader)
into older versions of Arrow.

I tried to vendor the functionality existing upstream by creating a new Shared Object Library
in order to be able to register the newer kernels via using `FunctionRegistry::AddFunction`.

This endedn up being less complex than originally expected and I had a small Python example
where I was able to do the following:

```python
import ctypes
import pyarrow as pa
import pyarrow.compute as pc

# Load the shared library
lib = ctypes.CDLL('/home/runner/work/kernel-loader/kernel-loader/build/libarrow_kernel_loader.so')

res = lib.LoadKernels()
assert res == 0
array1 = pa.array([2, 1 ,2])

result = pc.call_function("vendored_rank_quantile", [array1])
print(f"Rank Quantile: {result}")

chunked_array1 = pa.chunked_array([[2, 1 ,2], [1,3]])

result = pc.call_function("vendored_rank_quantile", [chunked_array1])
print(f"Rank Quantile for chunked array: {result}")
```

The initial approach was to expose a `LoadKernels` function that used the `FunctionRegistry` to call
`RegisterVectorRank`, which registered the new kernels I wanted to be able to use from an older Arrow version.

In order to be able to use that with Arrow 15 I had to vendor several header files and some cc files
applying some minor diffs. This can be seen on the [kernel-loader repository](https://github.com/raulcd/kernel-loader).

The problem was that both `libarrow.so` and `libarrow_kernel_loader.so` had some repeated symbols as
`_ZN5arrow7compute8internal18RegisterVectorRankEPNS0_16FunctionRegistryE`.

```bash
$ nm build/libarrow_kernel_loader.so | grep RegisterVectorRank
00000000001ab40f T _ZN5arrow7compute8internal18RegisterVectorRankEPNS0_16FunctionRegistryE
$ nm libarrow.so.1500 | grep RegisterVectorRank
0000000002ef3dd5 T _ZN5arrow7compute8internal18RegisterVectorRankEPNS0_16FunctionRegistryE
```

This violates the [One Definition Rule](https://en.wikipedia.org/wiki/One_Definition_Rule).

There are several approaches you can take around symbol visibility and to solve the issues for the **ODR**.
The best one would be to change your code so the symbols are different, for example organizing the code
into a different namespaces. As I was vendoring the code, I originally thought, this would require a bigger patch
and I did want to try to work with symbol visibility first.

I initially tried to remove the symbols from being exposed so it was only used internally.

I tried the following with `objcopy`:

```bash
$ objcopy --strip-unneeded --keep-symbol=LoadKernels --keep-symbol=_ZN14vendored_arrow7compute11LoadKernelsEPN5arrow7compute16FunctionRegistryE build/libarrow_kernel_loader.so
$ nm build/libarrow_kernel_loader.so 
00000000001c3fff T LoadKernels
```

This seems to be doing the trick but here is where I learnt about `.dynsym` and `.symtab` tables:
```bash
$ readelf --symbols build/libarrow_kernel_loader.so
Symbol table '.dynsym' contains 7299 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _ZN5arrow11TypeV[...]
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND [...]@GLIBCXX_3.4.21 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND _ZN5arrow12Struc[...]
... (Skipping 7000+ lines)
  7295: 00000000001c435a    35 FUNC    WEAK   DEFAULT   14 _ZNSt12__shared_[...]
  7296: 0000000000188d21    82 FUNC    WEAK   DEFAULT   14 _ZSt13__invoke_i[...]
  7297: 00000000001a0940    49 FUNC    WEAK   DEFAULT   14 _ZN5arrow11Int32[...]
  7298: 000000000016e854    18 FUNC    WEAK   DEFAULT   14 _ZSt7forwardISt1[...]

Symbol table '.symtab' contains 2 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 00000000001c3fff   122 FUNC    GLOBAL DEFAULT   14 LoadKernels

```

The `.dynsym` table contains symbols needed for dynamic linking while `.symtab` contains all symbols including those not required for dynamic linking, used for static linking.
I basically wanted this for dynamic linking so removing the symbols for `.symtab` wasn't enough.

Another approach would be to use the `__attribute__((visibility))` on C++ this is used to control the visibility of symbols in shared libraries.

This attribute is specific to GCC and Clang compilers but this was good for my use case.


The different types of visibility are:
- **default**: The symbol is visible to other shared objects and executables. This is the default visibility for symbols.
- **hidden**: The symbol is not visible to other shared objects and executables. It is only accessible within the shared object where it is defined.
- **protected**: The symbol is visible to other shared objects and executables, but references to the symbol from within the defining shared object will always resolve to the definition within that shared object.
- **internal**: The symbol is not visible outside the shared object and is treated as if it were static. This is rarely used.

```C++
__attribute__((visibility("default")))
void MyFunction() {
    // Function implementation
}
```

I ended up changing the namespace but that was a good investigation and I learnt more about the different symbol tables
and about the C++ attribute to control the symbol visibility.
