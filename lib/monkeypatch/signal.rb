# -*- coding: utf-8 -*-

module Signal
  def self.trapEach(*sigs)
    sigs.each do |sig|
      Signal.trap(sig) do |signum|
        yield signum
      end
    end
  end
end
