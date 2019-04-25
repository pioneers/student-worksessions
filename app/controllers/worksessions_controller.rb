require 'net/http'

class WorksessionsController < ApplicationController
  before_action :authenticate_user!, except: [:view, :tomorrow_status, :get_staff_tomorrow]
  before_action :set_worksession, :set_user, only: [:show, :edit, :update, :destroy, :sign_up, :cancel]
  before_action :set_today
  respond_to :json

  # GET /worksessions
  # GET /worksessions.json
  def index
    set_worksessions
    if params[:user_id].nil?
      @user = nil
    else
      @user = User.find(params[:user_id])
    end

  end

  def tomorrow_status
    set_worksessions
    @users = User.all
  end

  def homepage
    set_worksessions
    @users = User.all
    if not current_user.admin?
      redirect_to available_path(current_user)
    end
  end


  # GET /worksessions/1
  # GET /worksessions/1.json
  def show
    @user = User.find(params[:id])
  end

  def view
    if (params.has_key?(:id))
    #   @team_user = User.find_by team_name: params[:team_name]
    # else
      @user = User.find(params[:id])

    end
    # @team_user = User.find_by team_name: params[:team_name]
    logger.debug "user: #{@user.inspect}"
    @users = User.all
    # @team_user = User.find(params[:team_name])
    # if (params.has_key?(:team_name))
    #   @team_user = User.find_by team_name: params[:team_name]
    # else
    #   @team_user = nil
    #   @users = Array(User.find_by team_name: params[:team_name])
    # end
    # end
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
    @worksession = parse_worksessions
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

  def create_worksessions
    #for the next 2 weeks from today:
      #if monday, tuesday, thrusday, friday, create worksessions from 4-8pm
      #if weekend, create worksessions from 10am-6pm
    @tomorrow = @today + 1.days
    two_weeks = []
    for i in 0..13
      two_weeks << @tomorrow + i.days
    end
    #create a button for admin to create the next 2 weeks of worksessions
    #but dont want to recreate worksessions every time, only if they dont exist
    two_weeks.each do |date|
      if [1,2,4,5].include?(date.wday)
        start_time = date.change({ hour: 16 })
        end_time = date.change({ hour: 20 })
        divide_worksession(start_time, end_time)
        #create worksession from 4pm to 8pm
      elsif [6,0].include?(date.wday)
        start_time = date.change({ hour: 10 })
        end_time = date.change({ hour: 18 })
        divide_worksession(start_time, end_time)
        #create worksession from 10am to 6pm
      end
    end
    redirect_to authenticated_root_path

  end

  def add_team
    user = User.find(params[:user_id])
    worksession = Worksession.find(params[:worksession_id])
    worksession.users << user
    if (worksession.date.wday.between?(1, 6) and worksession.users.size < 8) or (worksession.users.size < 4)
        worksession.free = true
        worksession.save
    end
    redirect_to authenticated_root_path
  end

  def remove_team(user, worksession)
    user.worksessions.delete(worksession)
    if (@worksession.date.wday.between?(0, 1) and @worksession.users.size < 8) or (@worksession.date.wday.between?(5, 6) and @worksession.users.size < 4)
        @worksession.free = true
        @worksession.save
    end
    redirect_to authenticated_root_path
  end

  def available
    set_worksessions
  end

  # Usually by a team user
  def sign_up
    if @worksession.free == false
      respond_to do |format|
        format.html {
          flash[:notice] = 'Worksession is unavailable. Please choose another'
          redirect_to available_path
        }
      end
    else
      if !params[:notes].nil?
        @worksession.notes = params[:notes]
      end
      booking = Booking.create(user_id: @user.id, worksession_id: @worksession.id, notes: params[:notes])

      if Rails.env.production?
        url = URI.parse('http://worksessions-notifier.pierobotics.org/api/v0/signup/')
      else
        url = URI.parse('https://www.ocf.berkeley.edu/~tranjulie/wsflask/api/v0/signup/')
      end
      Net::HTTP.post_form(url, {
        'notes' => booking.notes,
        'date' => @worksession.date.strftime("%m/%d/%Y"),
        'start_time' => @worksession.begin_at.strftime("%I:%M %P"),
        'end_time' => @worksession.end_at.strftime("%I:%M %P"),
        'school' => @user.team_name,
      })

      # @worksession.users << @user
      if (@worksession.date.wday.between?(0, 1) and @worksession.users.size >= 8) or (@worksession.date.wday.between?(5, 6) and @worksession.users.size >= 4)
        @worksession.free = false
        @worksession.save
      end
      redirect_to available_path
    end

  end

  # Usually by a team user
  def cancel
    if !current_user.worksessions.include?(@worksession)
    respond_to do |format|
      format.html {
        redirect_to user_worksessions_path(params[:user_id]), notice: 'You cannot cancel a worksession you are not signed up for.'
      }
      format.json { render :show, status: :created, location: @worksession }
      end
    else
      @user.worksessions.delete(@worksession)
      @worksession.users.delete(@user)
      @user.save
      if (@worksession.date.wday.between?(0, 1) and @worksession.users.size < 8) or (@worksession.date.wday.between?(5, 6) and @worksession.users.size < 4)
        @worksession.free = true
        @worksession.save
      end
      redirect_to available_path(current_user)
      @worksession.save
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
    set_worksessions
    @available = []
    @worksessions.each do |worksession|
        @available << {:id => worksession.id, :title => "boop", :start => "#{worksession.begin_at.iso8601}",:end => "#{worksession.end_at.iso8601}" }
    end
    respond_to do |format|
      format.json { render :json => @events }
    end
  end

  def get_staff_tomorrow
    @available_tomorrow = Worksession.where(begin_at >= Date.tomorrow.midnight, begin_at <= Date.tomorrow.tomorrow.midnight)
    #send to flask website
    #how to send HTTP req to student_worksessions_notifier -- forms in RoR
  end

  private

    # We set the scope of worksession we interact with to only those that happened this year
    # to increase the speed of lookups.
    def set_worksessions
      @worksessions = Worksession.where("begin_at >= :start_date", {:start_date => (Time.now.beginning_of_year)})
    end

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
      Worksession.all.each do |worksession|
          if worksession.begin_at < @today +1.days
            worksession.free = false
            worksession.past = true
            worksession.save
          end
        end
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

    def parse_worksessions
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
      # if !check_possible_time(begin_time, end_time)
      #   return nil
      # end
    return divide_worksession(begin_time, end_time)
    #   new_start = begin_time.beginning_of_hour()
    #   new_end = new_start.advance(:hours => 1)


    # while new_end <= end_time
    #   @worksession = Worksession.create(date: date, begin_at: new_start, end_at: new_end)
    #   @worksession.notes = params[:worksession]["notes"]
    #   @worksession.free = true
    #   @worksession.created_by = current_user.id
    #   @worksession.save
    #   new_start = new_end.in_time_zone
    #   new_end = new_start.advance(:hours => 1)

    # end
    # return @worksession
  end

    def divide_worksession(start_time = nil, end_time = nil)
      new_start = start_time.beginning_of_hour()
      new_end = new_start.advance(:hours => 1)
      while new_end <= end_time
        @worksession = Worksession.create(date: new_start, begin_at: new_start, end_at: new_end)
        @worksession.free = true
        @worksession.created_by = current_user.id
        @worksession.save
        new_start = new_end.in_time_zone
        new_end = new_start.advance(:hours => 1)
      end
      return @worksession

    end
end
