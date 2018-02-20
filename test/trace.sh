#!/bin/bash
#
# used to test trace
#
set -x

. ../bin/00_utilities.sh

function a() 
{ 
trace e
b
trace x
}

function b() 
{
trace e
c
trace x
}

function c()
{
trace e
trace x
}

a
