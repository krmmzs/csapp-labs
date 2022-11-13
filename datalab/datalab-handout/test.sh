#!/bin/bash

make && echo ----------- make command completed --------------------------
./btest  && echo ----------- btest command completed --------------------------
./dlc ./bits.c && echo ----------- dlc command completed --------------------------

