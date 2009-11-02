module Inquisition
  class Convertor
    def self.parse(s)
      case s
      when /(.*?)(KB|K)$/i
        Float($1) * 1024**1
      when /(.*?)(MB|M)$/i
        Float($1) * 1024**2
      when /(.*?)(GB|G)$/i
        Float($1) * 1024**3
      when /(.*?)(TB|T)$/i
        Float($1) * 1024**4
      when /(.*?)%$/i
        Float($1)
      else
        Float(s)
      end
    end
  end
end
