class WorksessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_worksession, :set_user, only: [:show, :edit, :update, :destroy, :sign_up, :cancel]
  before_action :set_today
  respond_to :json

  # GET /worksessions
  # GET /worksessions.json
  def index
    @worksessions = Worksession.all
    if params[:user_id].nil?
      @user = nil
    else
      @user = User.find(params[:user_id])
    end
    
  end

  def homepage
    @worksessions = Worksession.all
    if not current_user.admin? 
      redirect_to user_worksessions_path(current_user)
    end
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

  # POST /worksessions
  # POST /worksessions.json
  # Should be used by admin user only
  def create
    @worksession = divide_worksessions
    respond_to do |format|
      if !@worksession.nil? and @worksession.save
        format.html { redirect_to user_worksessions_path(current_user.id), notice: 'Worksession was successfully created.' }
        format.json { render :show, status: :created, location: @worksession }
      else
        @worksession = Worksession.new
        format.html { render :new }
        format.json { render json: @worksession.errors, status: :unprocessable_entity }
      end
    end
  end

  def available
     @worksessions = Worksession.all
  end

  # Usually by a team user
  def sign_up
    if @worksession.free == false
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Worksession is unavailable. Please choose another. '
          redirect_to available_path
        }
      end
    else 
      if !params[:notes].nil?
        @worksession.notes = params[:notes]
      end
      @worksession.free = false
      @worksession.save
      @user.worksessions << @worksession
      @user.save
      redirect_to available_path
    end
    
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
      @worksession.free = true
      @worksession.user = nil
      @worksession.save
      @user.worksessions.delete(@worksession)
      @user.save
      redirect_to user_worksessions_path(params[:user_id])
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

  def get_events
    @worksessions = Worksession.all
    @available = []
    @worksessions.each do |worksession|
        @available << {:id => worksession.id, :title => "boop", :start => "#{worksession.begin_at.iso8601}",:end => "#{worksession.end_at.iso8601}" }
    end
    respond_to do |format|
      format.json { render :json => @events }
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

    def set_today
      Time.zone = "Pacific Time (US & Canada)"
      @today = DateTime.now.in_time_zone
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worksession_params
      params.require(:worksession).permit(:date, :notes, :begin_at, :end_at, :user_id)
    end

    def check_possible_time(begin_time, end_time)
      if end_time <= begin_time
        flash[:error] = "End Time must be after Start Time"
        return false
      elsif begin_time < @today
        flash[:error] = "Worksession must be in the future"
        return false

      end
      return true
    end

    def divide_worksessions
      parsed_date = DateTime.strptime(params[:worksession]["date"], "%m/%d/%Y").advance(:hours => 8)
      parsed_begin = DateTime.parse(params[:worksession]["begin_at"])
      parsed_end = DateTime.parse(params[:worksession]["end_at"])

      begin_time = DateTime::civil(parsed_date.year, parsed_date.month, parsed_date.day,
      parsed_begin.hour,
      parsed_begin.minute).change(:offset => "-08:00")
      end_time = DateTime::civil(parsed_date.year, parsed_date.month, parsed_date.day,
      parsed_end.hour,
      parsed_end.minute).change(:offset => "-08:00")
      date = parsed_date
      if !check_possible_time(begin_time, end_time)
        return nil
      end
      new_start = begin_time.beginning_of_hour()
      new_end = new_start.advance(:hours => 1)
    
        
    while new_end <= end_time
      @worksession = Worksession.create(date: date, begin_at: new_start, end_at: new_end)
      @worksession.notes = params[:worksession]["notes"]
      @worksession.free = true
      @worksession.created_by = current_user.id
      @worksession.save
      new_start = new_end.in_time_zone
      new_end = new_start.advance(:hours => 1)
    
    end
    return @worksession
  end
end
