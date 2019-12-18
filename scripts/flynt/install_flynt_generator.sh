#!/bin/bash

yarn global add @flyntwp/generator-flynt 2> >(grep -v warning 1>&2)
