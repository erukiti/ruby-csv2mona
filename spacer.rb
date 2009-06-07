#!/usr/bin/env ruby

require 'jcode'

$KCODE = "SJIS"

def getwidth(str)
	width = 0

	str.each_char { |chr|
		if chr.length == 1
			a = $width[chr[0]]
		elsif chr.length == 2
			a = $width[(chr[0] << 8) + chr[1]]
		else
			error
		end

		width += a if a != nil
	}

	width
end

$width = {}

File.open("width.dat", "r") { |f|
	f.each { |line|
		code, w = line.split(',')
		$width[code.to_i] = w.to_i
	}
}

#p getwidth(".")
#p getwidth(" ")
#p getwidth("`")
#p getwidth(" .")
#p getwidth("Å@")
#p getwidth("ÅD")
#p getwidth("ÅL")

#exit

#for i in 0x20 .. 0xff
#	str = "1"
#	str[0] = i
#	printf "%02x ", i
#	print "#{str} #{getwidth(str)}\n"
#end
#exit

#for i in 0x81 .. 0xef
#	for j in 0x40 .. 0xfc
#		str = ".."
#		str[0] = i
#		str[1] = j
#		width = getwidth(str)
#		printf ("%02x%02x %s %d\n", i, j, str, width) if width > 0
#	end
#end
#exit


#for i in 0x40 .. 0x7e
#	str = "11"
#	str[0] = 0x81
#	str[1] = i
#	printf "81%02x ", i
#	print "#{str} #{getwidth(str)}\n"
#end
#exit

class String
	def jinsert(jnth, other)
#print "#{jnth}, '#{other}'\n"
		nth = 0
		self.each_char { |chr|
			break if jnth == 0

			nth += chr.length
			jnth -= 1
		}

		self.insert(nth, other)
#print "** '#{self}'\n"
	end
end


def spacer_padding(zenspc, padchar, hanspc)
#print padchar, "\n"
	result = 'Å@' * zenspc

	if zenspc >= 2
		result.jinsert(1, padchar)
	else
		result.jinsert(0, padchar)
	end

	while hanspc > 0
		result.jinsert(hanspc - 1, ' ')
		hanspc -= 1
	end

#p result

	result
end

def spacer(len)
	zenwidth = getwidth('Å@')
	hanwidth = getwidth(' ')

	a = 0

	while true
#		p len
		#['', '.', "'", 'Å]', 'Åe', 'ÅE', 'ÅD', 'ÅM'].each { |padchar|
		#['', '.', 'ÅD', "'", 'Å]', 'Åe', 'ÅE', 'ÅM'].each { |padchar|
		#['', '.', "'", 'ÅD', 'ÅM'].each { |padchar|
		['', '.', "'", 'ﬁ', 'ÅM'].each { |padchar|
			padwidth = getwidth(padchar)
			next if len < padwidth
			zenspc = (len - padwidth) / zenwidth
			begin
				n = len - padwidth - (zenspc * zenwidth)
#p n
				return spacer_padding(zenspc, padchar, 0) if n == 0
				return spacer_padding(zenspc, padchar, n / hanwidth) if ((n % hanwidth) == 0) && (n / hanwidth <= zenspc + padchar.jlength + 1)

				zenspc -= 1
			end while (zenspc > 0)
		}

		a += 1
		if (a % 2) == 0
			len -= a
		else
			len += a
		end
	end
end

#spacer(6)
#exit

for i in 1 .. 40
	spc = spacer(i)
	print "#{i} #{getwidth(spc)} '#{spc}'\n"
end

