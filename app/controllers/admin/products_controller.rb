class Admin::ProductsController < AdminController
  before_action :navigation

  def active
    if params[:query].present?
      @products = Product.active.where("lower(name) = ?", params[:query].downcase).order(:display_index).paginate(page: params[:page], per_page: 20)
    else
      @products = Product.active.order(:display_index).paginate(page: params[:page], per_page: 20)
    end
  end

  def inactive
    @products = Product.inactive.order(:display_index).paginate(page: params[:page], per_page: 20)
  end

  def index
    @active_products_count = Product.active.count
    @inactive_products_count = Product.inactive.count
  end

  def new
    @product = Product.new
    @product.build_photo
    @categories = Category.all.includes(:tags)
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_product_path(@product)
    else
      @product.build_photo
      @categories = Category.all.includes(:tags)
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
    @categories = Category.all.includes(:tags)
  end

  def update
    @product = Product.find(params[:id])

    if @product.update_attributes(product_params)
      redirect_to admin_product_path(@product)
    else
      @categories = Category.all.includes(:tags)
      render :edit
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def destroy
    @product = Product.find(params[:id])

    @product.destroy
    redirect_to :index
  end

  def reorder
    offset = params[:page] ? (params[:page].to_i - 1) * 20 : 0
    params[:sortable].each_with_index do |id, index|
      Product.find(id).update_column(:display_index, index + offset + 1)
    end

    render json: true
  end

  private

  def product_params
    params.require(:product).permit(:active, :name, :dimensions, :production_rental_price, :short_rental_price, :display_index, photo_attributes: [:id, :attachment], tag_ids: [])
  end

  def navigation
    @admin_navigation = "products"
  end
end
