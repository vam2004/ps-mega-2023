class Block:
	def __init__(self, base, size, left, middle, right):
		self.base = base
		self.size = size
		self.left = left
		self.middle = middle
		self.right = right
class microFs:
	def __init__(self, source):
		self.source = source
	# path := string[] and space < 655356
	def alloc(self, path, space):
		pass
	# path := string[]
	def free(self, path):
		pass
	# path := string[]
	def open(self, path):
		pass
	# unfragment and reuse empty blocks
	def optimize(self):
		pass
"""
; the directory structure is 2–3 tree
; see https://en.wikipedia.org/wiki/2%E2%80%933_tree

block := | field_size (1 byte) | fields (1 byte) | left (4 bytes) | right (4 bytes) 
		 | content ((field_size + 8) * fields))  |

file :=  | file_size (2 bytes) | 0x03 or 0x04 (4 bytes) | 
; a 'block' is composed by:
; - the bitfield 'field_size' which have one byte
; - the bitfield 'fields' which have one byte
; - the bitfield 'left' which have four bytes
; - the bitfield 'right' whcih have four bytes


mean_field := | byte... (field_size) @ nonnull_byte (1 byte) |
leaf_field := | byte... (field_size - 4) @ refptr (4 bytes) @ 	0x00	|

; a 'mean_field' is a sequence of any bytes with length 'field_size' ended with a nonnull byte 
; a 'leaf_field' is a sequence of any bytes with length 'field_size - 4' 
; 	followed by the 'refptr', which have four bytes, and ended with a null byte

refptr := | is_file (1 bit) | address (63 bits) |

; a 'refptr' is composed by:
; - the bitfield 'is_file' which have one bit
; - the bitfield 'address' which have 63 bits


refname := | mean_field... @ leaf_field |

; a 'refname' is a sequence of 'mean_field' ended with a 'leaf_field'
 
"""

		