#include <linux/kernel.h>
#include <asm/io.h>
#include "xparameters.h"
#ifdef __linux__
#undef __linux__
#endif
#include "xv_demosaic.h"
#include "zynq_v4l2.h"

#define DEMOSAIC_BASEADDR(num)  XPAR_V_DEMOSAIC_ ## num ## _S_AXI_CTRL_BASEADDR
#define DEMOSAIC_HIGHADDR(num)  XPAR_V_DEMOSAIC_ ## num ## _S_AXI_CTRL_HIGHADDR
#define DEMOSAIC_DEVICE_ID(num) XPAR_V_DEMOSAIC_ ## num ## _DEVICE_ID
extern int vdma_h_res, vdma_v_res;

int zynq_v4l2_demosaic_init(void)
{
	int minor;
	XV_demosaic ins;
	void __iomem *mem;
	XStatus Status;
	uint32_t baseaddr[MINOR_NUM] = {DEMOSAIC_BASEADDR(0)};
	uint32_t highaddr[MINOR_NUM] = {DEMOSAIC_HIGHADDR(0)};
	uint32_t device_id[MINOR_NUM] = {DEMOSAIC_DEVICE_ID(0)};

	printk(KERN_INFO "%s\n", __FUNCTION__);

	for (minor = 0; minor < MINOR_NUM; minor++) {
		mem = ioremap_nocache(baseaddr[minor], highaddr[minor] - baseaddr[minor]);
		if (!mem) {
			printk(KERN_ERR "ioremap_nocache failed %d\n", minor);
			return -ENOMEM;
		}

		Status = XV_demosaic_Initialize(&ins, device_id[minor]);
		if (Status != XST_SUCCESS) {
			printk(KERN_ERR "XDemosaic_root_Initialize failed %d\n", minor);
			iounmap(mem);
			return -ENODEV;
		}

		ins.Config.BaseAddress = (UINTPTR)mem;
		XV_demosaic_Set_HwReg_width(&ins,vdma_h_res);
		XV_demosaic_Set_HwReg_height(&ins,vdma_v_res);
		XV_demosaic_Set_HwReg_bayer_phase(&ins,0x0002);
		XV_demosaic_EnableAutoRestart(&ins);
		XV_demosaic_Start(&ins);
		 iounmap(mem);
	}

	return 0;
}
