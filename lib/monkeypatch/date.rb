# -*- coding: utf-8 -*-

class Date
  def to_print(tbd = false)
    if (4..20).include? self.day or (24..30).include? self.day
      suffix = 'th'
    else
      suffix = ['st', 'nd', 'rd'][self.day % 10 - 1]
    end
    return "#{self.strftime '%B'} TBD, #{self.year}" if tbd
    "#{self.strftime '%B'} #{self.day}#{suffix}, #{self.year}"
  end
end
