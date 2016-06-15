class Order < ActiveRecord::Base
	has_many :line_items, dependent: :destroy

	PAYMENT_TYPES = [ "Cash", "Credit Card" ]

	validates_presence_of :name, :address, :email
	validates :pay_type, inclusion: PAYMENT_TYPES

	def add_line_items_from_cart(cart)
		cart.line_items.each do |item|
			item.cart_id = nil
			line_items << item
		end
	end
end
