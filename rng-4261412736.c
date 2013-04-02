#include <stdio.h>

int main()
{
	unsigned char x, y, z, a;

	x=0;
	y=0;
	z=0;
	a=1;

	for(unsigned long i=0;;i++)
	{
		unsigned char t = x ^ (x << 4);
		x=y;
		y=z;
		z=a;
		a = z ^ t ^ ( z >> 1) ^ (t << 1);

		printf("%i\n", a);

	}


}
