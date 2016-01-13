class Cart < ActiveRecord::Base
  #owned by user
  #has many products
  #has many businesses?
  

  belongs_to :user
  has_many :products
  
  def total
    count = self.user.products_count
    total = 0
    self.products.each_with_index do |product, idx|
      total += Product.price(count + idx) 
    end

    total
  end
end
