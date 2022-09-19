#!/bin/sh

eval `./emsdk/emsdk construct_env`

exec $*
