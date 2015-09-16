class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @categories = Category.all_categories
    @category = Category.find(params[:id])
    @loan_requests = @category.loan_requests.paginate(:page => params[:page], :per_page => 21, total_entries: @category.loan_requests_categories.length)
  end
end
