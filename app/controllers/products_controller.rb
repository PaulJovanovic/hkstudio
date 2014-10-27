class ProductsController < ApplicationController
  def index
    @categories = Category.order(:display_index)
    @tag_ids = []
    if params[:q].present?
      @tag_ids += params[:q].values.flatten
      product_ids = Product.active.joins(:tags).where(tags: {id: @tag_ids}).group(:product_id).count.keep_if{|k, v| v >= params[:q].count}.keys
      @products = Product.includes(:tags).where(products: { id: product_ids})
    else
      @products = Product.active.includes(:tags)
    end
    @products = @products.order(:display_index).paginate(page: params[:page], per_page: 50)
  end
end
