###############################################################################
# edid.py - EDID parsing routines
#
# code taken from xac-0.6_pre4
# copyright was not clearly indicated, put probably:
#   Copyright 1999-2006 Gentoo Foundation
#   Distributed under the terms of the GNU General Public License v2
#

### FIXME recheck endianness for these structs

from struct import pack, unpack

### EDID Header Magic
EDID_HEADER = "\0\xFF\xFF\xFF\xFF\xFF\xFF\0" 
### ASCII capital letter offset
ASC = 64
SERIAL_DT = "\0\0\0\xFF\0"
ASCII_DT = "\0\0\0\xFE\0"
RANGE_DT = "\0\0\0\xFD\0"
NAME_DT = "\0\0\0\xFC\0"

### Offsets from the edid spec
class Edid:
	def __init__(self, edid=None):
		self.edid = None
		self.valid = 1
		### Parse the passed in edid
		if edid == None:
#			print "Error: Empty EDID"
			self.valid = 0
			edid = "\0" * 128
		### Make sure it a valid edid (header matches)
		if edid[:8] != EDID_HEADER:
#			print "Error: Invalid EDID"
			self.valid = 0
			edid = "\0" * 128
		### Check the checksum 
		sum = 0
		for i in range(128):
			sum = (sum + int(unpack('B', edid[i])[0])) & 0xFF
		if sum != 0:
