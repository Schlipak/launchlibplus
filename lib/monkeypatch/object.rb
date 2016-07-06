# -*- coding: utf-8 -*-

class Object
  def address
    addr = (self.object_id * 2).to_s 16
    "0x#{addr.rjust(14, '0')}"
  end

  def debug
    "#<#{self.class}:#{self.address}>#{' ' + self.to_s unless self.to_s.empty?}"
  end
end

module AppObject
  def method_missing(method, *args)
    err = "Undefined method #{self.class}##{method}(#{args.join(', ')})"
    LLibPlus::JobQueue.push do
      LLibPlus::ErrorDialog.new(err, :fatal).run!
    end
  end
end
