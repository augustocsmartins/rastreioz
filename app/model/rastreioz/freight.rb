module Rastreioz
  class Freight < ActiveRecord::Base
    
    scope :range_between, lambda {|zipcode| where("? BETWEEN zipcode_start AND zipcode_end", zipcode )}

    scope :weight_between, lambda {|weight| where("? BETWEEN (weight_start) AND (weight_end)", weight)}

    scope :freight_info, lambda {|zipcode, weight| range_between(zipcode).weight_between(weight) }

  end
end
