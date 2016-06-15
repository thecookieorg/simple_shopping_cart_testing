class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:create]
  before_action :set_line_item, only: [:show, :edit, :update, :destroy]

  # GET /line_items
  # GET /line_items.json
  def index
    @line_items = LineItem.all
  end

  # GET /line_items/1
  # GET /line_items/1.json
  def show
    begin
      @cart = Cart.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error "Attempt to access invalid cart #{params[:id]}" 
      redirect_to store_url, :notice => 'Invalid cart'
    else
      if @cart.line_items.count.zero?
        respond_to do |format|
          format.html { redirect_to(store_url,
            :notice => 'Your cart is currently empty') }
          format.xml  { head :ok }
        end
      else
        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml => @cart }
        end
      end
    end
  end

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit
  end

  # POST /line_items
  # POST /line_items.json
  def create
    product = Product.find(params[:product_id])
    #@line_item = @cart.line_items.build(product: product)
    @line_item = @cart.add_product(product.id)
    #@line_item = LineItem.new(line_item_params)

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to @line_item.cart }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { render :new }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1
  # PATCH/PUT /line_items/1.json
  def update
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to @line_item, notice: 'Line item was successfully updated.' }
        format.json { render :show, status: :ok, location: @line_item }
      else
        format.html { render :edit }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.json
  def destroy
    #@line_item.destroy
    #@line_item.remove_product(product_id)

    @line_item = LineItem.find(params[:id])
    if @line_item.quantity > 1
      @line_item.update_attributes(:quantity => @line_item.quantity - 1)
    else
      @line_item.destroy
    end

    respond_to do |format|
      format.html { redirect_to(cart_url(session[:cart_id])) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_item_params
      params.require(:line_item).permit(:product_id)
    end
end
