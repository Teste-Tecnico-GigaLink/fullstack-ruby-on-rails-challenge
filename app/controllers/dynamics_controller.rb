class DynamicsController < ApplicationController
  before_action :set_dynamic, only: [:show, :edit, :update, :destroy]

  def index
    Rails.logger.info "Fetching all dynamics from cache or database"
    @dynamics = Rails.cache.fetch("all_dynamics", expires_in: 5.minutes) do
      Rails.logger.debug "Cache miss for all_dynamics, querying database"
      dynamics = Dynamic.all.to_a
      Rails.logger.debug "Retrieved #{dynamics.count} dynamics from database"
      dynamics
    end
  end

  def show
    Rails.logger.info "Showing dynamic with ID: #{params[:id]}"
    @reviews = Rails.cache.fetch("dynamic_#{@dynamic.id}_reviews", expires_in: 5.minutes) do
      Rails.logger.debug "Cache miss for dynamic_#{@dynamic.id}_reviews, querying database"
      reviews = @dynamic.reviews.to_a
      Rails.logger.debug "Retrieved #{reviews.count} reviews for dynamic #{@dynamic.id}"
      reviews
    end
  end

  def new
    Rails.logger.info "Rendering new dynamic form"
    @dynamic = Dynamic.new
  end

  def create
    Rails.logger.info "Attempting to create a new dynamic with params: #{dynamic_params.inspect}"
    @dynamic = Dynamic.new(dynamic_params)
    if @dynamic.save
      Rails.cache.delete("all_dynamics")
      Rails.logger.info "Dynamic created successfully with ID: #{@dynamic.id}"
      redirect_to dynamics_path, notice: 'Dinâmica criada com sucesso.'
    else
      Rails.logger.warn "Failed to create dynamic: #{@dynamic.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def edit
    Rails.logger.info "Rendering edit form for dynamic with ID: #{@dynamic.id}"
  end

  def update
    Rails.logger.info "Attempting to update dynamic with ID: #{@dynamic.id} with params: #{dynamic_params.inspect}"
    if @dynamic.update(dynamic_params)
      Rails.cache.delete("all_dynamics")
      Rails.cache.delete("dynamic_#{@dynamic.id}_reviews")
      Rails.logger.info "Dynamic #{@dynamic.id} updated successfully"
      redirect_to dynamic_path(@dynamic), notice: 'Dinâmica atualizada com sucesso.'
    else
      Rails.logger.warn "Failed to update dynamic #{@dynamic.id}: #{@dynamic.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    Rails.logger.info "Attempting to delete dynamic with ID: #{@dynamic.id}"
    @dynamic.destroy
    Rails.cache.delete("all_dynamics")
    Rails.cache.delete("dynamic_#{@dynamic.id}_reviews")
    Rails.logger.info "Dynamic #{@dynamic.id} deleted successfully"
    redirect_to dynamics_path, notice: 'Dinâmica removida com sucesso.'
  end

  def random
    Rails.logger.info "Fetching a random dynamic"
    @dynamic = Rails.cache.fetch("random_dynamic", expires_in: 5.minutes) do
      Rails.logger.debug "Cache miss for random_dynamic, querying database"
      dynamic = Dynamic.order('RANDOM()').first
      Rails.logger.debug "Selected random dynamic: #{dynamic&.id || 'none'}"
      dynamic
    end
    if @dynamic
      Rails.logger.info "Redirecting to random dynamic with ID: #{@dynamic.id}"
      redirect_to dynamic_path(@dynamic)
    else
      Rails.logger.warn "No dynamics available for random selection"
      redirect_to dynamics_path, notice: 'Nenhuma dinâmica disponível.'
    end
  end

  private

  def set_dynamic
    @dynamic = Dynamic.find(params[:id])
    Rails.logger.debug "Set dynamic with ID: #{@dynamic.id}"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Dynamic with ID: #{params[:id]} not found"
    redirect_to dynamics_path, alert: 'Dinâmica não encontrada.'
  end

  def dynamic_params
    params.require(:dynamic).permit(:name, :description)
  end
end