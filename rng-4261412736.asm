;************************** VARIABLE DEFINITIONS ******************************

		cblock		0xZZZZZZZ   ; Add the following variables to your cblock declaration.
		x                       ; t is a temporary used by xorshift, so any spare temp space
		y                       ; will do here.
		z
		t
		a
		endc					; end of variable declarations
		

xorshift
	; The RNG stores state in x,y,z,a, and uses t as the one
	; byte of working memory. The random number can be taken from a.
	; t can be reused in between calls to xorshift
	;
	; The algorithm in C is:
	; 	t = x ^ (x << 4);
	;	x=y;
	;	y=z;
	;	z=a;
	;	a = z ^ t ^ ( z >> 1) ^ (t << 1);
	;
	; There are 4 loops with seeds as follows:
	;
	;    x    y    z    a  | Length
	; ---------------------+--------
	;    0    0    0    0  | 1
	;    0    0    0    1  | 4261412737
	;    0    0    0   37  | 33554431
	;    0    81 126  233  | 127
	;
	; The routine clobbers W and STATUS
	;
	; Note: do not initialize memory with all zeros!

	
	;Swizzle x to make t
	;Make W  =  x << 4, and clear the carry flag
	movf	x,w
	andlw	B'00001111'  
	movwf	t
	rlf		t,f
	rlf		t,f
	rlf		t,f
	rlf		t,w    ;W is now x << 4
	xorwf	x,w    ;W is now x ^ (x << 4) 
	movwf	t      ; t = x ^ (x << 4)
	
	;Shift along x <- y <- z <- a
	movf	y,w			
	movwf	x			 ;x = y
	movf	z,w			 
	movwf	y            ;y = z
	movf	a,w			 
	movwf	z            ;z = a
	
	;Swizzle up a. Currently W = a
	movf	t, w
	xorwf	a, f		 ;a^= t : a = z^t
	
	;W = t now	
	rlf		t,w		;W = (t << 1); t destroyed; No need to mask (1 bit shift)
	xorwf	a, f	;a ^= (t << 1)  : a = z ^ t ^ (t << 1)

	bcf		STATUS, C ;Clear the carry flag for the next shift

	movf	z,w
	movwf	t
	rrf		t,w		; W = (z >> 1)   ; No mask needed 
	xorwf	a,f		; a ^= (z >> 1)

	return
end


