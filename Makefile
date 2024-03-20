mandelbrot.img: mandelbrot.asm
	nasm -f bin ./mandelbrot.asm -o ./mandelbrot.img -l ./mandelbrot.lst

.PHONY: clean
clean:
	/usr/bin/rm ./*.img ./*.lst