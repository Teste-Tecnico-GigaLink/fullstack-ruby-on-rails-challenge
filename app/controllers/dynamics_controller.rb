class DynamicsController < ApplicationController
  before_action :set_dynamic, only: [:show, :edit, :update, :destroy]

  def index
    @dynamics = Rails.cache.fetch("all_dynamics", expires_in: 5.minutes) do
      Dynamic.all.to_a
    end
  end

  def show
    @reviews = Rails.cache.fetch("dynamic_#{@dynamic.id}_reviews", expires_in: 5.minutes) do
      @dynamic.reviews.to_a
    end
  end

  def new
    @dynamic = Dynamic.new
  end

  def create
    @dynamic = Dynamic.new(dynamic_params)
    if @dynamic.save
      Rails.cache.delete("all_dynamics") # Invalida o cache
      redirect_to dynamics_path, notice: 'Dinâmica criada com sucesso.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @dynamic.update(dynamic_params)
      Rails.cache.delete("all_dynamics")
      Rails.cache.delete("dynamic_#{@dynamic.id}_reviews")
      redirect_to dynamic_path(@dynamic), notice: 'Dinâmica atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @dynamic.destroy
    Rails.cache.delete("all_dynamics")
    Rails.cache.delete("dynamic_#{@dynamic.id}_reviews")
    redirect_to dynamics_path, notice: 'Dinâmica removida com sucesso.'
  end

  def random
    @dynamic = Rails.cache.fetch("random_dynamic", expires_in: 5.minutes) do
      Dynamic.order('RANDOM()').first
    end
    if @dynamic
      redirect_to dynamic_path(@dynamic)
    else
      redirect_to dynamics_path, notice: 'Nenhuma dinâmica disponível.'
    end
  end

  private

  def set_dynamic
    @dynamic = Dynamic.find(params[:id])
  end

  def dynamic_params
    params.require(:dynamic).permit(:name, :description)
  end
end