#!/bin/bash
R CMD INSTALL --build . --configure-args='--disable-threading'
