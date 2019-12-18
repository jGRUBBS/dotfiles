#!/bin/bash

yarn global add yo 2> >(grep -v warning 1>&2)
