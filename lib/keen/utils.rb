
module Keen

  module Utils

    def self.symbolize_keys(hash)
      hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

  end
end

