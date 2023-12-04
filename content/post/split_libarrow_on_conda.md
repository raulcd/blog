---
title: "Split Arrow CPP libraries on conda"
date: 2023-11-28T11:11:19Z
draft: false
Description: "I have been working on dividing the Arrow CPP libraries on conda."
Tags: ["arrow", "conda"]
Categories: ["arrow"]
author: "Raúl Cumplido"
---

It has been a really long time since I have written anything but during the last year
I have been involved in the development and releases of Apache Arrow and I have been
contributing to the project and the overall ecosystem.

One of the things I have worked during the last months has been to divide the Apache
Arrow C++ conda package into subpackages in order to provide a more modular installation.

Before Arrow 14.0.0 on conda we did provide a single libarrow package that contained a full
build of Apache Arrow C++. Since 14.0.0 we also provide a single package with everything
called `libarrow-all` which is a metapackage that pulls all the following libraries:

* `libarrow`
* `libparquet`
* `libarrow-acero`
* `libarrow-dataset`
* `libarrow-flight`
* `libarrow-flight-sql`
* `libarrow-gandiva`
* `libarrow-substrait`

Those are also provided individually with the following dependencies:

![libarrow packages](/img/libarrow_package_dependency.jpg)

