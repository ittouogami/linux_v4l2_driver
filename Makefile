HOST_ARCH          ?= $(shell uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)
ARCH               ?= arm64
KERNEL_SRC_DIR     ?= ../headers/linux-headers-5.4.0-xlnx-v2020.1-zynqmp-fpga
XLNX_SDK_DIR       ?= ../../../ws/vitis_work/imx219_2020_2/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0
XLNX_HDR_DIR       ?= $(XLNX_SDK_DIR)/include
XLNX_VDMA_DIR      ?= $(XLNX_SDK_DIR)/libsrc/axivdma_v6_8/src
XLNX_DEMOSAIC_DIR  ?= $(XLNX_SDK_DIR)/libsrc/v_demosaic_v1_2/src
XLNX_MIPI_DIR      ?= $(XLNX_SDK_DIR)/libsrc/csi_v1_5/src

ifeq ($(ARCH), arm)
 ifneq ($(HOST_ARCH), arm)
   CROSS_COMPILE  ?= arm-linux-gnueabihf-
 endif
endif
ifeq ($(ARCH), arm64)
 ifneq ($(HOST_ARCH), arm64)
   CROSS_COMPILE  ?= aarch64-linux-gnu-
 endif
endif

CFILES = main.c ioctl.c vdma.c demosaic.c mipicsi.c dummy/dummy.c $(XLNX_VDMA_DIR)/xaxivdma.c $(XLNX_VDMA_DIR)/xaxivdma_channel.c $(XLNX_VDMA_DIR)/xaxivdma_sinit.c $(XLNX_VDMA_DIR)/xaxivdma_g.c $(XLNX_VDMA_DIR)/xaxivdma_intr.c $(XLNX_DEMOSAIC_DIR)/xv_demosaic.c $(XLNX_DEMOSAIC_DIR)/xv_demosaic_sinit.c $(XLNX_DEMOSAIC_DIR)/xv_demosaic_g.c $(XLNX_MIPI_DIR)/xcsi.c $(XLNX_MIPI_DIR)/xcsi_sinit.c $(XLNX_MIPI_DIR)/xcsi_intr.c $(XLNX_MIPI_DIR)/xcsi_g.c

obj-m += v4l2.o
v4l2-objs := $(CFILES:.c=.o)
ccflags-y += -I$(PWD)/dummy -I../$(XLNX_VDMA_DIR) -I../$(XLNX_DEMOSAIC_DIR) -I../$(XLNX_MIPI_DIR) -I../$(XLNX_HDR_DIR)

all: modify_demosaic
	make -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) modules

modify_demosaic:
	@./modify_demosaic.sh $(XLNX_DEMOSAIC_DIR)

clean:
	make -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) clean
	rm $(XLNX_VDMA_DIR)/*.o
	rm $(XLNX_DEMOSAIC_DIR)/*.o
	rm $(XLNX_MIPI_DIR)/*.o
