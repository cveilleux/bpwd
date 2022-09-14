

# Set to 1 for direct access IO register in bpwd_tst access program.
# This is suitable for DOS environment or evaluation purpose in Linux.
# Set to 0 to leave IO access to driver for noraml operation.
#
DIRECT_IO_ACCESS=0

# Set to 1 to use Lanner driver code.
# Set to 0 to use 2.6 kernel i2c-dec and i2c-i801 driver interface
#
#<<TODO>>
# Note: use LINUX_KERNEL_DRIVER arp function may not work.
# Test on 2.6.18(CentOS 5.4) block read not support
# Test on 2.6.25(FC9) block read ok but block write fail
#
LANNER_DRIVER=0

# +V.1.2.6 
# Note: use for Major number assign
# Set to 0 use Dynamic Major number assign
# Set to 247 (Lanner default) Static Major number assign
#
MAJOR_NUMBER=247


ifeq ($(DIRECT_IO_ACCESS), 1)

LANNER_DRIVER=0
LINUX_KERNEL_DRIVER=0
else

ifeq ($(LANNER_DRIVER),1)
LINUX_KERNEL_DRIVER=0
else 
LINUX_KERNEL_DRIVER=1
KERV := $(shell uname -r | cut -c1-3 | sed 's/2\.[56]/2\.6/')
endif 

endif 


ifeq ($(LANNER_DRIVER), 1) 
DIRS = driver src
else
DIRS = src
endif

all: config
	for i in $(DIRS); do $(MAKE) -C $$i $@; done

config:
	-rm -rf ./include/config.h
	-echo "//Created by Makefile, do not edit it" >> ./include/config.h
ifeq ($(DIRECT_IO_ACCESS), 1)
	-echo "#define DIRECT_IO_ACCESS" >> ./include/config.h
	-echo "#undef LANNER_DRIVER" >> ./include/config.h
	-echo "#undef LINUX_KERNEL_DRIVER" >> ./include/config.h
else
ifeq ($(LANNER_DRIVER), 1)
	-echo "#undef DIRECT_IO_ACCESS" >> ./include/config.h
	-echo "#define LANNER_DRIVER" >> ./include/config.h
	-echo "#undef LINUX_KERNEL_DRIVER" >> ./include/config.h
	-echo "#define LANNER_MAJOR_NUMBER $(MAJOR_NUMBER)" >> ./include/config.h
else
	-echo "#undef DIRECT_IO_ACCESS" >> ./include/config.h
	-echo "#undef LANNER_DRIVER" >> ./include/config.h
	-echo "#define LINUX_KERNEL_DRIVER" >> ./include/config.h
ifeq ($(KERV),2.4)
	-echo "#define LINUX_24" >> ./include/config.h
endif
endif

endif	

clean:
	for i in $(DIRS); do $(MAKE) -C $$i $@; done
	-rm -f include/config.h
	-rm -rf bin/bpwd_tst
	-rm -rf bin/bpwd_drv.ko
	-rm -rf bin/bpwd_drv.o

.PHONY: all clean config