#			print "Checksum failed, result should be 0, instead it's:", sum
			self.valid = 0
			edid = "\0" * 128

		self.edid = edid

	### ID String
	def get_id_string(self):
		name = unpack('>H',self.edid[8:10])[0]
		### FIXME Be sure to check endianness on an x86 machine
		n = chr(((name >> 10) & 0x1F) + ASC) + chr(((name >> 5) & 0x1F) + ASC) + chr(((name >> 0) & 0x1F) + ASC)
		return n + hex(unpack('>H', self.edid[10:12])[0])[2:].upper()
	
	### Serial Number
	def get_serial_number(self):
		return unpack('>I', self.edid[12:16])[0]

	### Tupple of week, year from EDID
	def get_date(self):
		date = unpack('BB', self.edid[16:18])
		return [date[0], date[1] + 1990]

	### EDID version, revision
	def get_edid_ver(self):
		return unpack('BB', self.edid[18:20])

	### Video input definition struct
	def get_video_input_def(self):
		vid_in = {}
		v = unpack('B', self.edid[20])[0]
		vid_in['digital'] = (v >> 7) & 1
		if vid_in['digital']:
			vid_in['DFP1x'] = (v & 1)	
		else:
			vid_in['video_level'] = (v >> 5) & 3
			vid_in['blank_to_black'] = (v >> 4) & 1
			vid_in['seperate_sync'] = (v >> 3) & 1
			vid_in['composite_sync'] = (v >> 2) & 1
			vid_in['sync_on_green'] = (v >> 1) & 1
			vid_in['serration_vsync'] = (v & 1)
		return vid_in

	### Size of screen (horiz, vert)
	def get_size(self):
		return unpack('BB', self.edid[21:23])

	### Gamma
	def get_gamma(self):
		return (unpack('B', self.edid[23])[0] / 100.0) + 1.0
	
	### Feature Support
	def get_feature_support(self):
		fs = {}
		f = unpack('B', self.edid[24])[0]
		fs['standby'] = (f >> 7) & 1
		fs['suspend'] = (f >> 6) & 1
		fs['active_off'] = (f >> 5) & 1
		fs['display_type'] = (f >> 3) & 3
		fs['rgb'] = (f >> 2) & 1
		fs['prefered_timing'] = (f >> 1) & 1
		fs['gtf'] = (f & 1)
		return fs

	### Color Characteristics
	def get_color_characteristics(self):
		cc = {}
		c = unpack('10B', self.edid[25:35])
		### Check the / 1024 value... (is this right?)
		cc['red_x'] = ((c[2] << 2) + ((c[0] >> 6) & 3)) / 1024.0
		cc['red_y'] = ((c[3] << 2) + ((c[0] >> 4) & 3)) / 1024.0
		cc['green_x'] = ((c[4] << 2) + ((c[0] >> 2) & 3)) / 1024.0
		cc['green_y'] = ((c[5] << 2) + (c[0] & 3)) / 1024.0
		cc['blue_x'] = ((c[6] << 2) + ((c[1] >> 6) & 3)) / 1024.0
		cc['blue_y'] = ((c[7] << 2) + ((c[1] >> 4) & 3)) / 1024.0
		cc['white_x'] = ((c[8] << 2) + ((c[1] >> 2) & 3)) / 1024.0
		cc['white_y'] = ((c[9] << 2) + (c[1] & 3)) / 1024.0

		return cc

	### Established Timings
	def get_timings(self):
		timing = [ [720,400,70], [720,400,88], [640,480,60], [640,480, 67],
			   [640,480,72], [640,480,75], [800,600,56], [800,600, 60],
			   [800,600,72], [800,600,75], [832,624,75], [1024,768, 87],
			   [1024,768,60], [1024,768,70], [1024,768,75], [1280, 1024,75] ]
		my_timing = []

		### Established timings
		est = unpack('BB', self.edid[35:37])
		### This is what the field is set to if not used	
		if est[0] == "\x01":
			est[0] = 0
		elif est[1] == "\x01":
			est[1] = 0	

		for j in range(2):
			for i in range(8):
				if ((est[j] >> i) & 1):
					my_timing.append(timing[i])

		### Add the "standard" timings into the timing array
		std = unpack('>8H', self.edid[38:54])
		man = unpack('B', self.edid[37])[0]

		for i in range(8):
			if ((man >> i) & 1):
				horiz = ((std[i] & 0xFF00) >> 8) * 8 + 248
				aspect = std[i] & 3
				if aspect == 0:
					vert = (horiz * 16) / 10
				elif aspect == 1:
					vert = (horiz * 4) / 3
				elif aspect == 2:
					vert = (horiz * 5) / 4
				else: # aspect == 3
					vert = (horiz * 16) / 9
	
				freq = ((std[i] & 0x00FC) >> 2) + 60
				my_timing.append([horiz, vert, freq])
		return my_timing

	### Monitor Descriptor
	def get_range_dt(self, tag):
		sync = {}
		### If possible, we get the range limit from the range limit tag
		sync['v_min'] = unpack('B',tag[5])[0]
		sync['v_max'] = unpack('B',tag[6])[0]
		sync['h_min'] = unpack('B',tag[7])[0]
		sync['h_max'] = unpack('B',tag[8])[0]
		return sync

	### Detailed Timing (from monitor details)
	def get_timing_dt(self, info):
		### Search for detailed timing info
		timing = {}
		timing['pixel_clock'] = unpack(">H",info[:2])[0]

		timing['horizontal_active'] = unpack("B",info[2])[0] + ((unpack("B",info[4])[0] >> 4) << 8)
		timing['horizontal_blanking'] = unpack("B",info[3])[0] + ((unpack("B",info[4])[0] & 0xF) << 8)

		timing['vertical_active'] = unpack("B",info[5])[0] + (((unpack("B",info[7])[0] >> 4) & 0xF) << 8)
		timing['vertical_blanking'] = unpack("B",info[6])[0] + ((unpack("B",info[7])[0] & 0xF) << 8)

		timing['hsync_offset'] = unpack("B",info[8])[0] + (((unpack("B", info[11])[0] >> 6) & 3) << 8)
		timing['hsync_pulse_width'] = unpack("B",info[9])[0] + (((unpack("B", info[11])[0] >> 4) & 3) << 8)
		timing['vsync_offset'] = (unpack("B",info[10])[0] >> 4) + (((unpack("B", info[11])[0] >> 2) & 3) << 8)
		timing['vsync_pulse_width'] = (unpack("B",info[10])[0] & 0xF) + ((unpack("B", info[11])[0] & 3) << 8)
				
		timing['himage_size'] = unpack("B",info[12])[0] + ((unpack("B",info[14])[0] >> 4) << 8)
		timing['vimage_size'] = unpack("B",info[13])[0] + ((unpack("B",info[14])[0] & 0xF) << 8)
				
		timing['hborder'] = unpack("B",info[15])[0]
		timing['vborder'] = unpack("B",info[16])[0]
				
		timing['interlaced'] = (unpack("B", info[17])[0] >> 7) & 1
		timing['stereo'] = (unpack("B", info[17])[0] >> 5) & 3
		timing['digital_composite'] = (unpack("B", info[17])[0] >> 3) & 3
		timing['variant'] = (unpack("B", info[17])[0] >> 1) & 3
		return timing

	### Parse Monitor Details
	def get_monitor_details(self):
		details = []
		for i in range(4):
			dmt_offset = i * 18 + 54
			tag = self.edid[dmt_offset:dmt_offset+18] 

			if tag[:5] == SERIAL_DT:
				for i in range(13):
					if tag[i + 5] == "\x0A" or tag[i + 5] == "\x00":
						i = i - 1
						break
				size = str(i + 1) + "s"
				details.append(["Serial", unpack(size, tag[5:i + 6])[0]])
			elif tag[:5] == ASCII_DT:
				for i in range(13):
					if tag[i + 5] == "\x0A" or tag[i + 5] == "\x00":
						i = i - 1
						break
				size = str(i + 1) + "s"
				details.append(["ASCII", unpack(size, tag[5:i + 6])[0]])
			elif tag[:5] == RANGE_DT:
				details.append(["Range", self.get_range_dt(tag)])
			elif tag[:5] == NAME_DT:
				for i in range(13):
					if tag[i + 5] == "\x0A" or tag[i + 5] == "\x00":
						i = i - 1
						break
				size = str(i + 1) + "s"
				details.append(["Name", unpack(size, tag[5:i + 6])[0]])
			elif tag[:3] == "\0\0\0" and (0 < unpack('B', tag[3])[0] < 16):
				details.append(["Manufacturer", str(unpack("13B", tag[5:18]))])
			elif tag[:2] != "\0\0":
				details.append(["Detailed Timing", self.get_timing_dt(tag)])
		return details

	### Get a readable name for this monitor
	def get_string_name(self):
		s = ""
		details = self.get_monitor_details()
		for i in details:
			if i[0] == "Name" or i[0] == "ASCII":
				s = s + i[1] + " "
		if not len(s):
			s = self.get_id_string()

		return s.strip()
			

	def has_extension(self):
		return unpack("B", self.edid[126])[0]
