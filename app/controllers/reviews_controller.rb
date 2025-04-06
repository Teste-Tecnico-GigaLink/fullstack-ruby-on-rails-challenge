class ReviewsController < ApplicationController
  def create
    @dynamic = Dynamic.find(params[:dynamic_id])
    @review = @dynamic.reviews.build(review_params)
    if @review.save
      redirect_to @dynamic, notice: 'Review adicionado com sucesso.'
    else
      render 'dynamics/show'
    end
  end

  private

  def review_params
    params.require(:review).permit(:comment, :rating)
  end
end