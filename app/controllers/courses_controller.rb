class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list, :show_credits, :degree_course, :join_degree, :table]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  @@degree = []
  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 4)
    @course = @courses-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end

  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    flash={:suceess => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def show_credits
    @course = current_user.courses
    @credits = 0.0
    @credits_public = 0.0
    @credits_professional = 0.0
    @course.each do |course|
      @credit_str = course.credit.slice 3,3
      @credits += @credit_str.to_f
      if course.course_type == "公共选修课"
        @credit_public_str = course.credit.slice 3,3
        @credits_public += @credit_public_str.to_f
      end
    end
    @@degree.each do |course|
      @credit_professional_str = course.credit.slice 3,3
      @credits_professional += @credit_professional_str.to_f
    end
  end

  def degree_course
    @course = current_user.courses - @@degree
    tmp = []
    @course.each do |course|
      if course.course_type != "公共选修课"
        tmp<<course
      end
    end
    @course = tmp
  end

  def join_degree
    @course = Course.find_by_id(params[:id])
    @@degree<<@course
    flash={:success => "成功设为学位课: #{@course.name}"}
    redirect_to degree_course_courses_path, flash: flash
  end

  def table
    @course = current_user.courses
    @Mon1 = current_user.courses-current_user.courses
    @Mon2 = current_user.courses-current_user.courses
    @Mon3 = current_user.courses-current_user.courses
    @Tue1 = current_user.courses-current_user.courses
    @Tue2 = current_user.courses-current_user.courses
    @Tue3 = current_user.courses-current_user.courses
    @Wed1 = current_user.courses-current_user.courses
    @Wed2 = current_user.courses-current_user.courses
    @Wed3 = current_user.courses-current_user.courses
    @Thur1 = current_user.courses-current_user.courses
    @Thur2 = current_user.courses-current_user.courses
    @Thur3 = current_user.courses-current_user.courses
    @Fri1 = current_user.courses-current_user.courses
    @Fri2 = current_user.courses-current_user.courses
    @Fri3 = current_user.courses-current_user.courses
    @Sat1 = current_user.courses-current_user.courses
    @Sat2 = current_user.courses-current_user.courses
    @Sat3 = current_user.courses-current_user.courses
    @Sun1 = current_user.courses-current_user.courses
    @Sun2 = current_user.courses-current_user.courses
    @Sun3 = current_user.courses-current_user.courses
    @course.each do |course|
      @course_str = course.course_time.slice 0,2
      @time_str = course.course_time.slice 3,1
      @time = @time_str.to_i
      if @course_str == "周一"
        if @time < 5
          @Mon1<<course
        end
        if @time > 4 and @time < 9
          @Mon2<<course
        end
        if @time > 8
          @Mon3<<course
        end
      end
      if @course_str == "周二"
        if @time < 5
          @Tue1<<course
        end
        if @time > 4 and @time < 9
          @Tue2<<course
        end
        if @time > 8
          @Tue3<<course
        end
      end
      if @course_str == "周三"
        if @time < 5
          @Wed1<<course
        end
        if @time > 4 and @time < 9
          @Wed2<<course
        end
        if @time > 8
          @Wed3<<course
        end
      end
      if @course_str == "周四"
        if @time < 5
          @Thur1<<course
        end
        if @time > 4 and @time < 9
          @Thur2<<course
        end
        if @time > 8
          @Thur3<<course
        end
      end
      if @course_str == "周五"
        if @time < 5
          @Fri1<<course
        end
        if @time > 4 and @time < 9
          @Fri2<<course
        end
        if @time > 8
          @Fri3<<course
        end
      end
      if @course_str == "周六"
        if @time < 5
          @Sat1<<course
        end
        if @time > 4 and @time < 9
          @Sat2<<course
        end
        if @time > 8
          @Sat3<<course
        end
      end
      if @course_str == "周日"
        if @time < 5
          @Sun1<<course
        end
        if @time > 4 and @time < 9
          @Sun2<<course
        end
        if @time > 8
          @Sun3<<course
        end
      end

    end
  end

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
