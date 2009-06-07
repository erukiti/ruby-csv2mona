#!/usr/bin/env ruby

$KCODE = "SJIS"

require 'csv'
require 'jcode'

def getwidth(str)
	len = 0
	str.each_char { |chr|
		if chr.length == 1
			len += $width[chr[0]]
		elsif chr.length == 2
			len += $width[(chr[0] << 8) + chr[1]]
		else
			error
		end
	}

	len
end

class String
	def jinsert(jnth, other)
		nth = 0
		self.each_char { |chr|
			break if jnth == 0

			nth += chr.length
			jnth -= 1
		}

		self.insert(nth, other)
	end
end


def spacer_padding(zenspc, padchar, hanspc)
	result = 'Å@' * zenspc

	if zenspc >= 2
		result.jinsert(1, padchar)
	else
		result.jinsert(0, padchar)
	end

	loc = zenspc + padchar.jlength
	while hanspc > 0
		result.jinsert(loc, ' ')
		loc -= 1
		hanspc -= 1
	end

	result
end


def spacer(len, topflag)
	zenwidth = getwidth('Å@')
	hanwidth = getwidth(' ')

	a = 0

	while true
		#['', '.', "'", 'ÅM'].each { |padchar|
		['', '.', "'", 'ﬁ', 'ÅM'].each { |padchar|
		#['', ].each { |padchar|
		#['', '.'].each { |padchar|
			padwidth = getwidth(padchar)
			next if len < padwidth
#p padchar, padwidth
			zenspc = (len - padwidth) / zenwidth
			begin
				n = len - padwidth - (zenspc * zenwidth)
#p n
				return spacer_padding(zenspc, padchar, 0) if n == 0
				return spacer_padding(zenspc, padchar, n / hanwidth) if ((n % hanwidth) == 0) && (n / hanwidth <= zenspc + padchar.jlength + (topflag ? 0 : 1))

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


$width = {}

File.open("width.dat", "r") { |f|
	f.each { |line|
		code, w = line.split(',')
		$width[code.to_i] = w.to_i
	}
}

ARGV.each { |csvfile|

	widthmax = []
	csvmatrix = []

	CSV.open(csvfile, 'r') { |row|
		csvrow = []
		columncount = 0
		row.each { |column|
			column ||= ''
			column.strip!
			csvrow << column
			widthmax[columncount] ||= 0
			#widthmax[columncount] = 0 if widthmax[columncount] == nil
#			print "<#{column}> #{getwidth(column)}\n"
			w = getwidth(column)
			widthmax[columncount] = w if w > widthmax[columncount]
			columncount += 1
		}

		csvmatrix << csvrow
	}

	csvmatrix.each { |row|
		columncount = 0
		isspace = false

wa=0
		w = 0
		row.each { |column|
			wmax = widthmax[columncount] + 21
			#wmax = widthmax.max + 1

			if column.length > 0
				w += getwidth(column)
wa += getwidth(column)
				spc = spacer(wmax - w, columncount == 0)

				print spc
				w += getwidth(spc)
wa += getwidth(spc)
			end
			w -= wmax

			print column
			columncount += 1
#print "#{wa} (#{getwidth(column)})  "
		}

		print "\r\n"
	}

	print "\r\n"
}

