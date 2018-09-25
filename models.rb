class Rate < ActiveRecord::Base
end

class VesBtc < ActiveRecord::Base
end

class UsdBtc < ActiveRecord::Base
end

class Currency < ActiveRecord::Base
  has_many :LobitPrices
end

class LobitPrice < ActiveRecord::Base
  belongs_to :currency
end