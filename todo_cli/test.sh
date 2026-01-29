#!/bin/bash

set -eux

moon run src add "buy milk"
moon run src list
moon run src done 1
moon run src list
moon run src delete 1
moon run src list
