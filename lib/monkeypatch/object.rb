# -*- coding: utf-8 -*-

class Object
  def address
    addr = (self.object_id * 2).to_s 16
    "0x#{addr.rjust(14, '0')}"
  end

  def debug
    "#<#{self.class}:#{self.address} \"#{self.to_s}\">"
  end
end
