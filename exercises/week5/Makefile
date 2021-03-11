# This Makefile can be used to build the Mandelbrot SaC program
#
# Assuming that all the file names are the same, you should be
# able to call `make`, which should build the Fractal1-demo.sac
# file, producing f1_demo in the current directory.
#
# To build other recipes, do `make <target>`, where <target>
# is one of the recipe outputs, e.g. f1_demo or mandelbrot.
# NOTE that just calling `make` will always build the first
#      target, e.g. `f1_demo`.

SAC2C := sac2c
SFLAGS := -v0 -check tc -t mt_pth

f2_demo: Fractal2-demo.sac fractal1 fractal2
	$(SAC2C) $(SFLAGS) -o $@ $<

# these recipes are /fake/, they are used as aliases
.PHONY: fractal1 fractal2
fractal1: host/seq/libFractal_tier1Mod.so
fractal2: host/seq/libFractal_tier2Mod.so

host/seq/lib%Mod.so: %.sac
	$(SAC2C) $(SFLAGS) $^
