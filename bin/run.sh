#!/bin/bash

args=$1
MIX_ENV=prod mix escript.build; ./github_stalking $args

