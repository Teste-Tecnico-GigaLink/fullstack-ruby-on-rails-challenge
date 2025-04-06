class DynamicsController < ApplicationController
  before_action :set_dynamic, only: [:show, :edit, :update, :destroy]

  def index
    @dynamics = Dynamic.all
  end

  def show
    @reviews = @dynamic.reviews 
  end

  def new
    @dynamic = Dynamic.new
  end

  def create
    @dynamic = Dynamic.new(dynamic_params)
    if @dynamic.save
      redirect_to dynamics_path, notice: 'Dinâmica criada com sucesso.'
    else
      render :new
    end
  end

  def update
    if @dynamic.update(dynamic_params)
      redirect_to dynamic_path(@dynamic), notice: 'Dinâmica atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @dynamic.destroy
    redirect_to dynamics_path, notice: 'Dinâmica removida com sucesso.'
  end

  def random
    @dynamic = Dynamic.order('RANDOM()').first
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