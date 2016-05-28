# This Makefile assumes that you have kernel header files for your current kernel version installed.
#
# Example:
# export KERNEL_SRC=/opt/kernel/linux

TARGET = raspbiecdrv

all: checkvars raspbiec raspbiecdrv

checkvars:
ifeq ($(strip $(KERNEL_SRC)),)
	$(error KERNEL_SRC not set (path to kernel source))
endif

raspbiec: raspbiec.o raspbiec_device.o raspbiec_utils.o
	g++ -Wall $^ -o $@

raspbiec.o: raspbiec.cpp raspbiec.h raspbiec_device.h raspbiec_utils.h raspbiec_common.h
	g++ -Wall -c $<

raspbiec_device.o: raspbiec_device.cpp raspbiec_device.h raspbiec_utils.h raspbiec_common.h
	g++ -Wall -c $<

raspbiec_utils.o: raspbiec_utils.cpp raspbiec_utils.h raspbiec_common.h
	g++ -Wall -c $<

ifneq ($(KERNELRELEASE),)
# call from kernel build system

obj-m	:= $(TARGET).o

else



KERNELDIR ?= ${KERNEL_SRC}
PWD       := $(shell pwd)

raspbiecdrv:
	$(MAKE)  -C $(KERNELDIR) SUBDIRS=$(PWD) modules

endif

clean:
	rm -rf *.o *.ko *~ core .depend *.mod.c .*.cmd .tmp_versions .*.o.d raspbiec

depend .depend dep:
	$(CC) $(CFLAGS) -M *.c > .depend

ins: default rem
	insmod $(TARGET).ko debug=1

rem:
	@if [ -n "`lsmod | grep -s $(TARGET)`" ]; then rmmod $(TARGET); echo "rmmod $(TARGET)"; fi

ifeq (.depend,$(wildcard .depend))
include .depend
endif
