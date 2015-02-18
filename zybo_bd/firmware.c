#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sleep.h>
#include "xil_cache.h"
#include "platform.h"

#define VCTRL(_off) (*(volatile uint32_t*)(0x43000000 + _off))

const char *lorem_ipsum = "Lorem ipsum dolor sit amet, consectetur adipisicing elit,\n"
		"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"
		"Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi\n"
		"ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit\n"
		"in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur\n"
		"sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\n"
		"mollit anim id est laborum.\n\n";

unsigned char framebuffer[4096 * 4096 * 3] __attribute__ ((aligned(4096)));
unsigned char firebuffer[2048][2048];
unsigned char colorpalette[256][4];

int screen_height = 720;
int screen_width = 1280;

uint32_t xorshift32()
{
  static uint32_t x = 314159265;
  x ^= x << 13;
  x ^= x >> 17;
  x ^= x << 5;
  return x;
}

void init_colorpalette()
{
	int i, v = 0;

	for (i = 0; i < 16; i++, v++) {
		colorpalette[v][0] = i;
		colorpalette[v][1] = 0;
		colorpalette[v][2] = 0;
	}

	for (i = 4; i < 64; i++, v++) {
		colorpalette[v][0] = 4*i;
		colorpalette[v][1] = 0;
		colorpalette[v][2] = 0;
	}

	for (i = 0; i < 64; i++, v++) {
		colorpalette[v][0] = 255;
		colorpalette[v][1] = 4*i;
		colorpalette[v][2] = 0;
	}

	for (i = 0; i < 64; i++, v++) {
		colorpalette[v][0] = 255;
		colorpalette[v][1] = 255;
		colorpalette[v][2] = 4*i;
	}

	for (i = 0; v < 256; i++, v++) {
		colorpalette[v][0] = 255-3*i;
		colorpalette[v][1] = 255-2*i;
		colorpalette[v][2] = 255-2*i;
	}
}

void update_framebuffer()
{
	unsigned char *pi = (void*)firebuffer;
	unsigned char *po = (void*)framebuffer;

	int i, j;
	for (i = 0; i < screen_height/2; i++)
	{
		for (j = 0; j < screen_width/2; j++)
		{
			int v, v1 = pi[0], v2 = pi[1], v3 = pi[2048], v4 = pi[2048 + 1];

			v = v1;
			po[0] = colorpalette[v][0];
			po[1] = colorpalette[v][1];
			po[2] = colorpalette[v][2];

			v = (v1 + v2) / 2;
			po[3] = colorpalette[v][0];
			po[4] = colorpalette[v][1];
			po[5] = colorpalette[v][2];

			v = (v1 + v3) / 2;
			po[3*screen_width + 0] = colorpalette[v][0];
			po[3*screen_width + 1] = colorpalette[v][1];
			po[3*screen_width + 2] = colorpalette[v][2];

			v = (v1 + v2 + v3 + v4) / 4;
			po[3*screen_width + 3] = colorpalette[v][0];
			po[3*screen_width + 4] = colorpalette[v][1];
			po[3*screen_width + 5] = colorpalette[v][2];

			po += 6;
			pi += 1;
		}

		pi += 2048 - screen_width/2;
		po += 3*screen_width;
	}

	Xil_DCacheFlush();
}

void update_firebuffer(int p, int q)
{
	int i, j;

	for (i = 0; i < screen_height/2+5; i++)
	for (j = 0; j < screen_width/2; j++)
	{
		int v = firebuffer[i][j];

		if (i+q < screen_height/2+5)
		{
			int k = j + p;
			if (k > screen_width/2) k -= screen_width/2;
			v += firebuffer[i+q][k];

			k = j - p;
			if (k < 0) k += screen_width/2;
			v += firebuffer[i+q][k];

			v += firebuffer[i+q][j];
			v = v / 4;
		}
		else
			v = v > 30 ? v-1 : 30;

		if (v > 16 && xorshift32() % 32 == 0)
			v -= 16;

		firebuffer[i][j] = v;
	}

	p = xorshift32() % (screen_width/2);
	if (xorshift32() % 8)
	{
		for (i = 0; i < 10; i++)
		for (j = i; j < 30-i; j++) {
			int v = firebuffer[screen_height/2+4-i][(j+p) % (screen_width/2)] + 10*(15-abs(15-j));
			if (v > 255) v = 255;
			firebuffer[screen_height/2+4-i][(j+p) % (screen_width/2)] = v;
		}
	}
	else
	{
		for (i = 0; i < 3; i++)
		for (j = 0; j < 10; j++)
			firebuffer[screen_height/2+i][(j+p) % (screen_width/2)] = 0;
	}
}

void draw_frames(int n)
{
	while (n--) {
		update_firebuffer(1, 3);
		update_firebuffer(3, 1);
		update_firebuffer(2, 2);
		update_framebuffer();
	}
}

void print_term(char ch)
{
	VCTRL(0x0C) = ch;
}

void print_term_str(const char *p)
{
	while (*p) VCTRL(0x0C) = *(p++);
}

int main()
{
	int i, j, k;

	init_platform();
	init_colorpalette();

	// teletype /dev/ttyUSB1 115200
	// printf("Running test...\n");

	screen_height = (VCTRL(0x08) >> 16) & 0xffff;
	screen_width  = (VCTRL(0x08) >>  0) & 0xffff;

	usleep(100000);
	update_framebuffer();
	VCTRL(0x00) = (uint32_t)framebuffer;

	print_term_str("Hello World!\n");
	print_term_str("This is a test for SimpleVO.\n");
	print_term_str("Have a nice day..");

	draw_frames(100);

	print_term_str("\n\n");
	print_term_str("VDMA blanking test in");

	for (i = 5; i >= 0; i--) {
		print_term(' ');
		print_term('0' + i);
		draw_frames(10);
	}
	VCTRL(0x00) = 0;

	for (i = 5; i >= 0; i--) {
		print_term('.');
		draw_frames(10);
	}

	print_term_str("\nFinished blanking test.\n\n");
	VCTRL(0x00) = (uint32_t)framebuffer;

	for (j = 0; j < 3; j++)
	{
		for (k = 0; k < 3; k++)
			for (i = 0; lorem_ipsum[i]; i++) {
				print_term(lorem_ipsum[i]);
				draw_frames(1);
			}

		for (k = 0; k < 10; k++)
			for (i = 0; i < 12; i++) {
				print_term("LOREM IPSUM "[i]);
				print_term('\n');
				draw_frames(1);
			}

		for (k = 0; k < 5; k++)
			for (i = 0; lorem_ipsum[i]; i++) {
				print_term(lorem_ipsum[i]);
				draw_frames(1);
			}

		for (i = 0; lorem_ipsum[i]; i++) {
			print_term(lorem_ipsum[i] == '\n' ? ' ' : lorem_ipsum[i]);
			draw_frames(1);
		}
		print_term_str("\n\n");
	}

	char buffer[128];
	snprintf(buffer, 128, "\004SimpleVO Demo (%dx%d)", screen_width, screen_height);
	print_term_str(buffer);
	draw_frames(-1);

	return 0;
}
