#include "verilated_vcd_c.h"
#include "Vverilator.h"

#define CYCLE() do { top->clk = 0; top->eval(); if (tfp) tfp->dump(sim_time++); top->clk = 1; top->eval(); if (tfp) tfp->dump(sim_time++); } while (0)

int main()
{
	VerilatedVcdC *tfp = NULL;
	Vverilator *top = new Vverilator;
	int sim_time = 0;
	int num_frames = 1;

#if 1
	tfp = new VerilatedVcdC;
	Verilated::traceEverOn(true);
	top->trace(tfp, 99);
	tfp->open("testbench.vcd");
#endif

	top->resetn = 0;
	top->out_axis_tready = 0;

	for (int i = 0; i < 10; i++)
		CYCLE();

	top->resetn = 1;
	CYCLE();

	top->out_axis_tready = 1;
	for (int k = 1; k != 0; k++) {
		if (top->out_axis_tvalid)
			printf("## %c%c%c%c %d %d %d\n",
					top->out_axis_tuser & 8 ? '1' : '0',
					top->out_axis_tuser & 4 ? '1' : '0',
					top->out_axis_tuser & 2 ? '1' : '0',
					top->out_axis_tuser & 1 ? '1' : '0',
					top->out_axis_tdata & 0x3f,
					(top->out_axis_tdata >> 6) & 0x3f,
					(top->out_axis_tdata >> 12) & 0x3f);
		if ((top->out_axis_tuser & 1) && !num_frames--)
			k = -100;
		CYCLE();
	}

	if (tfp)
		tfp->close();
	return 0;
}
