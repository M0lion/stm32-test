ENTRY(_start);

MEMORY {
	flash(rx): ORIGIN = 0x08000000, LENGTH = 0x20000
	sram(rwx): ORIGIN = 0x20000000, LENGTH = 16K
}

SECTIONS 
{
	.text :
	{
		KEEP(*(vectors))
			*(.text*)
	} > flash

	.data : 
	{
		_data_start = .;
		*(.sdata*)
		*(.data*)
		*(.rodata*)
		. = ALIGN(4);
		_data_end = .;
	} > sram AT > flash
	
	.ARM.exidx :
	{
		*(.ARM.exidx*)
		. = ALIGN(4);
  } > flash

	_data_load_start = LOADADDR(.data);

	.bss (NOLOAD) :
	{
		_bss_start = .;
		*(.bss*)
		_bss_end = .;
	} > sram
}

