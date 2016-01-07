class WorksessionsController < ApplicationController
  before_action :set_worksession, :set_user, only: [:show, :edit, :update, :destroy, :sign_up, :cancel]
  before_filter :authorize_admin, only: [:create, :edit, :delete]

  # GET /worksessions
  # GET /worksessions.json
  def index
    @worksessions = Worksession.all
  end

  # GET /worksessions/1
  # GET /worksessions/1.json
  def show
  end

  # GET /worksessions/new
  def new
    @worksession = Worksession.new
  end

  # GET /worksessions/1/edit
  def edit
  end

  # Usually by a team user
  def sign_up
    if @worksession.free == false
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Worksession is unavailable. Please choose another. '
          render :signup
        }
      end
    else 
      @worksession.free = false
      @worksession.save
      @user.worksessions << @worksession
      @user.save
    end
    redirect_to user_worksessions_path(params[:user_id])
  end

  # Usually by a team user
  def cancel
    if @worksession.free == true or not current_user.worksessions.include?(@worksession)
    respond_to do |format|
      format.html { 
        redirect_to user_worksessions_path(params[:user_id]), notice: 'You cannot cancel a worksession you are not signed up for.'
      }
      format.json { render :show, status: :created, location: @worksession }
      end
    else 
      @worksession.free = false
      @worksession.user = nil
      @worksession.save
      @user.worksessions.delete(@worksession)
      @user.save
      redirect_to user_worksessions_path(params[:user_id])
    end
  end

  # POST /worksessions
  # POST /worksessions.json
  # Should be used by admin user only
  def create
    @worksession = Worksession.create(worksession_params)
    @worksession.free = true
    @worksession.created_by = current_user.id
    respond_to do |format|
      if @worksession.save
        format.html { redirect_to user_worksessions_path(current_user.id), notice: 'Worksession was successfully created.' }
        format.json { render :show, status: :created, location: @worksession }
      else
        format.html { render :new }
        format.json { render json: @worksession.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /worksessions/1
  # PATCH/PUT /worksessions/1.json
  def update
    respond_to do |format|
      if @worksession.update(worksession_params)
        format.html { redirect_to worksessions_path(current_user.id), notice: 'Worksession was successfully updated.' }
        format.json { render :show, status: :ok, location: @worksession }
      else
        format.html { render :edit }
        format.json { render json: @worksession.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /worksessions/1
  # DELETE /worksessions/1.json
  def destroy
    @worksession.destroy
    respond_to do |format|
      format.html { redirect_to user_worksessions_path(current_user.id), notice: 'Worksession was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_worksession
      @worksession = Worksession.find(params[:id])
    end

    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worksession_params
      params.require(:worksession).permit(:date, :notes, :begin_at, :end_at, :user_id)
    end
end
