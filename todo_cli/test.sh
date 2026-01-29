#!/bin/bash

set -eux

moon run . add "buy milk"
moon run . list
moon run . done 1
moon run . list
moon run . delete 1
moon run . list
