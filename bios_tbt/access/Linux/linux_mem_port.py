__author__ = 'bmason'

import ctypes, sys, binascii

import os
curFileDir = os.path.normpath(os.path.split(os.path.abspath(__file__))[0])
port_library = ctypes.CDLL(os.sep.join([curFileDir, "libport.lso"]))
mem_library = ctypes.CDLL(os.sep.join([curFileDir, "libmem.lso"]))

_read_port = port_library.read_port
_read_port.argtypes = (ctypes.c_uint16, ctypes.c_uint8)
_read_port.restype = (ctypes.POINTER(ctypes.c_uint8))

_write_port = port_library.write_port
_write_port.argtypes = (ctypes.c_uint16, ctypes.c_uint8, ctypes.c_uint32)

_read_mem = mem_library.mem_read
_read_mem.argtypes = (ctypes.c_ulong, ctypes.c_void_p, ctypes.c_size_t)
_read_mem.restype = (ctypes.c_int)

_write_mem = mem_library.mem_write
_write_mem.argtypes = (ctypes.c_ulong, ctypes.c_void_p, ctypes.c_size_t)
_write_mem.restype = (ctypes.c_int)

def io(port, size, val = None):
	global _write_port, _read_port
	if(val is None):
		ret = _read_port(port, size)
		read_val = 0
		for i in xrange(0, size):
			read_val += ret[i] << 8 * (i)
		return int(read_val)
	else:
		ret = _write_port(port, size, val)
		return ret

def mem(address, size, val = None):
	global _write_mem, _read_mem
	if(val is None):
		dest = (ctypes.c_ubyte * size)()
		ret = _read_mem(address, ctypes.cast(dest, ctypes.c_void_p), size)
		read_val = 0
		a = ctypes.cast(dest,ctypes.c_char_p)
		for i in xrange(0, size):
			read_val += dest[i] << 8 * (i)
		return int(read_val)
	else:
		data = ctypes.c_ulonglong(val)
		ret = _write_mem(address, ctypes.byref(data), size)
		return ret

def memBlock(address, size, val = None):
	global _write_mem, _read_mem
	if(val is None):
		dest = (ctypes.c_ubyte * size)()
		ret = _read_mem(address, ctypes.cast(dest, ctypes.c_void_p), size)
		read_val = 0
		a = ctypes.cast(dest,ctypes.c_char_p)
		for i in xrange(0, size):
			read_val += dest[i] << 8 * (i)
		return binascii.unhexlify(hex(read_val)[2:].strip('L').zfill(size*2))[::-1]
	else:
		data = (ctypes.c_char_p)(val)
		ret = _write_mem(address, data, size)
		return ret
