class Admin::RentalsController < AdminController
	before_action :navigation

	def index
		@pending_rentals = Rental.where(status: "pending").count
		@approved_rentals = Rental.where(status: "approved").count
		@rejected_rentals = Rental.where(status: "rejected").count
	end

	def show
		@rental = Rental.find(params[:id])
	end

	def edit
		@rental = Rental.find(params[:id])
		if !@rental.pdf
			@rental.build_pdf
		end
	end

	def update
		@rental = Rental.find(params[:id])

		if @rental.update_attributes(rental_params)
			redirect_to admin_rental_path(@rental)
		else
			render :edit
		end
	end

	def reject
		@rental = Rental.find(params[:id])
		@rental.reject!
		redirect_to admin_rental_path(@rental)
	end

	def pending
		@pending_rentals = Rental.where(status: "pending").order(created_at: :desc).paginate(page: params[:page], per_page: 20)
	end

	def approved
		@approved_rentals = Rental.where(status: "approved").order(created_at: :desc).paginate(page: params[:page], per_page: 20)
	end

	def rejected
		@rejected_rentals = Rental.where(status: "rejected").order(created_at: :desc).paginate(page: params[:page], per_page: 20)
	end

	def send_invoice
		@rental = Rental.find(params[:id])
		RentalMailer.invoice(@rental).deliver
		flash[:notice] = "Invoice sent."
		redirect_to admin_rental_path(@rental)
	end

	def send_agreement
		@rental = Rental.find(params[:id])
		pdf = Agreement.where(duration_weeks: @rental.duration_weeks).last.pdf.url
		RentalMailer.agreement(@rental, pdf).deliver
		flash[:notice] = "#{@rental.duration_type_name} agreement Sent."
		redirect_to admin_rental_path(@rental)
	end

	private

	def rental_params
		params.require(:rental).permit(:start_date, :end_date, :duration_weeks, :status, :po_number, :discount_percentage, :tax_percentage, :include_tax, items_attributes: [:id, :price, :_destroy], pdf_attributes: [:id, :attachment])
	end

	def navigation
		@admin_navigation = "rentals"
	end

end
