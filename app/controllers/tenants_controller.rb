# frozen_string_literal: true

class TenantsController < ApplicationController
  before_action :set_tenant, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /tenants
  def index
    @tenants = Tenant.all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Tenant.all }
    end
  end

  # GET /tenants/new
  def new
    @tenant = Tenant.new
  end

  # GET /tenants/1/edit
  def edit
  end

  # POST /tenants
  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      redirect_to tenants_path, notice: "Tenant was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /tenants/1
  def update
    if @tenant.update(tenant_params)
      redirect_to tenants_path, notice: "Tenant was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /tenants/1
  def destroy
    return head(:conflict) if @tenant.id == @current_user.tenant_id

    @tenant.destroy

    redirect_to tenants_url, notice: "Tenant was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenant
      @tenant = Tenant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tenant_params
      params.require(:tenant).permit(:page, :name)
    end

    def access_granted
      return head(:forbidden) unless @current_role == "admin"
    end
end
